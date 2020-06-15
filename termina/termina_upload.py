#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# Copyright 2020 The Chromium OS Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.
"""Uploads termina to the correct gsutil buckets.

This script is designed to automate some of go/crostini-infra-playbook. It
should be run after termina_uprev.py.
"""

import argparse
import os
import subprocess
import tempfile


def upload_termina(termina_dir, milestone, build):
  """Uploads termina images to omaha/testing buckets.

  After running termina_uprev.py you can run this script to put the new images
  in the right gs buckets.

  Args:
    termina_dir: Directory where termina_uprev.py stored the images.
    milestone: Chrome milestone for this build.
    build: CrOS build which created these termina images.

  Raises:
    Exception: if termina_dir is not a directory.
  """
  if not os.path.isdir(termina_dir):
    raise Exception("Can not locate termina directory: " + termina_dir)

  omaha_url = "gs://chrome-component-termina/{}".format(build)
  testing_url = "gs://termina-component-testing/{}".format(milestone)

  for image, arch in [("tatl", "intel64"), ("tael", "arm32"),
                      ("tael", "arm64")]:
    local_copy = os.path.join(termina_dir, image, "files.zip")
    remote_copy = "{}/chromeos_{}-archive/".format(omaha_url, arch)
    subprocess.check_call(
        ["gsutil.py", "--", "cp", "-a", "public-read", local_copy, remote_copy])

  subprocess.check_call(["gsutil.py", "--", "cp", "-r", omaha_url, testing_url])

  with tempfile.NamedTemporaryFile(mode="w", delete=False) as tmp:
    tmp.write("{}\n".format(build))
    staging_file = tmp.name
  subprocess.check_call(
      ["gsutil.py", "--", "cp", staging_file, "{}/staging".format(testing_url)])
  # Not removing staging_file in case the user wants to check it.


def main():
  parser = argparse.ArgumentParser(description=__doc__)
  parser.add_argument(
      "--milestone", required=True, help="milestone number, e.g. 78")
  parser.add_argument(
      "--build", required=True, help="build number, e.g. 11396.0.0")
  parser.add_argument(
      "--dir",
      default="./uprev",
      help="directory where termina_uprev.py stored its results")
  args = parser.parse_args()

  upload_termina(args.dir, args.milestone, args.build)


if __name__ == "__main__":
  main()
