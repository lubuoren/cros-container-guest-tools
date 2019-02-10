#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# Copyright 2018 The Chromium OS Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.
"""LXD container integration tests."""

from __future__ import print_function

import argparse
import os
import pylxd
import sys
import time
import unittest
import xmlrunner

STOPPED = 102
RUNNING = 103

class LxdTestCase(unittest.TestCase):
  """LxdTestCase includes all test cases for CrOS LXD containers."""
  UNIFIED_TARBALL = 'unified.tar.xz'
  IMAGE_ALIAS = 'lxd_test_image'
  CONTAINER_NAME = 'lxd-test'
  TEST_PROFILE = 'test-profile'
  TEST_USER = 'testuser'

  @classmethod
  def setUpClass(cls):
    cls.client = pylxd.Client()
    cls.image = None
    if cls.client.images.exists(cls.IMAGE_ALIAS, alias=True):
      cls.image = cls.client.images.get_by_alias(cls.IMAGE_ALIAS)
    else:
      with open(cls.UNIFIED_TARBALL, 'rb') as unified_tarball:
        cls.image = cls.client.images.create(unified_tarball)
        cls.image.add_alias(cls.IMAGE_ALIAS, 'lxd test image')
        cls.image.save(wait=True)

    # Profile setup + mocks to bind-mount in.
    cls.profile = None
    if cls.client.profiles.exists(cls.TEST_PROFILE):
      cls.profile = cls.client.profiles.get(cls.TEST_PROFILE)
      cls.profile.delete(wait=True)

    script_dir = os.path.dirname(os.path.abspath(__file__))
    lddtree_dir = os.path.join(script_dir, 'mocks', 'lddtree')
    sshd_dir = os.path.join(script_dir, 'mocks', 'sshd_config')

    cls.profile = cls.client.profiles.create(
        cls.TEST_PROFILE,
        config={
            'boot.autostart': 'false',
            'security.syscalls.blacklist': 'keyctl errno 38'
        },
        devices={
            'root': {
                'path': '/',
                'pool': 'default',
                'type': 'disk',
            },
            'eth0': {
                'nictype': 'bridged',
                'parent': 'lxdbr0',
                'type': 'nic',
            },
            'cros_containers': {
                'source': lddtree_dir,
                'path': '/opt/google/cros-containers',
                'type': 'disk',
            },
            'sshd_config': {
                'source': sshd_dir,
                'path': '/dev/.ssh',
                'type': 'disk',
            },
        })

  @classmethod
  def tearDownClass(cls):
    cls.image.sync()
    cls.image.delete(wait=True)
    cls.profile.sync()
    cls.profile.delete(wait=True)

  def setUp(self):
    if self.client.containers.exists(self.CONTAINER_NAME):
      self.container = self.client.containers.get(self.CONTAINER_NAME)
      if self.container.status_code != STOPPED:
        self.container.stop(wait=True)
      self.container.delete(wait=True)

    self.container = self.client.containers.create(
        {
            'name': self.CONTAINER_NAME,
            'source': {
                'type': 'image',
                'alias': self.IMAGE_ALIAS
            },
            'profiles': [self.TEST_PROFILE],
        },
        wait=True)

  def tearDown(self):
    self.container.sync()
    if self.container.status_code != STOPPED:
      self.container.stop(wait=True)
    self.container.delete(wait=True)

  def test_system_services(self):
    self.container.start(wait=True)
    time.sleep(10)
    self.container.sync()
    self.assertEqual(self.container.status_code, RUNNING)
    ret, _, _ = self.container.execute(
        ['systemctl', 'is-active', 'cros-sftp.service'])
    self.assertEqual(ret, 0)

  def test_user_services_no_gpu(self):
    self.container.start(wait=True)
    time.sleep(10)
    self.assertEqual(self.container.status_code, RUNNING)
    ret, _, _ = self.container.execute(
        ['useradd', '-u', '1000', '-s', '/bin/bash', '-m', self.TEST_USER])
    self.assertEqual(ret, 0)

    groups = [
        'audio', 'cdrom', 'dialout', 'floppy', 'plugdev', 'sudo', 'users',
        'video'
    ]
    for group in groups:
      ret, _, _ = self.container.execute(
          ['usermod', '-aG', group, self.TEST_USER])
      self.assertEqual(ret, 0)

    ret, _, _ = self.container.execute(
        ['loginctl', 'enable-linger', self.TEST_USER])
    self.assertEqual(ret, 0)
    time.sleep(10)

    ret, _, _ = self.container.execute([
        'su', '-c', 'systemctl --user is-active cros-garcon.service',
        self.TEST_USER
    ])
    self.assertEqual(ret, 0)
    ret, _, _ = self.container.execute([
        'su', '-c', 'systemctl --user is-active sommelier@0.service',
        self.TEST_USER
    ])
    self.assertEqual(ret, 0)
    ret, _, _ = self.container.execute([
        'su', '-c', 'systemctl --user is-active sommelier-x@0.service',
        self.TEST_USER
    ])
    self.assertEqual(ret, 0)
    ret, _, _ = self.container.execute([
        'su', '-c',
        'systemctl --user show-environment | grep -q SOMMELIER_GLAMOR',
        self.TEST_USER
    ])
    self.assertEqual(ret, 1)
    ret, _, _ = self.container.execute([
        'su', '-c',
        'systemctl --user show-environment | grep -q SOMMELIER_DRM_DEVICE',
        self.TEST_USER
    ])
    self.assertEqual(ret, 1)

  def test_user_services_gpu(self):
    self.container.start(wait=True)
    self.container.devices.update({
          'renderD128': {
              'major': '226',
              'minor': '128',
              'mode': '0666',
              'path': '/dev/dri/renderD128',
              'type': 'unix-char',
          },
      })
    self.container.save()
    time.sleep(10)
    self.assertEqual(self.container.status_code, RUNNING)
    ret, _, _ = self.container.execute(
        ['useradd', '-u', '1000', '-s', '/bin/bash', '-m', self.TEST_USER])
    self.assertEqual(ret, 0)

    groups = [
        'audio', 'cdrom', 'dialout', 'floppy', 'plugdev', 'sudo', 'users',
        'video'
    ]
    for group in groups:
      ret, _, _ = self.container.execute(
          ['usermod', '-aG', group, self.TEST_USER])
      self.assertEqual(ret, 0)

    ret, _, _ = self.container.execute(
        ['loginctl', 'enable-linger', self.TEST_USER])
    self.assertEqual(ret, 0)
    time.sleep(10)

    ret, _, _ = self.container.execute([
        'su', '-c', 'systemctl --user is-active cros-garcon.service',
        self.TEST_USER
    ])
    self.assertEqual(ret, 0)
    ret, _, _ = self.container.execute([
        'su', '-c', 'systemctl --user is-active sommelier@0.service',
        self.TEST_USER
    ])
    self.assertEqual(ret, 0)
    ret, _, _ = self.container.execute([
        'su', '-c', 'systemctl --user is-active sommelier-x@0.service',
        self.TEST_USER
    ])
    self.assertEqual(ret, 0)
    ret, _, _ = self.container.execute([
        'su', '-c',
        'systemctl --user show-environment | grep -q SOMMELIER_GLAMOR',
        self.TEST_USER
    ])
    self.assertEqual(ret, 0)
    ret, _, _ = self.container.execute([
        'su', '-c',
        'systemctl --user show-environment | grep -q SOMMELIER_DRM_DEVICE',
        self.TEST_USER
    ])
    self.assertEqual(ret, 0)


if __name__ == '__main__':
  if len(sys.argv) != 3:
    print("usage: test.py result_dir unified_tarball")
    sys.exit(1)

  LxdTestCase.UNIFIED_TARBALL = sys.argv.pop()
  result_dir = sys.argv.pop()

  with open(os.path.join(result_dir, 'sponge_log.xml'), 'wb') as output:
    unittest.main(
        testRunner=xmlrunner.XMLTestRunner(output=output),
        failfast=False,
        buffer=False,
        catchbreak=False,
        verbosity=2)
