# azure config
export AZURE_EXTENSION_USE_DYNAMIC_INSTALL=yes_without_prompt
export AZURE_EXTENSION_RUN_AFTER_DYNAMIC_INSTALL=True

# bash
readonly NIX_INTEGER_MAX=10000000

# colors
readonly NIX_COLOR_RED='0;31'
readonly NIX_COLOR_GREEN='0;32'
readonly NIX_COLOR_YELLOW='0;33'
readonly NIX_COLOR_CYAN='0;36'

# directories
readonly NIX_DIR=$(cd $(dirname ${BASH_SOURCE}); pwd)
readonly NIX_DIR_NIX_PGP="${NIX_DIR}/pgp"
readonly NIX_DIR_NIX_SSH="${NIX_DIR}/ssh"
readonly NIX_DIR_NIX_SRC="${NIX_DIR}/src"
readonly NIX_DIR_NIX_OS="${NIX_DIR}/os"
readonly NIX_DIR_NIX_OS_ETC="${NIX_DIR_NIX_OS}/etc"
readonly NIX_DIR_NIX_OS_APT="${NIX_DIR_NIX_OS}/apt"
readonly NIX_DIR_NIX_OS_APT_SOURCES="${NIX_DIR_NIX_OS_APT}/sources"
readonly NIX_DIR_NIX_TST="${NIX_DIR}/tst"
readonly NIX_DIR_NIX_TST_SRC="${NIX_DIR_NIX_TST}/src"
readonly NIX_DIR_NIX_TST_SRC_RESOURCE="${NIX_DIR_NIX_TST_SRC}/resource"
readonly NIX_DIR_NIX_TST_SH="${NIX_DIR_NIX_TST}/sh"
readonly NIX_DIR_NIX_TST_BUG="${NIX_DIR_NIX_TST}/bug"
readonly NIX_DIR_NIX_TST_ENV="${NIX_DIR_NIX_TST}/env"
readonly NIX_DIR_NIX_USR="${NIX_DIR}/usr"

# repo directories
readonly NIX_REPO_DIR=$(cd $(dirname ${BASH_SOURCE})/..; pwd)
# readonly NIX_REPO_DIR_SRC=$(cd ${NIX_REPO_DIR}/src; pwd)
readonly NIX_REPO_DIR_KUSTO=$(cd ${NIX_REPO_DIR}/kusto; pwd)
readonly NIX_REPO_DIR_AZ=$(cd ${NIX_REPO_DIR}/az; pwd)

# os directories
readonly NIX_OS_DIR_TEMP='/tmp'
readonly NIX_OS_DIR_ETC='/etc'
readonly NIX_OS_DIR_APT="${NIX_OS_DIR_ETC}/apt"

# wsl
readonly NIX_WSL_CONF="${NIX_DIR_NIX_OS_ETC}/wsl.conf"
readonly NIX_OS_WSL_CONF="${NIX_OS_DIR_ETC}/wsl.conf"

# home directories
readonly NIX_HOME_DIR_SSH="${HOME}/.ssh"
readonly NIX_HOME_SUDO_HUSH="${HOME}/.sudo_as_admin_successful"

# apt
readonly NIX_OS_APT_DIR_LISTS='/var/lib/apt/lists'
readonly NIX_OS_APT_DIR_TRUSTED="${NIX_OS_DIR_APT}/trusted.gpg.d"
readonly NIX_OS_APT_DIR_SOURCES="${NIX_OS_DIR_APT}/sources.list.d"
readonly NIX_OS_APT_SOURCES_LIST="${NIX_OS_DIR_APT}/sources.list"
readonly NIX_OS_APT_CONFIG_HASH="${NIX_OS_DIR_APT}/config.hash"
readonly NIX_OS_APT_PACKAGE_TIMESTAMP="${NIX_OS_DIR_ETC}/apt-last-updated"
readonly NIX_OS_APT_LAST_UPDATE_TIMEOUT=30

# ssh
readonly NIX_OS_SSH_KNOWN_HOSTS="${NIX_HOME_DIR_SSH}/known_hosts"
readonly NIX_SSH_KNOWN_HOST="${NIX_DIR_NIX_SSH}/known_hosts"

