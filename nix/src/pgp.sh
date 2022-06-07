alias fd-pgp-list="nix::pgp::list"

nix::pgp::list() {
    find "${NIX_DIR_NIX_PGP}" \
        -name "*.pgp" \
        -type f \
        | pump nix::path::file::name
}

nix::pgp::cat() {
    local NAME="$1"
    shift

    cat "${NIX_DIR_NIX_PGP}/${NAME}.pgp"
}
