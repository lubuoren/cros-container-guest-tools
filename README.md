# cros-container-guest-tools

## Overview
These are the guest packages for setting up a container to integrate
with Chrome OS. This includes build scripts that are run in Google's
internal continuous integration service.

## Building
The guest packages can be built with Bazel.

```sh
bazel build //cros-debs:debs
```

## Releasing
`promote\_apt.sh MILESTONE` and `promote\_container.sh MILESTONE` in scripts
are used to promote containers from staging to live.
NOTE: Whatever is the latest in staging is what gets promoted to live so make
sure it's what was tested.
