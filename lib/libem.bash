#!/bin/bash

PATH=/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin:/opt/X11/bin

declare -r	BUILDSCRIPT=$( cd $(dirname "$0") && pwd )/$(basename "$0")
declare -rx	ARGS="$@"
declare -rx	SHLIBDIR=$( cd $(dirname "$BASH_SOURCE") && pwd )
declare -r	OS=$(uname -s)

# number of parallel make jobs
declare -i	JOBS=3

source "${SHLIBDIR}/lib.bash"

# while bootstraping the module command is not yet available
if typeset -f module > /dev/null 2>&1 ; then
	module purge
fi


function usage() {
	error "
Usage: $0 [OPTIONS..] [VERSION] [ENV=VALUE...]

VERSION
        Version of module to compile.

ENV=VALUE
        Set environment variable ENV to VALUE. This can be used to
        overwrite default versions.

-? | -h | --help
        Print usage

-v | --verbose )
        Verbose output

-j N | --jobs=N
        Run N parallel make jobs

-f | --force-rebuild
        Force rebuild of module.

--with-compiler=P/V
        Use compiler P with version V

--with-mpi=P/V
        Use MPI implementation P with version V

--with-hdf5=V
        Use parallel HDF5 version V

--with-hdf5_serial=V
        Use serial HDF5 version V
"
	exit 1
}


P=$(basename $0)
P=${P%.*}
_P=$(echo $P | tr [:lower:] [:upper:])
_V=${_P}_VERSION

