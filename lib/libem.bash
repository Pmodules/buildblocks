#!/bin/bash

PATH=/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin:/opt/X11/bin

shopt -s expand_aliases

source	"${PSI_PREFIX}/${PSI_CONFIG_DIR}/profile.bash"
module use unstable

declare -r	MODULECMD="${MODULESHOME}/bin/modulecmd"

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

declare -rx BUILD_BASEDIR=$(abspath $SHLIBDIR/..)

source "$(readlink ${BUILD_BASEDIR}/config/environment.bash)"

declare -xr BUILD_CONFIGDIR="${BUILD_BASEDIR}/config"
declare -xr BUILD_SCRIPTSDIR="${BUILD_BASEDIR}/scripts"
declare -xr BUILD_TMPDIR="${BUILD_BASEDIR}/tmp"
declare -xr BUILD_DOWNLOADSDIR="${BUILD_BASEDIR}/Downloads"
declare -xr BUILD_VERSIONSFILE="${BUILD_CONFIGDIR}/versions.conf"

if [[ -z "${BUILD_CONFIGDIR}/families.d/"*.conf ]]; then
	die 1 "Default family configuration not set in ${BUILD_CONFIGDIR}/families.d"
fi
for f in "${BUILD_CONFIGDIR}/families.d/"*.conf; do
	source "${f}"
done

declare -x  PREFIX=''
declare -x  DOCDIR=''
declare -x  MODULE_FAMILY=''
declare	-x  MODULE_RELEASE=''
declare     cur_module_release=''

declare     DEPEND_RELEASE=''
declare -x  MODULE_NAME=''


# these directories are module dependend
declare -x  MODULE_SRCDIR=''
declare -x  MODULE_BUILDDIR=''

declare -x  MODULE_BUILD_DEPENDENCIES
declare -x  MODULE_DEPENDENCIES

declare -x C_INCLUDE_PATH
declare -x CPLUS_INCLUDE_PATH
declare -x CPP_INCLUDE_PATH
declare -x LIBRARY_PATH
declare -x LD_LIBRARY_PATH
declare -x DYLD_LIBRARY_PATH

if [[ $DEBUG_ON ]]; then
	trap 'echo "$BASH_COMMAND"' DEBUG
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

--with=P/V
        Preload module P with version V. To preload multiple modules,
        use this option per module. Nete that order may matter.

--release=stable|unstable|deprecated

"
	exit 1
}


