# https://docs.microsoft.com/en-us/cli/azure/azure-cli-configuration#cli-configuration-file

nix::azure::env::use_dynamic_install() {
    export AZURE_EXTENSION_USE_DYNAMIC_INSTALL="$@"
}

nix::azure::env::run_after_dynamic_install() {
    export AZURE_EXTENSION_RUN_AFTER_DYNAMIC_INSTALL="$@"
}

nix::azure::env::only_show_errors() {
    export AZURE_CORE_OUTPUT="$@"
}
