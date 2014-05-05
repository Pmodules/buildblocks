#!/bin/bash

declare -rx ARGS="$@"

declare -rx SHLIBDIR=$( cd $(dirname "$BASH_SOURCE") && pwd )

declare -r OS=$(uname -s)

PATH=/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin:/opt/X11/bin

source "${SHLIBDIR}/lib.bash"

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

# the module name might already be set in the build script(!)
if [[ -z $P ]]; then
	P=$(basename $0)
	P=${P%.*}
fi

# unset the version of the module
_P=$(echo $P | tr [:lower:] [:upper:])
_V=${_P}_VERSION
unset ${_V}

declare -i  JOBS=3

#while read _name _version; do
#	[[ -z ${_name} ]] && continue
#	[[ -z ${_version} ]] && continue
#	[[ "${_name:0:1}" == '#' ]] && continue
#	_NAME=$(echo ${_name} | tr [:lower:] [:upper:])
#	eval ${_NAME}_VERSION=$_version 
#done < "${VERSIONS}"

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
	--with-hdf5=*)
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

declare -x  PREFIX=''
declare -x  DOCDIR=''
declare -x  EM_FAMILY=''
declare -x  EM_MODULENAME=''

declare -x  CONFIG_DIR="${EM_BASEDIR}/config"
declare -x  SCRIPTDIR="${EM_BASEDIR}/scripts"
declare -x  EM_TMPDIR="${EM_BASEDIR}/tmp"

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

module purge

#unset _P _V

function preexec() {
	echo "$BASH_COMMAND"
}

if [[ $DEBUG_ON ]]; then
	#trap 'eval echo \\"$BASH_COMMAND\\"' DEBUG
	trap 'echo "$BASH_COMMAND"' DEBUG
        #trap 'preexec' DEBUG
	#set -o functrace
fi

function em.set_build_dependencies() {
	EM_BUILD_DEPENDENCIES=("$@")
}

function _load_build_dependencies() {
	for m in "${EM_BUILD_DEPENDENCIES[@]}"; do
		[[ -z $m ]] && continue
		if [[ ! $m =~ "*/*" ]]; then
		    local _V=$(echo -n $m | tr [:lower:] [:upper:] )_VERSION
		    m=$m/${!_V}
		fi
		if module load "$m" 2>&1 | grep -q "Unable to locate"; then
			echo "Module \"$m\" not available, trying to build it..."
			"${SCRIPTDIR}/${m/\/*}.build" ${ARGS[@]}
			if [[ -z $(module avail "$m" 2>&1) ]]; then
				echo "Oops: Building module \"$m\" failed..."
				exit 1
			fi
		fi
		echo "Loading module: $m"
		module load "$m"
	done
}


function em.add_to_family() {
	if [[ -z ${1} ]]; then
		die 42 "${FUNCNAME}: Missing family argument."
	fi
	if [[ ! -d ${EM_ETCDIR}/${1} ]]; then
		dir 43 "${1}: family does not exist."
	fi
	EM_FAMILY=$1
	source "${CONFIG_DIR}/versions.conf"
	for f in "${CONFIG_DIR}/families.d/"*.conf; do
		source "${f}"
	done
	eval ${ENVIRONMENT_ARGS}
}

function em.set_runtime_dependencies() {
	EM_DEPENDENCIES=("$@")
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

function _set_env() {
	C_INCLUDE_PATH=''
	CPLUS_INCLUDE_PATH=''
	CPP_INCLUDE_PATH=''
	LIBRARY_PATH=''
	LD_LIBRARY_PATH=''
	DYLD_LIBRARY_PATH=''

	if [[ -z ${EM_FAMILY} ]]; then
		die 1 "$P: family not set."
	fi

	# overwrite environment variables with values we got on the cmd line
	eval ${ENVIRONMENT_ARGS}

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

	declare -rx DOWNLOADDIR="${EM_BASEDIR}/Downloads"

	# build module name
	case ${EM_FAMILY} in
	    Tools )
		EM_MODULENAME="${P}/${V}"
		;;
	    Programming )
		EM_MODULENAME="${P}/${V}"
		;;
	    Libraries )
		EM_MODULENAME="${P}/${V}"
		;;
	    Compiler )
		EM_MODULENAME="${COMPILER}/${COMPILER_VERSION}/${P}/${V}"
		;;
	    MPI )
		EM_MODULENAME="${COMPILER}/${COMPILER_VERSION}/${MPI}/${MPI_VERSION}/${P}/${V}"
		;;
	    HDF5 )
		EM_MODULENAME="${COMPILER}/${COMPILER_VERSION}/${MPI}/${MPI_VERSION}/${HDF5}/${HDF5_VERSION}/${P}/${V}"
		;;
	    HDF5_serial )
		EM_MODULENAME="${COMPILER}/${COMPILER_VERSION}/hdf5_serial/${HDF5_SERIAL_VERSION}/${P}/${V}"
		;;
	esac

	# set PREFIX of module
	PREFIX="${EM_BINDIR}/${EM_FAMILY}/${EM_MODULENAME}"

	DOCDIR="${PREFIX}/share/doc/$P"

	TARBALL="${DOWNLOADDIR}/${P/_serial}-$V.tar"
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

function em.set_env() {
	:
}

function em.prep() {

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
	:
}

function _set_link() {
	(mkdir -p "${MODULEPATH_ROOT}"
	cd "${MODULEPATH_ROOT}"
	local _path="${EM_FAMILY}/${EM_MODULENAME%/*}"
	mkdir -p "${_path}"
	cd "${_path}"

	local x
	IFS='/' x=(${_path})
	local -r _target="../"$(eval printf "../%.s" {1..${#x[@]}})${EM_ETCDIR##*/}/"${EM_FAMILY}/${P}"
	ln -fs "${_target}" "${EM_MODULENAME##*/}"
	)
}

function _cleanup_build() {
    (
	[[ -d /${EM_BUILDDIR} ]] || return 0
	cd "/${EM_BUILDDIR}";
	if [[ $(pwd) != / ]]; then
		echo "Cleaning up $(pwd)"
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


function em.make_all() {
	_set_env
	if [[ ! -d "${PREFIX}" ]] || [[ ${FORCE_REBUILD} ]]; then
		_load_build_dependencies
		em.prep
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

