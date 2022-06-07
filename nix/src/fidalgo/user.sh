alias fd-user-list="nix::fidalgo::user::list"
alias fd-user-report="nix::fidalgo::user::report"
alias fd-user-create="nix::user::create"
alias fd-batch-users-list="nix::env::tenant::batch nix::fidalgo::user::list"
alias fd-batch-users-report="nix::env::tenant::batch nix::fidalgo::user::report | a3f | fit"

nix::user::create() {
    local SUFFIX="$1"
    shift

    local USER="${NIX_MY_ALIAS}"
    if [[ "${SUFFIX}" ]]; then
        USER="${USER}-${SUFFIX}"
    fi

    nix::az::ad::user::create \
        "${NIX_MY_DISPLAY_NAME}" \
        "${USER}" \
        "${NIX_FID_TENANT_HOST}" \
        "$(nix::secret::cat)" >/dev/null
}

nix::fidalgo::user::group::membership() {
    local UPN="$1"
    local ID=$(nix::az::ad::user::id "${UPN}")
    nix::az::ad::user::get_member_groups \
        "${ID}" \
        | sed 's/ /-/g'
}

nix::fidalgo::user::report() {
    nix::fidalgo::user::list \
        | pump nix::fidalgo::user::record
}

nix::fidalgo::user::record() {
    local UPN="$1"

    echo "${UPN}" "$(
        nix::fidalgo::user::group::membership "${UPN}" \
            | nix::line::join
    )"
}

nix::fidalgo::user::list() {
    local -a QUERY=(
        "startswith(userPrincipalName,'${NIX_MY_ALIAS}@')"
        "or"
        "startswith(userPrincipalName,'${NIX_MY_ALIAS}-')"
    )

    nix::az::ad::user::filter "${QUERY[*]}"
}
