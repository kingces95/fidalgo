alias fd-tool-nuget-list="nix::tool::nuget::list"
alias fd-tool-nuget-xml="nix::tool::nuget::xml"
alias fd-tool-nuget-dir="nix::tool::nuget::dir"
alias fd-tool-nuget-install-test="nix::tool::nuget::install::test"
alias fd-tool-nuget-install="nix::tool::nuget::install"
alias fd-tool-nuget-uninstall="nix::tool::nuget::uninstall"
alias fd-tool-nuget-scorch="nix::tool::nuget::scorch"

nix::tool::nuget::list() {
    nix::tool::list 'nuget'
}

nix::tool::nuget::test() {
    local NAME="$1"
    shift

    nix::tool::test "${NAME}" 'nuget'
}

nix::tool::nuget::package() {
    local NAME="$1"
    shift

    nix::tool::lookup "${NAME}" "${NIX_TOOL_NUGET_FIELD_PACKAGE}"
}

nix::tool::nuget::version() {
    local NAME="$1"
    shift

    nix::tool::lookup "${NAME}" "${NIX_TOOL_NUGET_FIELD_VERSION}"
}

nix::tool::nuget::framework() {
    local NAME="$1"
    shift

    nix::tool::lookup "${NAME}" "${NIX_TOOL_NUGET_FIELD_FRAMEWORK}"
}

nix::tool::nuget::scorch() {
    nix::fs::dir::remove "${NIX_TOOL_NUGET_DIR}"
}

nix::tool::nuget::dir() {
    local NAME="$1"
    shift

    if ! nix::tool::nuget::test "${NAME}"; then
        return
    fi

    local PACKAGE="$(nix::tool::nuget::package "${NAME}")"
    local VERSION="$(nix::tool::nuget::version "${NAME}")"
    local FRAMEWORK="$(nix::tool::nuget::framework "${NAME}")"

    echo "${NIX_TOOL_NUGET_DIR}/${PACKAGE}/${VERSION}/${FRAMEWORK}"
}

nix::tool::nuget::xml() {
    local NAME="$1"
    shift

    local PACKAGE="$(nix::tool::nuget::package "${NAME}")"
    local VERSION="$(nix::tool::nuget::version "${NAME}")"
    local FRAMEWORK="$(nix::tool::nuget::framework "${NAME}")"

    cat <<-EOF
		<?xml version="1.0" encoding="utf-8"?>
		<packages>
		  <package 
		    id="${PACKAGE}" 
		    version="${VERSION}" 
		    targetFramework="${FRAMEWORK}" 
		  />
		</packages>
	EOF
}

nix::tool::nuget::install::test() {
    local NAME="$1"
    shift

    local DIR="$(nix::tool::nuget::dir "${NAME}")"

    [[ -d "${DIR}" ]]
}

nix::tool::nuget::install() (
    local NAME="$1"
    shift

    if nix::tool::nuget::install::test "${NAME}"; then
        return
    fi

    local DIR="$(nix::tool::nuget::dir "${NAME}")"
    mkdir -p "${DIR}"

    local CONFIG="${DIR}/packages.config"
    nix::tool::nuget::xml "${NAME}" > "${CONFIG}"
    
    cd "${DIR}"

    nix::tool::install 'nuget'
    
    local PACKAGE="$(nix::tool::nuget::package "${NAME}")"
    local LOG=$(mktemp "${NIX_OS_DIR_TEMP}/XXX.log")
    local ERR=$(mktemp "${NIX_OS_DIR_TEMP}/XXX.err")

    nix::sudo::log::begin "nuget: installing ${PACKAGE}"
    nuget install > "${LOG}" 2> "${ERR}"
    nix::sudo::log::end "(logs: ${LOG} ${ERR})"
)

nix::tool::nuget::uninstall() {
    local NAME="$1"
    shift

    if ! nix::tool::nuget::install::test "${NAME}"; then
        return
    fi

    local DIR="$(nix::tool::nuget::dir "${NAME}")"

    local PACKAGE="$(nix::tool::nuget::package "${NAME}")"

    nix::sudo::log::begin "nuget: uninstalling ${PACKAGE}"
    nix::fs::dir::remove "${DIR}"
    nix::sudo::log::end
}
