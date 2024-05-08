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
