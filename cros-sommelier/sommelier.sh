# Not bash or zsh?
[ -n "$BASH_VERSION" -o -n "$ZSH_VERSION" ] || return 0

# Not running under sommelier?
[ $(systemctl --user show-environment | grep ^SOMMELIER_VERSION=) ] || return 0

# DISPLAY not set?
if [ -z "$DISPLAY" ]; then
  export $(systemctl --user show-environment | grep ^DISPLAY=) > /dev/null
fi

# DISPLAY_LOW_DENSITY not set?
if [ -z "$DISPLAY_LOW_DENSITY" ]; then
  export $(systemctl --user show-environment | \
      grep ^DISPLAY_LOW_DENSITY=) > /dev/null
fi

# XCURSOR_SIZE not set?
if [ -z "$XCURSOR_SIZE" ]; then
  export $(systemctl --user show-environment | grep ^XCURSOR_SIZE=) > /dev/null
fi

# XCURSOR_SIZE_LOW_DENSITY not set?
if [ -z "$XCURSOR_SIZE_LOW_DENSITY" ]; then
  export $(systemctl --user show-environment | \
      grep ^XCURSOR_SIZE_LOW_DENSITY=) > /dev/null
fi

# WAYLAND_DISPLAY not set?
if [ -z "$WAYLAND_DISPLAY" ]; then
  export $(systemctl --user show-environment | \
    grep ^WAYLAND_DISPLAY=) > /dev/null
fi

# WAYLAND_DISPLAY_LOW_DENSITY not set?
if [ -z "$WAYLAND_DISPLAY_LOW_DENSITY" ]; then
  export $(systemctl --user show-environment | \
      grep ^WAYLAND_DISPLAY_LOW_DENSITY=) > /dev/null
fi
