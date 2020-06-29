# Copyright 2019 The Chromium OS Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

load("@bazel_tools//tools/build_defs/pkg:pkg.bzl", "pkg_deb", "pkg_tar")

genrule(
    name = "cros-keyring-gpg",
    srcs = ["cros.pubkey"],
    outs = ["cros.gpg"],
    cmd = """gpg --no-tty \
                 --homedir /tmp \
                 --no-default-keyring \
                 --lock-never \
                 --keyring ./tmp.keyring \
                 --import $(location cros.pubkey) && \
             gpg --no-tty \
                 --homedir /tmp \
                 --no-default-keyring \
                 --lock-never \
                 --keyring ./tmp.keyring \
                 --export > $@""",
)

pkg_tar(
    name = "cros-keyring",
    srcs = ["cros.gpg"],
    mode = "0644",
    package_dir = "//etc/apt/trusted.gpg.d",
    strip_prefix = "/cros-apt-config",
)

pkg_tar(
    name = "cros-apt-prefs",
    srcs = ["cros.pref"],
    mode = "0644",
    package_dir = "/etc/apt/preferences.d",
    strip_prefix = "/cros-apt-config",
)

pkg_tar(
    name = "debian-data",
    extension = "tar.gz",
    deps = [
        ":cros-apt-prefs",
        ":cros-keyring",
    ],
)

pkg_deb(
    name = "deb",
    architecture = "all",
    data = ":debian-data",
    depends = ["apt-transport-https"],
    description_file = "deb-description",
    homepage = "https://chromium.googlesource.com/chromiumos/docs/+/HEAD/containers_and_vms.md",
    maintainer = "The Chromium OS Authors <chromium-os-dev@chromium.org>",
    package = "cros-apt-config",
    section = "misc",
    version = "0.20",
    visibility = ["//cros-debs:__pkg__"],
)
