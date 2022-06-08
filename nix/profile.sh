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
    # git() { nix::tool::git::stub "$@"; }
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

nix::shim::insert() {
    local PTH="$1"
    shift

    local TMP=$(mktemp)
    cat "${PTH}" <(echo "$*") \
        | sort \
        > "${TMP}"

    mv "${TMP}" "${PTH}"
}

nix::shim::vlookup() {
    local KEY="$1"
    shift

    local COLUMN="$1"
    shift

    awk -v key="${KEY}" "\$1==key {print \$${COLUMN}}"
}

nix::shim::color::cyan() {
    echo -e -n "\e[0;36m"
}

nix::shim::color::yellow() {
    echo -e -n "\e[0;33m"
}

nix::shim::color::end() {
    echo -e -n "\033[0m"
}

nix::shim::echo::yellow() {
    nix::shim::color::yellow
    echo "$@"
    nix::shim::color::end
}

nix::shim::echo() {
    nix::shim::color::cyan
    echo "$@"
    nix::shim::color::end
}

nix::shim::prompt() {
    nix::shim::color::cyan
    read -p "$*"
    nix::shim::color::end
}

nix::shim::init() {

    # constants
    local REPO_DIR=$(cd "$(dirname ${BASH_SOURCE})/.."; pwd)
    local NIX_DIR="${REPO_DIR}/nix"
    local USR_DIR="${NIX_DIR}/usr"
    local GITHUB_USER_RECORDS="${USR_DIR}/github-user"
    local IP_ALLOCATION_RECORDS="${USR_DIR}/ip-allocation"

    # set USER if in codespace
    if [[ "${USER}" == 'codespace' ]]; then

        # try github/alias cache
        USER=$(cat "${GITHUB_USER_RECORDS}" | nix::shim::vlookup "${GITHUB_USER}" 2)

        # ask user for alias; set USER
        if [[ ! "${USER}" ]]; then
            nix::shim::echo "Welcome to NIX hosted by Codespace! Please identify yourself."
            nix::shim::echo
            
            nix::shim::prompt 'Microsoft alias (e.g. "chrkin") > '
            USER="${REPLY}"
            nix::shim::insert "${GITHUB_USER_RECORDS}" "${GITHUB_USER} ${USER}"

            nix::shim::echo
        fi
    fi

    local MY_DIR="${USR_DIR}/${USER}"
    local MY_PROFILE="${MY_DIR}/profile.sh"

    # initialze user profile
    if [[ ! -f "${MY_PROFILE}" ]]; then            
        nix::shim::echo "Welcome to NIX, ${USER}! Please initialize your profile."
        nix::shim::echo

        # display name
        nix::shim::prompt 'Display name (e.g "Chris King") > '
        local DISPLAY_NAME="${REPLY}"

        # cache github/alias map
        if [[ ! "${GITHUB_USER}" ]]; then
            nix::shim::prompt 'Github alias (e.g. "kingces95") > '
            GITHUB_USER="${REPLY}"
            nix::shim::insert "${GITHUB_USER_RECORDS}" "${GITHUB_USER} ${USER}"
        fi

        # timezone
        nix::shim::prompt 'Time zone offset (e.g "-8") > '
        local TZ_OFFSET="${REPLY}"

        # allocate ip
        local IP_ALLOCATION
        while true; do
            local ALLOCATION=$(( $RANDOM % 100 + 100 ))
            IP_ALLOCATION="10.${ALLOCATION}.0.0/16"
            if ! cat "${IP_ALLOCATION_RECORDS}" \
                | grep "${IP_ALLOCATION}" >/dev/null
            then
                break
            fi
        done
        nix::shim::insert "${IP_ALLOCATION_RECORDS}" "${USER} ${IP_ALLOCATION}"

        # allocate personal profile.sh
        mkdir -p "${MY_DIR}"
        cat <<- EOF > "${MY_PROFILE}"
			readonly NIX_MY_DISPLAY_NAME="${DISPLAY_NAME}"
			readonly NIX_MY_TZ_OFFSET=${TZ_OFFSET}h
			readonly NIX_MY_IP_ALLOCATION="${IP_ALLOCATION}"
			readonly NIX_MY_ENV_ID=0
			readonly NIX_MY_ENVIRONMENTS=(
			    DOGFOOD_INT
			    SELFHOST
			    INT
			    PPE
			)
		EOF

        local BRANCH="${USER}-onboarding"
        {
            git config --global user.name "${DISPLAY_NAME}"
            git config --global user.email "${USER}@microsoft.com"
            git checkout -b "${BRANCH}"
            git add .
            git commit -m "Onoarding ${USER}"
            git push --set-upstream origin "${BRANCH}"
        } >/dev/null 2>/dev/null

        nix::shim::echo 
        nix::shim::echo "Create a pull request for '${BRANCH}' on GitHub by visiting:"
        nix::shim::echo::yellow "https://github.com/kingces95/fidalgo/pull/new/${BRANCH}"
        nix::shim::echo 
        nix::shim::prompt 'Hit enter to continue. Login with you microsoft credentials when prompted.'
    fi    
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

    nix::shim::init

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