# source control
readonly NIX_AZURE_DEV_SSH_HOST='ssh.dev.azure.com'
readonly NIX_AZURE_DEV_SSH_KNOWN_HOST="${NIX_DIR_NIX_SSH}/${NIX_AZURE_DEV_SSH_HOST}"
readonly NIX_AZURE_DEV_SSH_WWW='https://dev.azure.com/devdiv/_usersSettings/keys'

# tool
readonly NIX_OS_APT_TOOLS="${NIX_DIR}/.tools"

# tool (apt)
readonly NIX_TOOL_APT_FIELD_PACKAGE=3
readonly NIX_TOOL_APT_FIELD_PGP=4
readonly NIX_TOOL_APT_FIELD_REPOSITORY=5

# tool (nuget)
readonly NIX_TOOL_NUGET_DIR="${NIX_OS_DIR_TEMP}/nuget"
readonly NIX_TOOL_NUGET_FIELD_PACKAGE=3
readonly NIX_TOOL_NUGET_FIELD_VERSION=4
readonly NIX_TOOL_NUGET_FIELD_FRAMEWORK=5

# personal
readonly NIX_MY_ALIAS=${USER}
readonly NIX_MY_DIR="${NIX_DIR_NIX_USR}/${NIX_MY_ALIAS}"
readonly NIX_MY_PROFILE="${NIX_MY_DIR}/profile.sh"

# azure conig
readonly NIX_AZURE_DIR="${NIX_DIR}/.azure"
readonly NIX_AZURE_PID_DIR="${NIX_AZURE_DIR}/${NIX}"
readonly NIX_AZURE_TOKEN_CACHE_FILE='msal_token_cache.json'
readonly NIX_AZURE_PROFILE_FILE='azureProfile.json'
readonly NIX_AZURE_TOKEN_CACHE="${NIX_AZURE_DIR}/${NIX_AZURE_TOKEN_CACHE_FILE}"

# CPC bugs
readonly NIX_WWW_CPC_BUG_INTEGRATION="https://aka.ms/devdivcpcintegrationbug"
readonly NIX_WWW_CPC_BUG="https://aka.ms/devdivcpcbug"
readonly NIX_WWW_CPC_FEATURE="https://aka.ms/fidalgow365featurerequest"

# dependencies
readonly NIX_DEPENDENCY_DEB=(
    https://packages.microsoft.com/config/ubuntu/21.04/packages-microsoft-prod.deb
)

readonly NIX_DEPENDENCY_APT=(
    apt-transport-https 
    lsb-release 
    gnupg 
    curl
    nuget
    jq
    dotnet-runtime-5.0
    colordiff
)

# global
readonly NIX_SECRET_FILE='.secret'
readonly NIX_SECRET="${NIX_DIR}/${NIX_SECRET_FILE}"
readonly NIX_UPN_MICROSOFT="${USER}@microsoft.com"

# kusto (type inference)
readonly -A NIX_KUSTO_TYPE_REGEX=(
    ['^"']='string'
    ['^true$']='boolean'
    ['^false$']='boolean'
    ['^[[:digit:]]+$']='long'
    ['^[[:digit:]]+[.][[:digit:]]+$']='real'
    ['^ago']='datetime'
    ['^[[:digit:]]+[wdhms]']='timespan'
)

# bookmarks
readonly NIX_WWW_OPTIONAL_CLAIMS=https://identitydocs.azurewebsites.net/static/v2/active-directory-optional-claims.html
readonly NIX_WWW_TOKEN_PARSER=https://jwt.io/
readonly NIX_WWW_SPECS=https://microsoft.sharepoint.com/teams/Fidalgo/Shared%20Documents
readonly NIX_WWW_GENEVA_ACTIONS=https://dev.azure.com/devdiv/OnlineServices/_wiki/wikis/OnlineServices.wiki/27512/Geneva-Actions

# kusto binary
readonly NIX_KUSTO_DIR="${NIX_TOOL_NUGET_DIR}/Microsoft.Azure.Kusto.Tools/6.0.1/net5.0"
readonly NIX_KUSTO_DLL="${NIX_KUSTO_DIR}/Microsoft.Azure.Kusto.Tools.6.0.1/tools/net5.0/Kusto.Cli.dll"

