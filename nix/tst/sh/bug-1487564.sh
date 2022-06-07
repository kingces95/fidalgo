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

