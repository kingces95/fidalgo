alias fd-my-profile="code ${NIX_MY_PROFILE}"
alias fd-my-profile-rm="nix::my::profile::rm"
alias fd-my-cpc-resources="nix::my::resource::report"

nix::my::profile::rm() {
    rm -r "${NIX_MY_DIR}"
}

nix::my::computed() {
    readonly NIX_MY_RESOURCE_GROUP="${NIX_MY_ALIAS}-rg"
    readonly NIX_MY_VNET="${NIX_MY_ALIAS}-vnet"
    readonly NIX_MY_SUBNET='default'
}

nix::my::group::list() {
    az group list \
        --query '[?starts_with(name,`chrkin`)].name' \
        --output tsv \
        --subscription=${NIX_CPC_SUBSCRIPTION}
}

nix::az::resource::list() {
    local -a AZGROUPS=( "$@" )

    local AZGROUP
    for AZGROUP in "${AZGROUPS[@]}"; do
        az resource list \
            --resource-group=${AZGROUP} \
            --query '[].[name,type]' \
            --output tsv \
            --subscription=${NIX_CPC_SUBSCRIPTION}
    done
}

nix::my::resource::list() {
    local -a AZGROUPS
    nix::my::group::list \
        | mapfile AZGROUPS

    local AZGROUP
    for AZGROUP in "${AZGROUPS[@]}"; do
        az resource list \
            --resource-group=${NIX_MY_RESOURCE_GROUP} \
            --query='[].[resourceGroup,name,type]' \
            --output=tsv \
            --subscription=${NIX_CPC_SUBSCRIPTION}
    done
}

nix::resource::vnet::report() {
    local NIX_AZ_RESOURCE_GROUP=$1
    shift

    local NIX_AZ_SUBSCRIPTION=$1
    shift

    nix::az::network::vnet::list | {
        while read NIX_AZ_NAME; do
            echo "name ${NIX_AZ_NAME}"

            local LOCATION="$(nix::az::network::vnet::location)"
            local DNS="$(nix::az::network::vnet::dns)"

            echo "option" "location" "${LOCATION}"
            echo "option" "dns" "${DNS}"

            echo "push subnet"
            local NIX_AZ_VENT_NAME="${NIX_AZ_NAME}"
            nix::az::network::vnet::subnet::list | {
                while read NAME; do
                    nix::resource::subnet::report "${NAME}"
                done
            }
            echo "pop"
        done
    }
}

nix::resource::subnet::report() {
    local NIX_AZ_NAME="$1"
    shift

    local ADDRESS_PREFIX=$(nix::az::network::vnet::subnet::address_prefix)
    local DELEGATION=$(nix::az::network::vnet::subnet::delegation)

    echo 'name' "${NIX_AZ_NAME}" 
    echo 'option' 'addressPrefix' "${ADDRESS_PREFIX}" 
    echo 'option' 'delegation' "${DELEGATION}"
}

nix::my::resource::report() (
    nix::env::tenant::switch::persona "${NIX_PERSONA_NETWORK_ADMIN}"

    local SUBSCRIPTION=${NIX_CPC_SUBSCRIPTION}
    local RG=${NIX_MY_RESOURCE_GROUP}
    local PORTAL_HOST=${NIX_CPC_PORTAL_HOST}
    local TENANT_HOST=${NIX_CPC_TENANT_HOST}

    local NAME TYPE
    while read NAME TYPE; do
        local URL="https://${PORTAL_HOST}"
        URL+="/#@${HOST}/resource"
        URL+="/subscriptions/${SUBSCRIPTION}/resourceGroups/${NIX_MY_RESOURCE_GROUP}/providers/${TYPE}/${NAME}"
        URL+='/overview'

        echo "${NAME} ${URL}"
    done < <(nix::my::resource::list)
)

# # to-ad
# az network vnet peering list \
#     --resource-group=permtest \
#     --vnet-name=vNetPermTest \
#     --subscription=5107c0cd-1b38-45e5-ad53-5308aeafd97a

# # from-ad
# az network vnet peering list \
#     --resource-group=fidalgoppe010 \
#     --vnet-name=vnet \
#     --subscription=974ae608-fbe5-429f-83ae-924a64019bf3 \
#     --query '[?name == `vNetPermTestPeering`]'
