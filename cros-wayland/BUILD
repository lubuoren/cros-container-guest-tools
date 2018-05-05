load("@bazel_tools//tools/build_defs/pkg:pkg.bzl", "pkg_tar", "pkg_deb")

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
        ":cros-wayland-udev",
    ],
)

pkg_deb(
    name = "cros-wayland-deb",
    architecture = "all",
    data = ":debian-data",
    description_file = "deb-description",
    homepage = "https://chromium.org",
    maintainer = "The Chromium OS Authors <chromium-os-dev@chromium.org>",
    package = "cros-wayland",
    version = "0.10",
    section = "x11",
    conffiles_file = "conffiles",
)
