load("@bazel_tools//tools/build_defs/pkg:pkg.bzl", "pkg_tar", "pkg_deb")

pkg_tar(
    name = "cros-tast-tests-desktop",
    strip_prefix= "/cros-tast-tests",
    package_dir = "/usr/share/applications",
    srcs = [
        "x11_demo.desktop",
        "x11_demo_fixed_size.desktop",
        "wayland_demo.desktop",
        "wayland_demo_fixed_size.desktop",
    ],
    mode = "0644",
)

pkg_tar(
    name = "cros-tast-tests-icon",
    strip_prefix= "/cros-tast-tests",
    package_dir = "/usr/share/icons/hicolor/32x32/apps",
    srcs = ["x11_demo.png", "wayland_demo.png"],
    mode = "0644",
)

pkg_tar(
    name = "debian-data",
    extension = "tar.gz",
    deps = [
        ":cros-tast-tests-desktop",
        ":cros-tast-tests-icon",
    ],
)

pkg_deb(
    name = "cros-tast-tests-deb",
    architecture = "all",
    data = ":debian-data",
    description_file = "deb-description",
    homepage = "https://chromium.org",
    maintainer = "The Chromium OS Authors <chromium-os-dev@chromium.org>",
    package = "cros-tast-tests",
    version = "0.4",
    section = "misc",
)
