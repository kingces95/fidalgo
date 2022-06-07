alias fd-test-pipeline="nix::test::pipeline::main"
alias fd-test-pipeline-find="nix::test::pipeline::spy nix::test::pipeline::find cat"
alias fd-test-pipeline-expand-file="nix::test::pipeline::spy nix::test::pipeline::expand::file a4f"
alias fd-test-pipeline-expand-line="nix::test::pipeline::spy nix::test::pipeline::expand::line a4f"
alias fd-test-pipeline-expand-resource="nix::test::pipeline::spy nix::test::pipeline::expand::resource a6f"
alias fd-test-pipeline-override="nix::test::pipeline::spy nix::test::pipeline::override a5f"
alias fd-test-pipeline-sort="nix::test::pipeline::spy nix::test::pipeline::sort a5f"
alias fd-test-pipeline-program="nix::test::pipeline::spy nix::test::pipeline::program a3f"
alias fd-test-pipeline-expand-role="nix::test::pipeline::spy nix::test::pipeline::expand::role a3f"
alias fd-test-pipeline-expand-new-group="nix::test::pipeline::spy nix::test::pipeline::expand::new_group a3f"
alias fd-test-pipeline-ids="nix::test::pipeline::spy nix::test::pipeline::ids a4f"
alias fd-test-pipeline-ids-declare="nix::test::pipeline::spy nix::test::pipeline::ids::declare cat"
alias fd-test-pipeline-resolve-pointer="nix::test::pipeline::spy nix::test::pipeline::resolve::pointer a3f"
alias fd-test-pipeline-resolve-context="nix::test::pipeline::spy nix::test::pipeline::resolve::context a3f"
alias fd-test-pipeline-group-trim="nix::test::pipeline::spy nix::test::pipeline::group::trim a3f"
alias fd-test-pipeline-emit="nix::test::pipeline::spy nix::test::pipeline::emit cat"

nix::test::pipeline::spy() {
    local STAGE="$1"
    shift

    local FORMAT="$1"
    shift

    NIX_TEST_SPY="${STAGE}" \
        nix::test::pipeline::main "$@" \
        | eval "${FORMAT}"
}

nix::test::pipeline::main() (
    exec 3>&1

    local SPY="nix::spy NIX_TEST_SPY"

    local TMP=$(mktemp)
    if nix::fs::walk 'tst' "$@" \
        | ${SPY} nix::test::pipeline::find \
        | ${SPY} nix::test::pipeline::expand::file \
        | ${SPY} nix::test::pipeline::expand::line \
        | ${SPY} nix::test::pipeline::expand::resource \
        | ${SPY} nix::test::pipeline::override \
        | ${SPY} nix::test::pipeline::sort \
        | ${SPY} nix::test::pipeline::program \
        | ${SPY} nix::test::pipeline::expand::role \
        | ${SPY} nix::test::pipeline::expand::new_group \
        > ${TMP}
    then
        if cat "${TMP}" \
            | ${SPY} nix::test::pipeline::ids \
            | ${SPY} nix::test::pipeline::ids::declare \
            > /dev/null
        then
            cat "${TMP}" \
                | ${SPY} nix::test::pipeline::resolve::pointer \
                | ${SPY} nix::test::pipeline::resolve::context \
                | ${SPY} nix::test::pipeline::group::trim \
                | ${SPY} nix::test::pipeline::emit
        fi
    fi

    rm "${TMP}"
)

nix::test::pipeline::find() {
    nix::record::prepend 'file'
}

nix::test::path::info() {
    NIX_TEST_INFO_NAME_REPLY=
    NIX_TEST_INFO_ENTITY_REPLY=
    NIX_TEST_INFO_RESOURCE_REPLY=
    NIX_TEST_INFO_PARENT_REPLY=

    # ./my-vnet/my-subnet/subnet
    local PTH="$1"

    nix::path::info "${PTH}"

    local FILE_NAME="${NIX_PATH_INFO_FILE_NAME_REPLY}"
    local DIR_NAME="${NIX_PATH_INFO_DIR_NAME_REPLY}"
    local PARENT_DIR_NAME="${NIX_PATH_INFO_DIR_PARTS_REPLY[1]}"

    NIX_TEST_INFO_NAME_REPLY="${DIR_NAME}"      # my-subnet
    NIX_TEST_INFO_ENTITY_REPLY="${FILE_NAME}"   # subnet

    # skip non-entities (e.g. user)
    if ! nix::bash::map::test NIX_AZURE_RESOURCE "${FILE_NAME}"; then
        return
    fi

    # my-subnet
    NIX_TEST_INFO_RESOURCE_REPLY="${FILE_NAME}"

    # check for parent
    if nix::bash::map::test NIX_AZURE_RESOURCE_PARENT \
        "${NIX_TEST_INFO_RESOURCE_REPLY}"; then

        # myvent
        NIX_TEST_INFO_PARENT_REPLY="${PARENT_DIR_NAME}"    
    fi
}

