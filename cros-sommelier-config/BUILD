load("@bazel_tools//tools/build_defs/pkg:pkg.bzl", "pkg_tar", "pkg_deb")

pkg_tar(
    name = "cros-sommelier-config",
    strip_prefix = "/cros-sommelier-config",
    package_dir = "/etc/systemd/user/sommelier@0.service.d",
    srcs = ["cros-sommelier-override.conf"],
    mode = "0644",
)

pkg_tar(
    name = "cros-sommelier-x-config",
    strip_prefix = "/cros-sommelier-config",
    package_dir = "/etc/systemd/user/sommelier-x@0.service.d",
    srcs = ["cros-sommelier-x-override.conf"],
    mode = "0644",
)

pkg_tar(
    name = "debian-data",
    extension = "tar.gz",
    deps = [
        ":cros-sommelier-config",
        ":cros-sommelier-x-config",
    ],
)

pkg_deb(
    name = "cros-sommelier-config-deb",
    architecture = "all",
    data = ":debian-data",
    description_file = "deb-description",
    homepage = "https://chromium.org",
    maintainer = "The Chromium OS Authors <chromium-os-dev@chromium.org>",
    package = "cros-sommelier-config",
    version = "0.10",
    section = "misc",
    conffiles_file = "conffiles",
    postinst = "postinst",
    prerm = "prerm",
    depends = ["libpam-systemd", "cros-sommelier"],
)
