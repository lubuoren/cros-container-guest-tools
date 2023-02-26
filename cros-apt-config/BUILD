# Copyright 2019 The ChromiumOS Authors
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

load("@rules_pkg//:pkg.bzl", "pkg_deb", "pkg_tar")

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
                 --export EB4C1BFD4F042F6DDDCCEC917721F63BD38B4796 > $@""",
)

pkg_tar(
    name = "cros-keyring",
    srcs = ["cros.gpg"],
    mode = "0644",
    package_dir = "//etc/apt/trusted.gpg.d",
    strip_prefix = "/cros-apt-config",
)

pkg_tar(
    name = "cros-keyring-new",
    srcs = ["cros.gpg"],
    mode = "0644",
    package_dir = "//usr/share/keyrings",
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
    name = "cros-apt-prefs-bullseye",
    srcs = ["cros-bullseye.pref"],
    mode = "0644",
    package_dir = "/etc/apt/preferences.d",
    strip_prefix = "/cros-apt-config",
)

pkg_tar(
    name = "cros-apt-prefs-buster",
    srcs = ["cros-buster.pref"],
    mode = "0644",
    package_dir = "/etc/apt/preferences.d",
    strip_prefix = "/cros-apt-config",
)

pkg_tar(
    name = "debian-data-bookworm",
    extension = "tar.gz",
    deps = [
        ":cros-apt-prefs",
        ":cros-keyring",
        ":cros-keyring-new",
    ],
)

pkg_tar(
    name = "debian-data-bullseye",
    extension = "tar.gz",
    deps = [
        ":cros-apt-prefs",
        ":cros-apt-prefs-bullseye",
        ":cros-keyring",
        ":cros-keyring-new",
    ],
)

pkg_tar(
    name = "debian-data-buster",
    extension = "tar.gz",
    deps = [
        ":cros-apt-prefs",
        ":cros-apt-prefs-buster",
        ":cros-keyring",
        ":cros-keyring-new",
    ],
)

pkg_deb(
    name = "deb-bookworm",
    architecture = "all",
    data = ":debian-data-bookworm",
    description_file = "deb-description",
    homepage = "https://chromium.googlesource.com/chromiumos/docs/+/HEAD/containers_and_vms.md",
    maintainer = "The ChromiumOS Authors <chromium-os-dev@chromium.org>",
    package = "cros-apt-config",
    section = "misc",
    version = "0.27",
    visibility = ["//cros-debs:__pkg__"],
)

pkg_deb(
    name = "deb-bullseye",
    architecture = "all",
    data = ":debian-data-bullseye",
    description_file = "deb-description",
    homepage = "https://chromium.googlesource.com/chromiumos/docs/+/HEAD/containers_and_vms.md",
    maintainer = "The ChromiumOS Authors <chromium-os-dev@chromium.org>",
    package = "cros-apt-config",
    section = "misc",
    # To maintain a clean upgrade path, the version should sort before the
    # :deb-bookworm versions.
    version = "0.27~cros11",
    visibility = ["//cros-debs:__pkg__"],
)

pkg_deb(
    name = "deb-buster",
    architecture = "all",
    data = ":debian-data-buster",
    description_file = "deb-description",
    homepage = "https://chromium.googlesource.com/chromiumos/docs/+/HEAD/containers_and_vms.md",
    maintainer = "The ChromiumOS Authors <chromium-os-dev@chromium.org>",
    package = "cros-apt-config",
    section = "misc",
    # To maintain a clean upgrade path, the version should sort before the
    # :deb-bookworm and :deb-bullseye versions.
    version = "0.27~cros10",
    visibility = ["//cros-debs:__pkg__"],
)