# kusto bookmarks
readonly NIX_KUSTO_WWW_AUTH_FLOW=https://docs.microsoft.com/en-us/azure/data-explorer/kusto/management/access-control/how-to-authenticate-with-aad

# kusto connection
readonly NIX_KUSTO_TOKEN_URL=https://help.kusto.windows.net

# kusto public
readonly NIX_KUSTO_PUBLIC_CLUSTER=fidalgopublic.westus2
readonly NIX_KUSTO_PUBLIC_DATA_SOURCE=https://fidalgopublic.westus2.kusto.windows.net/
readonly NIX_KUSTO_PUBLIC_INITIAL_CATALOG=fidalgo-public

# kusto dogfood
readonly NIX_KUSTO_DOGFOOD_CLUSTER=fidalgodogfood.westus2
readonly NIX_KUSTO_DOGFOOD_DATA_SOURCE=https://fidalgodogfood.westus2.kusto.windows.net
readonly NIX_KUSTO_DOGFOOD_INITIAL_CATALOG=fidalgo-dogfood

# kusto (query editing)
readonly NIX_KUSTO_VSCODE_SYNTAX_HIGHLIGHTING='rosshamish.kuskus-kusto-syntax-highlighting'

# http
readonly NIX_HTTP_DATAPLANE="${NIX_REPO_DIR}/http/dataplane"

# resource (azure)
readonly -A NIX_AZURE_RESOURCE=(
    ['devbox-definition']='fidalgo admin devbox-definition'
    ['dev-center']='fidalgo admin dev-center'
    ['gallery']='fidalgo admin gallery'
    ['machine-definition']='fidalgo admin machine-definition'
    ['network-setting']='fidalgo admin network-setting'
    ['pool']='fidalgo admin pool'
    ['project']='fidalgo admin project'
    ['subnet']='network vnet subnet'
    ['virtual-machine']='fidalgo dev virtual-machine'
    ['vnet']='network vnet'
    ['attached-network']='fidalgo admin attached-network'
    ['role-assignment']='role assignment'
    ['group']='group'
)
readonly -A NIX_AZURE_RESOURCE_PROVIDER=(
    ['vnet']='Microsoft.Network/virtualNetworks'
    ['network-setting']='Microsoft.Fidalgo/networksettings'
    ['gallery']='Microsoft.Fidalgo/gallery'
    ['dev-center']='Microsoft.Fidalgo/devcenters'
    ['project']='Microsoft.Fidalgo/projects'
    ['machine-definition']='Microsoft.Fidalgo/machinedefinitions'
    ['devbox-definition']='Microsoft.Fidalgo/devboxdefinition'

    ['pool']='pools'
    ['virtual-machine']='virtualmachine'
    ['subnet']='subnets'
    ['attached-network']='attachednetworks'
)
readonly -A NIX_AZURE_RESOURCE_PARENT=(
    ['gallery']='dev-center'
    ['pool']='project'
    ['virtual-machine']='project'
    ['subnet']='vnet'
    ['attached-network']='dev-center'
)
readonly -A NIX_AZURE_RESOURCE_POINTS_TO=(
    # parent-name added by default
    ['virtual-machine']='dev-center pool-name'
    ['project']='dev-center-id'
    ['pool']='devbox-definition-name attached-network-name'
    ['attached-network']='network-setting-id'
    ['network-setting']='subnet-id'
    ['devbox-definition']='dev-center-name'
)
readonly -A NIX_AZURE_RESOURCE_ACTIVATION_POSET=(
    ['vnet']=''
    ['subnet']='vnet'
    ['dev-center']='subnet'
    ['gallery']='dev-center'
    ['machine-definition']='subnet'
    ['devbox-definition']='subnet'
    ['project']='dev-center'
    ['network-setting']='subnet'
    ['attached-network']='dev-center network-setting'
    ['pool']='project devbox-definition machine-definition attached-network'
    ['virtual-machine']='dev-center project pool'
)
readonly -A NIX_AZURE_RESOURCE_NO_RESOURCE_GROUP=(
    ['virtual-machine']=true
)
readonly -A NIX_AZURE_RESOURCE_PERSONA=(
    ['vnet']='network-administrator'
    ['subnet']='network-administrator'
    ['dev-center']='administrator'
    ['gallery']='administrator'
    ['machine-definition']='administrator'
    ['devbox-definition']='administrator'
    ['project']='administrator'
    ['network-setting']='administrator'
    ['attached-network']='administrator'
    ['pool']='administrator'
    ['virtual-machine']='developer'
)
readonly -A NIX_AZURE_CPC_RESOURCE=(
    ['vnet']=true
    ['subnet']=true
)

