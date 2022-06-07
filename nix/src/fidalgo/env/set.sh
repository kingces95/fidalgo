nix::env::set() {
    local NAME="$1"
    shift

    local PERSONA="$1"
    shift

    nix::context::clear

    nix::env::fid::set "${NAME}"
    nix::env::cpc::set "${NAME}"
    nix::env::persona::set "${PERSONA}"

    nix::env::kusto::set "${NIX_FID_NAME}"

    # for debugging
    # return 1
}

nix::env::shared::set() {
    nix::context::add NIX_ENV_PREFIX                    "nix-${USER}-${NIX_FID_TAG}-${NIX_MY_ENV_ID}" # nix-chrkin-df-0
}

nix::env::persona::set() {
    local PERSONA="$1"

    nix::context::add NIX_ENV_PERSONA                   "${PERSONA}"

    local UPN="${NIX_PERSONA_UPN[${PERSONA}]}"
    nix::context::add NIX_ENV_UPN                       "${!UPN}"

    local ENV='FID'
    if [[ "${UPN}" =~ _CPC_ ]]; then
        ENV='CPC'
    fi
    nix::context::add NIX_ENV                           "${ENV}"
}

nix::env::fid::set() {
    local NAME=$1
    shift

    nix::context::add NIX_FID_NAME                      "${NAME}" # PUBLIC
    
    nix::env::afs::fid::set
    nix::env::shared::set

    nix::env::set::common "${NIX_FID_NAME}" "FID"

    # nix::context::add NIX_FID_LOCATION                "$(nix::env::fid::query NIX_AZ_TENANT_DEFAULT_LOCATION)" # centraluseuap
    nix::context::add NIX_FID_RESOURCE_GROUP            "${NIX_ENV_PREFIX}-fid-rg" # nix-chrkin-df-0-rg

    # personas
    nix::context::add NIX_ENV_PERSONA_ADMINISTRATOR     "${NIX_FID_UPN_DOMAIN_ADMIN}"
    nix::context::add NIX_ENV_PERSONA_DEVELOPER         "${NIX_FID_UPN_DOMAIN}"
    nix::context::add NIX_ENV_PERSONA_ME                "${NIX_FID_UPN_MICROSOFT}"
}

nix::env::cpc::set() {
    local NAME=$1
    shift

    nix::context::ref NIX_CPC_NAME                      "NIX_${NAME}_CPC" # SELFHOST
    nix::context::add NIX_CPC_RESOURCE_GROUP            "${NIX_ENV_PREFIX}-cpc-rg" # nix-chrkin-df-0-rg

    nix::env::afs::cpc::set

    nix::env::set::common "${NIX_CPC_NAME}" "CPC"

    # personas
    nix::context::add NIX_ENV_PERSONA_NETWORK_ADMIN     "${NIX_CPC_UPN_DOMAIN_ADMIN}"
    nix::context::add NIX_ENV_PERSONA_VM_USER           "${NIX_CPC_UPN_DOMAIN}"

    # vnet
    nix::context::ref NIX_CPC_DC_VNET                   "NIX_${NIX_CPC_NAME}_DC_VNET"
    nix::context::ref NIX_CPC_DC_VNET_RESOURCE_GROUP    "NIX_${NIX_CPC_NAME}_DC_VNET_RESOURCE_GROUP"
    nix::context::add NIX_CPC_ID_DC_VNET "$(
        nix::azure::resource::id::vnet \
            ${NIX_CPC_SUBSCRIPTION} \
            ${NIX_CPC_DC_VNET_RESOURCE_GROUP} \
            ${NIX_CPC_DC_VNET}
        )"
    nix::context::add NIX_CPC_WWW_DC_VNET "$(
        nix::azure::resource::www \
            ${NIX_CPC_PORTAL_HOST} \
            ${NIX_CPC_TENANT_HOST} \
            ${NIX_CPC_ID_DC_VNET}
        )"

    # domain controller
    nix::context::ref NIX_CPC_DC                        "NIX_${NIX_CPC_NAME}_DC"
    nix::context::ref NIX_CPC_DC_RESOURCE_GROUP         "NIX_${NIX_CPC_NAME}_DC_RESOURCE_GROUP"
    nix::context::add NIX_CPC_ID_DC "$(
        nix::azure::resource::id::vm \
            ${NIX_CPC_SUBSCRIPTION} \
            ${NIX_CPC_DC_RESOURCE_GROUP} \
            ${NIX_CPC_DC}
        )"
    nix::context::add NIX_CPC_WWW_DC "$(
        nix::azure::resource::www \
            ${NIX_CPC_PORTAL_HOST} \
            ${NIX_CPC_TENANT_HOST} \
            ${NIX_CPC_ID_DC}
        )"

    # domain credentials
    nix::context::add NIX_CPC_DOMAIN_NAME               "${NIX_CPC_TENANT_SUBDOMAIN}.local"
    nix::context::add NIX_CPC_DOMAIN_JOIN_ACCOUNT       "domainjoin@${NIX_CPC_TENANT_SUBDOMAIN}.local"
    nix::context::ref NIX_CPC_DNS                       "NIX_${NIX_CPC_NAME}_DNS"

    # misc
    nix::context::add NIX_CPC_WWW_MEM                   "NIX_${NIX_CPC_NAME}_WWW_MEM"
    nix::context::add NIX_CPC_WWW_END_USER              "NIX_${NIX_CPC_NAME}_WWW_END_USER"
}

