fd-login-as-network-administrator
az group create \
    --location=${NIX_CPC_LOCATION} \
    --name=${NIX_CPC_RESOURCE_GROUP}
az network vnet create \
    --location=${NIX_CPC_LOCATION} \
    --name=${NIX_ENV_PREFIX}-myvnet \
    --resource-group=${NIX_CPC_RESOURCE_GROUP} \
    --subscription=${NIX_CPC_SUBSCRIPTION}
az network vnet subnet create \
    --address-prefixes=10.0.0.0/24 \
    --delegations=Microsoft.Fidalgo/networkSettings \
    --name=${NIX_ENV_PREFIX}-mysubnet \
    --resource-group=${NIX_CPC_RESOURCE_GROUP} \
    --subscription=${NIX_CPC_SUBSCRIPTION} \
    --vnet-name=${NIX_ENV_PREFIX}-myvnet
fd-login-as-administrator
az group create \
    --location=${NIX_FID_LOCATION} \
    --name=${NIX_FID_RESOURCE_GROUP}
az fidalgo admin dev-center create \
    --identity-type=SystemAssigned \
    --location=${NIX_FID_LOCATION} \
    --name=${NIX_ENV_PREFIX}-mydevcenter \
    --resource-group=${NIX_FID_RESOURCE_GROUP} \
    --subscription=${NIX_FID_SUBSCRIPTION}
az fidalgo admin devbox-definition create \
    --dev-center-name=${NIX_ENV_PREFIX}-mydevcenter \
    --image-reference=id=/subscriptions/${NIX_CPC_SUBSCRIPTION}/resourceGroups/${NIX_FID_RESOURCE_GROUP}/providers/Microsoft.Fidalgo/devcenters/${NIX_ENV_PREFIX}-mydevcenter/galleries/Default/images/MicrosoftWindowsDesktop_windows-ent-cpc_win11-21h2-ent-cpc-m365 \
    --location=${NIX_FID_LOCATION} \
    --name=${NIX_ENV_PREFIX}-mydevboxdefinition \
    --resource-group=${NIX_FID_RESOURCE_GROUP} \
    --sku-name=PrivatePreview \
    --subscription=${NIX_FID_SUBSCRIPTION}
az fidalgo admin network-setting create \
    --domain-join-type=AzureADJoin \
    --location=${NIX_FID_LOCATION} \
    --name=${NIX_ENV_PREFIX}-mynetworksetting \
    --resource-group=${NIX_FID_RESOURCE_GROUP} \
    --subnet-id=/subscriptions/${NIX_CPC_SUBSCRIPTION}/resourceGroups/${NIX_CPC_RESOURCE_GROUP}/providers/Microsoft.Network/virtualNetworks/${NIX_ENV_PREFIX}-myvnet/subnets/${NIX_ENV_PREFIX}-mysubnet \
    --subscription=${NIX_FID_SUBSCRIPTION}
az fidalgo admin project create \
    --dev-center-id=/subscriptions/${NIX_FID_SUBSCRIPTION}/resourceGroups/${NIX_FID_RESOURCE_GROUP}/providers/Microsoft.Fidalgo/devcenters/${NIX_ENV_PREFIX}-mydevcenter \
    --location=${NIX_FID_LOCATION} \
    --name=${NIX_ENV_PREFIX}-myproject \
    --resource-group=${NIX_FID_RESOURCE_GROUP} \
    --subscription=${NIX_FID_SUBSCRIPTION}
az role assignment create \
    --assignee=${NIX_ENV_PERSONA_DEVELOPER} \
    --role=Contributor \
    --scope=/subscriptions/${NIX_FID_SUBSCRIPTION}/resourceGroups/${NIX_FID_RESOURCE_GROUP}/providers/Microsoft.Fidalgo/projects/${NIX_ENV_PREFIX}-myproject \
    --subscription=${NIX_FID_SUBSCRIPTION}

