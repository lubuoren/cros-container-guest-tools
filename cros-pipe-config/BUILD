# Copyright 2023 The ChromiumOS Authors
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

load("@rules_pkg//:pkg.bzl", "pkg_deb", "pkg_tar")

pkg_tar(
    name = "pipewire-pulse-config",
    srcs = [
        "pipewire-pulse/crostini.conf",
    ],
    mode = "0644",
    package_dir = "/etc/pipewire/pipewire-pulse.conf.d",
    strip_prefix = "/cros-pipe-config/pipewire-pulse",
)

pkg_tar(
    name = "pipewire-config",
    srcs = [
        "pipewire/crostini.conf",
    ],
    mode = "0644",
    package_dir = "/etc/pipewire/pipewire.conf.d",
    strip_prefix = "/cros-pipe-config/pipewire",
)

pkg_tar(
    name = "debian-data",
    extension = "tar.gz",
    deps = [
        ":pipewire-config",
        ":pipewire-pulse-config"
    ],
)

pkg_deb(
    name = "deb",
    architecture = "all",
    data = ":debian-data",
    depends = [
        "pipewire (>= 0.3.61)",
        "pipewire-alsa",
        "pipewire-pulse",
        "wireplumber",
        "cros-apt-config (>= 0.25)"
    ],
    description_file = "deb-description",
    homepage = "https://chromium.googlesource.com/chromiumos/docs/+/HEAD/containers_and_vms.md",
    maintainer = "The ChromiumOS Authors <chromium-os-dev@chromium.org>",
    package = "cros-pipe-config",
    section = "misc",
    version = "0.1.0",
    visibility = ["//cros-debs:__pkg__"],
)
