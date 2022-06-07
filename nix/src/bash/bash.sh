alias dmp="nix::bash::dump::declarations"
alias rec="nix::bash::dump::variables"

alias un="nix::bash::unset::variables"
alias file-name="nix::path::file::name"

alias elem="nix::bash::elements"
alias ret="nix::bash::return"

nix::bash::return() {
    return $1
}

nix::bash::is_set() {
    declare -p "$1" >/dev/null 2>&1
}

nix::bash::reverse() {
    nix::bash::args "$@" \
        | tac \
        | mapfile -t
}

nix::bash::args() {
    if (( $# == 0 )); then
        return
    fi

    printf '%s\n' "$@"
}

nix::bash::dereference() {
    while read; do
        echo "${!REPLY}"
    done
}

nix::bash::args::sorted() {
    nix::bash::args "$@" | sort
}

nix::bash::elements() {
    local -n ARRAY_REF=$1
    nix::bash::args "${ARRAY_REF[@]}"
}

nix::bash::dump::declarations() {
    while read; do
        declare -p ${REPLY}
    done < <(nix::bash::dump "$@")
}

nix::bash::type() {
    local DECLARE TYPE NAME VALUE
    IFS=" =" read DECLARE TYPE NAME VALUE < <(declare -p $1)

    case ${TYPE} in
    *A*) echo 'map' ;;
    *a*) echo 'array' ;;
    *i*) echo 'long' ;;
    *) echo string ;;
    esac
}

nix::bash::dump::functions() {
    declare -F \
        | nix::record::project 3 3 \
        | egrep "${1-.}"
}

nix::bash::variable::print() {
    local NAME="$1"
    shift

    local TYPE=$(nix::bash::type "${NAME}")
    case "${TYPE}" in
    *A*) ;&
    *a*) 
        local -n REF="${NAME}"
        for KEY in "${!REF[@]}"; do
            echo "${NAME}" "${TYPE}" "${KEY}" "${REF[${KEY}]}"
        done
    ;;
    *) echo "${NAME}" "${TYPE}" '-' "${!NAME}" ;;
    esac
}

nix::bash::dump::variables() {
    while read; do
        nix::bash::variable::print "${REPLY}"
    done < <(nix::bash::dump "$@")
}

nix::bash::char_count() {
    grep -o "[$1]" <<< "${REPLY}" | wc -l
}

nix::bash::dump() {
    local MATCH="$1"
    MATCH="${MATCH^^}"
    MATCH="${MATCH//-/_}"

    while (( $# > 0 )); do
        for REPLY in $(eval "echo \${!${MATCH}*}"); do
            echo ${REPLY}
        done
        shift
    done | sort
}

nix::bash::join() {
    local DELIMITER="${1?'Missing delimiter'}"
    shift

    if (( $# > 0 )); then
        echo -n "$1"
        shift

        while (( $# > 0 )); do
            echo -n "${DELIMITER}"
            echo -n "$1" 
            shift
        done
    fi

    echo
}

nix::bash::function::test() {
    local NAME="$1"
    shift

    declare -f "${NAME}" >/dev/null
}

nix::bash::function::parts() {
    local NAME="$1"
    nix::bash::args ${NAME//::/ }
}

nix::bash::function() {
    local FRAME_OFFSET=${1-0}
    local FRAME_BASE=3
    local FRAME=$(( FRAME_OFFSET + FRAME_BASE ))
    nix::bash::function::parts ${FRAME}
}

nix::bash::caller() {
    nix::bash::function "$@"
}

nix::bash::expand() {
    while read -r; do echo "${REPLY//\\/\\\\}"; done \
        | while read -r; do eval "echo \"${REPLY}\""; done
}

nix::string::repeat() {
    local COUNT="$1"
    shift

    local VALUE="$1"
    shift

    local -i INDEX
    for (( INDEX=0; INDEX < COUNT; INDEX++ )); do
        echo -n "${VALUE}"
    done

    echo
}

nix::string::indent() {
    local DEPTH="$1"
    shift
    
    echo -n "$(nix::string::repeat "${DEPTH}" ' ')"
}

nix::bash::symbol::test() {
    local SYMBOL="$1"
    shift

    declare -p "${SYMBOL}" >/dev/null 2>/dev/null
}

nix::bash::symbol::readonly::test() {
    local SYMBOL="$1"
    shift

    local FLAGS
    read _ FLAGS _ < <(
        declare -p "${SYMBOL}" 2>/dev/null
    ) && [[ "${FLAGS}" =~ 'r' ]]
}

