load("@bazel_tools//tools/build_defs/pkg:pkg.bzl", "pkg_tar", "pkg_deb")

pkg_tar(
    name = "cros-adapta-symlinks",
    symlinks = {"./usr/share/themes/CrosAdapta": "/opt/google/cros-containers/cros-adapta"},
)

pkg_tar(
    name = "debian-data",
    extension = "tar.gz",
    deps = [
        ":cros-adapta-symlinks",
    ],
)

pkg_deb(
    name = "cros-adapta-deb",
    architecture = "all",
    data = ":debian-data",
    depends = [
        "gtk2-engines-murrine",
        "gtk2-engines-pixbuf",
        "libgtk2.0-0",
        "libgtk-3-0",
        "qt5-gtk-platformtheme",
        "qt5-style-plugins",
    ],
    description_file = "deb-description",
    homepage = "https://chromium.googlesource.com/chromiumos/third_party/cros-adapta/",
    maintainer = "The Chromium OS Authors <chromium-os-dev@chromium.org>",
    package = "cros-adapta",
    section = "misc",
    version = "0.3",
)
