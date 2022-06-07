alias az-cloud-list-default="nix::az::cloud::list::default | sort"
alias az-cloud-list-custom="nix::az::cloud::list::custom | sort"
alias az-cloud-clean="nix::az::cloud::clean"
alias az-cloud-is-registered="nix::az::cloud::is_registered"

nix::az::cloud::list::default() {
    nix::bash::elements NIX_AZURE_CLOUD_BUILTIN
}

nix::az::cloud::list::custom() {
    nix::az::cloud::list \
        | sort \
        | nix::line::except <(
            nix::az::cloud::list::default \
            | sort
        )
}

nix::az::cloud::clean() {
    nix::az::cloud::list::custom \
        | pump nix::az::cloud::unregister
}

nix::az::cloud::is_registered() {
    local CLOUD=$1
    nix::az::cloud::list \
        | grep "${CLOUD}" >/dev/null 2>&1
}

nix::az::cloud::register_and_set() {
    local NAME="$1"
    shift

    local -n ENDPOINTS="$1"
    shift

    if ! nix::az::cloud::is_registered "${NAME}"; then
        local NIX_AZ_NAME="${NAME}"
        local NIX_AZ_TENANT_ENDPOINT_AD="${ENDPOINTS['endpoint-active-directory']}"
        local NIX_AZ_TENANT_ENDPOINT_AD_GRAPH_RESOURCE_ID="${ENDPOINTS['endpoint-active-directory-graph-resource-id']}"
        local NIX_AZ_TENANT_ENDPOINT_AD_RESOURCE_ID="${ENDPOINTS['endpoint-active-directory-resource-id']}"
        local NIX_AZ_TENANT_ENDPOINT_AD_DATA_LAKE_RESOURCE_ID="${ENDPOINTS['endpoint-active-directory-data-lake-resource-id']}"
        local NIX_AZ_TENANT_ENDPOINT_GALLERY="${ENDPOINTS['endpoint-gallery']}"
        local NIX_AZ_TENANT_ENDPOINT_RESOURCE_MANAGER="${ENDPOINTS['endpoint-resource-manager']}"
        local NIX_AZ_TENANT_ENDPOINT_MANAGEMENT="${ENDPOINTS['endpoint-management']}"
        local NIX_AZ_TENANT_ENDPOINT_SQL_MANAGEMENT="${ENDPOINTS['endpoint-sql-management']}"
        local NIX_AZ_TENANT_ENDPOINT_VM_IMAGE_ALIAS_DOC="${ENDPOINTS['endpoint-vm-image-alias-doc']}"

        nix::az::cloud::register
    fi

    nix::az::cloud::set "${NAME}"
}
