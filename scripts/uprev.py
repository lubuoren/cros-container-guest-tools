#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# Copyright 2020 The Chromium OS Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

"""Uprev crostini tast data dependencies"""

import argparse
import subprocess
import shlex
import json
import os

def update_data_file(url, filepath):
    result = {'url': url}
    ls = subprocess.check_output(['gsutil.py', 'ls', '-l', url])
    result['size'] = int(ls.decode().split()[0])

    sha256sum = subprocess.check_output(
        f'gsutil.py cp {shlex.quote(url)} - | sha256sum'
    , shell=True)
    result['sha256sum'] = sha256sum.decode().split()[0]

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

    latest_container = subprocess.check_output(
        ['gsutil.py', 'ls', f'gs://cros-containers-staging/{milestone}'
         '/images/debian/buster/arm64/default/']
    ).decode().split()[-1].split('/')[-2]

    for arch in ['amd64', 'arm64']:
        # The container URLs use 'arm64', but the tast data files use 'arm'
        if arch == 'arm64':
            file_arch = 'arm'
        else:
            file_arch = arch

        for ctype in ['test', 'app_test']:
            for release in ['stretch', 'buster', 'bullseye']:
                base_url = f'gs://cros-containers-staging/{milestone}' \
                    f'/images/debian/{release}/{arch}/{ctype}/{latest_container}/'

                metadata_file = f'crostini_{ctype}_container_metadata_{release}' \
                    f'_{file_arch}.tar.xz.external'
                update_data_file(base_url + 'lxd.tar.xz',
                                 os.path.join(data_dir, metadata_file))

                rootfs_file = f'crostini_{ctype}_container_rootfs_{release}' \
                    f'_{file_arch}.tar.xz.external'
                update_data_file(base_url + 'rootfs.tar.xz',
                                 os.path.join(data_dir, rootfs_file))

    print('Tast data dependencies updated')
    print(f'Go to {data_dir} and create a CL')

if __name__ == '__main__':
    main()