# cert
readonly NIX_CERT_WWW=https://dev.azure.com/devdiv/OnlineServices/_wiki/wikis/OnlineServices.wiki/27763/Certificate-Rotation
readonly NIX_CERT_ICM=https://portal.microsofticm.com/imp/v3/incidents/search/advanced?sl=mykzxnwjxrz
readonly NIX_CERT_OPT_CLAIMS=https://identitydocs.azurewebsites.net/static/v2/active-directory-optional-claims.html

# api
readonly NIX_API_VSCODE_PLUGIN_VISUALIZER=42Crunch.vscode-openapi
readonly NIX_API_VERSION=(
    2022-12-31-privatepreview
    2022-03-01-privatepreview
    2021-12-01-privatepreview
    2021-08-01-privatepreview
)

# az cli
readonly NIX_CLI_WWW=https://devdiv.visualstudio.com/OnlineServices/_wiki/wikis/OnlineServices.wiki/21260/Az-Cli
readonly NIX_CLI_CURL=https://fidalgosetup.blob.core.windows.net/cli-extensions
readonly NIX_CLI_VERSION=(
    0.3.2
    0.3.1
    0.2.0
    0.1.0
)

# environments
readonly NIX_FIDALGO_WWW_ENVIRONMENTS=https://devdiv.visualstudio.com/OnlineServices/_wiki/wikis/OnlineServices.wiki/20669/Environments

# const
readonly NIX_CONST_FIDALGO="fidalgo"
readonly NIX_CONST_EMPTY=

# hosts
readonly NIX_HOST_MICROSOFT_COM="microsoft.com"
readonly NIX_HOST_ONMICROSOFT_COM="onmicrosoft.com"
readonly NIX_HOST_MSFT_CCSCTP_NET="msft.ccsctp.net"
readonly NIX_HOST_PORTAL_COM="portal.azure.com"

# global (azure)
readonly NIX_CPC_LOCATION=westus2
readonly NIX_CPC_WWW_SUPPORED_LOCATIONS=https://docs.microsoft.com/en-us/windows-365/enterprise/requirements#supported-azure-regions-for-cloud-pc-provisioning
readonly NIX_FIDALGO_DATAPLANE_TOKEN_URL=https://devcenters.fidalgo.azure.com
readonly NIX_FIDALGO_DEFAULT_DNS_SUFFIX=devcenters.fidalgo.azure.com
readonly NIX_AZURE_LOCATION_DEFAULT=centraluseuap
readonly NIX_AZURE_CLOUD_DEFAULT=AzureCloud
readonly NIX_AZURE_CLOUD_DOGFOOD=Dogfood

# clouds (azure)
readonly -A NIX_AZURE_CLOUD_ENDPOINTS_PUBLIC=(
    ['endpoint-active-directory']='https://login.microsoftonline.com'
    ['endpoint-active-directory-graph-resource-id']='https://graph.windows.net/'
    ['endpoint-active-directory-resource-id']='https://management.core.windows.net/'
    ['endpoint-gallery']='https://gallery.azure.com/'
    ['endpoint-resource-manager']='https://management.azure.com/'
)
readonly -A NIX_AZURE_CLOUD_ENDPOINTS_DOGFOOD=(
    ['endpoint-active-directory']='https://login.windows-ppe.net/'
    ['endpoint-active-directory-graph-resource-id']='https://graph.ppe.windows.net/'
    ['endpoint-active-directory-resource-id']='https://management.core.windows.net/'
    ['endpoint-gallery']='https://df.gallery.azure-test.net/'
    ['endpoint-resource-manager']='https://api-dogfood.resources.windows-int.net/'
)
readonly -A NIX_AZURE_CLOUD_ENDPOINTS=(
    [${NIX_AZURE_CLOUD_DEFAULT}]="NIX_AZURE_CLOUD_ENDPOINTS_PUBLIC"
    [${NIX_AZURE_CLOUD_DOGFOOD}]="NIX_AZURE_CLOUD_ENDPOINTS_DOGFOOD"
)
readonly NIX_AZURE_CLOUD_BUILTIN=(
    "${NIX_AZURE_CLOUD_DEFAULT}"
    AzureChinaCloud
    AzureUSGovernment
    AzureGermanCloud
)

