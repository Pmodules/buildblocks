#!/bin/bash

if [[  -z ${bindir} ]]; then
        local bindir=$(dirname "${BASH_SOURCE}")
	bindir=$(cd "${bindir}"/.. && pwd)"/bin"
fi

log() {
        local -ri fd=$1
        local -r fmt="$2\n"
        shift 2
        printf -- "$fmt" "$@" >> /dev/fd/$fd
}

info() {
        log 2 "$1" "${@:2}"
}

error() {
        log 2 "$1" "${@:2}"
}

debug() {
        [[ ${PSI_DEBUG} ]] || return 0
        log 2 "$@"
}

die() {
        local -ri ec=$1
        shift
        if [[ -n $@ ]]; then
                local -r fmt=$1
                shift
                log 2 "$fmt" "$@"
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

#
# return normalized abolute pathname
# $1: filename
get_abspath() {
	local -r fname=$1
	[[ -r "${fname}" ]] || return 1
	if [[ -d ${fname} ]]; then
		echo $(cd "${fname}" && pwd)
	else
		local -r dname=$(dirname "${fname}")
		echo $(cd "${dname}" && pwd)/$(basename "${fname}")
	fi
}

get_options() {
	"${bindir}/getopt" "$@"
}

check_pmodules_env_vars() {
	[[ -n "${PSI_PREFIX}" ]] &&
	    [[ -n "${PSI_CONFIG_DIR}" ]] &&
	    [[ -n "${PSI_MODULES_ROOT}" ]] &&
	    [[ -n "${PSI_TEMPLATES_DIR}" ]] &&
	    [[ -n "${PMODULES_HOME}" ]] &&
	    [[ -n "${PMODULES_VERSION}" ]] || die 1 "
Error: the module environment you are going to use as source has not been
initialized properly!"
}

check_pmodules_directories() {
	local -r src_prefix="$1"

	[[ -d "${src_prefix}" ]] &&
	    [[ -d "${src_prefix}/${PSI_CONFIG_DIR}" ]] &&
	    [[ -d "${src_prefix}/${PSI_MODULES_ROOT}" ]] &&
	    [[ -d "${src_prefix}/${PSI_TEMPLATES_DIR}" ]] &&
	    [[ -d "${src_prefix}/Tools/Pmodules/${PMODULES_VERSION}" ]] || die 1 "
Error: the module environment '${src_prefix}' has not been initialized properly!"
}

check_pmodules_env() {
	check_pmodules_env_vars
	check_pmodules_directories "${PSI_PREFIX}"
}

append_path () {
        local -r P=$1
        local -r d=$2

        if ! echo ${!P} | egrep -q "(^|:)${d}($|:)" ; then
                if [[ -z ${!P} ]]; then
                        eval $P=${d}
                else
                        eval $P=${!P}:${d}
                fi
        fi
}

prepend_path () {
        local -r P=$1
        local -r d=$2

        if ! echo ${!P} | egrep -q "(^|:)${d}($|:)" ; then
                if [[ -z ${!P} ]]; then
                        eval $P=${d}
                else
                        eval $P=${d}:${!P}
                fi
        fi
}

remove_path() {
        local -r P=$1
        local -r d=$2
	local new_path=''
	local -r _P=( ${!P//:/ } )
	# loop over all entries in path
	for entry in "${_P[@]}"; do
		[[ "${entry}" != "${d}" ]] && new_path+=":${entry}"
	done
	# remove leading ':'
	eval ${P}="${new_path:1}"
}


# Local Variables:
# mode: sh
# sh-basic-offset: 8
# tab-width: 8
# End:
