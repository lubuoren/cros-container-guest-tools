# Copyright 2019 The Chromium OS Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

FROM debian:buster

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
        qemu-user-static \
        binfmt-support

ENV FOREIGN_ARCHES="arm64 armhf"
ENV ARCHES="${FOREIGN_ARCHES} amd64 i386"
ENV DISTRIBUTIONS="buster"
ENV CHROOT_DISTRIBUTION="buster"
ENV ARTIFACTS=/artifacts

COPY .pbuilderrc /root/
COPY .pbuilder /root/.pbuilder/
COPY *.sh /scratch/

WORKDIR /scratch
VOLUME $ARTIFACTS

ENV PACKAGES="apitrace mesa"
ENV MESA_BUILD_BRANCH=debian-build
ENV MESA_CHECKOUT_BRANCH=debian

CMD ./sync-and-build.sh

