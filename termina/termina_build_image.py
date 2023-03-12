#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# Copyright 2018 The Chromium OS Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

"""Converts a Chromium OS GPT disk image into a single rootfs/kernel"""

import argparse
import os
import shutil
import struct
import subprocess
import sys
import tempfile

from pathlib import Path
from termina_util import extract_vmlinux, mount_disk

def extract_squashfs_partition(dest_path, disk_path, part_num):
  base_cmd = ['sudo', 'partx', '--raw', '--noheadings', '--nr', str(part_num)]
  part_start_sectors = subprocess.check_output(base_cmd + ['--output', 'START', disk_path])
  part_start_bytes = int(part_start_sectors) * 512
  part_size_sectors = subprocess.check_output(base_cmd + ['--output', 'SECTORS', disk_path])
  part_size_bytes = int(part_size_sectors) * 512

  with open(disk_path, 'rb') as disk:
    disk.seek(part_start_bytes)
    magic, = struct.unpack('<I', disk.read(4))
    if magic != 0x73717368:
      print('this does not look like a squashfs partition')
      sys.exit(1)

    with open(dest_path, 'wb') as output:
      disk.seek(part_start_bytes)
      count = part_size_bytes
      while count > 0:
        buf = disk.read(4096)
        if len(buf) == 0:
          print('no more disk to read')
          sys.exit(1)
        else:
          to_write = count
          if to_write > 4096:
            to_write = 4096
          count -= output.write(buf[:to_write])

def can_hardlink(src_path, target_path):
  src_stat = src_path.stat()
  target_stat = target_path.stat()

  return src_stat.st_mode == target_stat.st_mode and \
         src_stat.st_uid == target_stat.st_uid and \
         src_stat.st_gid == target_stat.st_gid

def dedupe_hardlinks(target_dir):
  dupes = subprocess.check_output(['fdupes', '--recursive', str(target_dir)]).decode('utf-8')

  src_file = ''
  for line in dupes.splitlines():
    # Empty line means we're at the end of a set of dupes.
    if not line:
      src_file = ''
      continue

    # No src_file means we're at a new dupe source file.
    if not src_file:
      src_file = line
      continue

    # Check that we can perform the hard link.
    src_path = Path(src_file)
    target_path = Path(line)
    if not can_hardlink(src_path, target_path):
      continue

    # This file is a dupe - perform a hard link.
    target_path.unlink()
    os.link(str(src_path), str(target_path))


def create_fs_image(img_path, src_path, label=None):
  # Create image at 200% of source size.
  # resize2fs will shrink it to the minimum size later.
  du_output = subprocess.check_output(['du', '-bsx', src_path]).decode('utf-8')
  src_size = int(du_output.split()[0])
  img_size = int(src_size * 2.00)

  with img_path.open('wb+') as vm_rootfs:
    vm_rootfs.truncate(img_size)

  subprocess.run(
      [
          '/sbin/mkfs.ext4',
          '-F',
          '-m', '0',
          '-i', '16384',
          '-b', '4096',
          '-O', '^has_journal',
          '-d', str(src_path),
          str(img_path)
      ],
      stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, check=True)

  if label:
    subprocess.run(
        ['/sbin/e2label', str(img_path), label],
        stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, check=True)
  subprocess.run(
      ['/sbin/e2fsck', '-y', '-f', str(img_path)],
      stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, check=True)
  subprocess.run(
      ['/sbin/resize2fs', '-M', str(img_path)],
      stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, check=True)


def repack_rootfs(output_dir, disk_path):
  with tempfile.TemporaryDirectory() as tempdir_path:
    tempdir = Path(tempdir_path)
    rootfs_img_path = tempdir / 'rootfs.img'
    extract_squashfs_partition(str(rootfs_img_path), str(disk_path), 3)
    stateful_img_path = tempdir / 'stateful.img'
    extract_squashfs_partition(str(stateful_img_path), str(disk_path), 1)

    # Unsquash the rootfs and stateful partitions.
    rootfs_dir = tempdir / 'rootfs'
    subprocess.run(['unsquashfs', '-no-xattrs', '-d', str(rootfs_dir), str(rootfs_img_path)], stdout=subprocess.DEVNULL, check=True)
    stateful_dir = tempdir / 'stateful'
    subprocess.run(['unsquashfs', '-no-xattrs', '-d', str(stateful_dir), str(stateful_img_path)], stdout=subprocess.DEVNULL, check=True)

    # Extract the kernel. For ARM we just grab the Image-* file. For x86, we
    # grab the vmlinuz (bzImage).
    images = list(rootfs_dir.glob('boot/Image-*'))
    output_kernel = output_dir / 'vm_kernel'
    if len(images) > 0:
      shutil.copy(str(images[0]), str(output_kernel))
    else:
      shutil.copy(str(rootfs_dir / 'boot' / 'vmlinuz'), str(output_kernel))

    # Remove cruft we don't need.
    cruft_dirs = ['boot', 'lib/firmware', 'mnt/stateful_partition']
    for cruft_dir in cruft_dirs:
      shutil.rmtree(str(rootfs_dir / cruft_dir), ignore_errors=True)

    # Add new mnt dirs.
    (rootfs_dir / 'mnt' / 'stateful').mkdir()
    (rootfs_dir / 'mnt' / 'shared').mkdir()
    (rootfs_dir / 'mnt' / 'external').mkdir()

    # Copy the dev_image into its location at /usr/local.
    usr_local = rootfs_dir / 'usr' / 'local'
    dev_image = stateful_dir / 'dev_image'
    usr_local.rmdir()
    shutil.copytree(str(dev_image), str(usr_local), symlinks=True, ignore_dangling_symlinks=True)

    # Copy lsb-release and credits into place.
    shutil.copy(str(rootfs_dir / 'etc' / 'lsb-release'), str(output_dir))
    credits_path = rootfs_dir / 'opt/google/chrome/resources/about_os_credits.html'
    shutil.copy(str(credits_path), str(output_dir))

    dedupe_hardlinks(rootfs_dir)

    # Create vm_tools.img if /opt/google/cros-containers exists.
    tools_dir = rootfs_dir / 'opt' / 'google' / 'cros-containers'
    if tools_dir.exists():
      create_fs_image(output_dir / 'vm_tools.img', tools_dir, label='cros-vm-tools')

      # Remove contents of tools_dir so they are not included in vm_rootfs.img.
      # Leave the top-level /opt/google/cros-containers directory in place
      # as a mount point.
      for child in tools_dir.iterdir():
        shutil.rmtree(child)

    # Create vm_rootfs.img.
    create_fs_image(output_dir / 'vm_rootfs.img', rootfs_dir)


def main():
  parser = argparse.ArgumentParser(description='Build a Termina image')
  parser.add_argument('image', help='source disk image to build the Termina image from')
  parser.add_argument('output', help='output directory')

  args = parser.parse_args()

  disk_path = Path(args.image)
  if not disk_path.is_file():
    print('please provide the path to the termina image')
    sys.exit(1)

  output_dir = Path(args.output)
  if output_dir.exists():
    print('refusing to overwrite output directory')
    sys.exit(1)

  output_dir.mkdir()

  repack_rootfs(output_dir, disk_path)

  sys.exit(0)

if __name__ == '__main__':
  main()
