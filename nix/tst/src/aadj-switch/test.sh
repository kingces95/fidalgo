az fidalgo admin network-setting show-health-detail \
    --name=${NIX_ENV_PREFIX}-my-hybrid-network-setting \
    --resource-group=${NIX_FID_RESOURCE_GROUP} \
    --subscription=${NIX_FID_SUBSCRIPTION}

az fidalgo admin pool update \
    --name=${NIX_ENV_PREFIX}-my-pool \
    --project-name=${NIX_ENV_PREFIX}-my-project \
    --resource-group=${NIX_FID_RESOURCE_GROUP} \
    --subscription=${NIX_FID_SUBSCRIPTION} \
    --network-connection-name=${NIX_ENV_PREFIX}-my-hybrid-attached-network

az fidalgo admin attached-network delete \
    --attached-network-connection-name=${NIX_ENV_PREFIX}-my-attached-network \
    --dev-center-name=${NIX_ENV_PREFIX}-my-dev-center \
    --resource-group=${NIX_FID_RESOURCE_GROUP} \
    --yes

az fidalgo admin attached-network delete \
    --attached-network-connection-name=${NIX_ENV_PREFIX}-my-hybrid-attached-network \
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
    --name=${NIX_ENV_PREFIX}-my-hybrid-network-setting \
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
