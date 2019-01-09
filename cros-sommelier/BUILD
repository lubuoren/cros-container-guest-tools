load("@bazel_tools//tools/build_defs/pkg:pkg.bzl", "pkg_tar", "pkg_deb")

pkg_tar(
    name = "cros-sommelier-elf",
    strip_prefix = "/cros-sommelier",
    package_dir = "/usr/bin",
    symlinks = { "./usr/bin/sommelier.elf": "/opt/google/cros-containers/bin/sommelier.elf" },
)

pkg_tar(
    name = "cros-sommelier-unitfiles",
    strip_prefix = "/cros-sommelier",
    package_dir = "/usr/lib/systemd/user/",
    srcs = [
        "sommelier@.service",
        "sommelier-x@.service",
    ],
    mode = "0644",
)

pkg_tar(
    name = "cros-sommelierrc",
    strip_prefix = "/cros-sommelier",
    package_dir = "/etc",
    srcs = ["sommelierrc"],
    mode = "0644",
)

pkg_tar(
    name = "cros-sommelier-profiled",
    strip_prefix = "/cros-sommelier",
    package_dir = "/etc/profile.d",
    srcs = ["sommelier.sh"],
    mode = "0755",
)

pkg_tar(
    name = "debian-data",
    extension = "tar.gz",
    deps = [
        ":cros-sommelier-elf",
        ":cros-sommelier-unitfiles",
        ":cros-sommelierrc",
        ":cros-sommelier-profiled",
    ],
)

pkg_deb(
    name = "cros-sommelier-deb",
    architecture = "all",
    data = ":debian-data",
    description_file = "deb-description",
    homepage = "https://chromium.org",
    maintainer = "The Chromium OS Authors <chromium-os-dev@chromium.org>",
    package = "cros-sommelier",
    version = "0.21",
    section = "misc",
    conffiles_file = "conffiles",
    depends = ["libpam-systemd"],
    recommends = [
        "x11-utils",
        "x11-xserver-utils",
        "xauth",
        "xfonts-base",
        "xkb-data",
    ],
)
