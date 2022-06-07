alias fd-tool-cat="nix::tool::cat"
alias fd-tool-list="nix::tool::list"
alias fd-tool-type="nix::tool::type"
alias fd-tool-install="nix::tool::install"
alias fd-tool-uninstall="nix::tool::uninstall"
alias fd-tool-reinstall="nix::tool::reinstall"
alias fd-tool-install-all="nix::tool::install::all"
alias fd-tool-uninstall-all="nix::tool::uninstall::all"
alias fd-tool-reinstall-all="nix::tool::reinstall::all"
alias fd-tool-scorch="nix::tool::scorch"

nix::tool::cat() {
    cat "${NIX_OS_APT_TOOLS}"
}

nix::tool::list() {
    local TYPE="${1-.*}"
    shift

    nix::tool::cat \
        | nix::record::filter::regex 3 "^${TYPE}\$" 2 \
        | nix::record::project 2 1
}

nix::tool::lookup() {
    local NAME="$1"
    shift

    local COLUMN="$1"
    shift

    nix::tool::cat \
        | nix::record::vlookup \
            "${NAME}" \
            "${COLUMN}"
}

nix::tool::type() {
    local NAME="$1"
    shift

    nix::tool::lookup "${NAME}" 2
}

nix::tool::test() {
    local NAME="$1"
    shift

    local TYPE="$1"
    shift

    local REGEX="^${NAME}\$"
    nix::tool::list "${TYPE}" \
        | grep ${REGEX} >/dev/null
}

nix::tool::reinstall() {
    nix::tool::apt::reinstall
}

nix::tool::install() {
    while (( $# > 0 )); do
        local NAME="$1"
        shift

        local TYPE="$(nix::tool::type "${NAME}")"
        case "${TYPE}" in
            'apt') nix::tool::apt::install "${NAME}" ;;
            'nuget') nix::tool::nuget::install "${NAME}" ;;
        esac
    done
}

nix::tool::uninstall() {
    while (( $# > 0 )); do
        local NAME="$1"
        shift

        local TYPE="$(nix::tool::type "${NAME}")"
        case "${TYPE}" in
            'apt') nix::tool::apt::uninstall "${NAME}" ;;
            'nuget') nix::tool::nuget::uninstall "${NAME}" ;;
        esac
    done
}

nix::tool::reinstall::all() {
    nix::tool::list \
        | pump nix::tool::reinstall
}


nix::tool::install::all() {
    nix::tool::list \
        | pump nix::tool::install
}

nix::tool::uninstall::all() {
    nix::tool::list \
        | pump nix::tool::uninstall
    nix::tool::apt::clean
}

nix::tool::scorch() {
    nix::tool::uninstall::all
    nix::tool::apt::scorch
    nix::tool::nuget::scorch
    nix::sudo::logout
}

nix::tool::version() {
    read < <("$@")
    [[ "${REPLY}" =~ ([[:digit:].]+) ]]
    echo "${BASH_REMATCH[1]}"
}

nix::tool::apt::package::report() {
    echo 'jq' "$(nix::tool::apt::package::version jq --help)"
    echo 'nuget' "$(nix::tool::apt::package::version nuget help)"
    echo 'gpg' "$(nix::tool::apt::package::version gpg --help)"
}
