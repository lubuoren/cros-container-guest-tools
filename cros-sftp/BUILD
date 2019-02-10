load("@bazel_tools//tools/build_defs/pkg:pkg.bzl", "pkg_tar", "pkg_deb")

pkg_tar(
    name = "cros-sftp-unitfiles",
    strip_prefix = "/cros-sftp",
    package_dir = "/usr/lib/systemd/system/",
    srcs = ["cros-sftp.service"],
    mode = "0644",
    symlinks = { "./usr/lib/systemd/system/default.target.wants/cros-sftp.service": "/usr/lib/systemd/system/cros-sftp.service" },
)

pkg_tar(
    name = "debian-data",
    extension = "tar.gz",
    deps = [
        ":cros-sftp-unitfiles",
    ],
)

pkg_deb(
    name = "cros-sftp-deb",
    architecture = "all",
    data = ":debian-data",
    description_file = "deb-description",
    homepage = "https://chromium.org",
    maintainer = "The Chromium OS Authors <chromium-os-dev@chromium.org>",
    package = "cros-sftp",
    version = "0.14",
    section = "misc",
    depends = ["openssh-server"],
)
