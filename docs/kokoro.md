# Kokoro presubmit testing, signing, and releasing

[TOC]

[Kokoro] is a Google-internal continuous integration service, and is used
extensively for building, signing, testing, and releasing container images
and guest packages.

## crostini-guest flow

Kokoro configs are split into two pieces: jobs and builds. The jobs are held in
[crostini-guest], and the build configs are in the [container-guest-tools]
repository under `kokoro`. Build configs are reused across different jobs, e.g.
the `apt_repo` build is used in both the `continuous` and `presubmit` job flows.
However, the `presubmit` job flow bypasses the `apt_signer` build, and does not
publish artifacts to Google Storage buckets.

![Kokoro guest flow](images/kokoro_guest_flow.png "Kokoro guest flow")

## Branches (continuous jobs)

Both the [Termina] VM and [container-guest-tools] .deb packages are branched to
match Chrome OS milestones. So for the above `continuous` flow, there are job
instances for each active (stable, beta, dev, canary) branch. See the detailed
configs in [crostini-guest]. As an example, with 71 on stable and 74 in canary:

| Kokoro job                                      | Milestone | Chrome OS Branch      |
|-------------------------------------------------|-----------|-----------------------|
| `cros-containers/crostini-guest/71/guest_tools` | 71        | `release-R71-11151.B` |
| `cros-containers/crostini-guest/72/guest_tools` | 72        | `release-R72-11316.B` |
| `cros-containers/crostini-guest/73/guest_tools` | 73        | `release-R73-11647.B` |
| `cros-containers/crostini-guest/74/guest_tools` | 74        | `master`              |

The artifacts for each branch will be pushed to a subdirectory on the target
Google Storage bucket. Prebuilt containers are pushed to
`gs://cros-containers-staging/milestone`, and apt repos are pushed to
`gs://cros-packages-staging/milestone`.

### Future improvements

Push from staging to the live buckets `gs://cros-containers` and
`gs://cros-packages` based on the [Tast] test results.

## Presubmit jobs

The `presubmit` flow only runs on the `master` branch. Note that there are both
a `presubmit` and `presubmit-cr` jobs - the former runs for `Trybot-Ready +1`,
and the latter on `Code-Review +2` on Gerrit.

## Tests

Some tests are run directly in Kokoro by verifying that the guest container
starts up as expected. These tests are in [lxd/test.py](../lxd/test.py).

Testing in a live environment on a DUT is done with [Tast]. Most of those tests,
including the performance tests and `vm.CrostiniStartEverything`, run using
the staging version of the container. A staging version of the VM is also used,
which is stored in `gs://termina-component-testing`. When [Stainless] shows
green test results, the Termina VM, staging container image, and staging
apt packages can be rolled out to the production buckets.

### Future improvements
* Separate [Tast] tests into `bvt-cq` (production container and VM) and `pfq`
  (staging container and VM).
* Build VMs on Kokoro and push them to the testing bucket automatically. These
  are currently pushed manually.
* Release VMs automatically based on Tast test results, instead of using the
  [release dashboard].

[crostini-guest]: https://goto.google.com/crostini-guest-kokoro
[container-guest-tools]: https://chromium.googlesource.com/chromiumos/containers/cros-container-guest-tools/
[Kokoro]: https://goto.google.com/kokoro
[release dashboard]: https://goto.google.com/omaharelease
[Stainless]: https://goto.google.com/stainless
[Tast]: https://chromium.googlesource.com/chromiumos/platform/tast-tests/+/master/src/chromiumos/tast/local/bundles/cros/vm/
[Termina]: https://chromium.googlesource.com/chromiumos/overlays/board-overlays/+/24a9d16fc15c3d07d726f3f974a541572d3584e5/project-termina/

## Mesa

New versions of [Mesa] for use within the container are built from upstream.

[Mesa]: https://chromium.googlesource.com/chromiumos/containers/cros-container-guest-tools/+/refs/heads/master/mesa/
