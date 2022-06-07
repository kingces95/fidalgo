alias fd-cli-versions="nix::cli::versions"
alias fd-cli-uninstall="nix::cli::uninstall"
alias fd-cli-install-latest="nix::cli::install ${NIX_CLI_VERSION}"
alias fd-cli-install-previous="nix::cli::install ${NIX_CLI_VERSION[1]}"
alias fd-cli-which="nix::cli::which"
alias fd-cli-test="nix::cli::test"
alias fd-cli-www="nix::shell::browser::open ${NIX_CLI_WWW}"

nix::cli::versions() {
    nix::bash::elements NIX_CLI_VERSION
}

nix::cli::install() {
    local VERSION="${1-${NIX_CLI_VERSION}}"
    shift

    if nix::cli::test "${VERSION}"; then
        return
    fi

    nix::cli::uninstall

    local FILE="fidalgo-${VERSION}-py3-none-any.whl"
    nix::tty::log::install::begin "az: installing ${FILE}"
    nix::az::extension::curl "${NIX_CLI_CURL}/${FILE}"
    nix::tty::log::install::end
}

nix::cli::uninstall() {
    nix::az::extension::uninstall 'fidalgo'
}

nix::cli::which() {
    nix::az::extension::which 'fidalgo'
}

nix::cli::test() {
    local VERSION="${1-${NIX_CLI_VERSION}}"
    
    nix::az::extension::is_installed \
        'fidalgo' \
        "${VERSION}"
}
