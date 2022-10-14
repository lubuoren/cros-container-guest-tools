# mesa

## Overview

These are the scripts used to build mesa-related Debian packages for Crostini.

## Prerequisites

These scripts are designed to run on a Debian-based system. The following
packages must be installed:
* `debhelper`
* `debian-archive-keyring`
* `libva-dev` (for mesa)
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
sudo ./setupchroot.sh buster amd64 "$(realpath artifacts)"
```

An existing chroot will not be overwritten, to force creation of a new chroot
delete any existing chroots, e.g. `/var/cache/pbuilder/debian-buster-amd64.tgz`
Replace `buster` and `amd64` with the desired Debian version and architecture.

## Building packages

The source packages being built must be located in the working directory.
Multiple packages can be built in one command. If one source package depends on
another, they must be built in order. e.g. to build mesa for amd64 buster:

```sh
git clone https://chromium.googlesource.com/chromiumos/third_party/libdrm -b debian --depth 1
git clone https://chromium.googlesource.com/chromiumos/third_party/mesa -b debian --depth 1

sudo ./buildpackages.sh buster amd64 "$(realpath artifacts)" libdrm mesa
```

The build artifacts will be located in the `artifacts` directory.

#### Gerrit merge commits

Send merge commit to gerrit:
```sh
debchange -r
git add debian/changelog
git commit
git push cros upstream/main:refs/heads/temporary_upstream
repo upload . --cbr
```

## Versioning

The Chrome OS releases are often coming from ToT and do not match released
or even branched mesa builds.  Pre-releases will be numbered in a format such
as `19.2.0~cros1-2` to signify a Chrome OS pre-release of 19.2.0.  cros1 will
be the second merge from upstream.  -2 will be the third build of that 
upstream build.  An actual release will look like 19.2.0-0~bpo0-1 and will 
be considered greater than the Chrome OS pre-release.

## Additional packages

In addition to `mesa` the following packages are built:
- `apitrace` - To enable trace-based testing.

Builds can be limited via the `PACKAGES` environment variable.
