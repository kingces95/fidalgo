alias fd-tool-apt-list="nix::tool::apt::list"
alias fd-tool-apt-install="nix::tool::apt::package::install"
alias fd-tool-apt-uninstall="nix::tool::apt::package::uninstall"
alias fd-tool-apt-scorch="nix::tool::apt::scorch"

nix::tool::apt::list() {
    nix::tool::list 'apt'
}

nix::tool::apt::reinstall() {
    nix::tool::apt::uninstall "$@"
    nix::tool::apt::install "$@"
}

nix::tool::apt::install() {
    local NAME="$1"
    shift

    nix::tool::apt::pgp::install "${NAME}"
    nix::tool::apt::repository::install "${NAME}"
    nix::tool::apt::package::install "${NAME}"
}

nix::tool::apt::uninstall() {
    local NAME="$1"
    shift

    nix::tool::apt::package::uninstall "${NAME}"
}

nix::tool::apt::scorch() {
    nix::sudo::login

    nix::tool::apt::list \
        | pump nix::tool::apt::repository::uninstall \
        > /dev/null 2>/dev/null

    nix::tool::apt::list \
        | pump nix::tool::apt::pgp::uninstall \
        > /dev/null 2>/dev/null

    nix::tool::apt::clean
}

nix::tool::apt::clean() {
    nix::apt::sudo::clean
}