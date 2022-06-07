fd-login-as-network-administrator
az group create \
    --location=${NIX_FID_LOCATION} \
    --name=${NIX_CPC_RESOURCE_GROUP}
az network vnet create \
    --name=${NIX_ENV_PREFIX}-my-vnet \
    --resource-group=${NIX_CPC_RESOURCE_GROUP} \
    --location=${NIX_CPC_LOCATION} \
    --subscription=${NIX_CPC_SUBSCRIPTION}
az network vnet subnet create \
    --name=${NIX_ENV_PREFIX}-my-subnet \
    --resource-group=${NIX_CPC_RESOURCE_GROUP} \
    --subscription=${NIX_CPC_SUBSCRIPTION} \
    --address-prefixes=10.0.0.0/24 \
    --delegations=Microsoft.Fidalgo/networkSettings \
    --vnet-name=${NIX_ENV_PREFIX}-my-vnet
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
    --domain-join-type=AzureADJoin \
    --subnet-id=/subscriptions/${NIX_CPC_SUBSCRIPTION}/resourceGroups/${NIX_CPC_RESOURCE_GROUP}/providers/Microsoft.Network/virtualNetworks/${NIX_ENV_PREFIX}-my-vnet/subnets/${NIX_ENV_PREFIX}-my-subnet
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

az fidalgo admin dev-center show \
    --name=${NIX_ENV_PREFIX}-my-dev-center \
    --resource-group=${NIX_FID_RESOURCE_GROUP} \
    --subscription=${NIX_FID_SUBSCRIPTION}
az fidalgo dev virtual-machine show \
    --dev-center=${NIX_ENV_PREFIX}-my-dev-center \
    --name=${NIX_ENV_PREFIX}-my-vm \
    --project-name=${NIX_ENV_PREFIX}-my-project
az fidalgo dev virtual-machine list \
    --dev-center=${NIX_ENV_PREFIX}-my-dev-center \
    --project-name=${NIX_ENV_PREFIX}-my-project
az fidalgo dev virtual-machine get-remote-connection \
    --dev-center=${NIX_ENV_PREFIX}-my-dev-center \
    --name=${NIX_ENV_PREFIX}-my-vm \
    --project-name=${NIX_ENV_PREFIX}-my-project
az fidalgo dev virtual-machine stop \
    --dev-center=${NIX_ENV_PREFIX}-my-dev-center \
    --name=${NIX_ENV_PREFIX}-my-vm \
    --project-name=${NIX_ENV_PREFIX}-my-project
az fidalgo dev virtual-machine delete \
    --dev-center=${NIX_ENV_PREFIX}-my-dev-center \
    --name=${NIX_ENV_PREFIX}-my-vm \
    --user-id=$(fd-login-as-vm-user; az-signed-in-user-id) \
    --fidalgo-dns-suffix=${NIX_FID_DNS_SUFFIX} \
    --project-name=${NIX_ENV_PREFIX}-my-project \
    --yes
az fidalgo admin network-setting delete \
    --name=${NIX_ENV_PREFIX}-my-network-setting \
    --resource-group=${NIX_FID_RESOURCE_GROUP}
az fidalgo admin network-setting show \
    --name=${NIX_ENV_PREFIX}-my-network-setting \
    --resource-group=${NIX_FID_RESOURCE_GROUP} 
az fidalgo admin attached-network show \
    --dev-center-name=${NIX_ENV_PREFIX}-my-dev-center \
    --name=${NIX_ENV_PREFIX}-my-attached-network \
    --resource-group=${NIX_FID_RESOURCE_GROUP} \
    --subscription=${NIX_FID_SUBSCRIPTION}
az fidalgo admin network-setting show-health-detail \
    --name=${NIX_ENV_PREFIX}-my-network-setting \
    --resource-group=${NIX_FID_RESOURCE_GROUP} \
    --subscription=${NIX_FID_SUBSCRIPTION}
az network vnet show \
    --name=${NIX_ENV_PREFIX}-my-vnet \
    --resource-group=${NIX_CPC_RESOURCE_GROUP} \
    --subscription=${NIX_CPC_SUBSCRIPTION}

az group delete \
    --name ${NIX_CPC_RESOURCE_GROUP} \
    --yes
az group delete \
    --name ${NIX_FID_RESOURCE_GROUP} \
    --yes

while true; do
    az fidalgo dev virtual-machine show \
        --dev-center=${NIX_ENV_PREFIX}-my-dev-center \
        --name=${NIX_ENV_PREFIX}-my-vm \
        --project-name=${NIX_ENV_PREFIX}-my-project \
        --fidalgo-dns-suffix=${NIX_FID_DNS_SUFFIX} \
        --user-id=$(fd-login-as-vm-user; az-signed-in-user-id) \
        --query provisioningState \
        --output tsv
    sleep 10
done
