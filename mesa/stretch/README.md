# mesa

## Overview
This is the Docker image to build mesa Debian packages for the Chrome OS
container.

## Configuration
Configuration is handled via environment variables in the `Dockerfile`.
After changes are made the image will need to be regenerated.

## Generating Docker image
The Docker image can be created with:
```sh
sudo docker build --tag=buildmesa_stretch .
```

To export the base Docker image to use within the continuous build system:
```sh
sudo docker save buildmesa_stretch:latest | \
    xz -T 0 -z > buildmesa_stretch.tar.xz
```

The packages are built with `gbp-buildpackage` within a chroot of the Docker
container.  The chroots for each architecture can be pre-generated and
cached with:
```sh
name=bm$(date +%s)
sudo docker run --privileged --name=$name -it buildmesa_stretch \
    ./setupchroot.sh
sudo docker commit $name buildmesa_stretch:setup
```

To export the Docker image with cached chroot.  This image is too large
to use within the continuous build system:
```sh
sudo docker save buildmesa_stretch:setup | \
    xz -T 0 -z > buildmesa_stretch-setup.tar.xz
```

## Building packages
To build the packages using the image with cached chroot with artifacts
written to `$PWD/artifacts`:
```sh
sudo docker run \
    --privileged \
    --volume=$PWD/artifacts:/artifacts \
    -it buildmesa_stretch:setup ./sync-and-build.sh
```

To build the packages using the base image with artifacts written to
`$PWD/artifacts`:
```sh
sudo docker run \
    --privileged \
    --volume=$PWD/artifacts:/artifacts \
    -it buildmesa_stretch
```

To import the tarball Docker image on another machine:
```sh
sudo docker load -i buildmesa_stretch.tar.xz
```

### Building packages from untested changes
To test new mesa changes, prepare a local branch based off of
`debian`:
```sh
git remote add upstream git://anongit.freedesktop.org/mesa/mesa
git remote update upstream
git checkout -b debian-stretch-19.2 cros/debian-stretch-19.2
git merge upstream/master
debchange -i
git add debian/changelog
git commit
```

Upload a sandbox branch to test with Docker and start a container.
`buildmesa_stretch:latest` can be changed to `buildmesa_stretch:setup` if it is
available.
```sh
git push cros HEAD:refs/sandbox/"${USER}"/debian-stretch-test
sudo docker run \
    --privileged \
    --volume=$PWD/artifacts:/artifacts \
    -it buildmesa_stretch:latest \
    bash
```

Within the Docker container, perform a build.  $USER will need to be
set manually within the container.
```sh
./setupchroot.sh
./sync.sh
(cd mesa &&
 git fetch origin refs/sandbox/$USER/debian-stretch-test &&
 git checkout -B "${MESA_BRANCH}" FETCH_HEAD)
./buildpackages.sh
exit
```

The Debian packages will be available in `$PWD/artifacts/stretch` to test.

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
`/x20/teams/chromeos-vm/docker/buildmesa_stretch.tar.xz`:
```sh
prodaccess
cp buildmesa_stretch.tar.xz /google/data/rw/teams/chromeos-vm/docker
```

The owner of the tarball must be set to `chromeos-vm-ci-read-write` to
allows Kokoro to have access to it.

## LLVM Keyring
The LLVM keyring was generated with:
```sh
wget https://apt.llvm.org/llvm-snapshot.gpg.key
gpg --no-default-keyring --keyring ./llvm-tmp.gpg --import llvm-snapshot.gpg.key
gpg --keyring ./llvm-tmp.gpg --export --output llvm-keyring.gpg
```

## Versioning
The Chrome OS releases are often coming from ToT and do not match released
or even branched mesa builds.  Pre-releases will be numbered in a format such
as `19.2.0~cros1-2` to signify a Chrome OS pre-release of 19.2.0.  cros1 will
be the second merge from upstream.  -2 will be the third build of that 
upstream build.  An actual release will look like 19.2.0-0~bpo0-1 and will 
be considered greater than the Chrome OS pre-release.
