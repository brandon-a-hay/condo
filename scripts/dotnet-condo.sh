#!/usr/bin/env bash

# find the script path
CONDO_ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
CONDO_LOG="$CONDO_ROOT/condo.log"
CONDO_VERBOSITY='normal'

CONDO_CLR_INFO='\033[1;33m'       # BRIGHT YELLOW
CONDO_CLR_FAILURE='\033[1;31m'    # BRIGHT RED
CONDO_CLR_SUCCESS="\033[1;32m"    # BRIGHT GREEN
CONDO_CLR_CLEAR="\033[0m"         # DEFAULT COLOR

# get the current path
CURRENT_PATH=$(pwd)

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

__condo-help() {
    echo 'Condo Build System'
    echo
    echo 'Usage:'
    echo '  ./condo.sh [host-options] [command] [arguments] [common-options]'
    echo
    echo 'Host options:'
    echo '  --version           display version number'
    echo '  --info              display info about the host and condo build system'
    echo
    echo 'Arguments:'
    echo '  [host-options]      options passed to the host (dotnet)'
    echo '  [command]           the command to execute'
    echo '  [arguments]         options passed to the `install` command'
    echo '  [common-options]    options common to all commands'
    echo
    echo 'Common options:'
    echo '  -h|-?|--help        print help information for the specified command'
    echo '  -l|--log            location of the installation log'
    echo '                        DEFAULT: $CONDO_INSTALL_DIR/condo.log'
    echo '  -nc|--no-color      do not emit color to output, which is useful for capture'
    echo
    echo 'Commands:'
    echo '  install             installs condo on the local system'
    echo '  update              updates condo to the latest version'
    echo '  init                initializes condo in the current directory'
    echo '  build               uses condo to execute the build target (Build)'
    echo '  test                uses condo to execute the test target (Test)'
    echo '  publish             uses condo to execute the publish target (Publish)'
    echo '  ci                  uses condo to execute the continuous integration target (CI)'
    echo '  clean               uses condo to execute the clean target'
    echo
    echo 'Advanced commands:'
    echo '  nuget               uses condo to manipulate nuget feeds and credentials'
    echo '  conventions         uses condo to create new conventions'
    echo '  config               edit the condo configuration'
}
