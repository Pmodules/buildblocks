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


set -o errexit

trap "error_handler" ERR

error_handler() {
	local -i ec=$?

	exit ${ec}
}

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
	[[ ${PMODULES_DEBUG} ]] || return 0
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

#abspath () {
#	(cd "$1" && pwd)
#}

abspath () {
	readlink -f "$1"
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

