alias fd-tool-apt-repo-list="nix::tool::apt::repository::list"
alias fd-tool-apt-repo-lookup="nix::tool::apt::repository::lookup"
alias fd-tool-apt-repo-install="nix::tool::apt::repository::install"
alias fd-tool-apt-repo-uninstall="nix::tool::apt::repository::uninstall"

nix::tool::apt::repository::list() {
    find "${NIX_DIR_NIX_OS_APT_SOURCES}" \
        -name "*.list" \
        -type f \
        | pump nix::path::file::name
}

nix::tool::apt::repository::lookup() {
    local NAME="$1"
    shift

    nix::tool::lookup "${NAME}" "${NIX_TOOL_APT_FIELD_REPOSITORY}"
}

nix::tool::apt::repository::cat() {
    local NAME="$1"
    shift

    cat "${NIX_DIR_NIX_OS_APT_SOURCES}/${NAME}.list"
}

nix::tool::apt::repository::install() {
    local NAME="$1"
    shift

    local REPOSITORY="$(nix::tool::apt::repository::lookup "${NAME}")"
    if [[ ! "${REPOSITORY}" ]]; then
        return 1
    fi

    nix::tool::apt::repository::cat "${REPOSITORY}" \
        | nix::apt::repository::install "${REPOSITORY}"
}

nix::tool::apt::repository::uninstall() {
    local NAME="$1"
    shift

    local REPOSITORY="$(nix::tool::apt::repository::lookup "${NAME}")"
    if [[ ! "${REPOSITORY}" ]]; then
        return 1
    fi

    nix::apt::repository::uninstall "${REPOSITORY}"
}
