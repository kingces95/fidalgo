(
    fd-login-as-administrator
    az group create \
        --name=${NIX_FID_RESOURCE_GROUP} \
        --location=${NIX_FID_LOCATION} \
        --subscription=${NIX_FID_SUBSCRIPTION}
    az fidalgo admin dev-center create \
        --name=${NIX_ENV_PREFIX}-my-dev-center \
        --resource-group=${NIX_FID_RESOURCE_GROUP} \
        --location=${NIX_FID_LOCATION} \
        --subscription=${NIX_FID_SUBSCRIPTION} \
        --identity-type=SystemAssigned
    az fidalgo admin network-setting create \
        --name=${NIX_ENV_PREFIX}-my-azure-ad-network-setting \
        --resource-group=${NIX_FID_RESOURCE_GROUP} \
        --location=${NIX_FID_LOCATION} \
        --subscription=${NIX_FID_SUBSCRIPTION} \
        --subnet-id=/subscriptions/${NIX_CPC_SUBSCRIPTION}/resourceGroups/${NIX_MY_RESOURCE_GROUP}/providers/Microsoft.Network/virtualNetworks/${NIX_MY_VNET}/subnets/${NIX_MY_SUBNET} \
        --domain-join-type=AzureADJoin
    az fidalgo admin network-setting create \
        --name=${NIX_ENV_PREFIX}-my-hybrid-ad-network-setting \
        --resource-group=${NIX_FID_RESOURCE_GROUP} \
        --location=${NIX_FID_LOCATION} \
        --subscription=${NIX_FID_SUBSCRIPTION} \
        --subnet-id=/subscriptions/${NIX_CPC_SUBSCRIPTION}/resourceGroups/${NIX_MY_RESOURCE_GROUP}/providers/Microsoft.Network/virtualNetworks/${NIX_MY_VNET}/subnets/${NIX_MY_SUBNET} \
        --domain-join-type=HybridAzureADJoin \
        --domain-name=${NIX_CPC_DOMAIN_NAME} \
        --domain-password=$(nix::secret::cat) \
        --domain-username="${NIX_CPC_DOMAIN_JOIN_ACCOUNT}"
    az fidalgo admin attached-network create \
        --name=${NIX_ENV_PREFIX}-my-azure-ad-attached-network \
        --dev-center-name=${NIX_ENV_PREFIX}-my-dev-center \
        --resource-group=${NIX_FID_RESOURCE_GROUP} \
        --subscription=${NIX_FID_SUBSCRIPTION} \
        --network-connection-resource-id=/subscriptions/${NIX_FID_SUBSCRIPTION}/resourceGroups/${NIX_FID_RESOURCE_GROUP}/providers/Microsoft.Fidalgo/networksettings/${NIX_ENV_PREFIX}-my-azure-ad-network-setting
    az fidalgo admin attached-network create \
        --name=${NIX_ENV_PREFIX}-my-hybrid-ad-attached-network \
        --dev-center-name=${NIX_ENV_PREFIX}-my-dev-center \
        --resource-group=${NIX_FID_RESOURCE_GROUP} \
        --subscription=${NIX_FID_SUBSCRIPTION} \
        --network-connection-resource-id=/subscriptions/${NIX_FID_SUBSCRIPTION}/resourceGroups/${NIX_FID_RESOURCE_GROUP}/providers/Microsoft.Fidalgo/networksettings/${NIX_ENV_PREFIX}-my-hybrid-ad-network-setting
    az fidalgo admin devbox-definition create \
        --name=${NIX_ENV_PREFIX}-my-devbox-definition \
        --resource-group=${NIX_FID_RESOURCE_GROUP} \
        --location=${NIX_FID_LOCATION} \
        --subscription=${NIX_FID_SUBSCRIPTION} \
        --dev-center-name=${NIX_ENV_PREFIX}-my-dev-center \
        --sku-name=PrivatePreview \
        --image-reference=id=/subscriptions/${NIX_CPC_SUBSCRIPTION}/resourceGroups/${NIX_FID_RESOURCE_GROUP}/providers/Microsoft.Fidalgo/devcenters/${NIX_ENV_PREFIX}-my-dev-center/galleries/Default/images/MicrosoftWindowsDesktop_windows-ent-cpc_win11-21h2-ent-cpc-m365
    az fidalgo admin project create \
        --name=${NIX_ENV_PREFIX}-my-project \
        --resource-group=${NIX_FID_RESOURCE_GROUP} \
        --location=${NIX_FID_LOCATION} \
        --subscription=${NIX_FID_SUBSCRIPTION} \
        --dev-center-id=/subscriptions/${NIX_FID_SUBSCRIPTION}/resourceGroups/${NIX_FID_RESOURCE_GROUP}/providers/Microsoft.Fidalgo/devcenters/${NIX_ENV_PREFIX}-my-dev-center
    az role assignment create \
        --assignee=${NIX_ENV_PERSONA_DEVELOPER} \
        --role=Contributor \
        --scope=/subscriptions/${NIX_FID_SUBSCRIPTION}/resourceGroups/${NIX_FID_RESOURCE_GROUP}/providers/Microsoft.Fidalgo/projects/${NIX_ENV_PREFIX}-my-project \
        --subscription=${NIX_FID_SUBSCRIPTION}
    az fidalgo admin pool create \
        --name=${NIX_ENV_PREFIX}-my-pool \
        --project-name=${NIX_ENV_PREFIX}-my-project \
        --resource-group=${NIX_FID_RESOURCE_GROUP} \
        --location=${NIX_FID_LOCATION} \
        --subscription=${NIX_FID_SUBSCRIPTION} \
        --devbox-definition-name=${NIX_ENV_PREFIX}-my-devbox-definition \
        --network-connection-name=${NIX_ENV_PREFIX}-my-hybrid-ad-attached-network
)
