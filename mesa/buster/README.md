# mesa

## Overview

This is the Docker image to build mesa-related Debian packages for the Chrome
OS container.

## Configuration

Configuration is handled via environment variables in the `Dockerfile`.
After changes are made the image will need to be regenerated.

The values of these environment variables can be overridden during the
Docker invocation to limit what is being built.  Of note are the following
variables:
- ARCHES - The architectures to build for (amd64, i386, arm64, armhf)
- DISTRIBUTIONS - The distributions to build for (currently just buster)
- PACCKAGES - The packages to build for (apitrace, mesa)

## Generating Docker image

The Docker image can be created from platform/container-guest-tools/mesa/buster
with:
```sh
sudo docker build --tag=buildmesa_buster .
```

To export the base Docker image to use within the continuous build system:
```sh
sudo docker save buildmesa_buster:latest | xz -T 0 -z > buildmesa_buster.tar.xz
```

The packages are built with `pdebuild` within a chroot of the Docker
container.  The chroots for each architecture can be pre-generated and
cached with:
```sh
name=bm$(date +%s)
sudo docker run --privileged --name=$name -it buildmesa_buster ./setupchroot.sh
sudo docker commit $name buildmesa_buster:setup
```

To export the Docker image with cached chroot.  This image is too large
to use within the continuous build system and is mainly useful for testing:
```sh
sudo docker save buildmesa_buster:setup | \
    xz -T 0 -z > buildmesa_buster-setup.tar.xz
```

## Building packages

To build the packages using the image with cached chroot with artifacts
written to `$PWD/artifacts`:
```sh
sudo docker run \
    --privileged \
    --volume=$PWD/artifacts:/artifacts \
    -it buildmesa_buster:setup ./sync-and-build.sh
```

To build the packages using the base image with artifacts written to
`$PWD/artifacts`:
```sh
sudo docker run \
    --privileged \
    --volume=$PWD/artifacts:/artifacts \
    -it buildmesa_buster
```

To build only for specified architectures specify `ARCHES` environment
variable:
```sh
sudo docker run \
    --privileged \
    --volume=$PWD/artifacts:/artifacts \
    -e ARCHES='amd64' \
    -it buildmesa_buster
```

To import the tarball Docker image on another machine:
```sh
sudo docker load -i buildmesa_buster.tar.xz
```

### Building packages from untested changes

The Debian packages will be available in `$PWD/artifacts` to test.

#### Using Chrome OS checkout

These following steps are run from the top of a Chrome OS checkout.

Build packages using an existing mesa git repo within a Chrome OS checkout:
```sh
sudo docker run \
    --privileged \
    --volume=$PWD/src/platform/container-guest-tools/mesa/buster/artifacts:/artifacts \
    --volume=$PWD/.repo:/.repo \
    --volume=$PWD/src/third_party/mesa-debian:/scratch/mesa \
    -e PACKAGES='mesa' \
    -it buildmesa_buster:latest
```

#### Using sandbox branch

These following steps are run from third_party/mesa.

To test new mesa changes, prepare a local branch based off of
`debian`:
```sh
git remote add upstream git://anongit.freedesktop.org/mesa/mesa
git remote update upstream
git checkout -b debian cros/debian
git merge upstream/master
debchange -i
git add debian/changelog
git commit
```

Upload a sandbox branch to test with Docker and start a container.
`buildmesa_buster:latest` can be changed to `buildmesa_buster:setup` if it is
available.
```sh
git push cros HEAD:refs/sandbox/"${USER}"/debian-buster-test
sudo docker run \
    --privileged \
    --volume=$PWD/artifacts:/artifacts \
    -it buildmesa_buster:latest \
    bash
```

Within the Docker container, perform a build.  $USER will need to be
set manually within the container.
```sh
./setupchroot.sh
./sync.sh
(cd mesa &&
 git fetch origin refs/sandbox/$USER/debian-buster-test &&
 git checkout -B "${MESA_BUILD_BRANCH}" FETCH_HEAD)
./buildpackages.sh
exit
```

#### Gerrit merge commits

Send merge commit to gerrit:
```sh
debchange -r
git add debian/changelog
git commit
git push cros upstream/master:refs/heads/temporary_upstream
repo upload . --cbr
```

## Kokoro

The exported Docker image tarball must be copied to x20 under the path
`/x20/teams/chromeos-vm/docker/buildmesa_buster.tar.xz`:
```sh
prodaccess
cp buildmesa_buster.tar.xz /google/data/rw/teams/chromeos-vm/docker
```

The owner of the tarball must be set to `chromeos-vm-ci-read-write` to
allows Kokoro to have access to it.
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
