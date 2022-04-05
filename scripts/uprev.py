#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# Copyright 2020 The Chromium OS Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

"""Uprev crostini tast data dependencies"""

import argparse
import itertools
import json
import os
import subprocess
import urllib.request

BUCKET_NAME = 'cros-containers-staging'
ARCHES = ['amd64', 'arm64']
CONTAINER_TYPES = ['test', 'app_test']
RELEASES = ['buster', 'bullseye']


def update_data_file(url, filepath, size, sha256sum):
    result = {'url': url, 'size': size, 'sha256sum': sha256sum}

    print(f'Updated {os.path.basename(filepath)}')
    with open(filepath, 'w') as f:
        json.dump(result, f, indent=4, sort_keys=True)

def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        'milestone', help='milestone number, e.g. 78')
    args = parser.parse_args()
    milestone = args.milestone

    tast_tests = subprocess.check_output(
        ['repo', 'list', '-pf', 'chromiumos/platform/tast-tests']
    ).decode().strip()
    data_dir = os.path.join(tast_tests,
                            'src/chromiumos/tast/local/crostini/data')

    images = json.loads(urllib.request.urlopen(
        f'https://storage.googleapis.com/{BUCKET_NAME}/{milestone}/streams/v1/images.json'
    ).read())

    for arch, ctype, release in itertools.product(ARCHES, CONTAINER_TYPES, RELEASES):
        # The container URLs use 'arm64', but the tast data files use 'arm'
        if arch == 'arm64':
            file_arch = 'arm'
        else:
            file_arch = arch

        product = images['products'][f'debian:{release}:{arch}:{ctype}']
        latest_container = max(product['versions'].keys())
        items = product['versions'][latest_container]['items']

        base_url = f'gs://{BUCKET_NAME}/{milestone}/'

        metadata_item = items['lxd.tar.xz']
        metadata_file = f'crostini_{ctype}_container_metadata_{release}_{file_arch}.tar.xz.external'
        update_data_file(
            base_url + metadata_item['path'],
            os.path.join(data_dir, metadata_file),
            metadata_item['size'],
            metadata_item['sha256'],
        )

        rootfs_item = items['rootfs.squashfs']
        rootfs_file = f'crostini_{ctype}_container_rootfs_{release}_{file_arch}.squashfs.external'
        update_data_file(
            base_url + rootfs_item['path'],
            os.path.join(data_dir, rootfs_file),
            rootfs_item['size'],
            rootfs_item['sha256'],
        )

    print('Tast data dependencies updated')
    print(f'Go to {data_dir} and create a CL')

if __name__ == '__main__':
    main()
