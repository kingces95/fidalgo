alias fd-tool-apt-package-lookup="nix::tool::apt::package::lookup"
alias fd-tool-apt-package-install="nix::tool::apt::package::install"
alias fd-tool-apt-package-uninstall="nix::tool::apt::package::uninstall"

nix::tool::apt::package::lookup() {
    local NAME="$1"
    shift

    nix::tool::lookup "${NAME}" "${NIX_TOOL_APT_FIELD_PACKAGE}"
}

nix::tool::apt::package::install() {
    local NAME="$1"
    shift

    if nix::which::test "${NAME}"; then
        return
    fi

    local PACKAGE="$(nix::tool::apt::package::lookup "${NAME}")"
    if [[ ! "${PACKAGE}" ]]; then
        return 1
    fi

    nix::apt::package::install "${PACKAGE}"
}

nix::tool::apt::package::uninstall() {
    local NAME="$1"
    shift

    if ! nix::which::test "${NAME}"; then
        return
    fi

    local PACKAGE="$(nix::tool::apt::package::lookup "${NAME}")"
    if [[ ! "${PACKAGE}" ]]; then
        return 1
    fi

    nix::apt::package::uninstall "${PACKAGE}"
}
