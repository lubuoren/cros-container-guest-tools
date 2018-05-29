# Not bash or zsh?
[ -n "$BASH_VERSION" -o -n "$ZSH_VERSION" ] || return 0

# Not running under sommelier?
[ $(systemctl --user show-environment | grep ^SOMMELIER_VERSION=) ] || return 0

# DISPLAY not set?
if [ -n "$DISPLAY" ]; then
  export $(systemctl --user show-environment | grep ^DISPLAY=)
fi

# XCURSOR_SIZE not set?
if [ -n "$XCURSOR_SIZE" ]; then
  export $(systemctl --user show-environment | grep ^XCURSOR_SIZE=)
fi

# WAYLAND_DISPLAY not set?
if [ -n "$WAYLAND_DISPLAY" ]; then
  export $(systemctl --user show-environment | grep ^WAYLAND_DISPLAY=)
fi