DEBUG_ON=''
FORCE_REBUILD=''
ENVIRONMENT_ARGS=''
WITH_ARGS=''
while (( $# > 0 )); do
	case $1 in
	-j )
		JOBS=$2
		shift
		;;
	--jobs=[0-9]* )
		JOBS=${1/--jobs=}
		;;
	-v | --verbose)
		DEBUG_ON=':'
		;;
	-f | --force-rebuild )
		FORCE_REBUILD=':'
		;;
	-? | -h | --help )
		usage
		;;
	--with-hdf5=*)
		v=${1/--with-hdf5=}
		ENVIRONMENT_ARGS="${ENVIRONMENT_ARGS} HDF5=hdf5 HDF5_VERSION=$v"
		;;
	--with-hdf5_serial=*)
		v=${1/--with-hdf5_serial=}
		ENVIRONMENT_ARGS="${ENVIRONMENT_ARGS} HDF5_SERIAL=hdf5_serial HDF5_SERIAL_VERSION=$v"
		;;
	--with-*=* )
		# --with-mpi=openmpi/1.6.5 ->
		# MPI=openmpi MPI_VERSION=1.6.5 OPENMPI_VERSION=1.6.5
		arg=${1/--with-}
		f=$(echo ${arg/=*} | tr [:lower:] [:upper:])
		m=${arg/*=}
		if [[ -z $m ]]; then
			error "$1: module missing."
			usage
		fi
		p=${m/\/*}
		_p=$(echo ${p} | tr [:lower:] [:upper:])
		v=${m/*\/}
		if [[ -z $v ]] || [[ $p == $v ]]; then
			error "$1: version missing in module specification."
			usage
		fi
		ENVIRONMENT_ARGS="${ENVIRONMENT_ARGS} ${f}=${p} ${f}_VERSION=$v ${_p}_VERSION=${v}"
		;;
	* )
		if [[ $1 =~ = ]]; then
			eval $1
			ENVIRONMENT_ARGS="${ENVIRONMENT_ARGS} $1"
		else
			V=$1
		fi
		;;
	esac
	shift
done

declare -rx EM_BASEDIR=$(abspath $SHLIBDIR/..)

source "${EM_BASEDIR}/config/environment.bash"

declare -xr EM_CONFIGDIR="${EM_BASEDIR}/config"
declare -xr EM_SCRIPTDIR="${EM_BASEDIR}/scripts"
declare -xr EM_TMPDIR="${EM_BASEDIR}/tmp"
declare -rx EM_DOWNLOADDIR="${EM_BASEDIR}/Downloads"
declare -xr EM_DEFAULT_VERSIONSFILE="${EM_CONFIGDIR}/versions.conf"

if [[ -z "${EM_CONFIGDIR}/families.d/"*.conf ]]; then
	die 1 "Default family configuration not set in ${EM_CONFIGDIR}/families.d"
fi
for f in "${EM_CONFIGDIR}/families.d/"*.conf; do
	source "${f}"
done

eval "${ENVIRONMENT_ARGS}"



declare -x  PREFIX=''
declare -x  DOCDIR=''
declare -x  EM_FAMILY=''
declare	-x  EM_RELEASE='stable'
declare -x  EM_MODULENAME=''


# these directories are module dependend
declare -x  EM_SRCDIR=''
declare -x  EM_BUILDDIR=''

declare -x  EM_BUILD_DEPENDENCIES

declare -x C_INCLUDE_PATH
declare -x CPLUS_INCLUDE_PATH
declare -x CPP_INCLUDE_PATH
declare -x LIBRARY_PATH
declare -x LD_LIBRARY_PATH
declare -x DYLD_LIBRARY_PATH

if [[ $DEBUG_ON ]]; then
	trap 'echo "$BASH_COMMAND"' DEBUG
fi

#
# allowwd arguments are
#	'unstable'
#	'stable'
#	'obsolete'
function em.release() {
	case $1 in
	unstable | stable | obsolete )
		EM_RELEASE="$1"
		;;
	* )
		die 1 "$P: unknown release type: $1"
		;;
	esac
}

function em.supported_os() {
	for os in "$@"; do
		[[ ${os} == ${OS} ]] && return 0
	done
	die 0 "${P}: Not available for ${OS}."
}

function em.add_to_family() {
	if [[ -z ${1} ]]; then
		die 42 "${FUNCNAME}: Missing family argument."
	fi
	if [[ ! -d ${EM_ETCDIR}/${1} ]]; then
		die 43 "${1}: family does not exist."
	fi
	EM_FAMILY=$1
}

function em.set_build_dependencies() {
	EM_BUILD_DEPENDENCIES=("$@")
}

function em.set_runtime_dependencies() {
	EM_DEPENDENCIES=("$@")
}

function em.set_supported_compilers() {
	EM_SUPPORTED_COMPILERS=("$@")
}

function em.set_docfiles() {
	EM_DOCFILES=("$@")
}

function _load_build_dependencies() {
	for m in "${EM_BUILD_DEPENDENCIES[@]}"; do
		[[ -z $m ]] && continue
		if [[ ! $m =~ "*/*" ]]; then
			local _V=$(echo -n $m | tr [:lower:] [:upper:] )_VERSION
			if [[ -n ${!_V} ]]; then
		    		m=$m/${!_V}
			else
				echo "$m: warning: No version set, loading default ..."
			fi
		fi
		if [[ -z $(module avail "$m" 2>&1) ]]; then
			echo "$m: info: module does not exist, trying to build it..."
			"${EM_SCRIPTDIR}/${m/\/*}.build" ${ARGS[@]}
			if [[ -z $(module avail "$m" 2>&1) ]]; then
				die 1 "$m: oops: build failed..."
			fi
		fi
		echo "Loading module: $m"
		module load "$m"
	done
}



function _write_runtime_dependencies() {
	local -r fname="${PREFIX}/.dependencies"
	local dep
	echo -n "" > "${fname}"
	for dep in "${EM_DEPENDENCIES[@]}"; do
		[[ -z $dep ]] && continue
		if [[ ! $dep =~ "*/*" ]]; then
		    local _V=$(echo -n $dep | tr [:lower:] [:upper:] )_VERSION
		    dep=$dep/${!_V}
		fi
		echo "${dep}" >> "${fname}"
	done
}