az fidalgo admin attached-network create \
    --attached-network-connection-name=${NIX_ENV_PREFIX}-myattachednetwork \
    --network-connection-resource-id=/subscriptions/${NIX_FID_SUBSCRIPTION}/resourceGroups/${NIX_FID_RESOURCE_GROUP}/providers/Microsoft.Fidalgo/NetworkSettings/${NIX_ENV_PREFIX}-mynetworksetting \
    --dev-center-name=${NIX_ENV_PREFIX}-mydevcenter \
    --resource-group=${NIX_FID_RESOURCE_GROUP}
az fidalgo admin pool create \
    --devbox-definition-name=${NIX_ENV_PREFIX}-mydevboxdefinition \
    --location=${NIX_FID_LOCATION} \
    --name=${NIX_ENV_PREFIX}-mypool \
    --network-connection-name=${NIX_ENV_PREFIX}-myattachednetwork \
    --project-name=${NIX_ENV_PREFIX}-myproject \
    --resource-group=${NIX_FID_RESOURCE_GROUP} \
    --subscription=${NIX_FID_SUBSCRIPTION}

fd-login-as-developer
az fidalgo dev virtual-machine create \
    --dev-center=${NIX_ENV_PREFIX}-mydevcenter \
    --fidalgo-dns-suffix=${NIX_FID_DNS_SUFFIX} \
    --name=${NIX_ENV_PREFIX}-myvm \
    --pool-name=${NIX_ENV_PREFIX}-mypool \
    --project-name=${NIX_ENV_PREFIX}-myproject \
    --subscription=${NIX_FID_SUBSCRIPTION} 

az fidalgo admin dev-center show \
    --name=${NIX_ENV_PREFIX}-mydevcenter \
    --resource-group=${NIX_FID_RESOURCE_GROUP} \
    --subscription=${NIX_FID_SUBSCRIPTION}
az fidalgo dev virtual-machine show \
    --dev-center=${NIX_ENV_PREFIX}-mydevcenter \
    --name=${NIX_ENV_PREFIX}-myvm \
    --project-name=${NIX_ENV_PREFIX}-myproject
az fidalgo dev virtual-machine list \
    --dev-center=${NIX_ENV_PREFIX}-mydevcenter \
    --project-name=${NIX_ENV_PREFIX}-myproject
az fidalgo dev virtual-machine get-remote-connection \
    --dev-center=${NIX_ENV_PREFIX}-mydevcenter \
    --name=${NIX_ENV_PREFIX}-myvm \
    --project-name=${NIX_ENV_PREFIX}-myproject
az fidalgo dev virtual-machine stop \
    --dev-center=${NIX_ENV_PREFIX}-mydevcenter \
    --name=${NIX_ENV_PREFIX}-myvm \
    --project-name=${NIX_ENV_PREFIX}-myproject
az fidalgo dev virtual-machine delete \
    --dev-center=${NIX_ENV_PREFIX}-mydevcenter \
    --name=${NIX_ENV_PREFIX}-myvm \
    --project-name=${NIX_ENV_PREFIX}-myproject \
    --yes
az fidalgo admin network-setting delete \
    --name=${NIX_ENV_PREFIX}-mynetworksetting \
    --resource-group=${NIX_FID_RESOURCE_GROUP}
az fidalgo admin network-setting show \
    --name=${NIX_ENV_PREFIX}-mynetworksetting \
    --resource-group=${NIX_FID_RESOURCE_GROUP} 

az group delete \
    --name ${NIX_CPC_RESOURCE_GROUP}
az group delete \
    --name ${NIX_FID_RESOURCE_GROUP}

while true; do
    az fidalgo dev virtual-machine show \
        --dev-center=${NIX_ENV_PREFIX}-mydevcenter \
        --name=${NIX_ENV_PREFIX}-myvm \
        --project-name=${NIX_ENV_PREFIX}-myproject \
        --query provisioningState \
        --output tsv
    sleep 10
done
