alias fd-env-afs="nix::env::afs"
alias fd-env-afs-set="nix::env::afs::set"
alias fd-env-afs-dump="nix::env::afs::dump | sort | a2"
alias fd-env-afs-query-cpc="nix::env::afs::cpc::query"
alias fd-env-afs-query-fid="nix::env::afs::fid::query"

nix::env::afs::shared() {
    cat <<- EOF
		NIX_FID_TENANT              NIX_CPC_TENANT              NIX_AZ_TENANT
		NIX_FID_CLOUD               NIX_CPC_CLOUD               NIX_AZ_TENANT_CLOUD
		NIX_FID_TENANT_DOMAIN       NIX_CPC_TENANT_DOMAIN       NIX_AZ_TENANT_DOMAIN
		NIX_FID_TENANT_SUBDOMAIN    NIX_CPC_TENANT_SUBDOMAIN    NIX_AZ_TENANT_SUBDOMAIN
		NIX_FID_DNS_SUFFIX          NIX_CPC_DNS_SUFFIX          NIX_AZ_TENANT_DNS_SUFFIX
		NIX_FID_PORTAL_HOST         NIX_CPC_PORTAL_HOST         NIX_AZ_TENANT_PORTAL_HOST
		NIX_FID_CLI_VERSION         NIX_CPC_CLI_VERSION         NIX_AZ_TENANT_CLI_VERSION
		NIX_FID_TAG                 NIX_CPC_TAG                 NIX_AZ_SUBSCRIPTION_TAG
		NIX_FID_SUBSCRIPTION        NIX_CPC_SUBSCRIPTION        NIX_AZ_SUBSCRIPTION
	EOF
}

nix::env::afs::endpoint() {
    cat <<- EOF
		NIX_FID_TENANT_ENDPOINT_AD                        NIX_AZ_TENANT_ENDPOINT_ACTIVE_DIRECTORY
		NIX_FID_TENANT_ENDPOINT_AD_DATA_LAKE_RESOURCE_ID  NIX_AZ_TENANT_ENDPOINT_ACTIVE_DIRECTORY_DATA_LAKE_RESOURCE_ID
		NIX_FID_TENANT_ENDPOINT_AD_GRAPH_RESOURCE_ID      NIX_AZ_TENANT_ENDPOINT_ACTIVE_DIRECTORY_GRAPH_RESOURCE_ID
		NIX_FID_TENANT_ENDPOINT_AD_RESOURCE_ID            NIX_AZ_TENANT_ENDPOINT_ACTIVE_DIRECTORY_RESOURCE_ID
		NIX_FID_TENANT_ENDPOINT_GALLERY                   NIX_AZ_TENANT_ENDPOINT_GALLERY
		NIX_FID_TENANT_ENDPOINT_MANAGEMENT                NIX_AZ_TENANT_ENDPOINT_MANAGEMENT
		NIX_FID_TENANT_ENDPOINT_RESOURCE_MANAGER          NIX_AZ_TENANT_ENDPOINT_RESOURCE_MANAGER
		NIX_FID_TENANT_ENDPOINT_SQL_MANAGEMENT            NIX_AZ_TENANT_ENDPOINT_SQL_MANAGEMENT
		NIX_FID_TENANT_ENDPOINT_VM_IMAGE_ALIAS_DOC        NIX_AZ_TENANT_ENDPOINT_VM_IMAGE_ALIAS_DOC
	EOF
}

# list Fidalgo variables harvested from afs
nix::env::afs::fid() {
    nix::env::afs::shared | awk '{print $1, $3}'
    nix::env::afs::endpoint
    echo 'NIX_FID_LOCATION' 'NIX_AZ_TENANT_DEFAULT_FIDALGO_LOCATION'
}

# list Fidalgo variable/values harvested from afs
nix::env::afs::fid::query() { 
    local AFS_DIR="${NIX_REPO_DIR_AZ}/${NIX_FID_NAME,,}/default"

    paste -d " " \
        <(nix::env::afs::fid | awk '{print $1}') \
        <(nix::env::afs::fid | awk '{print $2}' | nix::afs::query "${AFS_DIR}")

    echo 'NIX_FID_AFS_SUBSCRIPTION_DIR' "${AFS_DIR}"
}
    
# add Fidalgo values harvestd from afs to the context
nix::env::afs::fid::set() {
    nix::context::read \
        < <(nix::env::afs::fid::query)
}

# list CloudPC variables harvested from afs
nix::env::afs::cpc() {
    nix::env::afs::shared | awk '{print $2, $3}'
}

# list CloudPC variable/values harvested from afs
nix::env::afs::cpc::query() { 
    local AFS_DIR="${NIX_REPO_DIR_AZ}/${NIX_CPC_NAME,,}/default"

    paste -d " " \
        <(nix::env::afs::cpc | awk '{print $1}') \
        <(nix::env::afs::cpc | awk '{print $2}' | nix::afs::query "${AFS_DIR}")

    echo NIX_CPC_AFS_SUBSCRIPTION_DIR "${AFS_DIR}"
}
    
# add CloudPC values harvestd from afs to the context
nix::env::afs::cpc::set() {
    nix::context::read \
        < <(nix::env::afs::cpc::query)
}

# dump variables/values harvestd from afs
nix::env::afs::dump() { 
    nix::env::afs::fid::query
    nix::env::afs::cpc::query
}
