# https://github.com/Azure/Project-Fidalgo-PrivatePreview/blob/main/Documentation/configure-catalog.md#get-the-repository-information-and-credentials
# adding RBAC owner to System Assigned identity

# https://github.com/kingces95/Project-Fidalgo-PrivatePreview.git

az keyvault create \
    --subscription 974ae608-fbe5-429f-83ae-924a64019bf3 \
    --resource-group ${NIX_ENV_PREFIX}-rg \
    --name ${NIX_ENV_PREFIX}-kv

az keyvault secret set \
    --subscription 974ae608-fbe5-429f-83ae-924a64019bf3 \
    --vault-name ${NIX_ENV_PREFIX}-kv \
    --name ${NIX_ENV_PREFIX}-kvs \
    --value "${PAT}"

# add access policy so alias can see secrets in portal
# add access policy so devceter can get secrets
# seems to need more than get

az keyvault secret show \
    --subscription 974ae608-fbe5-429f-83ae-924a64019bf3 \
    --vault-name ${NIX_ENV_PREFIX}-kv \
    --name ${NIX_ENV_PREFIX}-kvs \
    --query id \
    --output tsv

# https://nix-chrkin-ppe-11-kv.vault.azure.net/secrets/nix-chrkin-ppe-11-kvs/d6104f87a8864fc5ad0d1719949f1ced

az fidalgo admin catalog create \
    --subscription 974ae608-fbe5-429f-83ae-924a64019bf3 \
    --resource-group ${NIX_ENV_PREFIX}-rg \
    --dev-center-name ${NIX_ENV_PREFIX}-my-dev-center \
    --catalog-name ${NIX_ENV_PREFIX}-my-catalog \
    --git-hub \
        uri=https://github.com/kingces95/Project-Fidalgo-PrivatePreview.git \
        branch=main \
        secret-identifier=https://nix-chrkin-ppe-11-kv.vault.azure.net/secrets/nix-chrkin-ppe-11-kvs/d6104f87a8864fc5ad0d1719949f1ced \
        path=/Catalog

az fidalgo admin environment-type create \
    --subscription 974ae608-fbe5-429f-83ae-924a64019bf3 \
    --resource-group ${NIX_ENV_PREFIX}-rg \
    --dev-center-name ${NIX_ENV_PREFIX}-my-dev-center \
    --name ${NIX_ENV_PREFIX}-my-env-type
    
az fidalgo admin environment-type list \
    --subscription 974ae608-fbe5-429f-83ae-924a64019bf3 \
    --resource-group ${NIX_ENV_PREFIX}-rg \
    --dev-center-name ${NIX_ENV_PREFIX}-my-dev-center \
    --output table

az fidalgo admin catalog-item list \
    --subscription 974ae608-fbe5-429f-83ae-924a64019bf3 \
    --resource-group ${NIX_ENV_PREFIX}-rg \
    --dev-center-name ${NIX_ENV_PREFIX}-my-dev-center \
    --project-name=${NIX_ENV_PREFIX}-my-project \
    --output table

az fidalgo admin mapping create \
    --subscription 974ae608-fbe5-429f-83ae-924a64019bf3 \
    --resource-group ${NIX_ENV_PREFIX}-rg \
    --dev-center-name ${NIX_ENV_PREFIX}-my-dev-center \
    --project-id /subscriptions/974ae608-fbe5-429f-83ae-924a64019bf3/resourceGroups/${NIX_ENV_PREFIX}-rg/providers/Microsoft.Fidalgo/projects/${NIX_ENV_PREFIX}-my-project \
    --environment-type ${NIX_ENV_PREFIX}-my-env-type \
    --mapped-subscription-id /subscriptions/974ae608-fbe5-429f-83ae-924a64019bf3 \
    --name ${NIX_ENV_PREFIX}-my-mapping

az fidalgo admin environment create \
    --subscription 974ae608-fbe5-429f-83ae-924a64019bf3 \
    --resource-group ${NIX_ENV_PREFIX}-rg \
    --project-name=${NIX_ENV_PREFIX}-my-project \
    --environment-type ${NIX_ENV_PREFIX}-my-env-type \
    --catalog-item-name Empty \
    --name ${NIX_ENV_PREFIX}-my-env-empty

az fidalgo admin environment create \
    --subscription 974ae608-fbe5-429f-83ae-924a64019bf3 \
    --resource-group ${NIX_ENV_PREFIX}-rg \
    --project-name=${NIX_ENV_PREFIX}-my-project \
    --environment-type ${NIX_ENV_PREFIX}-my-env-type \
    --catalog-item-name WebApp \
    --name ${NIX_ENV_PREFIX}-my-env-web-app

az fidalgo admin environment create \
    --subscription 974ae608-fbe5-429f-83ae-924a64019bf3 \
    --resource-group ${NIX_ENV_PREFIX}-rg \
    --project-name=${NIX_ENV_PREFIX}-my-project \
    --environment-type ${NIX_ENV_PREFIX}-my-env-type \
    --catalog-item-name FunctionApp \
    --name ${NIX_ENV_PREFIX}-my-env-function-app

# environment type not marked as [Required]