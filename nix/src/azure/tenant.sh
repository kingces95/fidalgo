# todo: democratize from fidalgo
nix::az::tenant::public::eval() (
    local UPN="${NIX_UPN_MICROSOFT}"
    local TENANT="${NIX_PUBLIC_TENANT}"
    local CLOUD="${NIX_AZURE_CLOUD_DEFAULT}"
    local CLOUD_ENDPOINTS="NIX_PUBLIC_CLOUD_ENDPOINTS"
    local SUBSCRIPTION="${NIX_PUBLIC_SUBSCRIPTION}"
    local SUBSCRIPTION="${NIX_PUBLIC_SUBSCRIPTION_NAME}"

    nix::az::tenant::login \
        "${UPN}" \
        "${TENANT}" \
        "${CLOUD}" \
        "${CLOUD_ENDPOINTS}" \
        "${SUBSCRIPTION}" \
        "${SUBSCRIPTION_NAME}"

    # execute as me in public (e.g. kusto)
    "$@"
)

nix::az::tenant::login() {
    local UPN="$1"
    shift

    local TENANT="$1"
    shift

    local CLOUD="$1"
    shift

    local CLOUD_ENDPOINTS="$1"
    shift

    local SUBSCRIPTION="$1"
    shift

    local SUBSCRIPTION_NAME="$1"
    shift

    nix::az::tenant::profile::set "${UPN}" "${TENANT}"

    nix::az::tenant::profile::initialize \
        "${UPN}" \
        "${TENANT}" \
        "${CLOUD}" \
        "${SUBSCRIPTION}" \
        "${SUBSCRIPTION_NAME}"

    nix::az::tenant::profile::share_tokens

    nix::az::cloud::register_and_set "${CLOUD}" "${CLOUD_ENDPOINTS}"

    if nix::az::account::get_access_token::check; then
        return
    fi

    if [[ "${UPN}" =~ @microsoft[.]com$ ]]; then
        nix::az::login::with_device_code "${TENANT}" >/dev/null
    else
        local SECRET="$(nix::secret::get)"

        if ! nix::az::login::with_secret \
            "${UPN}" \
            "${SECRET}" \
            "${TENANT}" \
            >/dev/null; then

            nix::secret::rm
        else
            nix::secret::set "${SECRET}"
        fi

    fi || return

    nix::az::account::set "${SUBSCRIPTION}"
}
