alias fd-sudo="nix::sudo"
alias fd-sudo-test="nix::sudo::test"
alias fd-sudo-login="nix::sudo::login"
alias fd-sudo-logout="nix::sudo::logout"

nix::sudo() (
    nix::tty::prompt::begin >/dev/tty
    sudo -p "nix: [sudo] password for %p: " "$@"
    nix::tty::prompt::end >/dev/tty
)

nix::sudo::test() {
    [[ "$EUID" = 0 ]] || sudo -n true 2>/dev/null
}

nix::sudo::logout() {
    sudo -k
}

nix::sudo::login() {
    nix::sudo true
}

nix::sudo::log::begin() {
    nix::tty::log::begin "$@"

    # prompt for password on a new line
    declare -g NIX_SUDO_LOG_END_REPLY=$'\n'
    if ! nix::sudo::test; then
        nix::sudo::log::end
        nix::sudo::login
    fi
}

nix::sudo::log::end() {
    echo -n "${NIX_SUDO_LOG_END_REPLY}" >&2
    unset NIX_SUDO_LOG_END_REPLY
}

nix::sudo::gpg::dearmor() {
    nix::apt::sudo::install 'gpg'
    nix::gpg::dearmor 
}

nix::sudo::chown::root() {
    local PTH="$1"
    shift

    nix::sudo chown root:root "${PTH}"
}

nix::sudo::chmod::readable() {
    local PTH="$1"
    shift

    nix::sudo chmod +r "${PTH}"
}


nix::sudo::rm() {
    local TARGET="$1"
    shift

    nix::sudo rm "${TARGET}"
}

nix::sudo::mv() {
    local SOURCE="$1"
    shift

    local DESTINATION="$1"
    shift

    nix::sudo mv "${SOURCE}" "${DESTINATION}"
}

nix::sudo::cp() {
    local SOURCE="$1"
    shift

    local DESTINATION="$1"
    shift

    nix::sudo cp "${SOURCE}" "${DESTINATION}"
}

nix::sudo::write() {
    local PTH="$1"
    shift

    nix::sudo tee "${PTH}" >/dev/null
    nix::sudo::chmod::readable "${PTH}"
}

nix::sudo::touch() {
    local PTH="$1"
    shift

    nix::sudo touch "${PTH}"
    nix::sudo::chmod::readable "${PTH}"
}

nix::sudo::register() {
    local SOURCE="$1"
    shift

    local DESTINATION="$1"
    shift

    nix::sudo::cp "${SOURCE}" "${DESTINATION}"
    nix::sudo::chown::root "${DESTINATION}"
    nix::sudo::chmod::readable "${DESTINATION}"
}
