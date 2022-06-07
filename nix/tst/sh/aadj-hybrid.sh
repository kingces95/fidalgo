fd-login-as-administrator
az group create \
    --location=${NIX_FID_LOCATION} \
    --name=${NIX_FID_RESOURCE_GROUP}
az fidalgo admin dev-center create \
    --name=${NIX_ENV_PREFIX}-my-dev-center \
    --resource-group=${NIX_FID_RESOURCE_GROUP} \
    --location=${NIX_FID_LOCATION} \
    --subscription=${NIX_FID_SUBSCRIPTION} \
    --identity-type=SystemAssigned
az fidalgo admin network-setting create \
    --name=${NIX_ENV_PREFIX}-my-network-setting \
    --resource-group=${NIX_FID_RESOURCE_GROUP} \
    --location=${NIX_FID_LOCATION} \
    --subscription=${NIX_FID_SUBSCRIPTION} \
    --domain-join-type=HybridAzureADJoin \
    --domain-name=${NIX_CPC_DOMAIN_NAME} \
    --domain-password=$(nix::secret::cat) \
    --domain-username="${NIX_CPC_DOMAIN_JOIN_ACCOUNT}" \
    --subnet-id=/subscriptions/${NIX_CPC_SUBSCRIPTION}/resourceGroups/${NIX_MY_RESOURCE_GROUP}/providers/Microsoft.Network/virtualNetworks/${NIX_MY_VNET}/subnets/${NIX_MY_SUBNET}
az fidalgo admin attached-network create \
    --name=${NIX_ENV_PREFIX}-my-attached-network \
    --resource-group=${NIX_FID_RESOURCE_GROUP} \
    --subscription=${NIX_FID_SUBSCRIPTION} \
    --dev-center-name=${NIX_ENV_PREFIX}-my-dev-center \
    --network-connection-resource-id=/subscriptions/${NIX_FID_SUBSCRIPTION}/resourceGroups/${NIX_FID_RESOURCE_GROUP}/providers/Microsoft.Fidalgo/networksettings/${NIX_ENV_PREFIX}-my-network-setting
az fidalgo admin devbox-definition create \
    --name=${NIX_ENV_PREFIX}-my-devbox-definition \
    --resource-group=${NIX_FID_RESOURCE_GROUP} \
    --location=${NIX_FID_LOCATION} \
    --subscription=${NIX_FID_SUBSCRIPTION} \
    --dev-center-name=${NIX_ENV_PREFIX}-my-dev-center \
    --image-reference=id=/subscriptions/${NIX_CPC_SUBSCRIPTION}/resourceGroups/${NIX_FID_RESOURCE_GROUP}/providers/Microsoft.Fidalgo/devcenters/${NIX_ENV_PREFIX}-my-dev-center/galleries/Default/images/MicrosoftWindowsDesktop_windows-ent-cpc_win11-21h2-ent-cpc-m365 \
    --sku-name=PrivatePreview
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
    --resource-group=${NIX_FID_RESOURCE_GROUP} \
    --location=${NIX_FID_LOCATION} \
    --subscription=${NIX_FID_SUBSCRIPTION} \
    --network-connection-name=${NIX_ENV_PREFIX}-my-attached-network \
    --devbox-definition-name=${NIX_ENV_PREFIX}-my-devbox-definition \
    --project-name=${NIX_ENV_PREFIX}-my-project
fd-login-as-developer
az fidalgo dev virtual-machine create \
    --name=${NIX_ENV_PREFIX}-my-vm \
    --subscription=${NIX_FID_SUBSCRIPTION} \
    --dev-center=${NIX_ENV_PREFIX}-my-dev-center \
    --fidalgo-dns-suffix=${NIX_FID_DNS_SUFFIX} \
    --pool-name=${NIX_ENV_PREFIX}-my-pool \
    --project-name=${NIX_ENV_PREFIX}-my-project \
    --user-id=$(fd-login-as-vm-user; az-signed-in-user-id)

az fidalgo admin network-setting show-health-detail \
    --name=${NIX_ENV_PREFIX}-my-network-setting \
    --resource-group=${NIX_FID_RESOURCE_GROUP} \
    --subscription=${NIX_FID_SUBSCRIPTION}

az fidalgo admin pool update \
    --name=${NIX_ENV_PREFIX}-my-pool \
    --project-name=${NIX_ENV_PREFIX}-my-project \
    --resource-group=${NIX_FID_RESOURCE_GROUP} \
    --subscription=${NIX_FID_SUBSCRIPTION} \
    --network-connection-name=${NIX_ENV_PREFIX}-my-attached-network

az fidalgo admin attached-network delete \
    --attached-network-connection-name=${NIX_ENV_PREFIX}-my-attached-network \
    --dev-center-name=${NIX_ENV_PREFIX}-my-dev-center \
    --resource-group=${NIX_FID_RESOURCE_GROUP} \
    --yes

az fidalgo admin pool delete \
    --name=${NIX_ENV_PREFIX}-mypool \
    --project-name=${NIX_ENV_PREFIX}-my-project \
    --resource-group=${NIX_FID_RESOURCE_GROUP} \
    --subscription=${NIX_FID_SUBSCRIPTION} \
    --yes

az fidalgo admin network-setting delete \
    --name=${NIX_ENV_PREFIX}-my-network-setting \
    --resource-group=${NIX_FID_RESOURCE_GROUP} \
    --subscription=${NIX_FID_SUBSCRIPTION} \
    --yes
# This NetworkConnection is currently attached to one or more DevCenters. Detach from dependent DevCenters before attempting to delete this resource.

az fidalgo admin attached-network list \
    --dev-center-name=${NIX_ENV_PREFIX}-my-dev-center \
    --resource-group=${NIX_FID_RESOURCE_GROUP}
# Returns no attached networks
    
az fidalgo admin dev-center show \
    --name=${NIX_ENV_PREFIX}-my-dev-center \
    --resource-group=${NIX_FID_RESOURCE_GROUP} \
    --subscription=${NIX_FID_SUBSCRIPTION}

az fidalgo admin network-setting show \
    --name=${NIX_ENV_PREFIX}-my-network-setting \
    --resource-group=${NIX_FID_RESOURCE_GROUP} \
    --subscription=${NIX_FID_SUBSCRIPTION}

az group delete \
    --name ${NIX_FID_RESOURCE_GROUP}

while true; do
    az fidalgo dev virtual-machine show \
        --dev-center=${NIX_ENV_PREFIX}-my-dev-center \
        --name=${NIX_ENV_PREFIX}-my-vm \
        --project-name=${NIX_ENV_PREFIX}-my-project \
        --query provisioningState \
        --output tsv
    sleep 10
done
