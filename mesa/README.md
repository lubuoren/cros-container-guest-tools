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
sudo docker build --tag=buildmesa .
```

The packages are built with `gbp-buildpackage` within a chroot of the Docker
container.  The chroots for each architecture can be pre-generated and
cached with:
```sh
name=bm$(date +%s)
sudo docker run --privileged --name=$name -it buildmesa ./setupchroot.sh
sudo docker commit $name buildmesa:setup
```

To export the Docker image with cached chroot to use within the continuous
build system:
```sh
sudo docker save buildmesa:setup | xz -T 0 -z > buildmesa.tar.xz
```

To export the base Docker image to use within the continuous build system:
```sh
sudo docker save buildmesa:latest | xz -T 0 -z > buildmesa.tar.xz
```

## Building packages
To build the packages using the image with cached chroot with artifacts
written to `$PWD/artifacts`:
```sh
sudo docker run \
    --privileged \
    --volume=$PWD/artifacts:/artifacts \
    -it buildmesa:setup ./sync-and-build.sh
```

To build the packages using the base image with artifacts written to
`$PWD/artifacts`:
```sh
sudo docker run \
    --privileged \
    --volume=$PWD/artifacts:/artifacts \
    -it buildmesa
```

To import the tarball Docker image on another machine:
```sh
sudo docker load -i buildmesa.tar.xz
```

### Building packages from untested changes
To test new mesa changes, prepare a local branch based off of
`debian-stretch-19.1`:
```sh
git remote add upstream git://anongit.freedesktop.org/mesa/mesa
git remote update upstream
git checkout -b debian-stretch-19.1 cros/debian-stretch-19.1
git merge upstream/master
debchange -i
git add debian/changelog
git commit
```

Upload a sandbox branch to test with Docker and start a container.
```sh
git push cros HEAD:refs/sandbox/"${USER}"/debian-stretch-test
sudo docker run \
    --privileged \
    --volume=$PWD/artifacts:/artifacts \
    -it buildmesa:latest \
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

The Debian packages will be available in `$PWD/artifacts` to test.

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
`/x20/teams/chromeos-vm/docker/buildmesa.tar.xz`:
```sh
prodaccess
cp buildmesa.tar.xz /google/data/rw/teams/chromeos-vm/docker
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
