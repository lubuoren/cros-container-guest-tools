# Copyright 2019 The Chromium OS Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

FROM ubuntu:bionic

# Install Debian packages.
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get install -q -y \
        debian-keyring \
        debian-archive-keyring \
        git-buildpackage \
        debhelper \
        quilt \
        libva-dev \
        dh-python \
        libxml2-utils \
        python-all

ENV ARCHES="amd64 i386"
ENV DISTRIBUTION=stretch-backports
ENV ARTIFACTS=/artifacts

COPY .gbp.conf .pbuilderrc llvm-keyring.gpg  /root/
COPY .pbuilder /root/.pbuilder/
COPY *.sh /scratch/

WORKDIR /scratch
VOLUME $ARTIFACTS

ENV LIBDRM_TAG=libdrm-2.4.97-1
ENV MESA_BRANCH=debian-stretch-19.1

CMD ./sync-and-build.sh