readonly -A NIX_UPN_OVERRIDE=(
    ['PUBLIC']=${NIX_UPN_MICROSOFT}
    ['DOGFOOD']=${NIX_UPN_MICROSOFT}
    ['DOGFOOD_INT']=${NIX_UPN_MICROSOFT}
)

# fidalgo ad groups
readonly NIX_FIDGALGO_AD_GROUP_X2FA="MFA Excluded Users"
readonly NIX_FIDGALGO_AD_GROUP_ADMINS="Admins"

# fidalgo personas
readonly NIX_PERSONA_ADMINISTRATOR='administrator'
readonly NIX_PERSONA_DEVELOPER='developer'
readonly NIX_PERSONA_NETWORK_ADMIN='network-administrator'
readonly NIX_PERSONA_VM_USER='vm-user' # is developer except in dogfood
readonly NIX_PERSONA_ME='me'
readonly -A NIX_PERSONA_UPN=(
    ["${NIX_PERSONA_ADMINISTRATOR}"]='NIX_FID_UPN_DOMAIN_ADMIN'
    ["${NIX_PERSONA_DEVELOPER}"]='NIX_FID_UPN_DOMAIN'
    ["${NIX_PERSONA_NETWORK_ADMIN}"]='NIX_CPC_UPN_DOMAIN_ADMIN'
    ["${NIX_PERSONA_VM_USER}"]='NIX_CPC_UPN_DOMAIN'
    ["${NIX_PERSONA_ME}"]='NIX_FID_UPN_MICROSOFT'
)

readonly NIX_TEST_ENVIRONMENTS=(
    DOGFOOD
    DOGFOOD-INT
    SELFHOST
    PPE
)

# public (azure)
readonly NIX_PUBLIC_NAME=PUBLIC
readonly NIX_PUBLIC_CPC=${NIX_PUBLIC_NAME}
readonly NIX_PUBLIC_TAG=pub
readonly NIX_PUBLIC_CLOUD=${NIX_AZURE_CLOUD_DEFAULT}
readonly NIX_PUBLIC_TENANT=72f988bf-86f1-41af-91ab-2d7cd011db47
readonly NIX_PUBLIC_TENANT_DOMAIN=${NIX_HOST_ONMICROSOFT_COM}
readonly NIX_PUBLIC_TENANT_SUBDOMAIN=
readonly NIX_PUBLIC_SUBSCRIPTION=3de261df-f2d8-4c00-a0ee-a0be30f1e48e
readonly NIX_PUBLIC_SUBSCRIPTION_NAME="Project Fidalgo - R and D"
readonly NIX_PUBLIC_LOCATION=${NIX_AZURE_LOCATION_DEFAULT}
readonly NIX_PUBLIC_PORTAL_HOST=${NIX_HOST_PORTAL_COM}
readonly NIX_PUBLIC_KUSTO=PUBLIC
readonly NIX_PUBLIC_DNS_SUFFIX=${NIX_FIDALGO_DEFAULT_DNS_SUFFIX}
readonly NIX_PUBLIC_CLI_VERSION=0.3.2
readonly NIX_PUBLIC_DNS=10.1.0.4