P=$(basename $0)
P=${P%.*}
_P=$(echo $P | tr [:lower:] [:upper:])
_P=${_P//-/_}
_V=${_P}_VERSION

DEBUG_ON=''
FORCE_REBUILD=''
ENVIRONMENT_ARGS=''
WITH_ARGS=''
DRY_RUN=''
with_modules=()
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
	--dry-run )
		DRY_RUN='dry-run'
		;;
	--release=* )
		MODULE_RELEASE=${1/--release=}
		if [[ -n ${MODULE_RELEASE} ]] && [[ ${MODULE_RELASE:0:1} != . ]]; then
			MODULE_RELEASE=".${MODULE_RELEASE}"
		fi
		;;
	--with=*/* )
		with_modules+=( ${1/--with=} )
		;;
	*=* )
		eval $1
		ENVIRONMENT_ARGS="${ENVIRONMENT_ARGS} $1"
		;;
	* )
		V=$1
		;;
	esac
	shift
done


eval "${ENVIRONMENT_ARGS}"

function is_release () {
	local -a releases=( '' )
	releases+=( $(< "${PSI_PREFIX}/${PSI_RELEASES_CONF}") )
        local rel
        for rel in "${releases[@]}"; do
		[[ "${rel}" == "$1" ]] && return 0
	done
        return 1
}


function em.set_release() {
	is_release "$1" || die 1 "$P: unknown release type: $1"
	[[ "$1" == "deprecated" ]] && die 0 "$P: is deprecated, we don't rebuild it."
	MODULE_RELEASE=".$1"
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
	if [[ ! -d ${PSI_PREFIX}/${PSI_CONFIG_DIR}/${1} ]]; then
		die 43 "${1}: family does not exist."
	fi
	MODULE_FAMILY=$1
}

function em.set_build_dependencies() {
	MODULE_BUILD_DEPENDENCIES=("$@")
}

function em.set_runtime_dependencies() {
	MODULE_DEPENDENCIES=("$@")
}

function em.set_supported_compilers() {
	MODULE_SUPPORTED_COMPILERS=("$@")
}

function em.set_docfiles() {
	MODULE_DOCFILES=("$@")
}

function is_module_available() {
	[[ -n $("${MODULECMD}" bash avail "$1" 2>&1 1>/dev/null) ]]
}

function _load_build_dependencies() {
	for m in "${with_modules[@]}"; do
		module load "${m}"
	done
	for m in "${MODULE_BUILD_DEPENDENCIES[@]}"; do
		[[ -z $m ]] && continue
		if [[ ! $m =~ "*/*" ]]; then
			local _V=$(echo -n $m | tr [:lower:] [:upper:] )_VERSION
			if [[ -n ${!_V} ]]; then
		    		m=$m/${!_V}
			else
				echo "$m: warning: No version set, loading default ..."
			fi
		fi
		if [[ -z $("${MODULECMD}" bash avail "$m" 2>&1 1>/dev/null) ]]; then
			debug "${m}: module not available"
			for rel in $(< "${PSI_PREFIX}/${PSI_RELEASES_CONF}"); do
				debug "${m}: check release \"${rel/.}\""
				eval $("${PSI_PREFIX}/${PSI_CONFIG_DIR}/init/extensions/use.bash" ${rel/.})
				if is_module_available "${m}"; then
					die 1 "${m}: module available in release \"${rel/.}\", add this release with \"module use ${rel/.}\" and re-run build script."
				fi
			done
			[[ ${DRY_RUN} ]] && die 1 "${m}: module does not exist, cannot continue with dry run..."

			echo "$m: module does not exist, trying to build it..."
			local args=( '' )
			set -- ${ARGS[@]}
			while (( $# > 0 )); do
				case $1 in
				-j )
					args+=( "-j $2" )
					shift
					;;
				--jobs=[0-9]* )
					args+=( $1 )
					;;
				-v | --verbose)
					args+=( $1 )
					;;
				--release=* )
					args+=( $1 )
					;;
				--with=*/* )
					args+=( $1 )
					;;
				*=* )
					args+=( $1 )
					;;
				esac
				shift
			done
			"${BUILD_SCRIPTSDIR}/${m/\/*}.build" ${args[@]}
			if [[ -z $(module avail "$m" 2>&1) ]]; then
				die 1 "$m: oops: build failed..."
			fi
		fi
		local modulepath_root="${PSI_PREFIX}/${PSI_MODULES_ROOT}"
		local tmp=$( module display "${m}" 2>&1 | grep -m1 -- "${modulepath_root}" )
		tmp=${tmp/${modulepath_root}\/}
		tmp=${tmp%%/*}
		local _family=( ${tmp//./ } )
		# set module release to 'deprecated' if a build dependency
		# is deprecated
		if [[ ${_family[1]} == deprecated ]]; then
			DEPEND_RELEASE='.deprecated'
		# set module release to 'unstable' if a build dependency is
		# unstable and release not yet set
		elif [[ ${_family[1]} == unstable ]] && [[ -z ${DEPEND_RELEASE} ]]; then
			DEPEND_RELEASE='.unstable'
		fi
		echo "Loading module: ${m}"
		module load "${m}"
	done
}

function _write_runtime_dependencies() {
	local -r fname="${PREFIX}/.dependencies"
	info "Writing run-time dependencies to ${fname}"
	local dep
	echo -n "" > "${fname}"
	for dep in "${MODULE_DEPENDENCIES[@]}"; do
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
	info "Writing build dependencies to ${fname}"
	local dep
	echo -n "" > "${fname}"
	for dep in "${MODULE_BUILD_DEPENDENCIES[@]}"; do
		[[ -z $dep ]] && continue
		if [[ ! $dep =~ "*/*" ]]; then
		    local _V=$(echo -n $dep | tr [:lower:] [:upper:] )_VERSION
		    dep=$dep/${!_V}
		fi
		echo "${dep}" >> "${fname}"
	done
}

# setup general environment
function _setup_env1() {
	C_INCLUDE_PATH=''
	CPLUS_INCLUDE_PATH=''
	CPP_INCLUDE_PATH=''
	LIBRARY_PATH=''
	LD_LIBRARY_PATH=''
	DYLD_LIBRARY_PATH=''

	while read _name _version; do
		[[ -z ${_name} ]] && continue
		[[ -z ${_version} ]] && continue
		[[ "${_name:0:1}" == '#' ]] && continue
		_NAME=$(echo ${_name} | tr [:lower:] [:upper:])
		eval ${_NAME}_VERSION=$_version 
	done < "${BUILD_VERSIONSFILE}"

}

