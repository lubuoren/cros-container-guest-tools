#!/usr/bin/env python3
# Copyright 2022 The ChromiumOS Authors
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

"""Creates a slim rootfs for guest boards that can be used for testing"""

import argparse
import os
import subprocess
import sys
import tempfile

from pathlib import Path

"""
  Creates a slim rootfs for the given guest 'board'.
  - Creates a folder to house the rootfs.
  - Copies the essential binaries and dependencies from 'board''s rootfs to the new folder.
  - Creates a .img file that will be the final rootfs.
  - Formats the .img file to ext4.
  - Copies the folder (in step 1) contents to the .img file.
  - Resizes the image to be the minimum it can be.
  - Places the img file to the 'destination' either on the local file
    system or a gs bucket.
"""
def build_slim_rootfs(board, destination):
  with tempfile.TemporaryDirectory() as tempdir:
    print("Building slim rootfs for board:", board)

    # Create directory for the slim rootfs.
    tempdir_path = Path(tempdir)
    slim_rootfs_path = tempdir_path / 'slim-rootfs'

    # Copy the essential binaries and their dependencies to the slim rootfs.
    slim_rootfs_binaries = ['/sbin/init', '/usr/sbin/vshd', '/usr/bin/vm_syslog', '/usr/bin/tremplin']
    board_rootfs_path = Path('/build') / board
    for binary in slim_rootfs_binaries:
      subprocess.run(
          [
            'lddtree',
            '-R', str(board_rootfs_path),
            '--copy-to-tree', str(slim_rootfs_path),
            binary
          ],
          check=True
      )

    # Create mount points needed by a guest image.
    mounts = ['mnt', 'run', 'dev', 'proc', 'sys', 'tmp', 'mnt/external', 'mnt/shared']
    for mount in mounts:
      (slim_rootfs_path / mount).mkdir()

    # Create a .img file which will be the final slim rootfs. Assume 50 MB is fine
    # for now.
    slim_rootfs_img_path = tempdir_path / Path(board+'-slim-rootfs.img')
    with slim_rootfs_img_path.open('wb+') as slim_rootfs:
      slim_rootfs.truncate(50*1024*1024)

    # Format it to ext4.
    subprocess.run(
        [
          '/sbin/mkfs.ext4',
          slim_rootfs_img_path
        ],
        check=True
    )

    # Mount the ext4 img file and copy the slim rootfs contents to it.
    mount_path = tempdir_path / "foo"
    mount_path.mkdir()
    subprocess.run(
        [
          'sudo',
          'mount',
          slim_rootfs_img_path,
          mount_path
        ],
        check=True
    )
    # The trailing slash is needed as we want to copy the contents of the rootfs
    # folder without the folder itself.
    subprocess.run(
        [
          'sudo',
          'rsync',
          '-a',
          str(slim_rootfs_path) + '/',
          mount_path
        ],
        check=True
    )
    subprocess.run(
        [
          'sudo',
          'umount',
          mount_path
        ],
        check=True
    )

    # At this point the img file i.e. 'slim_rootfs_img_path'  houses the slim rootfs.
    # Shrink it to the minimum possible size.
    subprocess.run(
        [
          '/sbin/resize2fs',
          '-M',
          slim_rootfs_img_path
        ],
        check=True
    )

    # Copy img file to the destination.
    if destination.startswith('gs://'):
      print('Uploading to gs path:', destination)
      subprocess.run(
          [
            'gsutil',
            'cp',
            slim_rootfs_img_path,
            destination
          ],
          check=True
      )
    else:
      print('Copying to:', destination)
      subprocess.run(
          [
            'cp',
            slim_rootfs_img_path,
            destination
          ],
          check=True
      )

def main():
  parser = argparse.ArgumentParser(description='Build a slim rootfs for a Termina guest')
  parser.add_argument('board', help='Either tatl or tael')
  parser.add_argument('destination', help='The path of the slim rootfs file')

  args = parser.parse_args()
  board = args.board
  if board != 'tatl' and board != 'tael':
    print('only tatl and tael are supported')
    sys.exit(1)

  build_slim_rootfs(board, args.destination)
  sys.exit(0)

if __name__ == '__main__':
  main()
