alias fd-ssh-dir="nix::ssh::dir"
alias fd-ssh-ls="nix::ssh::ls"

nix::ssh::dir() {
    echo "${NIX_HOME_DIR_SSH}"
}

nix::ssh::ls() {
    ll "$(nix::ssh::dir)"
}
