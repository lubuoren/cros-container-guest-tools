load("@bazel_tools//tools/build_defs/pkg:pkg.bzl", "pkg_tar", "pkg_deb")

pkg_tar(
    name = "gtk2-config",
    strip_prefix = "/cros-ui-config",
    package_dir = "/etc/gtk-2.0/",
    srcs = ["gtkrc"],
    mode = "0644",
)

pkg_tar(
    name = "gtk3-config",
    strip_prefix = "/cros-ui-config",
    package_dir = "/etc/gtk-3.0/",
    srcs = ["settings.ini"],
    mode = "0644",
)

pkg_tar(
    name = "qt4-config",
    strip_prefix = "/cros-ui-config",
    package_dir = "/etc/xdg/",
    srcs = ["Trolltech.conf"],
    mode = "0644",
)

pkg_tar(
    name = "dconf-config",
    strip_prefix = "/cros-ui-config",
    package_dir = "/etc/dconf/db/local.d/",
    srcs = ["01-cros-ui"],
    mode = "0644",
)

pkg_tar(
    name = "dconf-profile",
    strip_prefix = "/cros-ui-config",
    package_dir = "/etc/dconf/profile/",
    srcs = ["user"],
    mode = "0644",
)

pkg_tar(
    name = "debian-data",
    extension = "tar.gz",
    deps = [
        ":dconf-config",
        ":dconf-profile",
        ":gtk2-config",
        ":gtk3-config",
        ":qt4-config",
    ],
)

pkg_deb(
    name = "cros-ui-config-deb",
    architecture = "all",
    data = ":debian-data",
    description_file = "deb-description",
    homepage = "https://chromium.org",
    maintainer = "The Chromium OS Authors <chromium-os-dev@chromium.org>",
    package = "cros-ui-config",
    version = "0.12",
    section = "misc",
    conffiles_file = "conffiles",
    postinst = "postinst",
    postrm = "postrm",
    depends = ["cros-adapta",
               "dconf-cli",
               "fonts-croscore",
               "fonts-roboto"],
)
