#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# Copyright 2018 The ChromiumOS Authors
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

"""Utility functions for dealing with termina images"""

import subprocess

from contextlib import contextmanager

def extract_vmlinux(vmlinuz_path, vmlinux_path):
  gzip_header = b'\x1f\x8b\x08'

  with open(vmlinuz_path, 'rb') as vmlinuz:
    vmlinuz_contents = vmlinuz.read()

    with open(vmlinux_path, 'w+b') as vmlinux:
      index = 0
      while True:
        index = vmlinuz_contents.find(gzip_header, index)
        if index == -1:
          print("no header found")
          return False
        # Attempt to decompress with gzip.
        result = subprocess.run(['gunzip'], input=vmlinuz_contents[index:], stdout=vmlinux, stderr=subprocess.DEVNULL)
        if result.returncode != 0:
          result = subprocess.run(['readelf', '-h', vmlinux_path], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
          if result.returncode == 0:
            return True
        else:
          print('failed to decompress at index', index, 'err', err)
          index += 1

@contextmanager
def mount_disk(src, target):
  subprocess.check_call(['sudo', 'mount', src, target])
  try:
    yield target
  finally:
    try:
      subprocess.check_call(['sudo', 'umount', target])
    except:
      print('failed to unmount', target)

def get_release_version(lsb_release_path):
  with open(str(lsb_release_path), 'r') as lsb_release:
    lsb_release_dict = {}
    for line in lsb_release.readlines():
      split_line = line.split('=')
      if len(split_line) != 2:
        continue
      lsb_release_dict[split_line[0]] = split_line[1]

  build = int(lsb_release_dict['CHROMEOS_RELEASE_BUILD_NUMBER'])
  branch = int(lsb_release_dict['CHROMEOS_RELEASE_BRANCH_NUMBER'])
  patches = lsb_release_dict['CHROMEOS_RELEASE_PATCH_NUMBER'].split('-')
  patch = int(patches[0])
  # HACK: patch is often a date (e.g. on tryjobs), so cap the patch number.
  if patch >= 1000:
    patch = 0

  return '%d.%d.%d' % (build, branch, patch)
