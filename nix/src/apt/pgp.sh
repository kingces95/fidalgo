alias fd-apt-pgp-install="nix::apt::pgp::install"
alias fd-apt-pgp-uninstall="nix::apt::pgp::uninstall"
alias fd-apt-pgp-list="nix::apt::pgp::list"

nix::apt::pgp::list() {
    nix::apt::fs::pgp::list \
        | pump nix::path::file::name
}

nix::apt::pgp::uninstall() {
    local NAME="$1"  # e.g. microsoft
    shift

    nix::sudo::rm "$(nix::apt::fs::pgp::path ${NAME})"
}

nix::apt::pgp::install() {
    local NAME="$1"  # e.g. microsoft
    shift

    local TEMP="$(mktemp)"

    # pgp -> gpg
    gpg --dearmor \
        > "${TEMP}"

    nix::sudo::register "${TEMP}" "$(nix::apt::fs::pgp::path ${NAME})"
    nix::fs::file::remove "${TEMP}"
}
