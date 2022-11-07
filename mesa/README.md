# mesa

## Overview

These are the scripts used to build mesa-related Debian packages for Crostini.

## Prerequisites

These scripts are designed to run on a Debian-based system. The following
packages must be installed:
* `debhelper`
* `debian-archive-keyring`
* `pbuilder`
* `quilt`
* `qemu-user-static` (if building for a non-native architecture)

## pbuilder setup

Copy the pbuilder configuration from this directory to `/root`:
```sh
sudo cp -r .pbuilder{,rc} /root
```

Create a directory to store build artifacts, e.g. `artifacts`:
```sh
mkdir artifacts
```

To create a chroot:
```sh
sudo ./setupchroot.sh bullseye amd64 "$(realpath artifacts)"
```

An existing chroot will not be overwritten, to force creation of a new chroot
delete any existing chroots, e.g. `/var/cache/pbuilder/debian-bullseye-amd64.tgz`
Replace `bullseye` and `amd64` with the desired Debian version and architecture.

## Building packages

The source packages being built must be located in the working directory.
Multiple packages can be built in one command. If one source package depends on
another, they must be built in order. e.g. to build mesa for amd64 bullseye:

```sh
git clone https://chromium.googlesource.com/chromiumos/third_party/libdrm -b debian-bullseye --depth 1
git clone https://chromium.googlesource.com/chromiumos/third_party/mesa -b debian-bullseye --depth 1

sudo ./buildpackages.sh bullseye amd64 "$(realpath artifacts)" libdrm mesa
```

The build artifacts will be located in the `artifacts` directory.

## Versioning

Crostini builds of mesa have a version format such as `21.2.6-1~cros11+1`.
`21.2.6-1` is the original Debian release that was backported, `~cros11`
are builds for Debian 11 (bullseye) and `+1` is the first build of this version.
This is similar to the version format used for Debian backports.

## Additional packages

In addition to `mesa` the following packages are built for Debian buster only:
- `waffle`
- `apitrace` - To enable trace-based testing.
- `glbench`
