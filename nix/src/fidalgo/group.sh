alias fd-group-x2fa-list="nix::az::ad::group::member::list '${NIX_FIDGALGO_AD_GROUP_X2FA}'"
alias fd-group-x2fa-add="nix::fidalgo::ad::group::upn::add '${NIX_FIDGALGO_AD_GROUP_X2FA}'"
alias fd-group-x2fa-remove="nix::fidalgo::ad::group::upn::remove '${NIX_FIDGALGO_AD_GROUP_X2FA}'"
alias fd-group-x2fa-check="nix::fidalgo::ad::group::upn::check '${NIX_FIDGALGO_AD_GROUP_X2FA}'"

alias fd-group-admin-list="nix::az::ad::group::member::list '${NIX_FIDGALGO_AD_GROUP_ADMINS}'"
alias fd-group-admin-add="nix::fidalgo::ad::group::upn::add '${NIX_FIDGALGO_AD_GROUP_ADMINS}'"
alias fd-group-admin-remove="nix::fidalgo::ad::group::upn::remove '${NIX_FIDGALGO_AD_GROUP_ADMINS}'"
alias fd-group-admin-check="nix::fidalgo::ad::group::upn::check '${NIX_FIDGALGO_AD_GROUP_ADMINS}'"

nix::fidalgo::ad::group::to_display_name() {
    local GROUP="$1"        # MFA-Excluded-Users
    echo "${GROUP//-/ }"    # MFA Excluded Users
}
nix::fidalgo::ad::group::from_display_name() {
    local GROUP="$1"        # MFA Excluded Users
    echo "${GROUP// /-}"    # MFA-Excluded-Users
}

nix::fidalgo::ad::group::upn::check() {
    local GROUP="${1//-/ }"
    shift

    local MEMBER="$1"
    shift

    local MEMBER_ID="$(nix::az::ad::user::id "${MEMBER}")"
    if ! $(nix::az::ad::group::member::check "${GROUP}" "${MEMBER_ID}"); then
        return 1
    fi
}

nix::fidalgo::ad::group::upn::add() {
    local GROUP="${1//-/ }"
    shift

    local MEMBER="$1"
    shift

    if nix::fidalgo::ad::group::upn::check "${GROUP}" "${MEMBER}"; then
        return
    fi

    local MEMBER_ID="$(nix::az::ad::user::id "${MEMBER}")"
    nix::az::ad::group::member::add "${GROUP}" "${MEMBER_ID}"
}

nix::fidalgo::ad::group::upn::remove() {
    local GROUP="${1//-/ }"
    shift

    local MEMBER="$1"
    shift

    if ! nix::fidalgo::ad::group::upn::check "${GROUP}" "${MEMBER}"; then
        return
    fi

    local MEMBER_ID="$(nix::az::ad::user::id "${MEMBER}")"
    nix::az::ad::group::member::remove "${GROUP}" "${MEMBER_ID}"
}