#setup module specific environment
function _setup_env2() {
	if [[ -z ${MODULE_FAMILY} ]]; then
		die 1 "$P: family not set."
	fi

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
	MODULE_SRCDIR="${BUILD_TMPDIR}/src/${P/_serial}-$V"
	MODULE_BUILDDIR="${BUILD_TMPDIR}/build/$P-$V/$COMPILER/$COMPILER_VERSION"

	# build module name
	# :FIXME: the MODULE_PREFIX should be derived from MODULE_NAME
	# :FIXME: this should be read from a configuration file
	case ${MODULE_FAMILY} in
	    Tools )
		MODULE_RPREFIX="${P}/${V}"
		MODULE_NAME="${P}/${V}"
		;;
	    Programming )
		MODULE_RPREFIX="${P}/${V}"
		MODULE_NAME="${P}/${V}"
		;;
	    Libraries )
		MODULE_RPREFIX="${P}/${V}"
		MODULE_NAME="${P}/${V}"
		;;
	    System )
		MODULE_RPREFIX="${P}/${V}"
		MODULE_NAME="${P}/${V}"
		;;
	    Compiler )
		MODULE_RPREFIX="${P}/${V}/${COMPILER}/${COMPILER_VERSION}"
		MODULE_NAME="${COMPILER}/${COMPILER_VERSION}/${P}/${V}"
		;;
	    MPI )
		MODULE_RPREFIX="${P}/${V}/${MPI}/${MPI_VERSION}/${COMPILER}/${COMPILER_VERSION}"
		MODULE_NAME="${COMPILER}/${COMPILER_VERSION}/${MPI}/${MPI_VERSION}/${P}/${V}"
		;;
	    HDF5 )
		MODULE_RPREFIX="${P}/${V}/${HDF5}/${HDF5_VERSION}/${MPI}/${MPI_VERSION}/${COMPILER}/${COMPILER_VERSION}/"
		MODULE_NAME="${COMPILER}/${COMPILER_VERSION}/${MPI}/${MPI_VERSION}/${HDF5}/${HDF5_VERSION}/${P}/${V}"
		;;
	    HDF5_serial )
		MODULE_RPREFIX="${P}/${V}/hdf5_serial/${HDF5_SERIAL_VERSION}/${COMPILER}/${COMPILER_VERSION}"
		MODULE_NAME="${COMPILER}/${COMPILER_VERSION}/hdf5_serial/${HDF5_VERSION}/${P}/${V}"
		;;
	    * )
		die 1 "$P: oops: unknown family: ${MODULE_FAMILY}"
		;;
	esac

	# set PREFIX of module
	PREFIX="${PSI_PREFIX}/${MODULE_FAMILY}/${MODULE_RPREFIX}"

	# get module release if already installed
	local saved_modulepath=${MODULEPATH}
	for rel in $(< "${PSI_PREFIX}/${PSI_RELEASES_CONF}"); do
		eval $("${PSI_PREFIX}/${PSI_CONFIG_DIR}/init/extensions/unuse.bash" ${rel/.})
	done
	for rel in '.stable' $(< "${PSI_PREFIX}/${PSI_RELEASES_CONF}"); do
		if [[ "${rel}" != '.stable' ]]; then
			eval $("${PSI_PREFIX}/${PSI_CONFIG_DIR}/init/extensions/use.bash" ${rel/.})
		fi
		if is_module_available "${P}/${V}"; then
			cur_module_release=${rel}
			info "${P}/${V}: already available and is in release \"${rel/.}\""
			break
		fi
	done
	MODULEPATH=${saved_modulepath}

	# set release of module
	# release is deprecated
	#   - if a build-dependency is deprecated or 
	#   - the module already exists and is deprecated or
	#   - is forced to be deprecated by setting this on the command line
	if [[ "${depend_release}" == '.deprecated' ]] || \
		[[ "${cur_module_release}" == '.deprecated' ]] \
		|| [[ "${MODULE_RELEASE}" == '.deprecated' ]]; then
		MODULE_RELEASE='.deprecated'
		info "${P}/${V}: will be released as \"deprecated\""
	#
	# release is stable
	#   - if all build-dependency are stable or
	#   - the module already exists and is stable
	#   - an unstable release of the module exists and the release is changed to stable on the command line
	elif [[ "${depend_release}" == '.stable' ]] \
		|| [[ "${cur_module_release}" == '.stable' ]] \
		|| [[ "${MODULE_RELEASE}" == '.stable' ]]; then
		MODULE_RELEASE='.stable'
		info "${P}/${V}: will be released as \"stable\""
	#
	# release is unstable
	#   - if a build-dependency is unstable or 
	#   - if the module does not exists and no other release-type is given on the command line
	#   - and all the cases I didn't think of
	else
		MODULE_RELEASE='.unstable'
		info "${P}/${V}: will be released as \"unstable\""
	fi

	# directory for README's, license files etc
	DOCDIR="${PREFIX}/share/doc/$P"

	# set tar-ball and flags for tar
	TARBALL="${BUILD_DOWNLOADSDIR}/${P/_serial}"
	if [[ -r "${TARBALL}-${V}.tar.gz" ]]; then
		TARBALL+="-${V}.tar.gz"
	elif [[ -r "${TARBALL}-${OS}-${V}.tar.gz" ]]; then
		TARBALL+="-${OS}-${V}.tar.gz"
	elif [[ -r "${TARBALL}-${V}.tar.bz2" ]]; then
		TARBALL+="-${V}.tar.bz2"
	elif [[ -r "${TARBALL}-${OS}-${V}.tar.bz2" ]]; then
		TARBALL+="-${OS}-${V}.tar.bz2"
	else
		error "tar-ball for $P/$V not found."
		exit 43
	fi

}

