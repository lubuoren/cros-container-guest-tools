#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# Copyright 2019 The Chromium OS Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

"""Builds the guest_images.tar archive from a local termina build.
This is useful for testing. Should be run inside the chroot, as some options
will only work correctly there."""

import argparse
import json
import os
import subprocess
import sys
import tempfile
import urllib.request

from pathlib import Path
from termina_uprev import build_component

pin_path = '/build/{}/usr/local/opt/google/containers/pins/{}'

def gsuri_to_https(gsuri):
  return gsuri.replace('gs://', 'https://storage.googleapis.com/', 1)

def get_component_version_from_pin(host_board):
  with open(pin_path.format(host_board, 'termina.json'),'r') as file:
    pin = json.load(file)
  return gsuri_to_https(pin['gsuri'])

def get_component_version_from_download(milestone, board):
  base_url = f'https://storage.googleapis.com/termina-component-testing/{milestone}/staging'
  response = urllib.request.urlopen(base_url)
  version = response.read().decode('utf-8').strip()

  if board == 'tatl':
    arch = 'chromeos_intel64-archive'
  elif board == 'tael':
    arch = 'chromeos_arm32-archive'
  return f'https://storage.googleapis.com/termina-component-testing/{milestone}/{version}/{arch}/files.zip'

def download_component(url, output_dir):
  dest = str(output_dir / 'vm_image.zip')
  print('Downloading from', url, 'to', dest)
  urllib.request.urlretrieve(url, dest)

def get_container_url_from_pin(host_board):
  urls = {}

  for pin_file in ['crostini_metadata.json', 'crostini_rootfs.json']:
    with open(pin_path.format(host_board, pin_file),'r') as file:
      pin = json.load(file)
      urls[pin['filename']] = gsuri_to_https(pin['gsuri'])

  return urls

def get_container_url_from_download(milestone, board, os_version):
  if board == 'tatl':
    arch = 'amd64'
  elif board == 'tael':
    arch = 'arm64'

  base_url = f'https://storage.googleapis.com/cros-containers-staging/{milestone}/'

  image_url = base_url + 'streams/v1/images.json'
  response = urllib.request.urlopen(image_url)
  image_json = json.loads(response.read().decode('utf-8'))
  os_str = f'debian:{os_version}:{arch}:test'
  image_json = image_json['products'][os_str]['versions']
  build = list(image_json.keys())[0]
  return {'container_rootfs.tar.xz':
          base_url + image_json[build]['items']['rootfs.tar.xz']['path'],
          'container_metadata.tar.xz':
          base_url + image_json[build]['items']['lxd.tar.xz']['path']}

def download_container(urls, output_dir):
  for dest in urls:
    path = urls[dest]
    dest = output_dir / dest
    print('Downloading from', path, 'to', dest)
    urllib.request.urlretrieve(path, str(dest))

def main():
  parser = argparse.ArgumentParser(description='Build guest_images.tar. Some features of this script may not work outside the Chrome OS chroot.')
  parser.add_argument('--vm-source', help='Where to get the VM image from. In pin mode, use the version fixed in the termina-pin ebuild (--host-board must be specified). In download mode, use the latest image uploaded to the termina-component-testing bucket for the given milestone and VM board (--board and --milestone must be given). In local mode, use a local build of termina (--board must be given).',
                      choices=['pin', 'download', 'local'], default='local')
  parser.add_argument('--container-source',
                      help='Where to get the container image from. In pin mode, use the version fixed in the crostini-pin ebuild (--host-board must be specified). In download mode, use the latest image uploaded to the cros-containers-staging bucket for the given milestone and VM board (--board and --milestone must be given, --os-version may be given). Local mode is not available here as it is not currently feasible to build the crostini container locally.',
                      choices=['pin', 'download'], default='download')
  parser.add_argument('--board', help='VM board to use. In pin mode the version specifiers in the pins take precedence over this option.',
                      choices=['tatl', 'tael'])
  parser.add_argument('--host-board', help='Board to source pins from. Only used in pin mode (default: %(default)s)',
                      default='eve')
  parser.add_argument('--milestone',
                      help='Milestone to download objects from. Only used in download mode.',
                      type=int)
  parser.add_argument('--os-version',
                      help='Version of container os to use. Only used in download mode (default: %(default)s)',
                      default='stretch')
  parser.add_argument('--output',
                      help='Location to put the final guest_images.tar file. Defaults to %(default)s, which allows locally run tast tests to use it. This should take precedence over the external link crostini_guest_images.tar.external in the same directory.',
                      default=Path.home() / 'trunk/src/platform/tast-tests/local_tests/crostini/data/crostini_guest_images.tar',
                      type=Path)

  args = parser.parse_args()

  if args.host_board is None and \
     (args.vm_source == 'pin' or args.container_source == 'pin'):
    print('--host-board must be set if pins are used')
    sys.exit(1)

  if (args.board is None or args.milestone is None) and \
     (args.vm_source == 'download' or args.container_source == 'download'):
    print('--board and --milestone must be set if download sources are used')
    sys.exit(1)

  if args.board is None and args.vm_source == 'local':
    print('--board must be set if local builds are used')
    sys.exit(1)

  with tempfile.TemporaryDirectory() as tempdir_path:
    tempdir = Path(tempdir_path)
    if args.vm_source == 'pin':
      url = get_component_version_from_pin(args.host_board)
      download_component(url, tempdir)
    elif args.vm_source == 'download':
      url = get_component_version_from_download(args.milestone, args.board)
      download_component(url, tempdir)
    elif args.vm_source == 'local':
      image_path = Path.home() / Path('trunk/src/build/images') / \
                   args.board / 'latest/chromiumos_test_image.bin'
      build_component(args.board, image_path.as_posix(), tempdir, '99999.0.0')
      os.rename(tempdir / args.board / 'files.zip', tempdir / 'vm_image.zip')

    if args.container_source == 'pin':
      urls = get_container_url_from_pin(args.host_board)
    elif args.container_source == 'download':
      urls = get_container_url_from_download(args.milestone, args.board,
                                             args.os_version)
    download_container(urls, tempdir)

    subprocess.run(['tar', '-C', str(tempdir), '-cf', args.output,
                    'vm_image.zip', 'container_metadata.tar.xz',
                    'container_rootfs.tar.xz'])

  sys.exit(0)

if __name__ == '__main__':
  main()
