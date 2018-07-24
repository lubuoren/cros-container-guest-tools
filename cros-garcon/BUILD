load("@bazel_tools//tools/build_defs/pkg:pkg.bzl", "pkg_tar", "pkg_deb")

pkg_tar(
    name = "cros-garcon-desktop",
    strip_prefix= "/cros-garcon",
    package_dir = "/usr/share/applications",
    srcs = ["garcon_host_browser.desktop"],
    mode = "0644",
)

pkg_tar(
    name = "cros-garcon-systemd",
    strip_prefix = "/cros-garcon",
    package_dir = "/usr/lib/systemd/user",
    srcs = ["cros-garcon.service"],
    mode = "0644",
    symlinks = { "./usr/lib/systemd/user/default.target.wants/cros-garcon.service": "/usr/lib/systemd/user/cros-garcon.service" },
)

pkg_tar(
    name = "cros-garcon-terminal-handler",
    strip_prefix = "/cros-garcon",
    package_dir = "/usr/bin",
    srcs = ["garcon-terminal-handler"],
    mode = "0755",
)

pkg_tar(
    name = "cros-garcon-url-handler",
    strip_prefix = "/cros-garcon",
    package_dir = "/usr/bin",
    srcs = ["garcon-url-handler"],
    mode = "0755",
)

pkg_tar(
    name = "cros-garcon-config",
    strip_prefix = "/cros-garcon",
    package_dir = "/etc/systemd/user/cros-garcon.service.d",
    srcs = ["cros-garcon-override.conf"],
    mode = "0644",
)

pkg_tar(
    name = "cros-garcon-polkit",
    strip_prefix = "/cros-garcon",
    package_dir = "/var/lib/polkit-1/localauthority/50-local.d",
    srcs = ["garcon-packagekit.pkla"],
    mode = "0644",
)

pkg_tar(
    name = "debian-data",
    extension = "tar.gz",
    deps = [
        ":cros-garcon-config",
        ":cros-garcon-desktop",
        ":cros-garcon-polkit",
        ":cros-garcon-systemd",
        ":cros-garcon-terminal-handler",
        ":cros-garcon-url-handler",
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
    depends = ["desktop-file-utils","packagekit","xdg-utils"],
    version = "0.16",
    section = "misc",
    conffiles_file = "conffiles",
    postinst = "postinst",
    prerm = "prerm",
)