nix::test::pipeline::expand::file() {
    local FILE PTH
    while read -r FILE PTH; do
        nix::test::path::info "${PTH}"

        local NAME="${NIX_TEST_INFO_NAME_REPLY}"
        local RESOURCE="${NIX_TEST_INFO_RESOURCE_REPLY}"
        local PARENT="${NIX_TEST_INFO_PARENT_REPLY}"
        
        if [[ ! "${NIX_TEST_INFO_RESOURCE_REPLY}" ]]; then
            continue
        fi

        echo 'resource' "${NAME}" "${RESOURCE}" "${PARENT:-.}"
        cat "${PTH}" | nix::record::prepend 'line' "${NAME}" "${RESOURCE}"
    done
}

nix::test::pipeline::expand::line() {
    while nix::record::expand 'line'; do
        local NAME RESOURCE OP KEY VALUE
        read -r NAME RESOURCE OP KEY VALUE <<< "${REPLY}"
        nix::test::il::explicit "${OP}" "${NAME}" "${RESOURCE}" "${KEY}" "${VALUE}"
    done
}

nix::test::pipeline::expand::resource() {
    while nix::record::expand 'resource'; do
        local NAME RESOURCE PARENT
        read -r NAME RESOURCE PARENT <<< "${REPLY}"
        
        nix::test::il::user "${NAME}" "${RESOURCE}"

        local CLOUD
        if nix::bash::map::test NIX_AZURE_CPC_RESOURCE "${RESOURCE}"; then
            CLOUD=CPC
        else
            CLOUD=FID
        fi

        nix::test::il::new_group "${NAME}" "${RESOURCE}" "${CLOUD}"
        nix::test::il::new "${NAME}" "${RESOURCE}"
        nix::test::il::name "${NAME}" "${RESOURCE}"
        nix::test::il::group "${NAME}" "${RESOURCE}" "${CLOUD}"
        nix::test::il::subscription "${NAME}" "${RESOURCE}" "${CLOUD}"

        if [[ "${PARENT}" = '.' ]]; then
            nix::test::il::location "${NAME}" "${RESOURCE}" "${CLOUD}"
        else
            nix::test::il::parent "${NAME}" "${RESOURCE}" "${PARENT}"
        fi

        # local POINTER
        for POINTER in ${NIX_AZURE_RESOURCE_POINTS_TO[${RESOURCE}]}; do
            nix::test::il::pointer "${NAME}" "${RESOURCE}" "${POINTER}"
        done
    done
}

nix::test::pipeline::override() {

    # explict options override implicit options
    local -A ENUM=( 
        [explicit]=0 
        [implicit]=1 
    )

    local SORT_FIELDS=( 
        2 # op
        3 # name
        4 # resource
        5 # key
    )

    nix::record::replace ENUM \
        | sort -k1,1n \
        | nix::record::sort::stable "${SORT_FIELDS[@]}" \
        | nix::record::unique 6 "${SORT_FIELDS[@]}" \
        | nix::record::shift 6
}

nix::test::pipeline::sort() {

    local ENUMS=(
        NIX_TEST_OP_ENUM
        ''
        NIX_AZURE_RESOURCE_ACTIVATION_ENUM
   )

    local ORDERS=(
        NIX_TEST_OP_ORDER
        ''
        NIX_AZURE_RESOURCE_ACTIVATION_ORDER
    )

    local SORT=(
        '-k3,3n'    # resource; activation order
        '-k2,2'     # name; impose stable total order
        '-k1,1n'    # op
        '-k4,4'     # option
    )

    nix::record::replace "${ENUMS[@]}" \
        | sort -s "${SORT[@]}" \
        | nix::record::replace "${ORDERS[@]}"
}

