#!/usr/bin/env bash


function usage() {
        local -r prog=$(basename $0)
        echo "Usage: $prog [--user=<user>] [--force] [--dry-run] <target-directory>"
        echo "      Initializes a local module environment in <target-directory>"
        echo "      for user <user>. <directory> must not exist yet."
        echo "      The <user> parameter must only be present if"
        echo "      $prog is executed as root."
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

declare force='no'
declare dry_run='no'
declare DRY=''
declare target_dirs=()

while (($# > 0)); do
    if [[ "${1#--dir}" != "$1" ]]; then
        option="${1#--dir}"
        option="${option#=}"
        [[ -z "$option" ]] && { shift; option="$1"; }
        {target_dir}="$option"
    elif [[ "${1#--user}" != "$1" ]]; then
        option="${1#--user}"
        option="${option#=}"
        [[ -z "$option" ]] && { shift; option="$1"; }
        ENV_USER="$option"
    elif [[ "$1" == "--force" ]]; then
        force='yes'
    elif [[ "$1" == "--dry-run" ]]; then
        dry_run='yes'
	DRY='echo'
    elif [[ "$1" =~ "^-" ]]; then
        echo "Error: Unknown option: $1"
        usage
        exit 1
    else
        target_dirs+=( "$1" )
    fi
    shift
done

if [[ ${#target_dirs[@]} == 0 ]]; then
    echo "Error: no target directory specified!"
    usage
    exit 1
fi

if (( EUID == 0 )); then
    if [[ -z "$ENV_USER" ]]; then
        echo "Error: --user parameter is required!"
        usage
        exit 1
    fi
    USER_ID=$(id -u "$ENV_USER")
    if (( $? != 0 )); then
        echo "Error: Unable to retrieve user id of user '$ENV_USER'"
        exit 1
    fi
else
    if [[ -n "$ENV_USER" ]]; then
        echo "Error: --user option is only allowed if running as root!"
        usage
        exit 1
    fi
    USER_ID=$EUID
fi

[[ -n "${PSI_PREFIX}" ]] &&
[[ -n "${PSI_CONFIG_DIR}" ]] &&
[[ -n "${PSI_MODULES_ROOT}" ]] &&
[[ -n "${PSI_TEMPLATES_DIR}" ]] &&
[[ -n "${PMODULES_HOME}" ]] &&
[[ -n "${PMODULES_VERSION}" ]] || {
	die 1 "
Error: the module environment you are going to use as source has not been
initialized properly!"
}


[[ -d "${PSI_PREFIX}" ]] &&
[[ -d "${PSI_PREFIX}/${PSI_CONFIG_DIR}" ]] &&
[[ -d "${PSI_PREFIX}/${PSI_MODULES_ROOT}" ]] &&
[[ -d "${PSI_PREFIX}/${PSI_TEMPLATES_DIR}" ]] &&
[[ -d "${PMODULES_HOME}" ]] || {
    die 1 "
Error: the module environment '$PSI_PREFIX' has not been initialized properly!"
}

echo "
Attempting to create a minimal module environment from the
environment at '${PSI_PREFIX}'
"

function init_pmodules_environment() {
        local -r target_dir=$1
	local src=''
	local dst=''
	echo "Initializing target directory '${target_dir}' ..."
	if [[ -d "${target_dir}" ]]  && [[ ${force} == no ]]; then
	    echo "Warning: ${target_dir} already exists."
	    read -p "Do you really want to re-run the initialization? (y/N) " ans
	    case ${ans} in
		y|Y )
		    :
		    ;;
		* )
		    exit 1
		    ;;
	    esac
	fi

	dst="${target_dir}"
	echo "Creating target directory '${src}'..."
	$DRY mkdir -p "${dst}" || die 1 "Error: make directory failed!"
	echo

	src="${PSI_PREFIX}/${PSI_CONFIG_DIR}/"
	dst="${target_dir}/${PSI_CONFIG_DIR}/"
	echo "Synching configuration from '${src}' to '${dst}'..."
	$DRY rsync --recursive --links --perms --delete \
	     "${src}" "${dst}" || die 1 "Error: synch operation failed!"
	echo
	
	src="${PSI_PREFIX}/${PSI_TEMPLATES_DIR}/"
	dst="${target_dir}/${PSI_TEMPLATES_DIR}/"
	echo "Synching template files from '${src}' to '${dst}'..."
	$DRY rsync --recursive --links --perms --delete \
	     "${src}" "${dst}" || die 1 "Error: synch operation failed!"
	echo
	
	src="${PMODULES_HOME}/"
	dst="${target_dir}/${PMODULES_HOME#$PSI_PREFIX/}/"
	echo "Synching Pmodules software from '${src}' to '${dst}'..."
	$DRY mkdir -p "${dst}" || die 1 "Error: creating target directory failed!"
	$DRY rsync --recursive --links --perms --delete \
	     "${src}" "${dst}" || die 1 "Error: synch operation failed!"
	echo
	
	src="${PSI_PREFIX}/${PSI_MODULES_ROOT}/Tools/Pmodules"
	dst="${target_dir}/${PSI_MODULES_ROOT}/Tools/Pmodules"
	echo "Setting up modulefile for Pmodules in '${dst}'..."
	$DRY mkdir -p "${dst}" || die 1 "Error: make directory failed!"
	$DRY ln -fs "../../../${PSI_TEMPLATES_DIR}/Tools/Pmodules/modulefile" \
	     "${dst}/${PMODULES_VERSION}" || die 1 "Error: setting sym-link failed!"
	$DRY cp "${src}/.release-${PMODULES_VERSION}" "${dst}" || die 1 "Error: setting release failed!"
	echo
	if [[ -n "${ENV_USER}" ]]; then
	        echo "Changing user of new module environment to '${ENV_USER}'..."
		$DRY chown -R "${ENV_USER}" "${target_dir}" || die 1 "Error: changing owner failed!"
		echo
	fi
	echo "New minimal module environment created at '${target_dir}'."
	echo "To use this environment, execute"
	echo "   ln -s ${target_dir} /opt/psi as root (delete the /opt/psi link if it already exists)"
	echo "   source ${target_dir}/$PSI_CONFIG_DIR/profile.bash"
}

umask 022
for target_dir in "${target_dirs[@]}"; do
	init_pmodules_environment "${target_dir}"
done
