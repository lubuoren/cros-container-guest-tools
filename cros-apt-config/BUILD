load("@bazel_tools//tools/build_defs/pkg:pkg.bzl", "pkg_tar", "pkg_deb")

genrule(
    name = "cros-keyring-gpg",
    srcs = ["cros.pubkey"],
    outs = ["cros.gpg"],
    cmd = """gpg --no-tty \
                 --homedir /tmp \
                 --no-default-keyring \
                 --lock-never \
                 --keyring ./tmp.keyring \
                 --import $(location cros.pubkey) && \
             gpg --no-tty \
                 --homedir /tmp \
                 --no-default-keyring \
                 --lock-never \
                 --keyring ./tmp.keyring \
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
    version = "0.19",
    section = "misc",
    depends = ["apt-transport-https"],
)
