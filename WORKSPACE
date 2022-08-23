# Copyright 2021 The Chromium OS Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

# This is the first commit that formats Description properly:
# "Properly format the deb Description field, fix format of changes file."
# This should be replaced by a stable release when one is available. Check
# https://github.com/bazelbuild/rules_pkg/releases for newer versions and
# instructions on how to update.
RULES_PKG_COMMIT = "7f7bcf9c93bed9ee693b5bfedde5d72f9a2d6ea4"

http_archive(
    name = "rules_pkg",
    sha256 = "5909da90955dbb0eb434724f951f1f947a1794c5f33e345175a0193972aac14d",
    strip_prefix = "rules_pkg-{}".format(RULES_PKG_COMMIT),
    urls = [
        "https://github.com/bazelbuild/rules_pkg/archive/{}.tar.gz".format(RULES_PKG_COMMIT),
    ],
)

load("@rules_pkg//:deps.bzl", "rules_pkg_dependencies")

rules_pkg_dependencies()