nix::env::set::common() {
    local NAME="$1"
    shift

    local ENV="$1"
    shift
    
    # indirect variables    
    # nix::context::ref "NIX_${ENV}_TAG"              "NIX_${NAME}_TAG"                               # NIX_FID_TAG               NIX_CPC_TAG                 df
    # nix::context::ref "NIX_${ENV}_CLOUD"            "NIX_${NAME}_CLOUD"                             # NIX_FID_CLOUD             NIX_CPC_CLOUD               AzureCloud
    # nix::context::ref "NIX_${ENV}_TENANT"           "NIX_${NAME}_TENANT"                            # NIX_FID_TENANT            NIX_CPC_TENANT              8ab2df1c-ed88-4946-a8a9-e1bbb3e4d1fd
    # nix::context::ref "NIX_${ENV}_TENANT_DOMAIN"    "NIX_${NAME}_TENANT_DOMAIN"                     # NIX_FID_TENANT_DOMAIN     NIX_CPC_TENANT_DOMAIN       onmicrosoft.com
    # nix::context::ref "NIX_${ENV}_TENANT_SUBDOMAIN" "NIX_${NAME}_TENANT_SUBDOMAIN"                  # NIX_FID_TENANT_SUBDOMAIN  NIX_CPC_TENANT_SUBDOMAIN    fidalgoppe010
    # nix::context::ref "NIX_${ENV}_SUBSCRIPTION"     "NIX_${NAME}_SUBSCRIPTION"                      # NIX_FID_SUBSCRIPTION      NIX_CPC_SUBSCRIPTION        974ae608-fbe5-429f-83ae-924a64019bf3
    # nix::context::ref "NIX_${ENV}_PORTAL_HOST"      "NIX_${NAME}_PORTAL_HOST"                       # NIX_FID_PORTAL_HOST       NIX_CPC_PORTAL_HOST         portal.azure.com
    # nix::context::ref "NIX_${ENV}_DNS_SUFFIX"       "NIX_${NAME}_DNS_SUFFIX"                        # NIX_FID_DNS_SUFFIX        NIX_CPC_DNS_SUFFIX          devcenters.fidalgo.azure-test.net
    # nix::context::ref "NIX_${ENV}_CLI_VERSION"      "NIX_${NAME}_CLI_VERSION"                       # NIX_FID_CLI_VERSION       NIX_CPC_CLI_VERSION         0.3.2

    # computed variable declarations
    nix::context::add "NIX_${ENV}_TENANT_HOST"      "$(nix::env::host ${NAME})"                         # NIX_FID_TENANT_HOST       NIX_CPC_TENANT_HOST         fidalgoppe010.onmicrosoft.com
    nix::context::add "NIX_${ENV}_UPN_MICROSOFT"    "${NIX_UPN_MICROSOFT}"                              # NIX_FID_UPN_MICROSOFT     NIX_CPC_UPN_MICROSOFT       you@microsoft.com
    nix::context::add "NIX_${ENV}_UPN_DOMAIN"       "$(nix::env::user ${NAME} ${NIX_MY_ALIAS})"         # NIX_FID_UPN_DOMAIN        NIX_CPC_UPN_DOMAIN          you@fidalgoppe010.onmicrosoft.com       
    nix::context::add "NIX_${ENV}_UPN_DOMAIN_ADMIN" "$(nix::env::user ${NAME} ${NIX_MY_ALIAS}-admin)"   # NIX_FID_UPN_DOMAIN_ADMIN  NIX_CPC_UPN_DOMAIN_ADMIN    you@fidalgoppe010.onmicrosoft.com

    # computed indirect variable declarations
    declare -gn "NIX_${ENV}_CLOUD_ENDPOINTS=$(nix::env::cloud_endpoints ${NAME})"                # NIX_FID_CLOUD_ENDPOINTS   NIX_CPC_CLOUD_ENDPOINTS     NIX_AZURE_CLOUD_ENDPOINTS_PUBLIC

    # load bookmarks
    nix::env::set::common::www "${ENV}"
}

