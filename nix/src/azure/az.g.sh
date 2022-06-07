alias az-account-get-access-token="nix::az::account::get_access_token"
alias az-account-list-default="nix::az::account::list::default"
alias az-account-list="nix::az::account::list"
alias az-account-set="nix::az::account::set"
alias az-account-show-subscription-id="nix::az::account::show::subscription::id"
alias az-account-show-subscription-name="nix::az::account::show::subscription::name"
alias az-account-show-tenant-id="nix::az::account::show::tenant::id"
alias az-account-show="nix::az::account::show"
alias az-account-tenant-list="nix::az::account::tenant::list"
alias az-account="nix::az::account"
alias az-acount-location-list="nix::az::acount::location::list"
alias az-ad-group-member-add="nix::az::ad::group::member::add"
alias az-ad-group-member-check="nix::az::ad::group::member::check"
alias az-ad-group-member-list="nix::az::ad::group::member::list"
alias az-ad-group-member-remove="nix::az::ad::group::member::remove"
alias az-ad-group-member="nix::az::ad::group::member"
alias az-ad-group="nix::az::ad::group"
alias az-ad-user-create="nix::az::ad::user::create"
alias az-ad-user-filter="nix::az::ad::user::filter"
alias az-ad-user-get-member-groups="nix::az::ad::user::get_member_groups"
alias az-ad-user-id="nix::az::ad::user::id"
alias az-ad-user="nix::az::ad::user"
alias az-ad="nix::az::ad"
alias az-cloud-list="nix::az::cloud::list"
alias az-cloud-register="nix::az::cloud::register"
alias az-cloud-set="nix::az::cloud::set"
alias az-cloud-show="nix::az::cloud::show"
alias az-cloud-unregister="nix::az::cloud::unregister"
alias az-cloud-which="nix::az::cloud::which"
alias az-cloud="nix::az::cloud"
alias az-extension-list="nix::az::extension::list"
alias az-extension-remove="nix::az::extension::remove"
alias az-extension-upgrade-source="nix::az::extension::upgrade::source"
alias az-extension-upgrade="nix::az::extension::upgrade"
alias az-extension-which="nix::az::extension::which"
alias az-extension="nix::az::extension"
alias az-group-delete="nix::az::group::delete"
alias az-group="nix::az::group"
alias az-login-with-device-code="nix::az::login::with_device_code"
alias az-login-with-secret="nix::az::login::with_secret"
alias az-login="nix::az::login"
alias az-logout="nix::az::logout"
alias az-network-vnet-dns="nix::az::network::vnet::dns"
alias az-network-vnet-list="nix::az::network::vnet::list"
alias az-network-vnet-location="nix::az::network::vnet::location"
alias az-network-vnet-show="nix::az::network::vnet::show"
alias az-network-vnet-subnet-address-prefix="nix::az::network::vnet::subnet::address_prefix"
alias az-network-vnet-subnet-delegation="nix::az::network::vnet::subnet::delegation"
alias az-network-vnet-subnet-list="nix::az::network::vnet::subnet::list"
alias az-network-vnet-subnet-show="nix::az::network::vnet::subnet::show"
alias az-network-vnet-subnet="nix::az::network::vnet::subnet"
alias az-network-vnet="nix::az::network::vnet"
alias az-network="nix::az::network"
alias az-query="nix::az::query"
alias az-resource-create="nix::az::resource::create"
alias az-resource="nix::az::resource"
alias az-signed-in-user-id="nix::az::signed_in_user::id"
alias az-signed-in-user-show="nix::az::signed_in_user::show"
alias az-signed-in-user-upn="nix::az::signed_in_user::upn"
nix::az::account() { nix::azure::cmd::account "$@" | cmd-exe; }
nix::az::account::get_access_token() { nix::azure::cmd::account::get_access_token "$@" | cmd-exe; }
nix::az::account::list() { nix::azure::cmd::account::list "$@" | cmd-exe; }
nix::az::account::list::default() { nix::azure::cmd::account::list::default "$@" | cmd-exe; }
nix::az::account::set() { nix::azure::cmd::account::set "$@" | cmd-exe; }
nix::az::account::show() { nix::azure::cmd::account::show "$@" | cmd-exe; }
nix::az::account::show::subscription::id() { nix::azure::cmd::account::show::subscription::id "$@" | cmd-exe; }
nix::az::account::show::subscription::name() { nix::azure::cmd::account::show::subscription::name "$@" | cmd-exe; }
nix::az::account::show::tenant::id() { nix::azure::cmd::account::show::tenant::id "$@" | cmd-exe; }
nix::az::account::tenant::list() { nix::azure::cmd::account::tenant::list "$@" | cmd-exe; }
nix::az::acount::location::list() { nix::azure::cmd::acount::location::list "$@" | cmd-exe; }
nix::az::ad() { nix::azure::cmd::ad "$@" | cmd-exe; }
nix::az::ad::group() { nix::azure::cmd::ad::group "$@" | cmd-exe; }
nix::az::ad::group::member() { nix::azure::cmd::ad::group::member "$@" | cmd-exe; }
nix::az::ad::group::member::add() { nix::azure::cmd::ad::group::member::add "$@" | cmd-exe; }
nix::az::ad::group::member::check() { nix::azure::cmd::ad::group::member::check "$@" | cmd-exe; }
nix::az::ad::group::member::list() { nix::azure::cmd::ad::group::member::list "$@" | cmd-exe; }
nix::az::ad::group::member::remove() { nix::azure::cmd::ad::group::member::remove "$@" | cmd-exe; }
nix::az::ad::user() { nix::azure::cmd::ad::user "$@" | cmd-exe; }
nix::az::ad::user::create() { nix::azure::cmd::ad::user::create "$@" | cmd-exe; }
nix::az::ad::user::filter() { nix::azure::cmd::ad::user::filter "$@" | cmd-exe; }
nix::az::ad::user::get_member_groups() { nix::azure::cmd::ad::user::get_member_groups "$@" | cmd-exe; }
nix::az::ad::user::id() { nix::azure::cmd::ad::user::id "$@" | cmd-exe; }
nix::az::cloud() { nix::azure::cmd::cloud "$@" | cmd-exe; }
nix::az::cloud::list() { nix::azure::cmd::cloud::list "$@" | cmd-exe; }
nix::az::cloud::register() { nix::azure::cmd::cloud::register "$@" | cmd-exe; }
nix::az::cloud::set() { nix::azure::cmd::cloud::set "$@" | cmd-exe; }
nix::az::cloud::show() { nix::azure::cmd::cloud::show "$@" | cmd-exe; }
nix::az::cloud::unregister() { nix::azure::cmd::cloud::unregister "$@" | cmd-exe; }
nix::az::cloud::which() { nix::azure::cmd::cloud::which "$@" | cmd-exe; }
nix::az::extension() { nix::azure::cmd::extension "$@" | cmd-exe; }
nix::az::extension::list() { nix::azure::cmd::extension::list "$@" | cmd-exe; }
nix::az::extension::remove() { nix::azure::cmd::extension::remove "$@" | cmd-exe; }
nix::az::extension::upgrade() { nix::azure::cmd::extension::upgrade "$@" | cmd-exe; }
nix::az::extension::upgrade::source() { nix::azure::cmd::extension::upgrade::source "$@" | cmd-exe; }
nix::az::extension::which() { nix::azure::cmd::extension::which "$@" | cmd-exe; }
nix::az::group() { nix::azure::cmd::group "$@" | cmd-exe; }
nix::az::group::delete() { nix::azure::cmd::group::delete "$@" | cmd-exe; }
nix::az::login() { nix::azure::cmd::login "$@" | cmd-exe; }
nix::az::login::with_device_code() { nix::azure::cmd::login::with_device_code "$@" | cmd-exe; }
nix::az::login::with_secret() { nix::azure::cmd::login::with_secret "$@" | cmd-exe; }
nix::az::logout() { nix::azure::cmd::logout "$@" | cmd-exe; }
nix::az::network() { nix::azure::cmd::network "$@" | cmd-exe; }
nix::az::network::vnet() { nix::azure::cmd::network::vnet "$@" | cmd-exe; }
nix::az::network::vnet::dns() { nix::azure::cmd::network::vnet::dns "$@" | cmd-exe; }
nix::az::network::vnet::list() { nix::azure::cmd::network::vnet::list "$@" | cmd-exe; }
nix::az::network::vnet::location() { nix::azure::cmd::network::vnet::location "$@" | cmd-exe; }
nix::az::network::vnet::show() { nix::azure::cmd::network::vnet::show "$@" | cmd-exe; }
nix::az::network::vnet::subnet() { nix::azure::cmd::network::vnet::subnet "$@" | cmd-exe; }
nix::az::network::vnet::subnet::address_prefix() { nix::azure::cmd::network::vnet::subnet::address_prefix "$@" | cmd-exe; }
nix::az::network::vnet::subnet::delegation() { nix::azure::cmd::network::vnet::subnet::delegation "$@" | cmd-exe; }
nix::az::network::vnet::subnet::list() { nix::azure::cmd::network::vnet::subnet::list "$@" | cmd-exe; }
nix::az::network::vnet::subnet::show() { nix::azure::cmd::network::vnet::subnet::show "$@" | cmd-exe; }
nix::az::query() { nix::azure::cmd::query "$@" | cmd-exe; }
nix::az::resource() { nix::azure::cmd::resource "$@" | cmd-exe; }
nix::az::resource::create() { nix::azure::cmd::resource::create "$@" | cmd-exe; }
nix::az::signed_in_user::id() { nix::azure::cmd::signed_in_user::id "$@" | cmd-exe; }
nix::az::signed_in_user::show() { nix::azure::cmd::signed_in_user::show "$@" | cmd-exe; }
nix::az::signed_in_user::upn() { nix::azure::cmd::signed_in_user::upn "$@" | cmd-exe; }
