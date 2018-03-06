load("@bazel_tools//tools/build_defs/pkg:pkg.bzl", "pkg_tar", "pkg_deb")

genrule(
    name = "cros-keyring-gpg",
    srcs = ["cros.pubkey"],
    outs = ["cros.gpg"],
    cmd = """gpg --no-default-keyring \
                 --keyring ./crostini.keyring \
                 --import $(location cros.pubkey) && \
             gpg --no-default-keyring \
                 --keyring ./crostini.keyring \
                 --export > $@""",
)

pkg_tar(
    name = "cros-keyring",
    strip_prefix = "/cros-apt-config",
    package_dir = "//etc/apt/trusted.gpg.d",
    srcs = ["cros.gpg"],
    mode = "0644",
)

pkg_tar(
    name = "cros-sources-list",
    strip_prefix = "/cros-apt-config",
    package_dir = "/etc/apt/sources.list.d",
    srcs = ["cros.list"],
    mode = "0644",
)

pkg_tar(
    name = "cros-apt-prefs",
    strip_prefix = "/cros-apt-config",
    package_dir = "/etc/apt/preferences.d",
    srcs = ["cros.pref"],
    mode = "0644",
)

pkg_tar(
    name = "debian-data",
    extension = "tar.gz",
    deps = [
        ":cros-apt-prefs",
        ":cros-keyring",
        ":cros-sources-list",
    ],
)

pkg_deb(
    name = "cros-apt-config-deb",
    architecture = "all",
    data = ":debian-data",
    description_file = "deb-description",
    homepage = "https://chromium.org",
    maintainer = "The Chromium OS Authors <chromium-os-dev@chromium.org>",
    package = "cros-apt-config",
    version = "0.4",
    section = "misc",
    conffiles_file = "conffiles",
    depends = ["apt-transport-https"],
)
