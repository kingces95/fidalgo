alias fd-az-tenant-profile-path="nix::az::tenant::profile::path"

nix::az::tenant::profile::clear() {
    if [[ ! -d "${NIX_AZURE_PID_DIR}" ]]; then
        return
    fi

    rm -r "${NIX_AZURE_PID_DIR}"
}

nix::az::tenant::profile::set() {
    local UPN="$1"
    shift

    local TENANT="$1"
    shift

    export AZURE_CONFIG_DIR="$(nix::az::tenant::profile::dir "${UPN}" "${TENANT}")"
}

nix::az::tenant::profile::dir() {
    local UPN="$1"
    shift

    local TENANT="$1"
    shift

    echo "${NIX_AZURE_PID_DIR}/${TENANT}/${UPN}"
}

nix::az::tenant::profile::path() {
    echo "${AZURE_CONFIG_DIR}/${NIX_AZURE_PROFILE_FILE}"
}

nix::az::tenant::profile::skeleton() {
    local UPN="$1"
    shift

    local TENANT="$1"
    shift

    local CLOUD="$1"
    shift

    local SUBSCRIPTION="$1"
    shift

    local SUBSCRIPTION_NAME="${1-"[Anonymous]"}"
    shift

    local INSTALLATION="$1"
    shift

    cat <<-EOF
	{
	    "installationId": "${INSTALLATION}",
	    "subscriptions": [
	        {
	            "id": "${SUBSCRIPTION}",
	            "name": "${SUBSCRIPTION_NAME}",
	            "state": "Enabled",
	            "user": {
	                "name": "${UPN}",
	                "type": "user"
	            },
	            "isDefault": true,
	            "tenantId": "${TENANT}",
	            "environmentName": "${CLOUD}",
	            "homeTenantId": "${TENANT}",
	            "managedByTenants": []
	        }
	    ]
	}
	EOF
}

nix::az::tenant::profile::initialize() {
    local UPN="$1"
    shift

    local TENANT="$1"
    shift

    local CLOUD="$1"
    shift

    local SUBSCRIPTION="$1"
    shift

    local SUBSCRIPTION_NAME="$1"
    shift

    local PTH="$(nix::az::tenant::profile::path)"

    if [[ -s "${PTH}" ]]; then
        return
    fi

    # provoke creation of skeleton with installationId
    az account clear >/dev/null 2>&1

    local INSTALLATION=$(
        cat "${PTH}" \
            | jq .installationId -r
    )

    nix::az::tenant::profile::skeleton \
        "${UPN}" \
        "${TENANT}" \
        "${CLOUD}" \
        "${SUBSCRIPTION}" \
        "${SUBSCRIPTION_NAME}" \
        "${INSTALLATION}" \
        > "${PTH}"
}

nix::az::tenant::profile::share_tokens() {

    mkdir -p "${AZURE_CONFIG_DIR}"

    # create shared msal_token_cache.json
    if [[ ! -f "${NIX_AZURE_TOKEN_CACHE}" ]]; then
        touch "${NIX_AZURE_TOKEN_CACHE}"
    fi

    # only share if no tokens already cached
    if [[ -f "${AZURE_CONFIG_DIR}/${NIX_AZURE_TOKEN_CACHE_FILE}" ]]; then
        return
    fi

    # link to shared msal_token_cache.json
    ln -s "${NIX_AZURE_TOKEN_CACHE}" "${AZURE_CONFIG_DIR}"
}
