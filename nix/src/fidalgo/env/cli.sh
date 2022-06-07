alias fd-cli-install="nix::env::cli::install"

nix::env::cli::install() {
    local -n VERSION="NIX_${NIX_ENV}_CLI_VERSION"
    nix::cli::install "${VERSION}"
}
