# Not bash or zsh?
[ -n "$BASH_VERSION" -o -n "$ZSH_VERSION" ] || return 0

# DISPLAY already set?
[ -z "$DISPLAY" ] || return 0

# Not running under sommelier?
[ $(systemctl --user show-environment | grep ^SOMMELIER_VERSION=) ] || return 0

export $(systemctl --user show-environment | grep ^DISPLAY=)
export $(systemctl --user show-environment | grep ^XCURSOR_SIZE=)
