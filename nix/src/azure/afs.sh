alias afs="nix::afs::dump | a2f"
alias afs-unset="nix::afs::unset"
alias afs-set="nix::afs::set"
alias afs-query="nix::afs::query"
alias afs-emit="nix::afs::emit"
alias afs-context-cat="nix::afs::context::cat"
alias afs-context-find="nix::afs::context::find"

nix::afs::context::find() {
    local DIR="$1"
    shift

    nix::fs::context::find az "${DIR}"
}

nix::afs::context::cat() {
    local DIR="$1"
    shift

    nix::afs::context::find "${DIR}" \
        | nix::fs::context::cat
}

nix::afs::dump() {
    nix::bash::dump::variables 'NIX_AZ_'
}

nix::afs::unset() {
    nix::context::clear
}

nix::afs::initialize() {
    local NIX_AZ_UPN="${NIX_AZ_USER_NAME}@${NIX_AZ_USER_DOMAIN}"

    # set AZURE_CONFIG_DIR
    nix::az::tenant::profile::set "${NIX_AZ_UPN}" "${NIX_AZ_TENANT}"

    # initialize .azure/upn/tenant directory
    time nix::az::tenant::profile::initialize \
        "${NIX_AZ_UPN}" \
        "${NIX_AZ_TENANT}" \
        "${NIX_AZ_TENANT_CLOUD}" \
        "${NIX_AZ_SUBSCRIPTION}" \
        "${NIX_AZ_SUBSCRIPTION_NAME}"

    # share tokens between .azure/upn/tenant directories
    nix::az::tenant::profile::share_tokens
}

nix::afs::login() {
    local NIX_AZ_UPN="${NIX_AZ_USER_NAME}@${NIX_AZ_USER_DOMAIN}"

    # register cloud
    if ! nix::az::cloud::is_registered "${NIX_AZ_TENANT_CLOUD}"; then
        nix::az::cloud::register
    fi

    # set cloud
    time nix::az::cloud::set "${NIX_AZ_TENANT_CLOUD}"

    # login
    if [[ "${NIX_AZ_UPN}" =~ @microsoft[.]com$ ]]; then
        nix::az::login::with_device_code "${TENANT}" >/dev/null
    else
        local SECRET="$(nix::secret::get)"

        if ! nix::az::login::with_secret \
            "${NIX_AZ_UPN}" \
            "${SECRET}" \
            "${NIX_AZ_TENANT}" \
            >/dev/null; then

            nix::secret::rm
        else
            nix::secret::set "${SECRET}"
        fi

    fi || return

    # nix::az::account::set "${SUBSCRIPTION}"
}

nix::afs::set() {
    local DIR="$1"
    shift

    nix::afs::unset
    source <(nix::afs::emit "${DIR}")
}

nix::afs::query() (
    local DIR="$1"
    shift

    nix::afs::set "${DIR}"
    nix::bash::dereference
)

#
# nix::azure
#

nix::azure::login::trap() {
    local LOG="$(mktemp)"
    local LOGIN_ERROR="az login"

    while true; do
        $(which az) "$@" 2> "${LOG}"

        if read < "${LOG}" && \
            [[ "${REPLY}" =~ "${LOGIN_ERROR}" ]]; then

            nix::afs::login
            continue
        fi
          
        cat "${LOG}" >&2
        break
    done
}

#
# nix::afs::emit
#

nix::afs::emit::context() {
    cat \
    | while read -r TYPE KEY VALUE; do
        if [[ "${KEY}" == 'id' ]]; then
            KEY=
        fi

        local NAME="$(nix::bash::name::to_bash ${TYPE} ${KEY})"
        echo nix::context::add "NIX_AZ_${NAME} \"${VALUE}\""
    done
}

nix::afs::emit::name() {
    echo nix::context::add NIX_AZ_NAME \""$@"\"

    nix::afs::emit::context
}

nix::afs::emit::child_of() {
    local NAME="$(nix::bash::name::to_bash $1)"
    shift

    echo nix::context::add "NIX_AZ_${NAME}_NAME \"\${NIX_AZ_NAME}\""

    nix::afs::emit::name "$@"
}

nix::afs::emit() {
    local DIR="$1"
    shift

    nix::afs::context::cat "${DIR}" \
        | nix::fs::context::dispatch \
            'nix::afs::emit' \
            'nix::afs::emit::context'
}

nix::afs::emit::user() {
    nix::afs::emit::name "${USER}"
    nix::afs::emit::context
}
nix::afs::emit::tenant() {
    nix::afs::emit::child_of 'user' "$@"
    echo '#' "nix::afs::login"
}
nix::afs::emit::subscription() {
    nix::afs::emit::child_of 'tenant' "$@"
}
nix::afs::emit::group() {
    nix::afs::emit::child_of 'subscription' "$@"
}
nix::afs::emit::vnet() {
    nix::afs::emit::child_of 'resource-group' "$@"
}
nix::afs::emit::subnet() {
    nix::afs::emit::child_of 'vnet' "$@"
}

#
# nix::fs::context
#

nix::fs::context::dispatch() {
    local FUNCTION_PREFIX="$1"
    shift

    local FUNCTION_DEFAULT="$1"
    shift

    local TYPE NAME
    while read -r TYPE NAME; do
        echo "# ${TYPE} ${NAME}"
        nix::line::take::chunk \
            | {
                local FUNC="${FUNCTION_PREFIX}::${TYPE}"

                # dispatch
                if nix::bash::function::test "${FUNC}"; then
                    "${FUNC}" "${NAME}"
                else
                    "${FUNCTION_DEFAULT}"
                fi
            }
    done
}

nix::fs::context::cat() {
    local -i CHUNK=0
    while read; do
        local PTH="${REPLY}"
        local FILE_NAME="$(nix::path::file::name ${PTH})"
        local DIR_NAME="$(nix::path::dir::name ${PTH})"

        if (( CHUNK > 0 )); then
            echo
        fi

        echo "${FILE_NAME}" "${DIR_NAME}"
        cat "${PTH}" | sed "s/^/${FILE_NAME} /g"
        CHUNK+=1
    done
}

nix::fs::context::find() (
    shopt -s nullglob

    local SUFFIX="$1"
    shift

    local DIR="${1:-$PWD}"
    shift

    if [[ "${DIR}" == '/' ]]; then
        return
    fi

    local FILE=( "${DIR}"/*.${SUFFIX} )

    local PARENT=$(dirname "${DIR}")
    nix::fs::context::find "${SUFFIX}" "${PARENT}"

    if [[ "${FILE}" ]]; then
        echo "${FILE}"
    fi
)

#
# nix::bash::name
#

nix::bash::name::to_bash() {
    local NAME="$*"
    NAME="${NAME^^}"
    NAME="${NAME// /_}"
    NAME="${NAME//-/_}"
    echo "${NAME}"
}

nix::bash::variable() {
    local NAME="$*// /-"
    nix::bash::name::to_bash "${NAME}"
}
