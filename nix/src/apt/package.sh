alias fd-apt-package-install="nix::apt::package::install"
alias fd-apt-package-uninstall="nix::apt::package::uninstall"
alias fd-apt-package-reinstall="nix::apt::package::reinstall"

nix::apt::package::reinstall() {
    nix::apt::package::uninstall "$@"
    nix::apt::package::install "$@"
}

nix::apt::package::install() {
    local PACKAGE="$1"
    shift

    local LOG=$(mktemp "${NIX_OS_DIR_TEMP}/XXX.log")
    local ERR=$(mktemp "${NIX_OS_DIR_TEMP}/XXX.err")

    nix::sudo::log::begin "apt: installing ${PACKAGE}"
    nix::apt::update
    nix::apt::sudo::install "${PACKAGE}" > "${LOG}" 2> "${ERR}"
    nix::sudo::log::end "(logs: ${LOG} ${ERR})"
}

nix::apt::package::uninstall() {
    local PACKAGE="$1"
    shift

    nix::sudo::log::begin "apt: uninstalling ${PACKAGE}"
    nix::apt::sudo::purge "${PACKAGE}"
    nix::sudo::log::end
}
