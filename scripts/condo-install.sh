#!/usr/bin/env bash

CONDO_ROOT="$HOME/.am/condo"
CONDO_LOG="$CONDO_ROOT/condo.log"
CONDO_VERBOSITY='normal'

CONDO_CLR_INFO='\033[1;33m'       # BRIGHT YELLOW
CONDO_CLR_FAILURE='\033[1;31m'    # BRIGHT RED
CONDO_CLR_SUCCESS="\033[1;32m"    # BRIGHT GREEN
CONDO_CLR_CLEAR="\033[0m"         # DEFAULT COLOR

__condo-success() {
    echo -e "${CONDO_CLR_SUCCESS}$@${CONDO_CLR_CLEAR}"
    echo "log  : $@" >> $CONDO_LOG
}

__condo-failure() {
    echo -e "${CONDO_CLR_FAILURE}$@${CONDO_CLR_CLEAR}"
    echo "err  : $@" >> $CONDO_LOG
}

__condo-info() {
    if [[ "$CONDO_VERBOSITY" != 'quiet' && "$CONDO_VERBOSITY" != 'minimal' ]]; then
        echo -e "${CONDO_CLR_INFO}$@${CONDO_CLR_CLEAR}"
        echo "log : $@" >> $CONDO_LOG
    fi
}

__condo-install-help() {
    echo 'Installation for Condo Build System'
    echo
    echo 'Usage:'
    echo '  ./condo.sh install [arguments] [common-options]'
    echo
    echo 'Common options:'
    echo '  -h|-?|--help        print this help information'
    echo '  -l|--log            location of the installation log'
    echo '                        DEFAULT: $CONDO_INSTALL_DIR/condo.log'
    echo
    echo 'Arguments:'
    echo '  -nc|--no-color      do not emit color to output, which is useful for capture'
    echo '  -id|--install-dir   location in which to install condo'
    echo '                        DEFAULT: $HOME/.am/condo'
    echo '  -b|--branch         install condo from the specified branch'
    echo '                        DEFAULT: master'
    echo '  -s|--source         install condo from the specified source path (local)'
    echo '  --uri               install condo from the specified URI'
    echo
    echo 'EXAMPLE:'
    echo '  ./condo.sh install --branch feature/cli --no-color --install-dir $HOME/.condo --log $HOME/condo.log'
    echo '    - installs condo from the `feature/cli` branch'
    echo '    - no color will be emitted to the console (either STDOUT or STDERR)'
    echo '    - condo will be installed to `$HOME/.condo`'
    echo '    - the installation log will be saved to $HOME/condo-install.log'
}