nix::env::set::common::www() {
    local ENV="$1"
    shift

    local -n PORTAL_HOST="NIX_${ENV}_PORTAL_HOST"
    local -n TENANT_HOST="NIX_${ENV}_TENANT_HOST"
    local -n SUBSCRIPTION="NIX_${ENV}_SUBSCRIPTION"

    nix::context::add "NIX_${ENV}_WWW" "$(               # NIX_FID_WWW               NIX_CPC_WWW                 https://portal.azure.com
        nix::azure::resource::www \
            "${PORTAL_HOST}"
        )"                

    nix::context::add "NIX_${ENV}_WWW_SUBSCRIPTION" "$(  # NIX_FID_WWW_SUBSCRIPTION  NIX_CPC_WWW_SUBSCRIPTION
        nix::azure::resource::www \
            "${PORTAL_HOST}" \
            "${TENANT_HOST}" \
            $(nix::azure::resource::id "${SUBSCRIPTION}")
        )" 
}

nix::env::kusto::set() {
    local TENANT="$1"
    shift

    local -n KUSTO_TENANT="NIX_${TENANT}_KUSTO"

    # indirect variables
    nix::context::ref "NIX_KUSTO_ENV_CLUSTER"           "NIX_KUSTO_${KUSTO_TENANT}_CLUSTER"
    nix::context::ref "NIX_KUSTO_ENV_DATA_SOURCE"       "NIX_KUSTO_${KUSTO_TENANT}_DATA_SOURCE"
    nix::context::ref "NIX_KUSTO_ENV_INITIAL_CATALOG"   "NIX_KUSTO_${KUSTO_TENANT}_INITIAL_CATALOG"
}

nix::env::cloud_endpoints() {
    local NAME="$1"
    shift

    local -n CLOUD="NIX_${NAME}_CLOUD"
    echo "${NIX_AZURE_CLOUD_ENDPOINTS[${CLOUD}]}"
}

nix::env::user() {
    local NAME="$1"
    shift

    local USER="$1"
    shift

    # e.g. in public we must use personal alias as we cannot create accounts
    if nix::bash::map::test NIX_UPN_OVERRIDE "${NAME}"; then
        
        # chrkin@microsoft.com
        echo "${NIX_UPN_OVERRIDE[${NAME}]}"
        return
    fi

    local TENANT_HOST="$(nix::env::host ${NAME})"
    
    # chrkin@fidalgoppe010.onmicrosoft.com
    echo "${USER}@${TENANT_HOST}"
}

nix::env::host() {
    local NAME="$1"
    shift

    local -n TENANT_DOMAIN="NIX_${NAME}_TENANT_DOMAIN"
    local -n TENANT_SUBDOMAIN="NIX_${NAME}_TENANT_SUBDOMAIN"

    if [[ "${TENANT_SUBDOMAIN}" ]]; then                                            
        echo "${TENANT_SUBDOMAIN}.${TENANT_DOMAIN}"
    else
        echo "${TENANT_DOMAIN}"
    fi
}
