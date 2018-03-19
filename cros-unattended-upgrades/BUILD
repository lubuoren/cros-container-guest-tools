load("@bazel_tools//tools/build_defs/pkg:pkg.bzl", "pkg_tar", "pkg_deb")

pkg_tar(
    name = "cros-unattended-upgrades",
    strip_prefix = "/cros-unattended-upgrades",
    package_dir = "/etc/apt/apt.conf.d",
    srcs = ["95cros-unattended-upgrades"],
    mode = "0644",
)

pkg_tar(
    name = "debian-data",
    extension = "tar.gz",
    deps = [
        ":cros-unattended-upgrades",
    ],
)

pkg_deb(
    name = "cros-unattended-upgrades-deb",
    architecture = "all",
    data = ":debian-data",
    description_file = "deb-description",
    homepage = "https://chromium.org",
    maintainer = "The Chromium OS Authors <chromium-os-dev@chromium.org>",
    package = "cros-unattended-upgrades",
    version = "0.7",
    section = "misc",
    conffiles_file = "conffiles",
    depends = ["unattended-upgrades"],
)
