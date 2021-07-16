#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# Copyright 2018 The Chromium OS Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

"""Uprevs Termina images"""

import argparse
import json
import os
import shutil
import struct
import subprocess
import sys
import tempfile
import urllib.request

from pathlib import Path
from termina_build_image import repack_rootfs
from termina_util import mount_disk, get_release_version

def get_build_path(board, branch):
  query = {
      'builder': {
          'project': 'chromeos',
          'bucket': 'general',
          'builder': 'LegacyRelease',
      },

      'tags': [{
          'key': 'cbb_branch',
          'value': f'{branch}',
      }, {
          'key': 'cbb_config',
          'value': f'{board}-release',
      }],

      'status': 'SUCCESS',
  }

  query_str = json.dumps(query)

  result_str = subprocess.run(
      ['bb', 'ls', '-n', '1', '-json', '-fields', 'output', '-predicate', query_str],
      stdout=subprocess.PIPE,
      check=True).stdout.decode()

  result = json.loads(result_str)

  return result['output']['properties']['artifact_link']

def download_image(board, gs_path, output_dir):
  target_path = output_dir / '{}_base_image.tar.xz'.format(board)

  subprocess.run(
      ['gsutil', 'cp',
       f'{gs_path}/chromiumos_base_image.tar.xz',
       target_path],
      check=True)

  return target_path

def unpack_component(board, image_path, output_dir):
  component_dir = output_dir / board
  component_dir.mkdir()
  result = subprocess.run(['tar', 'xvf', image_path, '-C', str(component_dir)], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, check=True)
  return component_dir / 'chromiumos_base_image.bin'

def build_component(board, image_path, output_dir, component_version):
  print('Repacking rootfs')
  component_dir = output_dir / board
  component_dir.mkdir(exist_ok=True)
  repack_rootfs(component_dir, image_path)

  # Assemble the component disk image.
  print('Building component disk image')

  # Create image at 150% of source size.
  # resize2fs will shrink it to the minimum size later.
  du_output = subprocess.check_output(['du', '-bsx',
                                       component_dir]).decode('utf-8')
  src_size = int(du_output.split()[0])
  img_size = int(src_size * 1.50)

  component_disk = component_dir / 'image.ext4'
  with component_disk.open('wb+') as component:
    component.truncate(img_size)
  subprocess.run(['/sbin/mkfs.ext4', '-b', '4096', '-O', '^has_journal', str(component_disk)], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, check=True)
  mnt_dir = component_dir / 'mnt'
  mnt_dir.mkdir()

  with mount_disk(str(component_disk), str(mnt_dir)) as mntpoint:
    for component_file in ['about_os_credits.html', 'lsb-release',
                           'vm_kernel', 'vm_rootfs.img', 'vm_tools.img']:
      subprocess.run(['sudo', 'cp', str(component_dir / component_file),
                      str(mnt_dir / component_file)], check=True)

  subprocess.run(['/sbin/e2fsck', '-y', '-f', str(component_disk)], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, check=True)
  subprocess.run(['/sbin/resize2fs', '-M', str(component_disk)], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, check=True)

  # Create manifest and zip up.
  print('Zipping up component and manifest')
  release_version = get_release_version(component_dir / 'lsb-release')
  if not release_version:
    print("No valid version in lsb-release")
    sys.exit(1)

  manifest_contents = {
    'description': 'Chrome OS VM Container',
    'name': 'termina',
    'version': release_version,
    'min_env_version': component_version,
    'squash' : 'false',
    'image_name' : 'image.ext4',
    'fs_type' : 'ext4',
    'is_removable' : 'true'
  }

  manifest_encoded = json.dumps(manifest_contents)

  manifest_path = component_dir / 'manifest.json'
  with open(str(manifest_path), 'w+') as manifest:
    manifest.write(manifest_encoded)

  subprocess.run(['zip', '-rj', str(component_dir / 'files.zip'), str(component_disk), str(manifest_path)], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, check=True)

def main():
  parser = argparse.ArgumentParser(description='Uprev Termina images')
  parser.add_argument('--branch', help='optional branch name, e.g. release-R72-11316.B (default: main)', default='main')
  parser.add_argument('--output_dir', help='local dir to save results')
  parser.add_argument('component_version', help='version of the component')

  args = parser.parse_args()

  with tempfile.TemporaryDirectory() as tempdir_path:
    tempdir = Path(tempdir_path)
    for board in ['tatl', 'tael']:
      gs_path = get_build_path(board, args.branch)
      download_path = download_image(board, gs_path, tempdir)
      image_path = unpack_component(board, download_path, tempdir)
      build_component(board, image_path, tempdir, args.component_version)
      if args.output_dir:
        target_dir = Path(args.output_dir) / board
        shutil.copytree(str(tempdir / board), str(target_dir))

  sys.exit(0)

if __name__ == '__main__':
  main()