nix::test::pipeline::program() {
    nix::record::project 5 1 4 5
}

nix::test::pipeline::expand::role() {
    while nix::record::expand 'role'; do
        local ASSIGNEE ROLE
        read -r ASSIGNEE ROLE <<< "${REPLY}"
        nix::test::il::new::role "${ASSIGNEE}" "${ROLE}"
    done
}

nix::test::pipeline::expand::new_group() {
    while nix::record::expand 'new-group'; do
        local GROUP SUBSCRIPTION LOCATION 
        read -r GROUP SUBSCRIPTION LOCATION <<< "${REPLY}"
        nix::test::il::new::group "${GROUP}" "${SUBSCRIPTION}" "${LOCATION}"
    done < <(nix::line::unique '^new-group')
}

nix::test::pipeline::ids() {
    local OP KEY VALUE
    while read OP KEY VALUE; do
        [[ "${OP}" == 'new' ]] || nix::assert "Expected new op, but got '${OP}'."
        local RESOURCE="${VALUE}"
        local PARENT_RESOURCE="${NIX_AZURE_RESOURCE_PARENT[${RESOURCE}]}"

        local SUBSCRIPTION=
        local NAME=
        local GROUP=
        local PARENT=
        
        while read OP KEY VALUE; do
            case "${OP}" in
            'subscription') SUBSCRIPTION="${VALUE}" ;;
            'group') GROUP="${VALUE}" ;;
            'name') NAME="${VALUE}" ;;
            'parent') PARENT="${VALUE}" ;;
            esac
        done < <(nix::line::take::chunk)

        # skip anonomous activations; e.g. role assignments
        if [[ ! "${NAME}" ]]; then
            continue 
        fi

        local ID=$(nix::azure::id "${SUBSCRIPTION}" "${GROUP}" "${RESOURCE}" "${NAME}" "${PARENT}")
        echo "${NAME}" "${RESOURCE}" "${NAME%-${RESOURCE}}" "${ID}"
    done < <(
        egrep '^(new|subscription|name|parent|group)\s' \
            | nix::line::chunk '^new'
    )
}

nix::test::pipeline::ids::declare() {
    declare -gA NIX_TEST_DEFAULT_RESOURCE_ID=()
    declare -gA NIX_TEST_DEFAULT_RESOURCE_NAME=()
    declare -gA NIX_TEST_RESOURCE_ID=()

    NIX_TEST_DEFAULT_RESOURCE_ID['subnet']=$(
        nix::azure::id "\${NIX_CPC_SUBSCRIPTION}" "\${NIX_MY_RESOURCE_GROUP}" 'subnet' "\${NIX_MY_SUBNET}" "\${NIX_MY_VNET}" 
    )

    local NAME RESOURCE PREFIX ID
    while read -r NAME RESOURCE PREFIX ID; do
        NIX_TEST_DEFAULT_RESOURCE_ID["${RESOURCE}"]="${ID}"
        NIX_TEST_DEFAULT_RESOURCE_NAME["${RESOURCE}"]="${NAME}"
        NIX_TEST_RESOURCE_ID["${NAME}"]="${ID}"
    done

    readonly NIX_TEST_DEFAULT_RESOURCE_ID
    readonly NIX_TEST_DEFAULT_RESOURCE_NAME
    readonly NIX_TEST_RESOURCE_ID

    # strictly for debugging
    echo NIX_TEST_DEFAULT_RESOURCE_ID "${#NIX_TEST_DEFAULT_RESOURCE_ID[@]}"
    echo NIX_TEST_DEFAULT_RESOURCE_NAME "${#NIX_TEST_DEFAULT_RESOURCE_NAME[@]}"
    echo NIX_TEST_RESOURCE_ID "${#NIX_TEST_RESOURCE_ID[@]}"
}

