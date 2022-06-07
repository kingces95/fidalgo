alias fd-secret="nix::secret::cat"
alias fd-secret-rm="nix::secret::rm"
alias fd-secret-path="nix::secret::path"
alias fd-secret-read="nix::secret::read"
alias fd-secret-set="nix::secret::set"
alias fd-secret-get="nix::secret::get"
alias fd-secret-test="nix::secret::test"

nix::secret::prompt() {
    nix::tty::printf '%s' "$* > "
    read -s
    echo '********'
}

nix::secret::read() {
    while true; do
        nix::secret::prompt "Enter team secret" >&2
        local SECRET="${REPLY}"

        nix::secret::prompt "Re-enter team secret" >&2
        if [[ ! "${SECRET}" == "${REPLY}" ]]; then
            nix::tty::echo "Passwords do not match." >&2
            continue
        fi

        break
    done
}

nix::secret::path() {
    echo "${NIX_SECRET}"
}

nix::secret::cat() {
    if ! nix::secret::test; then
        return
    fi

    cat "${NIX_SECRET}"
}

nix::secret::test() {
    [[ -s "${NIX_SECRET}" ]]
}

nix::secret::rm() {
    if ! nix::secret::test; then
        return
    fi

    rm "${NIX_SECRET}"
}

nix::secret::set() {
    local SECRET="$1"
    if ! nix::secret::test \
        || [[ ! $"{SECRET}" == "$(nix::secret::cat)" ]]; then
        echo "${SECRET}" > "${NIX_SECRET}"
    fi
}

nix::secret::get() {
    if nix::secret::test; then
        nix::secret::cat
    else
        nix::secret::read
        echo "${REPLY}"
    fi
}