function _prep() {

	# untar sources
	if [[ ! -d ${MODULE_SRCDIR} ]]; then
		mkdir -p "${BUILD_TMPDIR}/src"
		(cd "${BUILD_TMPDIR}/src" && tar xvf "${TARBALL}")
	fi

	# create build directory
	mkdir -p "${MODULE_BUILDDIR}"

}

function em.pre_configure() {
	:
}

function em.configure() {
	${MODULE_SRCDIR}/configure \
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
	info "Installing documentation to ${DOCDIR}"
	install -m 0755 -d "${DOCDIR}"
	install -m0444 "${MODULE_DOCFILES[@]/#/${MODULE_SRCDIR}/}" "${BUILDSCRIPT}" "${DOCDIR}"
}

function _set_link() {
	local _path
	if [[ "${cur_module_release}" != '' ]]; then
		_path="${PSI_PREFIX}/${PSI_MODULES_ROOT}/${MODULE_FAMILY}${cur_module_release/.stable}/${MODULE_NAME}"
		if [[ -e "${_path}" ]]; then
			info "Removing old sym-link \"${_path}\" ..."
			rm "${_path}"
		fi
	fi
	(
		_path="${PSI_PREFIX}/${PSI_MODULES_ROOT}/${MODULE_FAMILY}${MODULE_RELEASE/.stable}/${MODULE_NAME%/*}"
		info "Setting new sym-link \"${_path}/${V}\" ..."
		mkdir -p "${_path}"
		cd "${_path}"
		local x
		IFS='/' x=( ${_path/${PSI_PREFIX}\/${PSI_MODULES_ROOT}\/} )
		local n=${#x[@]}
		local -r _target="../"$(eval printf "../%.s" {1..${n}})${PSI_CONFIG_DIR##*/}/"${MODULE_FAMILY}/${P}/modulefile"
		ln -fs "${_target}" "${MODULE_NAME##*/}"
	)
}

function _cleanup_build() {
    (
	[[ -d /${MODULE_BUILDDIR} ]] || return 0
	cd "/${MODULE_BUILDDIR}/..";
	if [[ $(pwd) != / ]]; then
		echo "Cleaning up $(pwd)/${COMPILER_VERSION}"
		rm -rf *
	fi
    );
}

function em.cleanup_src() {
    (
	[[ -d /${MODULE_SRCDIR} ]] || return 0
	cd "/${MODULE_SRCDIR}/..";
	if [[ $(pwd) != / ]]; then
		echo "Cleaning up $(pwd)"
		rm -rf ${MODULE_SRCDIR##*/}
	fi
    );
	return 0
}

function _check_compiler() {
	test -z ${MODULE_SUPPORTED_COMPILERS} && return 0
	for cc in ${MODULE_SUPPORTED_COMPILERS[@]}; do
		if [[ ${COMPILER}/${COMPILER_VERSION} =~ ${cc} ]]; then
			return 0
		fi
	done
	die 0 "Package cannot be build with ${COMPILER}/${COMPILER_VERSION}."
}

# unfortunatelly we need sometime an OS depended post-install
function _post_install_linux() {
	cd "${PREFIX}"
	# solve multilib problem with LIBRARY_PATH on 64bit Linux
	[[ -d "lib" ]] && [[ ! -d "lib64" ]] && ln -s lib lib64
	return 0
}

function _post_install() {
	info "Run post-installation for ${OS} ..."
	[[ "${OS}" == "Linux" ]] && _post_install_linux
	info "Post-installation done ..."
	return 0
}

function em.make_all() {
	echo "${P}:"
	_setup_env1
	_load_build_dependencies
	# setup module specific environment
	_setup_env2

	if [[ ! -d "${PREFIX}" ]] || [[ ${FORCE_REBUILD} ]]; then
 		echo "Building $P/$V ..."
		[[ "${DRY_RUN}" ]] && die 0 ""
		_check_compiler
		_prep
		cd "${MODULE_SRCDIR}"
		em.pre_configure
		cd "${MODULE_BUILDDIR}"
		em.configure
		em.build
		em.install
		em.post_install
		em.install_doc
		_post_install
		_write_runtime_dependencies
		_write_build_dependencies
		
	else
 		echo "Not rebuilding $P/$V ..."
	fi
	_set_link
	_cleanup_build
}


# Local Variables:
# mode: sh
# sh-basic-offset: 8
# tab-width: 8
# End:
