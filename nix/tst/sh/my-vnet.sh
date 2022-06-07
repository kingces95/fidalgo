fd-login-as-network-administrator

az group create \
    --location=${NIX_CPC_LOCATION} \
    --name=${NIX_MY_RESOURCE_GROUP} \
    --subscription=${NIX_CPC_SUBSCRIPTION}

az network vnet create \
    --location=${NIX_CPC_LOCATION} \
    --name=${NIX_MY_VNET} \
    --address-prefixes="${NIX_MY_IP_ALLOCATION}" \
    --dns-servers=${NIX_CPC_DNS} \
    --resource-group=${NIX_MY_RESOURCE_GROUP} \
    --subscription=${NIX_CPC_SUBSCRIPTION}

az network vnet subnet create \
    --delegations=Microsoft.Fidalgo/networkSettings \
    --address-prefixes="${NIX_MY_IP_ALLOCATION}" \
    --name=${NIX_MY_SUBNET} \
    --resource-group=${NIX_MY_RESOURCE_GROUP} \
    --subscription=${NIX_CPC_SUBSCRIPTION} \
    --vnet-name=${NIX_MY_VNET}

az network vnet peering create \
    --name="${NIX_CPC_DC_VNET}" \
    --vnet-name=${NIX_MY_VNET} \
    --remote-vnet=/subscriptions/${NIX_CPC_SUBSCRIPTION}/resourceGroups/${NIX_CPC_DC_VNET_RESOURCE_GROUP}/providers/Microsoft.Network/virtualNetworks/${NIX_CPC_DC_VNET} \
    --resource-group=${NIX_MY_RESOURCE_GROUP} \
    --allow-forwarded-traffic \
    --allow-vnet-access \
    --subscription=${NIX_CPC_SUBSCRIPTION}

az network vnet peering create \
    --name="${NIX_MY_VNET}" \
    --vnet-name=${NIX_CPC_DC_VNET} \
    --remote-vnet=/subscriptions/${NIX_CPC_SUBSCRIPTION}/resourceGroups/${NIX_MY_RESOURCE_GROUP}/providers/Microsoft.Network/virtualNetworks/${NIX_MY_VNET} \
    --resource-group=${NIX_CPC_DC_VNET_RESOURCE_GROUP} \
    --allow-forwarded-traffic \
    --allow-vnet-access

fd-my-cpc-resources

az network vnet list \
    --resource-group=${NIX_MY_RESOURCE_GROUP} \
    --subscription=${NIX_CPC_SUBSCRIPTION}

az network vnet subnet list \
    --resource-group=${NIX_MY_RESOURCE_GROUP} \
    --subscription=${NIX_CPC_SUBSCRIPTION} \
    --vnet-name=${NIX_MY_VNET}

az network vnet peering list \
    --vnet-name=${NIX_MY_VNET} \
    --resource-group=${NIX_MY_RESOURCE_GROUP} \
    --subscription=${NIX_CPC_SUBSCRIPTION}

nix::resource::vnet::report \
    ${NIX_MY_RESOURCE_GROUP} \
    ${NIX_CPC_SUBSCRIPTION}

nix::resource::subnet::report \
    ${NIX_MY_SUBNET} \
    ${NIX_MY_VNET} \
    ${NIX_MY_RESOURCE_GROUP} \
    ${NIX_CPC_SUBSCRIPTION}