# selfhost (azure)
readonly NIX_SELFHOST_NAME=SELFHOST
readonly NIX_SELFHOST_CPC=${NIX_SELFHOST_NAME}
readonly NIX_SELFHOST_TAG=sh
readonly NIX_SELFHOST_CLOUD=${NIX_AZURE_CLOUD_DEFAULT}
readonly NIX_SELFHOST_TENANT=003b06c3-d471-4452-9686-9e7f3ca85f0a
readonly NIX_SELFHOST_TENANT_DOMAIN=${NIX_HOST_ONMICROSOFT_COM}
readonly NIX_SELFHOST_TENANT_SUBDOMAIN=${NIX_CONST_FIDALGO}sh010
readonly NIX_SELFHOST_SUBSCRIPTION=f141e9f2-4778-45a4-9aa0-8b31e6469454
readonly NIX_SELFHOST_SUBSCRIPTION_NAME="Project Fidalgo - Selfhost"
readonly NIX_SELFHOST_LOCATION=${NIX_AZURE_LOCATION_DEFAULT}
readonly NIX_SELFHOST_PORTAL_HOST=${NIX_HOST_PORTAL_COM}
readonly NIX_SELFHOST_KUSTO=PUBLIC
readonly NIX_SELFHOST_DNS_SUFFIX=${NIX_FIDALGO_DEFAULT_DNS_SUFFIX}
readonly NIX_SELFHOST_WWW_MEM=https://aka.ms/cpcsh
readonly NIX_SELFHOST_WWW_END_USER=https://aka.ms/cpc-iwp-sh
readonly NIX_SELFHOST_CLI_VERSION=0.3.2
readonly NIX_SELFHOST_DC_VNET_RESOURCE_GROUP=Networks
readonly NIX_SELFHOST_DC_VNET=DomainController-vnet
readonly NIX_SELFHOST_DC_RESOURCE_GROUP=DomainController
readonly NIX_SELFHOST_DC=DomainController
readonly NIX_SELFHOST_DNS=10.1.0.4

# int (azure)
readonly NIX_INT_NAME=INT
readonly NIX_INT_CPC=${NIX_INT_NAME}
readonly NIX_INT_TAG=int
readonly NIX_INT_CLOUD=${NIX_AZURE_CLOUD_DEFAULT}
readonly NIX_INT_TENANT=eb457173-3dfd-4145-bd18-68e25e0a10fa
readonly NIX_INT_TENANT_DOMAIN=${NIX_HOST_ONMICROSOFT_COM}
readonly NIX_INT_TENANT_SUBDOMAIN=${NIX_CONST_FIDALGO}beta
readonly NIX_INT_SUBSCRIPTION=f4791044-4994-4266-8f75-d738453862cf
readonly NIX_INT_SUBSCRIPTION_NAME="Project Fidalgo - Cloud PC Beta"
readonly NIX_INT_LOCATION=${NIX_AZURE_LOCATION_DEFAULT}
readonly NIX_INT_PORTAL_HOST=${NIX_HOST_PORTAL_COM}
readonly NIX_INT_KUSTO=PUBLIC
readonly NIX_INT_DNS_SUFFIX=${NIX_FIDALGO_DEFAULT_DNS_SUFFIX}
readonly NIX_INT_WWW_MEM=https://aka.ms/cpcint
readonly NIX_INT_WWW_END_USER=https://aka.ms/cpc-iwp-int
readonly NIX_INT_CLI_VERSION=0.3.2
readonly NIX_INT_DC_VNET_RESOURCE_GROUP=Networks
readonly NIX_INT_DC_VNET=WestUS2-VNet
readonly NIX_INT_DC_RESOURCE_GROUP=DomainController
readonly NIX_INT_DC=DomainController
readonly NIX_INT_DNS=10.1.0.4

# dogfood (azure)
readonly NIX_DOGFOOD_NAME=DOGFOOD
readonly NIX_DOGFOOD_CPC=${NIX_SELFHOST_NAME}
readonly NIX_DOGFOOD_TAG=df
readonly NIX_DOGFOOD_SUBSCRIPTION=f2f8f952-f0fc-42ec-951d-44fd27d801b0
readonly NIX_DOGFOOD_SUBSCRIPTION_NAME="Project Fidalgo - R and D - Dogfood"
readonly NIX_DOGFOOD_CLOUD=${NIX_AZURE_CLOUD_DOGFOOD}
readonly NIX_DOGFOOD_TENANT=f686d426-8d16-42db-81b7-ab578e110ccd
readonly NIX_DOGFOOD_TENANT_DOMAIN=${NIX_HOST_MSFT_CCSCTP_NET}
readonly NIX_DOGFOOD_TENANT_SUBDOMAIN=
readonly NIX_DOGFOOD_LOCATION=centralus
readonly NIX_DOGFOOD_PORTAL_HOST="df.onecloud.azure-test.net"
readonly NIX_DOGFOOD_KUSTO=DOGFOOD
readonly NIX_DOGFOOD_DNS_SUFFIX="devcenters.fidalgo.azure-test.net"
readonly NIX_DOGFOOD_CLI_VERSION=0.3.2

