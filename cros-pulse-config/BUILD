load("@bazel_tools//tools/build_defs/pkg:pkg.bzl", "pkg_tar", "pkg_deb")

pkg_tar(
    name = "cros-pulse-config-systemd",
    strip_prefix = "/cros-pulse-config",
    package_dir = "/usr/lib/systemd/user",
    srcs = ["cros-pulse-config.service"],
    mode = "0644",
    symlinks = { "./usr/lib/systemd/user/default.target.wants/cros-pulse-config.service": "/usr/lib/systemd/user/cros-pulse-config.service" },
)

pkg_tar(
    name = "debian-data",
    extension = "tar.gz",
    deps = [
        ":cros-pulse-config-systemd",
    ],
)

pkg_deb(
    name = "cros-pulse-config-deb",
    architecture = "all",
    data = ":debian-data",
    description_file = "deb-description",
    homepage = "https://chromium.org",
    maintainer = "The Chromium OS Authors <chromium-os-dev@chromium.org>",
    package = "cros-pulse-config",
    version = "0.1",
    section = "misc",
    depends = ["pulseaudio"],
)