function _write_build_dependencies() {
	local -r fname="${PREFIX}/.build_dependencies"
	local dep
	echo -n "" > "${fname}"
	for dep in "${EM_BUILD_DEPENDENCIES[@]}"; do
		[[ -z $dep ]] && continue
		if [[ ! $dep =~ "*/*" ]]; then
		    local _V=$(echo -n $dep | tr [:lower:] [:upper:] )_VERSION
		    dep=$dep/${!_V}
		fi
		echo "${dep}" >> "${fname}"
	done
}

function _setup_env() {
	C_INCLUDE_PATH=''
	CPLUS_INCLUDE_PATH=''
	CPP_INCLUDE_PATH=''
	LIBRARY_PATH=''
	LD_LIBRARY_PATH=''
	DYLD_LIBRARY_PATH=''

	if [[ -z ${EM_FAMILY} ]]; then
		die 1 "$P: family not set."
	fi

	while read _name _version; do
		[[ -z ${_name} ]] && continue
		[[ -z ${_version} ]] && continue
		[[ "${_name:0:1}" == '#' ]] && continue
		_NAME=$(echo ${_name} | tr [:lower:] [:upper:])
		eval ${_NAME}_VERSION=$_version 
	done < "${EM_DEFAULT_VERSIONSFILE}"

	# overwrite environment variables with values we got on the cmd line
	eval "${ENVIRONMENT_ARGS}"

	# this allows us to specify the version as PKGNAME_VERSION=1.2.3 on the cmd-line
        if [[ -z $V ]]; then
		V=$(eval echo \$${_P}_VERSION)
	fi

	# oops, we need a version
	if [[ -z $V ]]; then
		die 1 "$P: Missing version."
	fi
	EM_SRCDIR="${EM_TMPDIR}/src/${P/_serial}-$V"
	EM_BUILDDIR="${EM_TMPDIR}/build/$P-$V/$COMPILER/$COMPILER_VERSION"

	# build module name
	case ${EM_FAMILY} in
	    Tools )
		EM_PREFIX="${P}/${V}"
		EM_MODULENAME="${P}/${V}"
		;;
	    Programming )
		EM_PREFIX="${P}/${V}"
		EM_MODULENAME="${P}/${V}"
		;;
	    Libraries )
		EM_PREFIX="${P}/${V}"
		EM_MODULENAME="${P}/${V}"
		;;
	    System )
		EM_PREFIX="${P}/${V}"
		EM_MODULENAME="${P}/${V}"
		;;
	    Compiler )
		EM_PREFIX="${P}/${V}/${COMPILER}/${COMPILER_VERSION}"
		EM_MODULENAME="${COMPILER}/${COMPILER_VERSION}/${P}/${V}"
		;;
	    MPI )
		EM_PREFIX="${P}/${V}/${MPI}/${MPI_VERSION}/${COMPILER}/${COMPILER_VERSION}"
		EM_MODULENAME="${COMPILER}/${COMPILER_VERSION}/${MPI}/${MPI_VERSION}/${P}/${V}"
		;;
	    HDF5 )
		EM_PREFIX="${P}/${V}/${HDF5}/${HDF5_VERSION}/${MPI}/${MPI_VERSION}/${COMPILER}/${COMPILER_VERSION}/"
		EM_MODULENAME="${COMPILER}/${COMPILER_VERSION}/${MPI}/${MPI_VERSION}/${HDF5}/${HDF5_VERSION}/${P}/${V}"
		;;
	    HDF5_serial )
		EM_PREFIX="${P}/${V}/hdf5_serial/${HDF5_SERIAL_VERSION}/${COMPILER}/${COMPILER_VERSION}"
		EM_MODULENAME="${COMPILER}/${COMPILER_VERSION}/hdf5_serial/${HDF5_VERSION}/${P}/${V}"
		;;
	    * )
		die 1 "$P: oops: unknown family: ${EM_FAMILY}"
		;;
	esac

	case ${EM_RELEASE} in
	unstable | obsolete )
		EM_FAMILY="${EM_FAMILY}.${EM_RELEASE}"
		;;
	stable )
		;;
	* )
		die "$P: oops: unknown release type..."
		;;
	esac

	# set PREFIX of module
	PREFIX="${EM_BINDIR}/${EM_FAMILY}/${EM_PREFIX}"

	DOCDIR="${PREFIX}/share/doc/$P"

	TARBALL="${EM_DOWNLOADDIR}/${P/_serial}-$V.tar"
	if [[ -r $TARBALL.gz ]]; then
		TARBALL=${TARBALL}.gz
		_UNTAR_FLAGS='xvzf'
	elif [[ -r ${TARBALL}.bz2 ]]; then
		TARBALL=${TARBALL}.bz2
		_UNTAR_FLAGS='xvjf'
	else
		error "tar-ball for $P/$V not found."
		exit 43
	fi
}

