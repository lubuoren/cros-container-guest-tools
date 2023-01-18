# Copyright 2023 The ChromiumOS Authors
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

load("@rules_pkg//:pkg.bzl", "pkg_deb", "pkg_tar")

pkg_tar(
    name = "cros-vmstat-metrics-service-files",
    srcs = ["cros-vmstat-metrics.service"],
    mode = "0644",
    package_dir = "/usr/lib/systemd/user",
    strip_prefix = "/cros-vmstat-metrics",
)

pkg_tar(
    name = "debian-data",
    extension = "tar.gz",
    deps = [
        ":cros-vmstat-metrics-service-files",
    ],
)

pkg_deb(
    name = "deb",
    architecture = "all",
    data = ":debian-data",
    description_file = "deb-description",
    homepage = "https://chromium.googlesource.com/chromiumos/docs/+/HEAD/containers_and_vms.md",
    maintainer = "The Chromium OS Authors <chromium-os-dev@chromium.org>",
    package = "cros-vmstat-metrics",
    version = "0.1",
    section = "misc",
    visibility = ["//cros-debs:__pkg__"],
)
