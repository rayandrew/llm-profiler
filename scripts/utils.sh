
if [ "$(hostname)" != "midnight" ]; then
    export CC=cc
    export CXX=CC
fi

export C_INCLUDE_PATH="${PROJECT_ROOT}/.venv/hwloc/include:$C_INCLUDE_PATH"
export CPLUS_INCLUDE_PATH="${PROJECT_ROOT}/.venv/hwloc/include:$CPLUS_INCLUDE_PATH"
export LIBRARY_PATH="$LIBRARY_PATH:${PROJECT_ROOT}/.venv/hwloc/lib"
export PKG_CONFIG_PATH="${PROJECT_ROOT}/.venv/hwloc/lib/pkgconfig:$PKG_CONFIG_PATH"

export ML_ENV=$PWD/.venv

# colors
blue='\033[0;34m'
green='\033[0;32m'
red='\033[0;31m'
yellow='\033[0;33m'
reset='\033[0m'

log_info() {
    echo -e "${blue}[I]${reset} $@"
}

log_err() {
    echo -e "${red}[E]${reset} $@"
}

log_success() {
    echo -e "${green}[S]${reset} $@"
}

assert_eq() {
    if [ $1 -ne 0 ]; then
        log_err "$2"
        exit 1
    fi
}

assert_ne() {
    if [ $1 -eq 0 ]; then
        log_err "$2"
        exit 1
    fi
}
