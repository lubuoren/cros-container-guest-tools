# Copyright 2019 The ChromiumOS Authors
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.
"""This module provides the copy_debs_to_folder rule."""

def _is_wanted_file(f):
    """We only want real debs, exclude the *.changes and deb.deb symlinks."""
    return f.basename.endswith(".deb") and "_" in f.basename

def _quote(s):
    """Quotes a string per bash quoting rules."""
    return "'" + s.replace("'", "'\\''") + "'"

def _copy_debs_to_folder_impl(ctx):
    """Copies only 'real' *.deb files into the specified folder."""
    out_dir = ctx.attr.out_dir

    source_files = [f for f in ctx.files.srcs if _is_wanted_file(f)]
    dest_files = [ctx.actions.declare_file(out_dir + "/" + f.basename) for f in source_files]
    dest_dir = dest_files[0].dirname

    command = "mkdir -p %s; cp %s %s" % (dest_dir, " ".join([_quote(f.path) for f in source_files]), dest_dir)
    ctx.actions.run_shell(
        inputs = source_files,
        outputs = dest_files,
        progress_message = "Running " + command,
        command = command,
    )

    return [DefaultInfo(files = depset(dest_files))]

copy_debs_to_folder = rule(
    implementation = _copy_debs_to_folder_impl,
    attrs = {
        "srcs": attr.label_list(
            mandatory = True,
            allow_files = True,
        ),
        "out_dir": attr.string(mandatory = True),
    },
)
