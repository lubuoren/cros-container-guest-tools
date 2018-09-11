load("@bazel_tools//tools/build_defs/pkg:pkg.bzl", "pkg_tar", "pkg_deb")

pkg_tar(
    name = "cros-notificationd-dbus-service-files",
    strip_prefix = "/cros-notificationd",
    package_dir = "/usr/share/dbus-1/services/",
    srcs = ["org.freedesktop.Notifications.service"],
    mode = "0644",
)

pkg_tar(
    name = "debian-data",
    extension = "tar.gz",
    deps = [
        ":cros-notificationd-dbus-service-files",
    ],
)

pkg_deb(
    name = "cros-notificationd-deb",
    architecture = "all",
    data = ":debian-data",
    description_file = "deb-description",
    homepage = "https://chromium.org",
    maintainer = "The Chromium OS Authors <chromium-os-dev@chromium.org>",
    package = "cros-notificationd",
    version = "0.1",
    section = "misc",
)
