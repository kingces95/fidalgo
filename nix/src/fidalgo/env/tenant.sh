alias fd-switch-to-public="nix::env::tenant::switch ${NIX_PUBLIC_NAME}"
alias fd-switch-to-dogfood="nix::env::tenant::switch ${NIX_DOGFOOD_NAME}"
alias fd-switch-to-dogfood-int="nix::env::tenant::switch ${NIX_DOGFOOD_INT_NAME}"
alias fd-switch-to-selfhost="nix::env::tenant::switch ${NIX_SELFHOST_NAME}"
alias fd-switch-to-int="nix::env::tenant::switch ${NIX_INT_NAME}"
alias fd-switch-to-ppe="nix::env::tenant::switch ${NIX_PPE_NAME}"

alias fd-switch-to-selfhost-as-me="nix::env::tenant::switch ${NIX_SELFHOST_NAME} ${NIX_PERSONA_ME}"
alias fd-switch-to-int-as-me="nix::env::tenant::switch ${NIX_INT_NAME} ${NIX_PERSONA_ME}"
alias fd-switch-to-ppe-as-me="nix::env::tenant::switch ${NIX_PPE_NAME} ${NIX_PERSONA_ME}"

alias fd-login="nix::env::tenant::switch::persona "${NIX_PERSONA_ADMINISTRATOR}""
alias fd-login-as-administrator="nix::env::tenant::switch::persona "${NIX_PERSONA_ADMINISTRATOR}""
alias fd-login-as-developer="nix::env::tenant::switch::persona "${NIX_PERSONA_DEVELOPER}""
alias fd-login-as-vm-user="nix::env::tenant::switch::persona "${NIX_PERSONA_VM_USER}""
alias fd-login-as-network-administrator="nix::env::tenant::switch::persona "${NIX_PERSONA_NETWORK_ADMIN}""
alias fd-login-as-me="nix::env::tenant::switch::persona "${NIX_PERSONA_ME}""

alias fd-logout="nix::env::tenant::logout"
alias fd-batch="nix::env::tenant::batch"

nix::env::tenant::logout() {
    nix::az::logout
}

nix::env::tenant::switch::persona() {
    local PERSONA="$1"
    shift

    nix::env::tenant::switch "${NIX_FID_NAME}" "${PERSONA}"
}

nix::env::tenant::switch() {
    local NAME="${1:-${NIX_PUBLIC_NAME}}"
    shift

    local PERSONA="${1:-${NIX_PERSONA_ADMINISTRATOR}}"
    shift

    if [[ "${NIX_FID_NAME}" == "${NAME}" ]] \
        && [[ "${NIX_ENV_PERSONA}" == "${PERSONA}" ]] \
        && nix::az::account::get_access_token::check; then

        # refresh for development purposes 
        nix::env::set "${NAME}" "${PERSONA}"
        return
    fi

    if ! nix::env::set "${NAME}" "${PERSONA}"; then
        return
    fi

    local ENV="${NIX_ENV}"
    local -n TENANT="NIX_${ENV}_TENANT"
    local -n CLOUD="NIX_${ENV}_CLOUD"
    local CLOUD_ENDPOINTS="NIX_${ENV}_CLOUD_ENDPOINTS"
    local -n SUBSCRIPTION="NIX_${ENV}_SUBSCRIPTION"

    nix::az::tenant::login \
        "${NIX_ENV_UPN}" \
        "${TENANT}" \
        "${CLOUD}" \
        "${CLOUD_ENDPOINTS}" \
        "${SUBSCRIPTION}"

    nix::env::cli::install

    export PS1="\$(nix::env::tenant::prompt ${PERSONA})"
}

nix::env::tenant::prompt() {
    local RESULT=$?

    local PERSONA="$1"
    shift

    local FIDALGO_CONTEXT
    if (( NIX_MY_ENV_ID > 0 )); then
        FIDALGO_CONTEXT+=( "${NIX_MY_ENV_ID}" )
    fi

    FIDALGO_CONTEXT+=( "${NIX_FID_NAME}" )
    if [[ ! "${PERSONA}" == "${NIX_PERSONA_ADMINISTRATOR}" ]]; then
        FIDALGO_CONTEXT+=( "${PERSONA}" )
    fi

    local PROMPT=( "[${FIDALGO_CONTEXT[*]}]" )

    local DIR="$(pwd)"
    DIR="${DIR/${NIX_REPO_DIR}/...}"
    PROMPT+=( "${DIR}/" )

    if (( RESULT )); then
        # vscode console does not like colored prompts
        # PROMPT+=( "$(nix::color::red ${RESULT})" )
        PROMPT+=( "${RESULT}" )
    fi

    PROMPT+=( '$' )

    echo -e "${PROMPT[*]} "
}

nix::env::tenant::eval() (
    local ENVIRONMENT="$1"
    shift

    nix::env::tenant::switch "${ENVIRONMENT}"
    "$@"
)

nix::env::tenant::batch() (
    local ENVIRONMENT
    for ENVIRONMENT in "${NIX_MY_ENVIRONMENTS[@]}"; do
        nix::env::tenant::eval "${ENVIRONMENT}" "$@" 2>&1 \
            | sed "s/^/${ENVIRONMENT} /g"
    done
)

