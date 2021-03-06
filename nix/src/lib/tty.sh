nix::tty::printf() {
    local FORMAT="$1"
    shift

    printf \
        "$(nix::color::cyan "${FORMAT}")" \
        "$@"
}

nix::tty::prompt::begin() {
    printf "$(nix::color::begin::yellow)"
}

nix::tty::prompt::end() {
    printf "$(nix::color::end)"
}

nix::tty::echo() {
    nix::tty::printf '%s\n' "$*"
}

nix::tty::color_reset() {
    echo -e -n "\033[0m"
}

nix::tty::log::install::begin() {
    nix::tty::printf "$* " >&2
}

nix::tty::log::install::end() {
    nix::tty::echo "$@" >&2
}

nix::tty::context() {
    echo -e -n $(nix::color::begin::cyan)
    trap nix::tty::color_reset EXIT
}
