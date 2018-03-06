load("@bazel_tools//tools/build_defs/pkg:pkg.bzl", "pkg_tar", "pkg_deb")

pkg_tar(
    name = "cros-xwl-config",
    strip_prefix = "/cros-xwl-config",
    package_dir = "/etc/systemd/user/xwl@0.service.d",
    srcs = ["cros-xwl-override.conf"],
    mode = "0644",
)

pkg_tar(
    name = "debian-data",
    extension = "tar.gz",
    deps = [
        ":cros-xwl-config",
    ],
)

pkg_deb(
    name = "cros-xwl-config-deb",
    architecture = "all",
    data = ":debian-data",
    description_file = "deb-description",
    homepage = "https://chromium.org",
    maintainer = "The Chromium OS Authors <chromium-os-dev@chromium.org>",
    package = "cros-xwl-config",
    version = "0.4",
    section = "misc",
    conffiles_file = "conffiles",
    postinst = "postinst",
    prerm = "prerm",
    depends = ["libpam-systemd", "xwl"],
)
