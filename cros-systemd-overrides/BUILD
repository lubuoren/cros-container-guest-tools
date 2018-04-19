load("@bazel_tools//tools/build_defs/pkg:pkg.bzl", "pkg_tar", "pkg_deb")

pkg_tar(
    name = "debian-data",
)

pkg_deb(
    name = "cros-systemd-overrides-deb",
    architecture = "all",
    data = ":debian-data",
    description_file = "deb-description",
    homepage = "https://chromium.org",
    maintainer = "The Chromium OS Authors <chromium-os-dev@chromium.org>",
    package = "cros-systemd-overrides",
    version = "0.10",
    section = "misc",
    depends = ["systemd"],
)
