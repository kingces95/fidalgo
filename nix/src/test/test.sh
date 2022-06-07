alias fd-test-build="nix::test::build"

nix::test::build() {
    local PTH="$1"
    shift

    local FILE_NAME=$(nix::path::file::name "${PTH}")
    local DESTINATION="${NIX_DIR_NIX_TST_SH}/${FILE_NAME}.sh"

    nix::test::pipeline::main "${PTH}" \
        > "${DESTINATION}"
}
