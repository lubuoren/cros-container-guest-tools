load("@bazel_tools//tools/build_defs/pkg:pkg.bzl", "pkg_tar", "pkg_deb")

pkg_tar(
    name = "cros-tast-tests-desktop",
    strip_prefix= "/cros-tast-tests",
    package_dir = "/usr/share/applications",
    srcs = ["x11_demo.desktop", "wayland_demo.desktop"],
    mode = "0644",
)

pkg_tar(
    name = "debian-data",
    extension = "tar.gz",
    deps = [":cros-tast-tests-desktop"],
)

pkg_deb(
    name = "cros-tast-tests-deb",
    architecture = "all",
    data = ":debian-data",
    description_file = "deb-description",
    homepage = "https://chromium.org",
    maintainer = "The Chromium OS Authors <chromium-os-dev@chromium.org>",
    package = "cros-tast-tests",
    version = "0.1",
    section = "misc",
)
