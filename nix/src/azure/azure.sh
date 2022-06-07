alias az-enum-resource="nix::azure::resource::enum | nix::record::align 2"
alias az-who="nix::azure::who | a2f"

nix::az::account::get_access_token::check() {
    nix::az::account::get_access_token >/dev/null 2>&1
}

nix::azure::resource::enum() {
    nix::bash::elements NIX_AZURE_RESOURCE_ACTIVATION_ORDER \
        | nix::record::number
}

nix::azure::who() {
    if ! nix::az::account::get_access_token::check; then
        return
    fi

    echo "az user $(nix::az::signed_in_user::upn)"
    echo "az user-id $(nix::az::signed_in_user::id)"
    echo "az subscription $(nix::az::account::show::subscription::name)"
    echo "az subscription-id $(nix::az::account::show::subscription::id)"
    echo "az tenant-id $(nix::az::account::show::tenant::id)"
    echo "az cloud $(nix::az::cloud::which)"
}

nix::azure::id() {
    local SUBSCRIPTION=$1
    shift

    local RESOURCE_GROUP=$1
    shift

    local RESOURCE=$1
    shift

    local NAME=$1
    shift

    local PARENT=$1
    shift

    ID="/subscriptions/${SUBSCRIPTION}"
    ID+="/resourceGroups/${RESOURCE_GROUP}"
    if [[ ! "${PARENT}" ]]; then
        ID+="/providers/${NIX_AZURE_RESOURCE_PROVIDER[${RESOURCE}]}"
    else
        local PARENT_RESOURCE="${NIX_AZURE_RESOURCE_PARENT[${RESOURCE}]}"
        ID+="/providers/${NIX_AZURE_RESOURCE_PROVIDER[${PARENT_RESOURCE}]}"
        ID+="/${PARENT}/${NIX_AZURE_RESOURCE_PROVIDER[${RESOURCE}]}"
    fi
    ID+="/${NAME}"

    echo "${ID}"
}