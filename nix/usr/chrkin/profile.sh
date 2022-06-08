TZ='Pacific/Honolulu'

readonly NIX_MY_DISPLAY_NAME="Chris King"
readonly NIX_MY_TZ_OFFSET=-10h
readonly NIX_MY_IP_ALLOCATION="10.100.0.0/16"
readonly NIX_MY_ENVIRONMENTS=(
    DOGFOOD_INT
    DOGFOOD
    SELFHOST
    INT
    PPE
)

readonly NIX_KUSTO_TIME_FORMAT='hh:mm:ss-tt'

# 0 - Pull Request 396016: Pool cannot patch network settings with different ad join type. 
#       Now bug 1537283. https://dev.azure.com/devdiv/OnlineServices/_workitems/edit/1537283

# 1 - Pull Request 397830: Return not a guest in local or dogfood test environment. Now bug 1537547 Failed to create CPC.
# 2 - Pull Request 397830: Return not a guest in local or dogfood test environment. Now bug 1537547 Failed to create CPC. Reproduction.
#       https://dev.azure.com/devdiv/OnlineServices/_sprints/taskboard/Azure%20Lab%20Services%20-%20Fidalgo/OnlineServices/Copper/CY22%20Q2/2Wk/2Wk3

# 3 - Pull Request 396016: Pool cannot patch network settings with different ad join type. 
# 4 - aadj; Retry creation of CPC; Failed
# 5 - aadj-hybrid; try establish basline using HybridAadj now that DC is healthy; 
#            Oops. Forgot to use DC network. Cannot cleanup network-settings because of Bug 1537283
# 6 - aadj-hybrid; try establish basline using HybridAadj now that DC is healthy; failed. Renamed everything. Will run again.
# 7 - aadj; Retry creation of CPC for reporting to channel; Failed but did more re-names
# 8 - aadj; Retry creation of CPC for reporting to channel; Also in INT; In INT Forbidden to create network settings; In SF cannot delete NetworkSettings in wrong region
# 9 - aadj; Retry in SelfHost with correct location (did attached network last) worked!
# 10 - aadj; Retry in SelfHost with correct location (do attached network early) 
# 11 - bug 1487564
# 12 - new test framework; blocked by Bug 1551855: Failed Pool Creation due to bad NetworkSettingsId
# 13 - try new hybrid-ad.sh
readonly NIX_MY_ENV_ID=13

alias r="nix::shell::pushd ${NIX_REPO_DIR}"
alias re="nix::shim::relogin"
alias rel="nix::shim::reload"
alias reg="nix::shim::regenerate"
alias rx="nix::shim::break"

alias pd-nix="nix::shell::pushd ${NIX_DIR}"
alias pd-nix-src="nix::shell::pushd ${NIX_DIR}/src"
alias pd-usr="nix::shell::pushd ${NIX_DIR}/usr"
alias pd-tst="nix::shell::pushd ${NIX_DIR}/tst"
alias pd-aadj="nix::shell::pushd ${NIX_DIR}/tst/src/aadj"
alias pd-kusto="nix::shell::pushd ${NIX_REPO_DIR_KUSTO}"
alias pd-http="nix::shell::pushd ${NIX_REPO_DIR}/http"
alias pd-dp="nix::shell::pushd ${NIX_REPO_DIR}/http/dataplane"

alias pd-swag-rm="nix::shell::pushd ${NIX_REPO_DIR_SRC}/sdk/specification/devtestcenter/resource-manager/Microsoft.Fidalgo/preview"

# projects/aadj-project-df/users/me/virtualmachines/aadj-vm0-df
alias aadj-curl="nix::dataplane::vm::put aadj-project-df aadj-pool aadj-vm0-df"

alias who="fd-who"
alias dp="nix::bash::dump::declarations"

alias public="fd-switch-to-public"
alias dogfood="fd-switch-to-dogfood"
alias dogfood-int="fd-switch-to-dogfood-int"
alias selfhost="fd-switch-to-selfhost"
alias int="fd-switch-to-int"
alias ppe="fd-switch-to-ppe"
alias ppe3="fd-switch-to-ppe3"

alias su-admin="fd-login-as-administrator"
alias su-net="fd-login-as-network-administrator"
alias su-me="fd-login-as-me"
alias su-dev="fd-login-as-developer"
alias su-usr="fd-login-as-vm-user"

alias me="fd-my-profile"
alias nix="fd-nix | grep -i"
alias var="fd-nix-env | grep -i"
alias cpc="fd-nix-cpc | grep -i"
alias fid="fd-nix-fid | grep -i"
alias www="fd-nix-env-www"

alias pd="nix::shell::pushd"
alias u="pd .."
alias uu="u && u"
alias uuu="uu && u"
alias uuuu="uuu && u"

alias p="nix::shell::popd"
alias pp="p && p"
alias ppp="pp && p"
alias pppp="ppp && p"

alias ag="alias -p | grep "
alias callees="nix::function::callee::tree"
alias callers="nix::function::caller::tree"

alias cmd="nix::cmd::compile"
alias cmd-exe="nix::cmd::run"
alias x="nix::cmd::run"
alias cmd-show="nix::cmd::compile | nix::line::join"
alias cmd-emit="nix::cmd::compile | nix::cmd::emit"

alias fit="fd-line-fit"
alias exe="fd-line-exe"
alias skip="fd-line-skip"
alias except="nfd-line-except"


# cat $FILE | jq '. |  {RefreshToken:.RefreshToken,Account:.Account}'

# dynamic stubs
# lazy apt-get dotnet
# apt update suppression
# lazy secret promopting
# pipeline spy

# make az profile readonly
# lazy apt-get kusto
# lazy user creation
# docker development
# fast loading, cloud caching
# fail fast loading
# atomic switching
# democratize az commands
# harvest subscriptions
# live cpu usage
# background task as test runner
# lint alias/function names
# warn if kusto query exceeds 90 days
# detect callee/caller cycles between namespaces
# test

nix::snippit() {
    # printf '%s\n' main "$(lsof -p $$ | grep dev)" > /dev/stderr

    echo ls -l /proc/$BASHPID/fd
    ls -l /proc/$BASHPID/fd

    pipe() {
        # printf '%s %s:%s %s\n' $1 $BASHPID $BASH_SUBSHELL $$ > /dev/stderr
        # printf '%s\n' $1 "$(lsof -p $BASHPID | grep dev)" > /dev/stderr
        cat
        echo $1
        echo ls -l /proc/$BASHPID/fd
        ls -l /proc/$BASHPID/fd
    }

    echo hi | pipe a | pipe b | pipe c | pipe d
}

nix::env::diff() {
    nix::record::diff <(nix) <("$@"; nix)
}

nix::record::diff() {
    local BEFORE="$1"
    shift

    local AFTER="$1"
    shift

    diff "${BEFORE}" "${AFTER}" \
        --unchanged-line-format="" \
        --new-line-format="+ %L" \
        --old-line-format="- %L" \
        | sort -k2,2 -k1,1r
}

# Bug 1487564: Incorrectly formatted parameters lead to 500 on environment deployment
# Bug 1472319: Environment creation fails with internal server error when authentication errors occur.
