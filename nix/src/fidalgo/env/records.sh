alias fd-who="nix::env::who | a3f"
alias fd-nix="nix::bash::dump::variables NIX_ | a2f"
alias fd-nix-raw="nix::bash::dump::variables NIX_"
alias fd-nix-env="nix::env::records | a2f"
alias fd-nix-env-www="nix::env::records::www | a2"
alias fd-nix-cpc="nix::env::records::cpc | a2f"
alias fd-nix-fid="nix::env::records::fid | a2f"
alias fd-subscriptions="nix::env::query::subscriptions"

nix::env::records() {
    nix::bash::dump::variables NIX_ENV_
}

nix::env::records::fid() {
    nix::bash::dump::variables NIX_FID_
}

nix::env::records::cpc() {
    nix::bash::dump::variables NIX_CPC_
}

nix::env::records::www() {
    nix::bash::dump::variables NIX_FID_WWW
    nix::bash::dump::variables NIX_CPC_WWW
}

nix::env::who() {
    nix::azure::who
    echo "env fid ${NIX_FID_NAME}"
    echo "env cpc ${NIX_CPC_NAME}"
    echo "env as ${NIX_ENV_PERSONA}"
    echo "env cli $(nix::cli::which)"
    echo "kusto token-url ${NIX_KUSTO_TOKEN_URL}"
    echo "kusto data-source ${NIX_KUSTO_ENV_DATA_SOURCE}"
    echo "kusto initial-catalog ${NIX_KUSTO_ENV_INITIAL_CATALOG}"
    echo "me name ${NIX_MY_ALIAS}"
    echo "me profile ${NIX_MY_PROFILE}"
    echo "me env-id ${NIX_MY_ENV_ID}"
}

nix::env::query::subscriptions() {
    az account list --query '[].[id, state, isDefault, name]' --output tsv
}
