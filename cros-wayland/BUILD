load("@bazel_tools//tools/build_defs/pkg:pkg.bzl", "pkg_tar", "pkg_deb")

cc_binary(
    name = "cros-wayland-lock",
    srcs = ["cros_wayland_lock.c"],
)

pkg_tar(
    name = "cros-wayland-lock-bin",
    strip_prefix = "/cros-wayland",
    package_dir = "/usr/bin",
    srcs = [":cros-wayland-lock"],
    mode = "0755",
)

genrule(
    name = "skel-config",
    srcs = ["skel.weston.ini"],
    outs = [".config/weston.ini"],
    cmd = "mv $(location skel.weston.ini) $@",
)

pkg_tar(
    name = "cros-wayland-etc-skel",
    strip_prefix = "/cros-wayland",
    package_dir = "/etc/skel",
    srcs = [":skel-config"],
    mode = "0644",
)

pkg_tar(
    name = "cros-wayland-systemd",
    strip_prefix = "/cros-wayland",
    package_dir = "/usr/lib/systemd/user",
    srcs = ["cros-wayland.service"],
    mode = "0644",
    symlinks = { "./usr/lib/systemd/user/default.target.wants/cros-wayland.service": "/usr/lib/systemd/user/cros-wayland.service" },
)

pkg_tar(
    name = "cros-wayland-udev",
    strip_prefix = "/cros-wayland",
    package_dir = "/lib/udev/rules.d",
    srcs = ["10-cros-virtwl.rules"],
    mode = "0644",
)

pkg_tar(
    name = "debian-data",
    extension = "tar.gz",
    deps = [
        ":cros-wayland-etc-skel",
        ":cros-wayland-lock-bin",
        ":cros-wayland-systemd",
        ":cros-wayland-udev",
    ],
)

pkg_deb(
    name = "cros-wayland-deb",
    architecture = "amd64",
    data = ":debian-data",
    description_file = "deb-description",
    homepage = "https://chromium.org",
    maintainer = "The Chromium OS Authors <chromium-os-dev@chromium.org>",
    package = "cros-wayland",
    version = "0.8",
    section = "x11",
    conffiles_file = "conffiles",
    depends = ["libc6 (>= 2.4)",
            "libegl1-mesa (= 13.0.6-1cros1)",
            "libgtk-3-0 (= 3.22.11-1cros1)",
            "libwayland-cursor0 (= 1.12.0-1cros1)",
            "weston (= 1.12.0-3cros1)",
            "xwayland (= 2:1.19.2-1+deb9u2cros2)"],
    suggests = ["libqt5waylandclient5 (= 5.7.1~20161021-2cros1)"],
    recommends = ["xwl"],
)
