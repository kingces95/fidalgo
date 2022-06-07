nix::apt::sudo::purge() {
    while (( $# > 0 )); do 
        local NAME="$1"
        shift

        nix::apt::sudo::get purge "${NAME}"
    done

    nix::apt::sudo::get autoremove
}

nix::apt::sudo::update() {
    nix::apt::sudo::get update
}

nix::apt::sudo::clean() {
    nix::apt::sudo::get autoremove
}

nix::apt::sudo::install() {    
    while (( $# > 0 )); do 
        local NAME="$1"
        shift

        # nuget installer spews logs as warnings
        if [[ "${NAME}" == 'nuget' ]]; then
            nix::apt::sudo::install::nuget
            continue
        fi

        nix::apt::sudo::get install "${NAME}"
    done
}

nix::apt::sudo::install::nuget() {
    nix::apt::sudo::get install "nuget" 2>/dev/null
}

nix::apt::sudo::get() {
    local COMMAND="$1"
    shift

    nix::sudo \
        apt-get \
        "${COMMAND}" \
        '-qq' \
        '-y' \
        "$@" > /dev/null
}

# https://docs.docker.com/desktop/windows/install/
# Start-Process '.\win\build\Docker Desktop Installer.exe' -Wait install
# https://docs.microsoft.com/en-us/windows/wsl/install-manual#step-4---download-the-linux-kernel-update-package
# wsl --set-default-version 2
# https://apps.microsoft.com/store/detail/ubuntu-2004/9N6SVWS3RX71?hl=en-us&gl=US
