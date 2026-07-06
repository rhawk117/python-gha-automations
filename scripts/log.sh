#!/usr/bin/env bash

_kc_in_ci() {
    [[ "${CI:-false}" == "true" ]]
}

_KC_RED='\033[0;31m'
_KC_GREEN='\033[0;32m'
_KC_YELLOW='\033[1;33m'
_KC_BLUE='\033[0;34m'
_KC_CYAN='\033[0;36m'
_KC_BOLD='\033[1m'
_KC_RESET='\033[0m'

log_info() {
    if _kc_in_ci; then
        printf '%s\n' "::info::$*"
    else
        printf '%b  %s\n' "${_KC_BLUE}  info${_KC_RESET}" "$*"
    fi
}

log_success() {
    if _kc_in_ci; then
        printf '%s\n' "::notice::$*"
    else
        printf '%b  %s\n' "${_KC_GREEN}    ok${_KC_RESET}" "$*"
    fi
}

log_warn() {
    if _kc_in_ci; then
        printf '%s\n' "::warning::$*"
    else
        printf '%b  %s\n' "${_KC_YELLOW}  warn${_KC_RESET}" "$*" >&2
    fi
}

log_error() {
    if _kc_in_ci; then
        printf '%s\n' "::error::$*"
    else
        printf '%b  %s\n' "${_KC_RED} error${_KC_RESET}" "$*" >&2
    fi
}

log_step() {
    if _kc_in_ci; then
        printf '%s\n' "::group::$*"
    else
        printf '\n%b %s%b\n' "${_KC_BOLD}${_KC_CYAN}▶" "$*" "${_KC_RESET}"
    fi
}

log_step_end() {
    if _kc_in_ci; then
        printf '%s\n' "::endgroup::"
    fi
}
