load("@bazel_tools//tools/build_defs/pkg:pkg.bzl", "pkg_tar", "pkg_deb")

pkg_tar(
    name = "cros-garcon-systemd",
    strip_prefix = "/cros-garcon",
    package_dir = "/usr/lib/systemd/user",
    srcs = ["cros-garcon.service"],
    mode = "0644",
    symlinks = { "./usr/lib/systemd/user/default.target.wants/cros-garcon.service": "/usr/lib/systemd/user/cros-garcon.service" },
)

pkg_tar(
    name = "debian-data",
    extension = "tar.gz",
    deps = [
        ":cros-garcon-systemd",
    ],
)

pkg_deb(
    name = "cros-garcon-deb",
    architecture = "all",
    data = ":debian-data",
    description_file = "deb-description",
    homepage = "https://chromium.org",
    maintainer = "The Chromium OS Authors <chromium-os-dev@chromium.org>",
    package = "cros-garcon",
    depends = ["xdg-utils"],
    version = "0.7",
    section = "misc",
)
