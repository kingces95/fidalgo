nix::gpg::path() {
    nix::bash::args "${NIX_DIR_NIX_PUB}"/*
}

nix::gpg::dearmor() {
    local ARMORED_KEY="$1"
    gpg --dearmor -o ARMORED_KEY
}

nix::apt::sudo::() {
    sudo apt-get install -y gpg

    wget -O - https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor -o microsoft.asc.gpg
    sudo mv microsoft.asc.gpg /etc/apt/trusted.gpg.d/
    wget https://packages.microsoft.com/config/ubuntu/{os-version}/prod.list
    sudo mv prod.list /etc/apt/sources.list.d/microsoft-prod.list
    sudo chown root:root /etc/apt/trusted.gpg.d/microsoft.asc.gpg
    sudo chown root:root /etc/apt/sources.list.d/microsoft-prod.list
}
