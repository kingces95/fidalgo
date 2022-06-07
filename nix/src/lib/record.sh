alias sort-table=nix::record::sort_table
alias record-join=nix::record::join
alias vlookup="nix::record::vlookup"

alias a2='nix::record::align 2'
alias a3='nix::record::align 3'
alias a4='nix::record::align 4'
alias a5='nix::record::align 5'
alias a6='nix::record::align 6'
alias a7='nix::record::align 7'
alias a8='nix::record::align 8'
alias a9='nix::record::align 9'

alias a2f='nix::record::align 2 | nix::line::fit'
alias a3f='nix::record::align 3 | nix::line::fit'
alias a4f='nix::record::align 4 | nix::line::fit'
alias a5f='nix::record::align 5 | nix::line::fit'
alias a6f='nix::record::align 6 | nix::line::fit'
alias a7f='nix::record::align 7 | nix::line::fit'
alias a8f='nix::record::align 8 | nix::line::fit'
alias a9f='nix::record::align 9 | nix::line::fit'

pump() { nix::record::pump 1 "$@"; }
pump2() { nix::record::pump 2 "$@"; }
pump3() { nix::record::pump 3 "$@"; }
pump4() { nix::record::pump 4 "$@"; }

nix::record::shift() {
    local -i FIELDS=$1
    shift

    local COUNT=${1-1}

    while nix::record::mapfile "${FIELDS}"; do
        set -- "${MAPFILE[@]}"
        shift "${COUNT}"
        echo "$*"
    done
}

nix::record::vlookup() {
    local KEY="$1"
    shift

    local COLUMN="$1"
    shift

    while nix::record::mapfile "$(( COLUMN + 1 ))"; do
        local INDEX=$(( COLUMN - 1 ))
        if [[ "${MAPFILE[0]}" == "${KEY}" ]]; then
            echo "${MAPFILE[${INDEX}]}"
            return
        fi
    done

    return 1
}

nix::record::number() {
    nl \
        | nix::record::project 2 2 1 \
        | sort
}

nix::record::join() {
    local F1=$1 # delimited by spaces
    shift

    local F2=$1 # record; last field may have spaces
    shift

    local F2_FIELDS=$1
    shift

    local F1_JOIN_FIELD=${1-1}
    shift

    local F2_JOIN_FIELD=${1-1}
    shift

    local UNJOINED="${1:-UNJOINED}"
    shift

    {
        MAPFILE=()
        if ! nix::record::mapfile ${F2_FIELDS} <&4; then
            return
        fi
        
        while true; do     
            if ! read -a F1_RECORD <&3; then
                cat <&4 | sed "s/^/${UNJOINED} /g" 
                return
            fi
            
            local JOIN_FIELD1="${F1_RECORD[$((${F1_JOIN_FIELD} - 1))]}"
            unset F1_RECORD[$((${F1_JOIN_FIELD} - 1))]

            while true; do
                local JOIN_FIELD2="${MAPFILE[$((${F2_JOIN_FIELD} - 1))]}"

                # echo "${JOIN_FIELD1}" == "${JOIN_FIELD2}" >&2

                if [[ "${JOIN_FIELD1}" > "${JOIN_FIELD2}" ]]; then
                    echo "${UNJOINED}" "${MAPFILE[*]}"

                elif [[ "${JOIN_FIELD1}" == "${JOIN_FIELD2}" ]]; then
                    echo "${F1_RECORD[*]}" "${MAPFILE[*]}"

                else
                    break;
                fi

                if ! nix::record::mapfile ${F2_FIELDS} <&4; then
                    return
                fi
            done

        done 
    } 3<"${F1}" 4<"${F2}"

    # record-join <(echo a 0; echo a 1; echo b 4;) <(echo . a 2; echo . b 3 zzz  aaa;) 3 1 2
}

nix::record::add_ordinal() { 
    local F1_ENUM=$1
    shift

    local F2_FIELDS=$1
    shift

    local F2_JOIN_FIELD=$1
    shift

    local UNJOINED=$1
    shift

    local F1_JOIN_FIELD=1
    local F2_RECORDS="/dev/stdin"

    nix::record::join "${F1_ENUM}" \
        <(sort -s -k${F2_JOIN_FIELD},${F2_JOIN_FIELD} "${F2_RECORDS}") \
        ${F2_FIELDS} ${F1_JOIN_FIELD} ${F2_JOIN_FIELD} \
        "${UNJOINED}"
}

nix::record::mapfile() {
    local -i FIELDS=$1
    shift

    MAPFILE=()

    if ! read; then
        return 1
    fi

    local RECORD
    while (( FIELDS - 1 > 0 )); do
        read -r RECORD REPLY <<< "${REPLY}"
        MAPFILE+=( ${RECORD} )
        FIELDS=$(( FIELDS - 1))
    done

    if [[ "${REPLY}" == "" ]]; then
        return;
    fi
    MAPFILE+=( "${REPLY}" )
}

nix::record::contains() {
    local -i FIELDS=$1
    shift

    local VALUE=$1
    shift

    local -i FIELD="${1-1}"
    shift

    local INDEX=$(( ${FILTER_FIELD} - 1 ))
    while nix::record::mapfile "${FIELDS}"; do
        if [[ "${MAPFILE[${INDEX}]}" = "${VALUE}" ]]; then
            return
        fi
    done

    return 1
}

nix::record::filter::regex() {
    local -i FIELDS=$1
    shift

    local REGEX=$1
    shift

    local -i FILTER_FIELD=${1-1}
    shift

    local INDEX=$(( ${FILTER_FIELD} - 1 ))
    while nix::record::mapfile "${FIELDS}"; do
        if [[ "${MAPFILE[${INDEX}]}" =~ ${REGEX} ]]; then
            echo "${MAPFILE[*]}"
        fi
    done
}

