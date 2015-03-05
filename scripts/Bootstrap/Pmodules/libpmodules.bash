#!/bin/bash

log() {
        local -ri fd=$1
        local -r fmt="$2\n"
        shift 2
        printf -- "$fmt" "$@" >> /dev/fd/$fd
}

info() {
        log 2 "$1\n" "${@:2}"
}

error() {
        log 2 "$1\n" "${@:2}"
}

debug() {
        [[ ${PSI_DEBUG} ]] || return 0
        log 2 "$@"
}

die() {
        local -ri ec=$1
        shift
        local cout
        if (( ec == 0)); then
                cout='1'
        else
                cout='2'
        fi      
        if [[ -n $@ ]]; then
                local -r fmt=$1
                shift
                log $cout "$fmt" "$@"
        fi
        exit $ec
}

#
# get answer to yes/no question
#
# $1: prompt
#
get_YN_answer() {
	local -r prompt="$1"
	local ans
	read -p "${prompt}" ans
	case ${ans} in
		y|Y ) 
			return 0;;
		* )
			return 1;;
	esac
}

get_options() {
	"${bindir}/getopt" "$@"
}

check_pmodules_env() {
	[[ -n "${PSI_PREFIX}" ]] &&
	    [[ -n "${PSI_CONFIG_DIR}" ]] &&
	    [[ -n "${PSI_MODULES_ROOT}" ]] &&
	    [[ -n "${PSI_TEMPLATES_DIR}" ]] &&
	    [[ -n "${PMODULES_HOME}" ]] &&
	    [[ -n "${PMODULES_VERSION}" ]] || die 1 "
Error: the module environment you are going to use as source has not been
initialized properly!"

	[[ -d "${PSI_PREFIX}" ]] &&
	    [[ -d "${PSI_PREFIX}/${PSI_CONFIG_DIR}" ]] &&
	    [[ -d "${PSI_PREFIX}/${PSI_MODULES_ROOT}" ]] &&
	    [[ -d "${PSI_PREFIX}/${PSI_TEMPLATES_DIR}" ]] &&
	    [[ -d "${PMODULES_HOME}" ]] || die 1 "
Error: the module environment '$PSI_PREFIX' has not been initialized properly!"

}


# Local Variables:
# mode: sh
# sh-basic-offset: 8
# tab-width: 8
# End:
