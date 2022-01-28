#!/usr/bin/env python3
# Copyright 2018 The Chromium OS Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

import argparse
import datetime
import hashlib
import json
import os
import shutil
import sys

index_template = {
    'format': 'index:1.0',
    'index': {
        'images': {
            'path': 'streams/v1/images.json',
            'datatype': 'image-downloads',
            'products': [
            ],
        }
    }
}

images_template = {
    'datatype': 'image-downloads',
    'format': 'products:1.0',
    'content_id': 'images',
    'products': {}
}

def sha256sum(paths):
    sha256 = hashlib.sha256()
    for path in paths:
        with open(path, 'rb') as f:
            page = f.read(4096)
            while page != b"":
                sha256.update(page)
                page = f.read(4096)

    return sha256.hexdigest()

def image_path(distro, release, arch, image_type, version):
    return 'images/{0}/{1}/{2}/{3}/{4}'.format(distro, release, arch, image_type, version)

def create_product(distro, arch, os_desc, release, image_type, version, rootfs_tarball, rootfs_squash, lxd_tarball):
    img_path = image_path(distro, release, arch, image_type, version)

    rootfs_stat = os.stat(rootfs_tarball)
    rootfs_sha256 = sha256sum([rootfs_tarball])
    rootfs_item = {
        'size': rootfs_stat.st_size,
        'path': '{}/rootfs.tar.xz'.format(img_path),
        'sha256': rootfs_sha256,
        'ftype': 'root.tar.xz'
    }

    rootfs_squash_stat = os.stat(rootfs_squash)
    rootfs_squash_sha256 = sha256sum([rootfs_squash])
    rootfs_squash_item = {
        'size': rootfs_squash_stat.st_size,
        'path': '{}/rootfs.squashfs'.format(img_path),
        'sha256': rootfs_squash_sha256,
        'ftype': 'squashfs'
    }

    lxd_stat = os.stat(lxd_tarball)
    lxd_sha256 = sha256sum([lxd_tarball])
    combined_rootfs_sha256 = sha256sum([lxd_tarball, rootfs_tarball])
    combined_squash_sha256 = sha256sum([lxd_tarball, rootfs_squash])
    lxd_item = {
       'size': lxd_stat.st_size,
       'path': '{}/lxd.tar.xz'.format(img_path),
       'combined_sha256': combined_rootfs_sha256,
       'combined_rootxz_sha256': combined_rootfs_sha256,
       'combined_squashfs_sha256': combined_squash_sha256,
       'sha256': lxd_sha256,
       'ftype': 'lxd.tar.xz'
    }

    product = {
         'aliases': '{0}/{1}/{2},{0}/{1}/{2}/{3}'.format(distro, release, image_type, arch),
         'arch': arch,
         'os': os_desc,
         'release_title': release,
         'release': release,
         'versions': {}
    }
    if image_type == 'default':
        product['aliases'] += ',{0}/{1},{0}/{1}/{2}'.format(distro, release, arch)

    product['versions'][version] = {
        'items': {
           'rootfs.squashfs': rootfs_squash_item,
           'rootfs.tar.xz': rootfs_item,
           'lxd.tar.xz': lxd_item
        }
    }

    return product


def main():
    parser = argparse.ArgumentParser(description='Create simplestreams .json files.')
    parser.add_argument('in_dir', help='input directory tree of container rootfs tarballs')
    parser.add_argument('out_dir', help='output directory')

    args = parser.parse_args()

    try:
        os.makedirs(args.out_dir)
    except:
        print('Failed to create out directory')
        sys.exit(1)

    date = datetime.datetime.today().strftime('%Y%m%d_%H:%M')
    index = index_template.copy()
    images = images_template.copy()

    expected_files = {'lxd.tar.xz', 'rootfs.tar.xz', 'rootfs.squashfs'}
    for root, dirs, files in os.walk(args.in_dir):
        files_set = set(files)
        if len(expected_files.intersection(files_set)) != len(expected_files):
            continue
        split_dirs = root.split('/')
        if len(split_dirs) < 4:
            continue

        # Format is /path/to/in_dir/distro/release/arch/image_type.
        distro = split_dirs[-4]
        release = split_dirs[-3]
        arch = split_dirs[-2]
        image_type = split_dirs[-1]
        rootfs_source_path = os.path.join(root, 'rootfs.tar.xz')
        rootfs_squash_source_path = os.path.join(root, 'rootfs.squashfs')
        lxd_source_path = os.path.join(root, 'lxd.tar.xz')

        product_name = '{}:{}:{}:{}'.format(distro, release, arch, image_type)
        index['index']['images']['products'].append(product_name)

        product = create_product(distro,
                                 arch,
                                 "Debian",
                                 release,
                                 image_type,
                                 date,
                                 rootfs_source_path,
                                 rootfs_squash_source_path,
                                 lxd_source_path)
        images['products'][product_name] = product

        out_images_path = os.path.join(args.out_dir,
                                       image_path(distro, release, arch, image_type, date))
        lxd_path = os.path.join(out_images_path, "lxd.tar.xz")
        rootfs_path = os.path.join(out_images_path, "rootfs.tar.xz")
        rootfs_squash_path = os.path.join(out_images_path, "rootfs.squashfs")
        try:
            print(out_images_path)
            os.makedirs(out_images_path)
        except:
            print('Failed to create images directory')
            sys.exit(1)

        shutil.copy(lxd_source_path, lxd_path)
        shutil.copy(rootfs_source_path, rootfs_path)
        shutil.copy(rootfs_squash_source_path, rootfs_squash_path)

    stream_path = os.path.join(args.out_dir, 'streams/v1')
    try:
        os.makedirs(stream_path)
    except:
        print('Failed to create streams directory')
        sys.exit(1)

    index_path = os.path.join(stream_path, 'index.json')
    images_path = os.path.join(stream_path, 'images.json')
    with open(index_path, 'w') as index_file:
        json.dump(index, index_file)

    with open(images_path, 'w') as images_file:
        json.dump(images, images_file)

if __name__ == '__main__':
    main()
