#!/bin/bash

#
# We need GNU versions of the following utilities. This code works
# well on Linux and Mac OS X with MacPorts.
# :FIXME: implement a smarter, portable solution.
#
shopt -s expand_aliases
unalias -a

__path=$(which gdate 2>/dev/null)
if [[ $__path ]]; then
	alias date=$__path
else
	alias date=$(which date 2>/dev/null)
fi

__path=$(which ginstall 2>/dev/null)
if [[ $__path ]]; then
	alias install=$__path
else
	alias install=$(which install 2>/dev/null)
fi

__path=$(which greadlink 2>/dev/null)
if [[ $__path ]]; then
	alias readlink=$__path
else
	alias readlink=$(which readlink 2>/dev/null)
fi

__path=$(which gsed 2>/dev/null)
if [[ $__path ]]; then
	alias sed=$__path
else
	alias sed=$(which sed 2>/dev/null)
fi

#
# set an error handler. If a function _exit() exists, it will be called
# with the passed exit code.
#
# $1	exit code
#
set -o errexit

trap "std::error_handler" ERR

std::error_handler() {
	local -i ec=$?

	typeset -F _exit 1>/dev/null 2>&1 && _exit "${ec}"
	exit ${ec}
}

#
# logging/message functions
#
std::log() {
	local -ri fd=$1
	local -r fmt="$2\n"
	shift 2
	printf -- "$fmt" "$@" >> /dev/fd/$fd
}

std::info() {
	std::log 2 "$1\n" "${@:2}"
}

std::error() {
	std::log 2 "$1\n" "${@:2}"
}

std::debug() {
	[[ ${PMODULES_DEBUG} ]] || return 0
	std::log 2 "$@"
}

std::die() {
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
		std::log $cout "$fmt" "$@"
	fi
	exit $ec
}

std::abspath () {
	readlink -f "$1"
}

std::append_path () {
	local -r P=$1
	local -r d=$2

        if ! egrep -q "(^|:)${d}($|:)" <<<${!P} ; then
		if [[ -z ${!P} ]]; then
			eval $P=${d}
		else
			eval $P=${!P}:${d}
        	fi
	fi
}

std::prepend_path () {
	local -r P=$1
	local -r d=$2

	if ! egrep -q "(^|:)${d}($|:)" <<<${!P} ; then
		if [[ -z ${!P} ]]; then
			eval $P=${d}
		else
			eval $P="${d}:${!P}"
        	fi
	fi
}

read_versions() {
	local -r fname="$1"
	local varname=''
	while read _name _version; do
		[[ -z ${_name} ]] && continue
		[[ -z ${_version} ]] && continue
		[[ "${_name:0:1}" == '#' ]] && continue
		var_name=$(echo ${_name} | tr [:lower:] [:upper:])_VERSION
		# don't set version, if already set
		if [[ -z ${!var_name} ]]; then
			eval ${var_name}="${_version}"
		fi
	done < "${fname}"
}

