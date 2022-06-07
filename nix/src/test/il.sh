nix::test::il::explicit() {
    local OP="$1"
    local NAME="$2"
    local RESOURCE="$3"
    local KEY="$4"
    local VALUE="$5"

    if [[ "${OP}" == 'option' ]]; then
        if nix::bash::map::test NIX_TEST_KNOWN_OPTIONS "${KEY}"; then
            OP="${NIX_TEST_KNOWN_OPTIONS[${KEY}]}"
        fi
    fi

    echo 'explicit' "${OP}" "${NAME}" "${RESOURCE}" "${KEY}" "${VALUE}"
}

nix::test::il::implicit() {
    echo 'implicit' "$@"
}

nix::test::il::user() {
    local NAME="$1"
    local RESOURCE="$2"

    nix::test::il::implicit 'user' "${NAME}" "${RESOURCE}" 'name' \
        "${NIX_AZURE_RESOURCE_PERSONA[${RESOURCE}]}"
}

nix::test::il::cloud() {
    local NAME="$1"
    local RESOURCE="$2"
    local CLOUD="$3"

    nix::test::il::implicit 'cloud' "${NAME}" "${RESOURCE}" 'name' "\${NIX_${CLOUD}_CLOUD}"
}

nix::test::il::login() {
    local NAME="$1"
    local RESOURCE="$2"
    local CLOUD="$3"

    nix::test::il::implicit 'login' "${NAME}" "${RESOURCE}" 'tenant' "\${NIX_${CLOUD}_TENANT}"
}

nix::test::il::new() {
    local NAME="$1"
    local RESOURCE="$2"

    nix::test::il::implicit 'new' "${NAME}" "${RESOURCE}" 'type' "${RESOURCE}"
}

nix::test::il::option() {
    nix::test::il::implicit 'option' "$@"
}

nix::test::il::pointer() {
    local NAME="$1"
    local SOURCE_RESOURCE="$2"
    local OPTION="$3"

    local TARGET_RESOURCE="${OPTION}"
    local TYPE='name'

    if [[ "${OPTION}" =~ ^([a-z0-9_-]*)-(id|name)$ ]]; then
        TARGET_RESOURCE="${BASH_REMATCH[1]}"
        TYPE="${BASH_REMATCH[2]}"
    fi

    # hacks
    if [[ "${OPTION}" == 'attached-network-name' ]]; then
        OPTION='network-connection-name'
    elif [[ "${OPTION}" == 'network-setting-id' ]]; then
        OPTION='network-connection-resource-id'
    fi

    nix::test::il::implicit 'pointer' "${NAME}" "${SOURCE_RESOURCE}" "${OPTION}" \
        "${SOURCE_RESOURCE} \${NIX_ENV_PREFIX}-${NAME} ~> ${TYPE} ${TARGET_RESOURCE}"
}

nix::test::il::group() {
    local NAME="$1"
    local RESOURCE="$2"
    local CLOUD="$3"

    nix::test::il::implicit 'group' "${NAME}" "${RESOURCE}" 'resource-group' "\${NIX_${CLOUD}_RESOURCE_GROUP}"
}

nix::test::il::new_group() {
    local NAME="$1"
    local RESOURCE="$2"
    local CLOUD="$3"

    nix::test::il::implicit 'new-group' "${NAME}" "${RESOURCE}" "\${NIX_${CLOUD}_RESOURCE_GROUP}" \
        "\${NIX_${CLOUD}_SUBSCRIPTION}" "\${NIX_${CLOUD}_LOCATION}" 
}

nix::test::il::subscription() {
    local NAME="$1"
    local RESOURCE="$2"
    local CLOUD="$3"

    nix::test::il::implicit 'subscription' "${NAME}" "${RESOURCE}" 'subscription' "\${NIX_${CLOUD}_SUBSCRIPTION}"
}

nix::test::il::name() {
    local NAME="$1"
    local RESOURCE="$2"

    nix::test::il::implicit 'name' "${NAME}" "${RESOURCE}" 'name' "\${NIX_ENV_PREFIX}-${NAME}"
}

nix::test::il::location() {
    local NAME="$1"
    local RESOURCE="$2"
    local CLOUD="$3"

    nix::test::il::implicit 'location' "${NAME}" "${RESOURCE}" 'location' "\${NIX_${CLOUD}_LOCATION}"
}

nix::test::il::parent() {
    local NAME="$1"
    local RESOURCE="$2"
    local PARENT="$3"

    nix::test::il::implicit 'parent' "${NAME}" "${RESOURCE}" \
        "${NIX_AZURE_RESOURCE_PARENT[${RESOURCE}]}-name" \
        "\${NIX_ENV_PREFIX}-${PARENT}"
}

nix::test::il::new::role() {
    local ASSIGNEE="$1"
    local ROLE="$2"

    cat <<-EOF
		new type role-assignment
		option assignee ${ASSIGNEE}
		option role ${ROLE}
		context scope id
		context subscription subscription
		EOF
}

nix::test::il::new::group() {
    local GROUP="$1"
    local SUBSCRIPTION="$2"
    local LOCATION="$3"

    cat <<-EOF
		new type group
		option name ${GROUP}
		location location ${LOCATION}
		subscription subscription ${SUBSCRIPTION}
		EOF
}