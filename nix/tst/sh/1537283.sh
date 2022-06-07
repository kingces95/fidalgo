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

az fidalgo admin network-setting create \
    --domain-join-type=AzureADJoin \
    --location=${NIX_FID_LOCATION} \
    --name=${NIX_ENV_PREFIX}-mynetworksetting \
    --resource-group=${NIX_FID_RESOURCE_GROUP} \
    --subnet-id=/subscriptions/${NIX_CPC_SUBSCRIPTION}/resourceGroups/${NIX_MY_RESOURCE_GROUP}/providers/Microsoft.Network/virtualNetworks/${NIX_MY_VNET}/subnets/${NIX_MY_SUBNET} \
    --subscription=${NIX_FID_SUBSCRIPTION}

az fidalgo admin network-setting create \
    --domain-join-type=HybridAzureADJoin \
    --location=${NIX_FID_LOCATION} \
    --domain-name=${NIX_CPC_DOMAIN_NAME} \
    --domain-password=$(nix::secret::cat) \
    --domain-username="${NIX_CPC_DOMAIN_JOIN_ACCOUNT}" \
    --name=${NIX_ENV_PREFIX}-myhybridnetworksetting \
    --resource-group=${NIX_FID_RESOURCE_GROUP} \
    --subnet-id=/subscriptions/${NIX_CPC_SUBSCRIPTION}/resourceGroups/${NIX_MY_RESOURCE_GROUP}/providers/Microsoft.Network/virtualNetworks/${NIX_MY_VNET}/subnets/${NIX_MY_SUBNET} \
    --subscription=${NIX_FID_SUBSCRIPTION}

az fidalgo admin attached-network create \
    --attached-network-connection-name=${NIX_ENV_PREFIX}-myattachednetwork \
    --network-connection-resource-id=/subscriptions/${NIX_FID_SUBSCRIPTION}/resourceGroups/${NIX_FID_RESOURCE_GROUP}/providers/Microsoft.Fidalgo/NetworkSettings/${NIX_ENV_PREFIX}-mynetworksetting \
    --dev-center-name=${NIX_ENV_PREFIX}-mydevcenter \
    --resource-group=${NIX_FID_RESOURCE_GROUP}

az fidalgo admin attached-network create \
    --attached-network-connection-name=${NIX_ENV_PREFIX}-myhybridattachednetwork \
    --network-connection-resource-id=/subscriptions/${NIX_FID_SUBSCRIPTION}/resourceGroups/${NIX_FID_RESOURCE_GROUP}/providers/Microsoft.Fidalgo/NetworkSettings/${NIX_ENV_PREFIX}-myhybridnetworksetting \
    --dev-center-name=${NIX_ENV_PREFIX}-mydevcenter \
    --resource-group=${NIX_FID_RESOURCE_GROUP}

az fidalgo admin pool create \
    --name=${NIX_ENV_PREFIX}-mypool \
    --devbox-definition-name=${NIX_ENV_PREFIX}-mydevboxdefinition \
    --location=${NIX_FID_LOCATION} \
    --network-connection-name=${NIX_ENV_PREFIX}-myattachednetwork \
    --project-name=${NIX_ENV_PREFIX}-myproject \
    --resource-group=${NIX_FID_RESOURCE_GROUP} \
    --subscription=${NIX_FID_SUBSCRIPTION}

az fidalgo admin network-setting show-health-detail \
    --name=${NIX_ENV_PREFIX}-myhybridnetworksetting \
    --resource-group=${NIX_FID_RESOURCE_GROUP} \
    --subscription=${NIX_FID_SUBSCRIPTION}

az fidalgo admin pool update \
    --name=${NIX_ENV_PREFIX}-mypool \
    --project-name=${NIX_ENV_PREFIX}-myproject \
    --resource-group=${NIX_FID_RESOURCE_GROUP} \
    --subscription=${NIX_FID_SUBSCRIPTION} \
    --network-connection-name=${NIX_ENV_PREFIX}-myhybridattachednetwork

az fidalgo admin attached-network delete \
    --attached-network-connection-name=${NIX_ENV_PREFIX}-myattachednetwork \
    --dev-center-name=${NIX_ENV_PREFIX}-mydevcenter \
    --resource-group=${NIX_FID_RESOURCE_GROUP} \
    --yes

az fidalgo admin attached-network delete \
    --attached-network-connection-name=${NIX_ENV_PREFIX}-myhybridattachednetwork \
    --dev-center-name=${NIX_ENV_PREFIX}-mydevcenter \
    --resource-group=${NIX_FID_RESOURCE_GROUP} \
    --yes

az fidalgo admin pool delete \
    --name=${NIX_ENV_PREFIX}-mypool \
    --project-name=${NIX_ENV_PREFIX}-myproject \
    --resource-group=${NIX_FID_RESOURCE_GROUP} \
    --subscription=${NIX_FID_SUBSCRIPTION} \
    --yes

az fidalgo admin network-setting delete \
    --name=${NIX_ENV_PREFIX}-myhybridnetworksetting \
    --resource-group=${NIX_FID_RESOURCE_GROUP} \
    --subscription=${NIX_FID_SUBSCRIPTION} \
    --yes
# This NetworkConnection is currently attached to one or more DevCenters. Detach from dependent DevCenters before attempting to delete this resource.

az fidalgo admin attached-network list \
    --dev-center-name=${NIX_ENV_PREFIX}-mydevcenter \
    --resource-group=${NIX_FID_RESOURCE_GROUP}
# Returns no attached networks
    
az fidalgo admin dev-center show \
    --name=${NIX_ENV_PREFIX}-mydevcenter \
    --resource-group=${NIX_FID_RESOURCE_GROUP} \
    --subscription=${NIX_FID_SUBSCRIPTION}

az fidalgo admin network-setting show \
    --name=${NIX_ENV_PREFIX}-mynetworksetting \
    --resource-group=${NIX_FID_RESOURCE_GROUP} \
    --subscription=${NIX_FID_SUBSCRIPTION}

az group delete \
    --name ${NIX_FID_RESOURCE_GROUP}