__condo-install() {
    # get the current path
    local CURRENT_PATH="$pwd"

    # find the script path
    local ROOT_PATH=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

    # setup well-known condo paths
    local CLI_ROOT="$CONDO_ROOT/cli"
    local SRC_ROOT="$CONDO_ROOT/src"
    local CONDO_SHELL="$SRC_ROOT/src/AM.Condo/Scripts/condo.sh"

    # change to the root path
    pushd $ROOT_PATH 1>/dev/null

    # write a newline for separation
    echo

    # continue testing for arguments
    while [[ $# > 0 ]]; do
        case $1 in
            -h|-\?|--help)
                __condo-install-help
                exit 0
                ;;
            -l|--local)
                local CONDO_LOCAL=1
                ;;
            --uri)
                local CONDO_URI=$2
                shift
                ;;
            -b|--branch)
                local CONDO_BRANCH=$2
                shift
                ;;
            -s|--source)
                local CONDO_SOURCE=$2
                shift
                ;;
            -id|--install-dir)
                CONDO_ROOT="$1"

                if [ -z "${CONDO_LOG_SET:-}" ]; then
                    CONDO_LOG="$CONDO_ROOT/condo-install.log"
                fi

                shift
                ;;
            -l|--log)
                CONDO_LOG="$1"
                local CONDO_LOG_SET=1
                shift
                ;;
            -nc|--no-color)
                local CONDO_CLR_INFO=
                local CONDO_CLR_FAILURE=
                local CONDO_CLR_CLEAR=
                ;;
            *)
                echo -e "${CONDO_CLR_FAILURE}Invalid argument:${CONDO_CLR_CLEAR} $1"
                __condo-install-help
                exit 1
                ;;
        esac
        shift
    done

    if [ -d "$CONDO_ROOT" ]; then
        __condo-info 'Resetting condo build system...'
        rm -rf "$CONDO_ROOT"
    fi

    if [ -z "${DOTNET_INSTALL_DIR:-}" ]; then
        export DOTNET_INSTALL_DIR=~/.dotnet
    fi

    if [ -z "${CONDO_BRANCH:-}" ]; then
        CONDO_BRANCH='master'
    fi

    if [ -z "${CONDO_URI:-}" ]; then
        CONDO_URI="https://github.com/automotivemastermind/condo/tarball/$CONDO_BRANCH"
    fi

    if [ "$CONDO_LOCAL" = "1" ]; then
        CONDO_SOURCE="$ROOT_PATH"
    fi

    if [ ! -d "$SRC_ROOT" ]; then
        __condo-info "Creating path for condo at $CONDO_ROOT..."
        mkdir -p $SRC_ROOT

        if [ ! -z $CONDO_SOURCE ]; then
            __condo-info "Using condo build system from $CONDO_SOURCE..."
            cp -r $CONDO_SOURCE/* $SRC_ROOT/
            cp -r $CONDO_SOURCE/template $CONDO_ROOT
        else
            local CURL_OPT='-s'
            if [ ! -z "${GH_TOKEN:-}" ]; then
                CURL_OPT='$CURL_OPT -H "Authorization: token $GH_TOKEN"'
            fi

            __condo-info "Using condo build system from $CONDO_URI..."

            CONDO_TEMP=$(mktemp -d)
            CONDO_TAR="$CONDO_TEMP/condo.tar.gz"

            retries=5

            until (curl $CURL_OPT -o $CONDO_TAR --location $CONDO_URI 2>/dev/null); do
                __condo-failure "Unable to retrieve condo: '$CONDO_URI'"

                if [ "$retries" -le 0 ]; then
                    exit 1
                fi

                retries=$((retries - 1))
                __condo-failure "Retrying in 10 seconds... attempts left: $retries"
                sleep 10s
            done

            CONDO_EXTRACT="$CONDO_TEMP/extract"
            CONDO_SOURCE="$CONDO_EXTRACT"

            mkdir -p $CONDO_EXTRACT
            tar xf $CONDO_TAR --strip-components 1 --directory $CONDO_EXTRACT
            cp -r $CONDO_SOURCE/* $SRC_ROOT/
            cp -r $CONDO_SOURCE/template $CONDO_ROOT
            rm -Rf $CONDO_TEMP

            local SHA_URI="https://api.github.com/repos/automotivemastermind/condo/commits/$CONDO_BRANCH"
            local CONDO_SHA=$(curl $CURL_OPT $SHA_URI | grep sha | head -n 1 | sed 's#.*\:.*"\(.*\).*",#\1#')
            local CONDO_SHA_PATH="$CONDO_ROOT/sha"
            local CONDO_VERSION_PATH="$CONDO_ROOT/version"
            local CONDO_BRANCH_PATH="$CONDO_ROOT/branch"

            echo $CONDO_SHA > $CONDO_SHA_PATH
            echo $CONDO_BRANCH > $CONDO_BRANCH_PATH
        fi
    fi

    # ensure that the condo shell is executable
    chmod a+x $CONDO_SHELL

    # write a newline for separation
    echo

    # change to the original path
    popd
}

__condo-install "$@"

# capture the current exit code
EXIT_CODE=$?

# exit
exit $EXIT_CODE
