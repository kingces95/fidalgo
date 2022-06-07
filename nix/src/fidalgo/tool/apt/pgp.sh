alias fd-tool-apt-pgp-lookup="nix::tool::apt::pgp::lookup"
alias fd-tool-apt-pgp-install="nix::tool::apt::pgp::install"
alias fd-tool-apt-pgp-uninstall="nix::tool::apt::pgp::uninstall"

nix::tool::apt::pgp::lookup() {
    local NAME="$1"
    shift

    nix::tool::lookup "${NAME}" "${NIX_TOOL_APT_FIELD_PGP}"
}

nix::tool::apt::pgp::install() {
    local NAME="$1"
    shift

    local PGP="$(nix::tool::apt::pgp::lookup "${NAME}")"
    if [[ ! "${PGP}" ]]; then
        return 1
    fi

    nix::pgp::cat "${PGP}" \
        | nix::apt::pgp::install "${PGP}"
}

nix::tool::apt::pgp::uninstall() {
    local NAME="$1"
    shift

    local PGP="$(nix::tool::apt::pgp::lookup "${NAME}")"
    if [[ ! "${PGP}" ]]; then
        return 1
    fi

    nix::apt::pgp::uninstall "${PGP}"
}