# dogfood-int (azure)
readonly NIX_DOGFOOD_INT_NAME=DOGFOOD_INT
readonly NIX_DOGFOOD_INT_CPC=${NIX_INT_NAME}
readonly NIX_DOGFOOD_INT_TAG=df-int
readonly NIX_DOGFOOD_INT_SUBSCRIPTION=699a5a77-12d2-422b-8a50-c4f94d5a8864
readonly NIX_DOGFOOD_INT_SUBSCRIPTION_NAME="Project Fidalgo - R and D - Dogfood - INT"
readonly NIX_DOGFOOD_INT_CLOUD=${NIX_AZURE_CLOUD_DOGFOOD}
readonly NIX_DOGFOOD_INT_TENANT=${NIX_DOGFOOD_TENANT}
readonly NIX_DOGFOOD_INT_TENANT_DOMAIN=${NIX_DOGFOOD_TENANT_DOMAIN}
readonly NIX_DOGFOOD_INT_TENANT_SUBDOMAIN=${NIX_DOGFOOD_TENANT_SUBDOMAIN}
readonly NIX_DOGFOOD_INT_LOCATION=${NIX_DOGFOOD_LOCATION}
readonly NIX_DOGFOOD_INT_PORTAL_HOST=${NIX_DOGFOOD_PORTAL_HOST}
readonly NIX_DOGFOOD_INT_KUSTO=${NIX_DOGFOOD_KUSTO}
readonly NIX_DOGFOOD_INT_DNS_SUFFIX=${NIX_DOGFOOD_DNS_SUFFIX}
readonly NIX_DOGFOOD_INT_CLI_VERSION=${NIX_DOGFOOD_CLI_VERSION}

# ppe (azure)
readonly NIX_PPE_NAME=PPE
readonly NIX_PPE_CPC=${NIX_PPE_NAME}
readonly NIX_PPE_TAG=ppe
readonly NIX_PPE_CLOUD=${NIX_AZURE_CLOUD_DEFAULT}
readonly NIX_PPE_TENANT=8ab2df1c-ed88-4946-a8a9-e1bbb3e4d1fd
readonly NIX_PPE_SUBSCRIPTION_NAME="Project Fidalgo - Cloud PC PPE"
readonly NIX_PPE_TENANT_DOMAIN=${NIX_HOST_ONMICROSOFT_COM}
readonly NIX_PPE_TENANT_SUBDOMAIN=${NIX_CONST_FIDALGO}ppe010
readonly NIX_PPE_SUBSCRIPTION=974ae608-fbe5-429f-83ae-924a64019bf3
readonly NIX_PPE_LOCATION=${NIX_AZURE_LOCATION_DEFAULT}
readonly NIX_PPE_PORTAL_HOST=${NIX_HOST_PORTAL_COM}
readonly NIX_PPE_KUSTO=PUBLIC
readonly NIX_PPE_DNS_SUFFIX=${NIX_FIDALGO_DEFAULT_DNS_SUFFIX}
readonly NIX_PPE_WWW_MEM=https://aka.ms/cpccanary
readonly NIX_PPE_WWW_END_USER=https://aka.ms/cpc-iwp-ppe 
readonly NIX_PPE_CLI_VERSION=0.3.2
readonly NIX_PPE_DC_VNET_RESOURCE_GROUP=fidalgoppe010
readonly NIX_PPE_DC_VNET=vNet
readonly NIX_PPE_DC_RESOURCE_GROUP=fidalgoppe010
readonly NIX_PPE_DC=ADWinVM
readonly NIX_PPE_DNS=10.1.0.4

