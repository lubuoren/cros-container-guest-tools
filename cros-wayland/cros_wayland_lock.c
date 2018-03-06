// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#include <sys/file.h>
#include <sys/stat.h>
#include <sys/types.h>

#include <limits.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

int main(int argc, char **argv) {
  char* runtime_dir = getenv("XDG_RUNTIME_DIR");
  char lockfile[128];

  if (!runtime_dir) {
    fprintf(stderr, "no runtime dir, oh noes\n");
    return 1;
  }

  int ret = snprintf(lockfile,
                     sizeof(lockfile),
                     "%s/wayland-0.lock",
                     runtime_dir);

  if (ret < 0) {
    fprintf(stderr, "failed to create path to lockfile\n");
    return 1;
  }

  int fd = creat(lockfile, S_IRWXU);

  if (fd < 0) {
    fprintf(stderr, "failed to create lockfile\n");
    return 1;
  }

  ret = flock(fd, LOCK_EX | LOCK_NB);
  if (ret < 0) {
    fprintf(stderr, "failed to get exclusive lock\n");
    return 1;
  }

  while (true) {
    sleep(UINT_MAX);
  }

  return 1;
}