nix::test::pipeline::resolve::pointer() {

    while nix::record::expand 'pointer'; do

        local OPTION                                        # dev-center-id
        local SOURCE_RESOURCE                               # project
        local NAME                                          # \${NIX_ENV_PREFIX}-my-project
        local TYPE                                          # id
        local TARGET_RESOURCE                               # dev-center

        local POINTER
        read -r OPTION POINTER <<< "${REPLY}"
        read -r SOURCE_RESOURCE NAME _ TYPE TARGET_RESOURCE <<< "${POINTER}"

        local PREFIX="${NAME%-${SOURCE_RESOURCE}}"          # \${NIX_ENV_PREFIX}-my-project > \${NIX_ENV_PREFIX}-my
        local TARGET_NAME="${PREFIX}-${TARGET_RESOURCE}"    # \${NIX_ENV_PREFIX}-my-dev-center

        local RESOLUTION=

        # echo "${NAME}: --${OPTION} ${TARGET_NAME}" >&2

        # attempt resolution by name; e.g my-dev-center
        if nix::bash::map::test NIX_TEST_RESOURCE_ID "${TARGET_NAME}"; then
            if [[ "${TYPE}" == 'id' ]]; then
                RESOLUTION="${NIX_TEST_RESOURCE_ID[${TARGET_NAME}]}"
            else
                RESOLUTION="${TARGET_NAME}"
            fi
        
        # fallback to resolution by target type; e.g. dev-center
        else
            if [[ "${TYPE}" == 'id' ]]; then
                RESOLUTION="${NIX_TEST_DEFAULT_RESOURCE_ID[${TARGET_RESOURCE}]}"
            else
                RESOLUTION="${NIX_TEST_DEFAULT_RESOURCE_NAME[${TARGET_RESOURCE}]}"
            fi
        fi

        echo 'pointer' "${OPTION}" "${RESOLUTION}"        
    done
}

nix::test::pipeline::resolve::context() {
    local CONTEXT="$(mktemp)"

    while nix::record::expand 'context' "${CONTEXT}"; do
        local OPTION VALUE
        read -r OPTION VALUE <<< "${REPLY}"

        local RESOLUTION='?'
        case "${VALUE}" in
            'id')
                local NAME=$(
                    tac "${CONTEXT}" \
                        | nix::record::vlookup 'name' 3
                )
                RESOLUTION="${NIX_TEST_RESOURCE_ID[${NAME}]}"
            ;;
            'subscription')
                RESOLUTION=$(
                    tac "${CONTEXT}" \
                        | nix::record::vlookup 'subscription' 3
                )
            ;;
            *) nix::assert "Context '${VALUE}' is unexpected."
        esac

        echo 'context' "${OPTION}" "${RESOLUTION}"
    done

    rm "${CONTEXT}"
}

nix::test::pipeline::group::trim() {
    local CONTEXT="$(mktemp)"

    while nix::record::expand 'group' "${CONTEXT}"; do
        local OPTION VALUE
        read -r OPTION VALUE <<< "${REPLY}"

        local RESOURCE=$(
            tac "${CONTEXT}" \
                | nix::record::vlookup 'new' 3
        )

        if nix::bash::map::test NIX_AZURE_RESOURCE_NO_RESOURCE_GROUP "${RESOURCE}"; then
            continue
        fi

        echo 'group' "${OPTION}" "${VALUE}"
    done

    rm "${CONTEXT}"
}

nix::test::pipeline::emit() {
    local OP KEY VALUE
    while read -r OP KEY VALUE; do
        [[ "${OP}" == 'user' ]] || nix::assert "Expected 'user', got '${OP}'."
        [[ "${KEY}" == 'name' ]] || nix::assert "Expected 'name', got '${KEY}'."
        local PERSONA="${VALUE}"

        {
            echo "fd-login-as-${PERSONA}"

            local CTX_ID=
            local CTX_NAME=
            local CTX_SUBSCRIPTION=

            while read OP KEY VALUE; do
                [[ "${OP}" == 'new' ]] || nix::assert "Expected 'new', got '${OP}'."
                [[ "${KEY}" == 'type' ]] || nix::assert "Expected 'type', got '${KEY}'."
                local RESOURCE="${VALUE}"

                {
                    nix::azure::cmd::resource::create "${RESOURCE}"

                    while read OP KEY VALUE; do
                        case "${OP}" in
                        'option-list') echo 'option-list' "${KEY}" "${VALUE}" ;;
                        *) nix::cmd::option "${KEY}" "${VALUE}"
                        esac
                    done < <(nix::line::take::chunk)
                } \
                    | nix::cmd::compile \
                    | nix::cmd::emit

            done < <(
                nix::line::take::chunk \
                    | nix::line::chunk '^new'
            )

        } | nix::bash::emit::subproc

    done < <(
        nix::line::unique '^user' \
            | nix::line::chunk '^user'
    )
}
