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
