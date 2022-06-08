nix::load() {

    # run last pipe in same process that launched the pipeline
    shopt -s lastpipe

    # disable job control so lastpipe works in interactive mode
    set +m

    # on exit, nuke the .azure directory for this shell
    trap nix::shim::on_exit EXIT

    # load variables
    . "$(dirname ${NIX_DIR_NIX_SRC:-${BASH_SOURCE}})/env.sh"

    # load functions; source *.sh files
    while read; do source "${REPLY}"; done \
        < <(find "${NIX_DIR_NIX_SRC}" -type f -name "*.sh")

    # load computed variables
    nix::env::computed

    # create user profile if missing
    if [[ ! -f "${NIX_MY_PROFILE}" ]]; then
        mkdir -p "${NIX_MY_DIR}"
        nix::my::init > "${NIX_MY_PROFILE}"
    fi

    # load personal variables
    . "${NIX_MY_PROFILE}"

    # load computed personal variables
    nix::my::computed

    # load stubs
    nix::load::stubs
}

nix::load::ps4() {
    export PS4='+(${BASH_SOURCE}:${LINENO}): ${FUNCNAME[0]:+${FUNCNAME[0]}(): }'
}

nix::load::stubs() {
    jq() { nix::tool::stub "$@"; }
    nuget() { nix::tool::stub "$@"; }
    gpg() { nix::tool::stub "$@"; }
    dotnet() { nix::tool::stub "$@"; }
    az() { nix::tool::stub "$@"; }
    git() { nix::tool::git::stub "$@"; }
}

nix::load::generate() {
    nix::kusto::csl::harvest NIX_REPO_DIR_KUSTO \
        > "${NIX_DIR}/src/fidalgo/dri.g.sh"

    nix::azure::cmd::emit::harvest \
        > "${NIX_DIR}/src/azure/az.g.sh"
}

nix::shim::break() {
    exit "${NIX_RELOAD_REMAIN_EXIT_CODE}" >/dev/null 2>&1
}

nix::shim::reload() {
    exit "${NIX_RELOAD_EXIT_CODE}" >/dev/null 2>&1

    # if jobs are running, calling exit twice kills them and exits
    exit "${NIX_RELOAD_EXIT_CODE}" >/dev/null 2>&1
}

nix::shim::relogin() {
    nix::shim::rc::emit > "${NIX_RELOAD_RC}"
    nix::shim::reload
}

nix::shim::regenerate() {
    nix::shim::rc::emit::regenerate > "${NIX_RELOAD_RC}"
    nix::shim::reload
}

nix::shim::rc::emit::regenerate() {
    echo "nix::load::generate"
    echo "nix::shim::relogin"
}

nix::shim::rc::emit() {
    echo "nix::env::tenant::switch" \
        "${NIX_FID_NAME}" \
        "${NIX_ENV_PERSONA}"
    echo "cd ${PWD}"
}

nix::shim::on_exit() {
    local EXIT_CODE=$?
    
    if (( EXIT_CODE == NIX_RELOAD_EXIT_CODE )); then
        return
    fi
            
    nix::az::tenant::profile::clear
}

nix::shim::hush() {
    local HUSH_SUDO="${HOME}/.sudo_as_admin_successful"
    if [[ ! -f "${HUSH_SUDO}" ]]; then
        touch "${HUSH_SUDO}"
    fi
}

nix::shim::path() {
    local DIRS=(
        '/usr/local/sbin'
        '/usr/local/bin'
        '/usr/sbin'
        '/usr/bin'
        '/sbin'
        '/bin'
    )

    ( IFS=:; echo "${DIRS[*]}"; )
}

nix::shim() {
    if [[ -v NIX_RC ]]; then

        export -n NIX
        export -n NIX_RC
        export -n NIX_RELOAD_RC
        export -n NIX_RELOAD_EXIT_CODE
        export -n NIX_RELOAD_REMAIN_EXIT_CODE

        readonly NIX
        readonly NIX_RC
        readonly NIX_RELOAD_RC
        readonly NIX_RELOAD_EXIT_CODE
        readonly NIX_RELOAD_REMAIN_EXIT_CODE

        nix::load

        if [[ -f "${NIX_RC}" ]]; then
            . "${NIX_RC}"
            rm "${NIX_RC}"
        fi

        return
    fi

    local EXIT_CODE

    export NIX=$$
    export NIX_RELOAD_EXIT_CODE=100
    export NIX_RELOAD_REMAIN_EXIT_CODE=101

    export NIX_RC=$(mktemp)
    nix::shim::rc::emit > "${NIX_RC}"

    nix::shim::hush

    while true; do
        export NIX_RELOAD_RC=$(mktemp)

        (
            PATH="$(nix::shim::path)"
            bash --rcfile <(echo "
                . ~/.bashrc
                . '${BASH_SOURCE}'
            ")
        )
        EXIT_CODE=$?

        if (( EXIT_CODE == NIX_RELOAD_EXIT_CODE )); then
            NIX_RC="${NIX_RELOAD_RC}"
            continue
        fi

        rm "${NIX_RELOAD_RC}"

        break
    done

    unset NIX
    unset NIX_RC
    unset NIX_RELOAD_RC
    unset NIX_RELOAD_EXIT_CODE

    if ! (( EXIT_CODE == NIX_RELOAD_REMAIN_EXIT_CODE )); then
        exit "${EXIT_CODE}"
    fi
}

nix::shim
