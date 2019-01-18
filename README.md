# cros-container-guest-tools

## Overview
These are the guest packages for setting up a container to integrate
with Chrome OS. This includes build scripts that are run in Google's
internal continuous integration service.

## Building
The guest packages can be built with Bazel. The CrOS milestone to target and
release name (stretch, buster, etc.) are required.

```sh
bazel build //... --action_env="MILESTONE=74" --action_env="RELEASE=buster"
```