function _prep() {

	# untar sources
	if [[ ! -d ${EM_SRCDIR} ]]; then
		mkdir -p "${EM_TMPDIR}/src"
		(cd "${EM_TMPDIR}/src" && tar ${_UNTAR_FLAGS} "${TARBALL}")
	fi

	# create build directory
	mkdir -p "${EM_BUILDDIR}"

}

function em.pre_configure() {
	:
}

function em.configure() {
	${EM_SRCDIR}/configure \
		--prefix="${PREFIX}"
}

function em.build() {
	make -j${JOBS}
}

function em.install() {
	make install
}

function em.post_install() {
	:
}

function em.install_doc() {
	install -m0444 ${EM_DOCFILES[*]} "${BUILDSCRIPT}" "${DOCDIR}"
}

function _set_link() {
	(mkdir -p "${MODULEPATH_ROOT}"
	cd "${MODULEPATH_ROOT}"
	local _path="${EM_FAMILY}/${EM_MODULENAME%/*}"
	mkdir -p "${_path}"
	cd "${_path}"

	local x
	IFS='/' x=(${_path})
	local -r _target="../"$(eval printf "../%.s" {1..${#x[@]}})${EM_ETCDIR##*/}/"${EM_FAMILY}/${P}/modulefile"
	ln -fs "${_target}" "${EM_MODULENAME##*/}"
	)
}

function _cleanup_build() {
    (
	[[ -d /${EM_BUILDDIR} ]] || return 0
	cd "/${EM_BUILDDIR}/..";
	if [[ $(pwd) != / ]]; then
		echo "Cleaning up $(pwd)/${COMPILER_VERSION}"
		rm -rf *
	fi
    );
}

function em.cleanup_src() {
    (
	[[ -d /${EM_SRCDIR} ]] || return 0
	cd "/${EM_SRCDIR}/..";
	if [[ $(pwd) != / ]]; then
		echo "Cleaning up $(pwd)"
		rm -rf ${EM_SRCDIR##*/}
	fi
    );
}

function _check_compiler() {
	test -z ${EM_SUPPORTED_COMPILERS} && return 0
	for cc in ${EM_SUPPORTED_COMPILERS[@]}; do
		if [[ ${COMPILER}/${COMPILER_VERSION} =~ ${cc} ]]; then
			return 0
		fi
	done
	die 0 "Package cannot be build with ${COMPILER}/${COMPILER_VERSION}."
}

function em.make_all() {
	_setup_env
	if [[ ! -d "${PREFIX}" ]] || [[ ${FORCE_REBUILD} ]]; then
 		echo "Building $P/$V ..."
		_load_build_dependencies
		_check_compiler
		_prep
		cd "${EM_SRCDIR}"
		em.pre_configure
		cd "${EM_BUILDDIR}"
		em.configure
		em.build
		em.install
		em.post_install
		cd "${EM_SRCDIR}"
		mkdir -p "${DOCDIR}"
		em.install_doc
	else
 		echo "Not rebuilding $P/$V ..."
	fi
	_write_runtime_dependencies
	_write_build_dependencies
	_set_link
	_cleanup_build
}