# ppe3 (azure)
readonly NIX_PPE3_NAME=PPE3
readonly NIX_PPE3_CPC=${NIX_PPE3_NAME}
readonly NIX_PPE3_TAG=ppe3
readonly NIX_PPE3_CLOUD=${NIX_AZURE_CLOUD_DEFAULT}
readonly NIX_PPE3_TENANT=1316ce3a-a74f-4436-8c07-dd3098443d11
readonly NIX_PPE3_TENANT_DOMAIN=${NIX_HOST_ONMICROSOFT_COM}
readonly NIX_PPE3_TENANT_SUBDOMAIN=${NIX_CONST_FIDALGO}ppe030
readonly NIX_PPE3_SUBSCRIPTION=e575eed6-974a-4442-a79a-f5e20eebe2e1
readonly NIX_PPE3_SUBSCRIPTION_NAME="Unknown"
readonly NIX_PPE3_LOCATION=${NIX_AZURE_LOCATION_DEFAULT}
readonly NIX_PPE3_PORTAL_HOST=${NIX_HOST_PORTAL_COM}
readonly NIX_PPE3_KUSTO=PUBLIC
readonly NIX_PPE3_DNS_SUFFIX=${NIX_FIDALGO_DEFAULT_DNS_SUFFIX}
readonly NIX_PPE3_WWW_MEM=[unknown]
readonly NIX_PPE3_WWW_END_USER=[unknown]
readonly NIX_PPE3_CLI_VERSION=0.3.2
readonly NIX_PPE3_DC_VNET_RESOURCE_GROUP=DomainController
readonly NIX_PPE3_DC_VNET=DomainController-VNet
readonly NIX_PPE3_DC_RESOURCE_GROUP=DomainController
readonly NIX_PPE3_DC=DomainController
readonly NIX_PPE3_DNS=10.1.0.4

readonly NIX_HIT_ORDER=(
    query
    segment
    port
    host
    scheme
    method
    header
    type
    data
)

readonly NIX_TEST_OP_ORDER=(
    cloud
    user
    new-group
    login
    new
    name
    parent
    group
    location
    subscription
    pointer
    context
    option
    option-list
    role
)

readonly -A NIX_TEST_KNOWN_OPTIONS=(
    ['name']='name'
    ['resource-group']='group'
    ['subscription']='subscription'
    ['location']='location'
)

readonly NIX_TEST_OPTION_ORDER=(
    name
    resource-group
    location
    subscription
)

readonly NIX_HTTP='http://'
readonly NIX_HTTP_SECURE='https://'

# http headers
readonly NIX_HTTP_HEADER_ACCEPT='Accept'
readonly NIX_HTTP_HEADER_AUTHORIZATION='Authorization'
readonly NIX_HTTP_HEADER_CONTENT_TYPE='Content-Type'

# http application
readonly NIX_HTTP_APPLICATION_JSON='application/json'

# http method
readonly NIX_HTTP_METHOD_GET='GET'
readonly NIX_HTTP_METHOD_POST='POST'
readonly NIX_HTTP_METHOD_PATCH='PATCH'
readonly NIX_HTTP_METHOD_PUT='PUT'
readonly NIX_HTTP_METHOD_DELETE='DELETE'

# networking
readonly NIX_HTTP_PORT=80
readonly NIX_HTTP_DATAPLANE_PORT=5001 

readonly NIX_IP_ALLOCATION_RECORDS="${NIX_DIR_NIX_USR}/ip-allocation"
readonly NIX_GIHUB_USER_RECORDS="${NIX_DIR_NIX_USR}/github-user"

nix::env::computed() {
    nix::bash::map::poset::total_order NIX_AZURE_RESOURCE_ACTIVATION_POSET \
        | mapfile -t NIX_AZURE_RESOURCE_ACTIVATION_ORDER
    readonly NIX_AZURE_RESOURCE_ACTIVATION_ORDER

    nix::bash::enum::declare \
        NIX_AZURE_RESOURCE_ACTIVATION_ENUM \
        NIX_AZURE_RESOURCE_ACTIVATION_ORDER

    nix::bash::enum::declare \
        NIX_TEST_OPTION_ENUM \
        NIX_TEST_OPTION_ORDER

    nix::bash::enum::declare \
        NIX_TEST_OP_ENUM \
        NIX_TEST_OP_ORDER

    readonly NIX_HOST_IP="$(nix::host::ip)"

    # github alias -> microsoft alias
    nix::bash::map::declare "NIX_GITHUB_USER" < "${NIX_GIHUB_USER_RECORDS}"

    # microsoft alias -> ip allocations
    nix::bash::map::declare "NIX_IP_ALLOCATION" < "${NIX_IP_ALLOCATION_RECORDS}"
}
