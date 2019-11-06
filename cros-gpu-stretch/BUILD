# Copyright 2019 The Chromium OS Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

load("@bazel_tools//tools/build_defs/pkg:pkg.bzl", "pkg_tar", "pkg_deb")

genrule(
    name = "llvm-keyring-gpg",
    srcs = ["llvm-snapshot.gpg.key"],
    outs = ["llvm-snapshot.gpg"],
    cmd = """gpg --no-tty \
                 --homedir /tmp \
                 --no-default-keyring \
                 --lock-never \
                 --keyring ./tmp.keyring \
                 --import $(location llvm-snapshot.gpg.key) && \
             gpg --no-tty \
                 --homedir /tmp \
                 --no-default-keyring \
                 --lock-never \
                 --keyring ./tmp.keyring \
                 --export > $@""",
)

pkg_tar(
    name = "llvm-keyring",
    srcs = ["llvm-snapshot.gpg"],
    mode = "0644",
    package_dir = "//etc/apt/trusted.gpg.d",
    strip_prefix = "/cros-gpu-stretch",
)

pkg_tar(
    name = "cros-gpu-list",
    srcs = ["cros-gpu.list"],
    mode = "0644",
    package_dir = "/etc/apt/sources.list.d",
    strip_prefix = "/cros-gpu-stretch",
)

pkg_tar(
    name = "cros-gpu-pref",
    srcs = ["cros-gpu.pref"],
    mode = "0644",
    package_dir = "/etc/apt/preferences.d",
    strip_prefix = "/cros-gpu-stretch",
)

pkg_tar(
    name = "debian-data",
    extension = "tar.gz",
    deps = [
        ":cros-gpu-list",
        ":cros-gpu-pref",
        ":llvm-keyring",
    ],
)

pkg_deb(
    name = "deb",
    architecture = "all",
    conflicts = ["cros-gpu-alpha"],
    data = ":debian-data",
    depends = ["apt-transport-https"],
    description_file = "deb-description",
    homepage = "https://chromium.googlesource.com/chromiumos/docs/+/HEAD/containers_and_vms.md",
    maintainer = "The Chromium OS Authors <chromium-os-dev@chromium.org>",
    package = "cros-gpu",
    section = "misc",
    version = "9.7",
    visibility = ["//cros-debs:__pkg__"],
)