nix::enum::map() {
    local FIELD="$1"
    shift

    local -A MAP
    nl | nix::record::swap | nix::bash::map::read MAP
}

nix::record::replace() {
    local MAPS=( "$@" )
    shift

    while nix::record::mapfile $(( ${#MAPS[@]} + 1 )); do
        local -i INDEX
        for (( INDEX=0; INDEX<${#MAPS[@]}; INDEX++ )); do
            local VALUE="${MAPFILE["${INDEX}"]}"

            if [[ ! "${MAPS[${INDEX}]}" ]]; then
                continue
            fi

            local -n MAP_REF="${MAPS[${INDEX}]}"
            MAPFILE["${INDEX}"]="${MAP_REF[${VALUE}]-?}"
        done
        echo "${MAPFILE[*]}"
    done
}

nix::record::sort::stable() {
    local SORT_FIELDS=( "$@" )
    
    local SORT_BY=$(
        nix::bash::args "${SORT_FIELDS[@]}" \
            | nix::record::project 1 1 1 \
            | nix::record::printf 2 '-k%s,%s' \
            | nix::line::join
    )

    sort -s ${SORT_BY}
}

nix::record::project() {
    local -i FIELDS=$1
    shift

    while nix::record::mapfile ${FIELDS}; do
        local FIELD
        local SEP=''
        for FIELD in "$@"; do
            local INDEX=$(( ${FIELD} - 1 ))
            echo -n "${SEP}${MAPFILE[${INDEX}]}"
            SEP=' '
        done
        echo
    done
}

nix::record::swap() {
    nix::record::project 2 2 1
}

nix::record::max_width() {
    local -i FIELDS=$1
    local -ai MAX_FIELD_WIDTH

    while nix::record::mapfile ${FIELDS}; do
        set -- "${MAPFILE[@]}"

        local INDEX
        for INDEX in ${!MAPFILE[@]}; do
            local FIELD_WIDTH=${#MAPFILE[${INDEX}]}
            if (( ${MAX_FIELD_WIDTH[$INDEX]-0} < ${FIELD_WIDTH} )); then
                MAX_FIELD_WIDTH[$INDEX]=FIELD_WIDTH
            fi
        done
    done

    nix::bash::args "${MAX_FIELD_WIDTH[@]}"
}

nix::record::printf() {
    local -i FIELDS=$1
    shift

    local FORMAT="${1-'%s'}"
    shift

    while nix::record::mapfile "${FIELDS}"; do
        printf -- "${FORMAT}\n" "${MAPFILE[@]}"
    done
}

nix::record::align::format() {
    local -i FIELDS=$1

    nix::record::max_width "${FIELDS}" \
    | nix::record::printf 1 '%%-%ss' \
    | nix::line::join
}

nix::record::align() {
    local -i FIELDS="$1"
   
    local TMP=$(mktemp)
    cat > "${TMP}"

    local FORMAT=$(nix::record::align::format "${FIELDS}" < "${TMP}")
   
    nix::record::printf "${FIELDS}" "${FORMAT}" < "${TMP}"

    rm "${TMP}"
}

nix::record::pump() {
    local FIELDS="$1"
    shift

    local FUNCTION="$1"
    shift

    while nix::record::mapfile "${FIELDS}"; do
        ${FUNCTION} "${MAPFILE[@]}" "$@"
    done
}

nix::record::prepend() {
    nix::line::prepend "$* "
}

nix::record::unique() {
    local -i FIELDS=$1
    shift

    local KEY_FIELDS=( "$@" )
    shift

    local -a LAST_KEYS=()
    while nix::record::mapfile "${FIELDS}"; do

        local -a KEYS=()
        for KEY_FIELD in "${KEY_FIELDS[@]}"; do
            local INDEX=$(( KEY_FIELD - 1 ))
            KEYS+=( ${MAPFILE[${INDEX}]} )
        done

        if [[ "${KEYS[*]}" == "${LAST_KEYS[*]}" ]]; then
            continue
        fi

        echo "${MAPFILE[*]}"
        LAST_KEYS=( "${KEYS[@]}" )
    done
}

nix::record::context::chunk() {
    local -i FIELDS="$1"
    shift

    local SEARCH_TERM="$1"
    shift

    local CONTEXT
    while nix::record::mapfile "${FIELDS}"; do
        if [[ "${MAPFILE}" =~ ${SEARCH_TERM} ]]; then
            local NEXT_CONTEXT="${MAPFILE[*]}"
            if [[ "${NEXT_CONTEXT}" == "${CONTEXT}" ]]; then
                continue
            fi

            CONTEXT="${NEXT_CONTEXT}"
            echo
        fi

        echo "${MAPFILE[*]}"
    done
}

nix::record::distinct() {
    local FIELD="${1-1}"
    shift

    local -A KEYS=()

    local FIELDS=$(( FIELD + 1 ))
    local INDEX=$(( FIELD - 1 ))
    while nix::record::mapfile "${FIELDS}"; do
        local KEY="${MAPFILE[$INDEX]}"
        if nix::bash::map::test KEYS "${KEY}"; then
            continue
        fi
        KEYS["${KEY}"]=true

        echo "${MAPFILE[@]}"
    done
}

nix::record::override() {
    tac \
    | nix::record::distinct \
    | tac
}

nix::record::expand() {
    local FILTER="$1"
    shift

    local TEE="$1"
    shift

    local OP
    while read -r OP REPLY; do
        if [[ "${TEE}" ]]; then
            echo "${OP} ${REPLY}" >> "${TEE}"
        fi

        if [[ "${OP}" == "${FILTER}" ]]; then
            return
        fi

        echo "${OP} ${REPLY}"
    done

    return 1
}