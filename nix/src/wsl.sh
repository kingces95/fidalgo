nix::wsl::conf::unregister() {
    nix::sudo::rm "${NIX_OS_WSL_CONF}" 
}

nix::wsl::conf::register() {
    nix::sudo::register "${NIX_WSL_CONF}" "${NIX_OS_WSL_CONF}"
}
