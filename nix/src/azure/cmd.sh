alias az-location-list="nix::azure::cmd::acount::location::list"
alias az-harvest="nix::azure::cmd::emit::harvest"

nix::azure::cmd::emit::function() {
    local TARGET="$1"
    
    local FUNCTION=${TARGET/cmd::/}
    FUNCTION=${FUNCTION/azure/az}
    
    local ALIAS=${FUNCTION//nix::/}
    ALIAS=${ALIAS//::/-}
    ALIAS=${ALIAS//_/-}

    # tweaks
    ALIAS=${ALIAS//ad-user-login/}

    echo "alias ${ALIAS}=\"${FUNCTION}\""
    echo "${FUNCTION}() { ${TARGET} \"\$@\" | nix::cmd::run; }"
}

nix::azure::cmd::emit::harvest() {
    declare -F \
        | grep "nix::azure::cmd::" \
        | grep -v "::cmd::option" \
        | grep -v "::cmd::emit" \
        | nix::record::project 3 3 \
        | pump nix::azure::cmd::emit::function \
        | sort
}

nix::azure::cmd::option::only_show_errors() {
    nix::cmd::flag 'only-show-errors'
}

nix::azure::cmd::option::yes() {
    nix::cmd::flag 'yes'
}

nix::azure::cmd::option::upgrade() {
    nix::cmd::flag 'upgrade'
}

nix::azure::cmd::option::upgrade_yes() {
    nix::azure::cmd::option::upgrade
    nix::azure::cmd::option::yes
}

nix::azure::cmd::query() {
    local QUERY="$1"

    if [[ ! "${QUERY}" ]]; then
        return
    fi

    nix::cmd::option 'query' "${QUERY}"
    nix::cmd::option 'output' 'tsv'
    nix::azure::cmd::option::only_show_errors
}

nix::azure::cmd() {
    nix::cmd::name 'az'
    while (( $# > 0 )); do
        nix::cmd::argument "$1"
        shift
    done
}

# resource
nix::azure::cmd::resource() {
    local RESOURCE=$1
    shift

    local VERB=$1
    shift

    nix::azure::cmd \
        ${NIX_AZURE_RESOURCE[${RESOURCE}]:-'unknown'} \
        "${VERB}"
}

nix::azure::cmd::resource::create() {
    nix::azure::cmd::resource "$1" 'create'
}

# logout
nix::azure::cmd::logout() {
    nix::azure::cmd 'logout'
}

# login
nix::azure::cmd::login() {
    local TENANT="$1"
    shift
    
    nix::azure::cmd 'login'
    nix::cmd::flag 'allow-no-subscriptions'

    if [[ "${TENANT}" ]]; then
        nix::cmd::option 'tenant' "${TENANT}"
    fi
}

nix::azure::cmd::login::with_device_code() {
    local TENANT="$1"
    shift

    nix::azure::cmd::login "${TENANT}"
    nix::cmd::flag 'use-device-code'
}

nix::azure::cmd::login::with_secret() {
    local USERNAME="$1"
    shift

    local SECRET="$1"
    shift

    local TENANT="$1"
    shift

    nix::azure::cmd::login "${TENANT}"
    nix::cmd::option 'username' "${USERNAME}"
    nix::cmd::option 'password' "${SECRET}"
}

# extension
nix::azure::cmd::extension() {
    nix::azure::cmd 'extension' "$@"
    nix::azure::cmd::option::only_show_errors
}

nix::azure::cmd::extension::remove() {
    nix::azure::cmd::extension 'remove'
    nix::cmd::option 'name' "$1"
}

nix::azure::cmd::extension::upgrade::source() {
    nix::azure::cmd::extension 'add'
    nix::cmd::option 'source' "$1"
    nix::azure::cmd::option::upgrade_yes
}

nix::azure::cmd::extension::upgrade() {
    nix::azure::cmd::extension 'add'
    nix::cmd::option 'name' "$1"
    nix::azure::cmd::option::upgrade_yes
}

nix::azure::cmd::extension::list() {
    nix::azure::cmd::extension 'list'
    nix::azure::cmd::query '[].[name, version]'
}

nix::azure::cmd::extension::which() {
    nix::azure::cmd::extension 'list'
    nix::azure::cmd::query "[?name == \`$1\`].[version]"
}

# group
nix::azure::cmd::group() {
    nix::azure::cmd 'group' "$@"
}

nix::azure::cmd::group::delete() {
    nix::azure::cmd::group 'delete'
    nix::cmd::option 'name' "$1"
}

# network
nix::azure::cmd::network() {
    nix::azure::cmd 'network' "$@"
}

# vnet
nix::azure::cmd::network::vnet() {
    : ${NIX_AZ_RESOURCE_GROUP?}
    : ${NIX_AZ_SUBSCRIPTION?}

    nix::azure::cmd::network 'vnet' "$@"
    nix::cmd::option 'resource-group' "${NIX_AZ_RESOURCE_GROUP}"
    nix::cmd::option 'subscription' "${NIX_AZ_SUBSCRIPTION}"
}

nix::azure::cmd::network::vnet::list() {
    nix::azure::cmd::network::vnet 'list'
    nix::azure::cmd::query '[].name'
}

nix::azure::cmd::network::vnet::show() {
    : ${NIX_AZ_NAME?}

    nix::azure::cmd::network::vnet 'show'
    nix::cmd::option 'name' "${NIX_AZ_NAME}"
}

nix::azure::cmd::network::vnet::dns() {
    nix::azure::cmd::network::vnet::show
    nix::azure::cmd::query 'dhcpOptions.dnsServers[]'
}

nix::azure::cmd::network::vnet::location() {
    nix::azure::cmd::network::vnet::show
    nix::azure::cmd::query 'location'
}

# subnet
nix::azure::cmd::network::vnet::subnet() {
    : ${NIX_AZ_VENT_NAME?}
    
    nix::azure::cmd::network::vnet 'subnet' "$@"
    nix::cmd::option 'vnet-name' "${NIX_AZ_VENT_NAME}"
}

nix::azure::cmd::network::vnet::subnet::list() {
    nix::azure::cmd::network::vnet::subnet 'list'
    nix::azure::cmd::query '[].name'
}

nix::azure::cmd::network::vnet::subnet::show() {
    : ${NIX_AZ_NAME?}

    nix::azure::cmd::network::vnet::subnet 'show'
    nix::cmd::option 'name' "${NIX_AZ_NAME}"
}

nix::azure::cmd::network::vnet::subnet::address_prefix() {
    nix::azure::cmd::network::vnet::subnet::show
    nix::azure::cmd::query 'addressPrefix'
}

nix::azure::cmd::network::vnet::subnet::delegation() {
    nix::azure::cmd::network::vnet::subnet::show
    nix::azure::cmd::query 'delegations[*].serviceName'
}

# ad
nix::azure::cmd::ad() {
    nix::azure::cmd 'ad' "$@"
}

# ad user
nix::azure::cmd::ad::user() {
    nix::azure::cmd::ad 'user' "$@"
}

# ad user get-member-groups
nix::azure::cmd::ad::user::get_member_groups() {
    local MEMBER="$1"
    shift

    nix::azure::cmd::ad::user 'get-member-groups'
    nix::cmd::option 'id' "${MEMBER}"
    nix::azure::cmd::query '[].displayName'
}

# ad user create
nix::azure::cmd::ad::user::create() {
    local DISPLAY_NAME="$1"
    shift

    local USER="$1"
    shift

    local HOST="$1"
    shift

    local SECRET="$1"
    shift

    local UPN="${USER}@${HOST}"

    nix::azure::cmd::ad::user 'create'
    nix::azure::cmd::option::only_show_errors
    nix::cmd::option 'display-name' "${DISPLAY_NAME}"
    nix::cmd::option 'user-principal-name' "${UPN}"
    nix::cmd::option 'password' "${SECRET}"
    nix::cmd::option 'force-change-password-next-login' 'false'
}

# ad user list
nix::azure::cmd::ad::user::filter() {
    nix::azure::cmd::ad::user 'list'
    nix::cmd::option 'filter' "$1"
    nix::azure::cmd::query '[].userPrincipalName'
}

nix::azure::cmd::ad::user::id() {
    nix::azure::cmd::ad::user 'show'
    nix::cmd::option 'id' "$1"
    nix::azure::cmd::query 'id'
}

# ad group
nix::azure::cmd::ad::group() {
    nix::azure::cmd::ad 'group' "$@"
}

# ad group member
nix::azure::cmd::ad::group::member() {
    nix::azure::cmd::ad::group 'member' "$@"
    nix::azure::cmd::option::only_show_errors
}

nix::azure::cmd::ad::group::member::add() {
    local GROUP="$1"
    shift

    local MEMBER="$1"
    shift

    nix::azure::cmd::ad::group::member 'add'
    nix::cmd::option 'group' "${GROUP}"
    nix::cmd::option 'member-id' "${MEMBER}"
}

nix::azure::cmd::ad::group::member::remove() {
    local GROUP="$1"
    shift

    local MEMBER="$1"
    shift

    nix::azure::cmd::ad::group::member 'remove'
    nix::cmd::option 'group' "${GROUP}"
    nix::cmd::option 'member-id' "${MEMBER}"
}

nix::azure::cmd::ad::group::member::check() {
    local GROUP="$1"
    shift

    local MEMBER="$1"
    shift

    nix::azure::cmd::ad::group::member 'check'
    nix::cmd::option 'group' "${GROUP}"
    nix::cmd::option 'member-id' "${MEMBER}"
    nix::azure::cmd::query 'value'
}

nix::azure::cmd::ad::group::member::list() {
    local GROUP="$1"
    shift

    nix::azure::cmd::ad::group::member 'list'
    nix::cmd::option 'group' "${GROUP}"
    nix::azure::cmd::query '[].userPrincipalName'
}

# cloud
nix::azure::cmd::cloud() {
    nix::azure::cmd 'cloud' "$@"
    nix::azure::cmd::option::only_show_errors
}

# cloud set
nix::azure::cmd::cloud::set() {
    local CLOUD="$1"
    shift

    nix::azure::cmd::cloud 'set'
    nix::cmd::option 'name' "${CLOUD}"
}

# cloud list
nix::azure::cmd::cloud::list() {
    nix::azure::cmd::cloud 'list'
    nix::azure::cmd::query '[].name'
}

# cloud register
nix::azure::cmd::cloud::register() {
    nix::azure::cmd::cloud 'register'
    nix::azure::cmd::option::only_show_errors

    nix::cmd::option 'name' "${NIX_AZ_NAME}"

    nix::cmd::option 'endpoint-active-directory' \
        "${NIX_AZ_TENANT_ENDPOINT_AD}"
    nix::cmd::option 'endpoint-active-directory-data-lake-resource-id' \
        "${NIX_AZ_TENANT_ENDPOINT_AD_DATA_LAKE_RESOURCE_ID}"
    nix::cmd::option 'endpoint-active-directory-graph-resource-id' \
        "${NIX_AZ_TENANT_ENDPOINT_AD_GRAPH_RESOURCE_ID}"
    nix::cmd::option 'endpoint-active-directory-resource-id' \
        "${NIX_AZ_TENANT_ENDPOINT_AD_RESOURCE_ID}"
    nix::cmd::option 'endpoint-gallery' \
        "${NIX_AZ_TENANT_ENDPOINT_GALLERY}"
    nix::cmd::option 'endpoint-management' \
        "${NIX_AZ_TENANT_ENDPOINT_MANAGEMENT}"
    nix::cmd::option 'endpoint-resource-manager' \
        "${NIX_AZ_TENANT_ENDPOINT_RESOURCE_MANAGER}"
    nix::cmd::option 'endpoint-sql-management' \
        "${NIX_AZ_TENANT_ENDPOINT_SQL_MANAGEMENT}"
    nix::cmd::option 'endpoint-vm-image-alias-doc' \
        "${NIX_AZ_TENANT_ENDPOINT_VM_IMAGE_ALIAS_DOC}"
}

# cloud unregister
nix::azure::cmd::cloud::unregister() {
    local NAME="$1"
    shift

    nix::azure::cmd::cloud 'unregister'
    nix::cmd::option 'name' "${NAME}"
}

# account
nix::azure::cmd::account() {
    nix::azure::cmd 'account' "$@"
}

nix::azure::cmd::account::set() {
    local SUBSCRIPTION="$1"
    
    nix::azure::cmd::account 'set'
    nix::cmd::option 'subscription' "${SUBSCRIPTION}"
}

# tenant list
nix::azure::cmd::account::tenant::list() {
    nix::azure::cmd::account 'tenant' 'list'
    nix::azure::cmd::query '[].tenantId'
}

# account get-access-token
nix::azure::cmd::account::get_access_token() {
    local RESOURCE="$1"
    shift

    nix::azure::cmd::account 'get-access-token'

    if [[ "${RESOURCE}" ]]; then
        nix::cmd::option 'resource' "${RESOURCE}"
    fi

    nix::azure::cmd::query 'accessToken'
}

# account location list
nix::azure::cmd::acount::location::list() {
    nix::azure::cmd::account 'list-locations'
    nix::azure::cmd::query "[].name"
}

# account list
nix::azure::cmd::account::list() {
    nix::azure::cmd::account 'list'
    nix::azure::cmd::query "$1"
}

nix::azure::cmd::account::list::default() {
    nix::azure::cmd::account::list '[?isDefault].name'
}

# account show
nix::azure::cmd::account::show() {
    nix::azure::cmd::account 'show'
    nix::azure::cmd::query "$1"
}

nix::azure::cmd::account::show::subscription::id() {
    nix::azure::cmd::account::show 'id'
}

nix::azure::cmd::account::show::subscription::name() {
    nix::azure::cmd::account::show 'name'
}

nix::azure::cmd::account::show::tenant::id() {
    nix::azure::cmd::account::show 'tenantId'
}

# signed-in-user show
nix::azure::cmd::signed_in_user::show() {
    nix::azure::cmd 'ad' 'signed-in-user' 'show'
    nix::azure::cmd::query "$1"
}

nix::azure::cmd::signed_in_user::upn() {
    nix::azure::cmd::signed_in_user::show 'userPrincipalName'
}

nix::azure::cmd::signed_in_user::id() {
    nix::azure::cmd::signed_in_user::show 'objectId'
}

# cloud show
nix::azure::cmd::cloud::show() {
    nix::azure::cmd cloud 'show'
    nix::azure::cmd::query "$1"
}

nix::azure::cmd::cloud::which() {
    nix::azure::cmd::cloud::show 'name'
}
