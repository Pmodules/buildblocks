#!/usr/bin/env bash


function usage() {
    PROG=$(basename $0)
    echo "Usage: $PROG --dir=<directory> [--user=<user>]"
    echo "      Initializes a local module environment in <directory>"
    echo "      for user <user>. <directory> must not exist yet."
    echo "      The <user> parameter must only be present if"
    echo "      $PROG is executed as root."
}

declare force='no'

while (($# > 0)); do
    if [[ "${1#--dir}" != "$1" ]]; then
        option="${1#--dir}"
        option="${option#=}"
        [[ -z "$option" ]] && { shift; option="$1"; }
        ENV_DIR="$option"
    elif [[ "${1#--user}" != "$1" ]]; then
        option="${1#--user}"
        option="${option#=}"
        [[ -z "$option" ]] && { shift; option="$1"; }
        ENV_USER="$option"
    else
        echo "Error: Unknown option: $1"
        usage
        exit 1
    fi
    shift
done

[[ -z "$ENV_DIR" ]] && {
    echo "Error: --dir parameter is required!"
    usage
    exit 1
}

if (( EUID == 0 )); then
    [[ -z "$ENV_USER" ]] && {
        echo "Error: --user parameter is required!"
        usage
        exit 1
    }
    USER_ID=$(id -u "$ENV_USER")
    (( $? == 0 )) || {
        echo "Error: Unable to retrieve user id of user '$ENV_USER'"
        exit 1
    }
else
    [[ -z "$ENV_USER" ]] || {
        echo "Error: --user option is only allowed if running as root!"
        usage
        exit 1
    }
    USER_ID=$EUID
fi

if [[ -d "$ENV_DIR" ]]  && [[ ${force} == no ]]; then
    echo "Warning: $ENV_DIR already exists."
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

echo "Attempting to create a local module environment from a partial copy of the environment at '$PSI_PREFIX'"

[[ -d "$PSI_PREFIX" ]] &&
[[ -d "$PSI_PREFIX/$PSI_CONFIG_DIR" ]] &&
[[ -d "$PSI_PREFIX/$PSI_MODULES_ROOT" ]] &&
[[ -d "$MODULESHOME" ]] || {
    echo "Error: the module environment '$PSI_PREFIX' has not been initialized properly!"
    echo "Maybe it is not a module environment, not accessible, or the init script at"
    echo "'$PSI_PREFIX/config/profile.bash' has not been sourced."
    exit 1
}

echo "Creating directory $ENV_DIR..."
mkdir -p "$ENV_DIR" || {
    echo "Error: cannot create directory $ENV_DIR!"
    exit 1
}
pushd "$ENV_DIR" || {
    echo "Error: Cannot change to directory $ENV_DIR"
    rmdir "$ENV_DIR"
    exit
}
ENV_DIR=$(pwd -P)
popd
trap "rm -rf $ENV_DIR" EXIT

(( EUID == 0 )) && {
    echo "Changing owner of directory $ENV_DIR to $ENV_USER..."
    chown $USER_ID "$ENV_DIR"
    su $ENV_USER || {
        echo "Error: cannot change user to $ENV_USER!"
        exit 1
    }
}

(( EUID == USER_ID )) || {
    echo "Error: attempt to run as user with id $USER_ID failed!"
    exit 1
}

cd "$ENV_DIR" || {
    echo "Error: failed to change working directory to $ENV_DIR!"
    exit 1
}

echo "Copy configuration..."
rsync --recursive --links --perms --delete ${PSI_PREFIX}/${PSI_CONFIG_DIR}/ ${PSI_CONFIG_DIR}/ || {
    echo "Error: copy operation failed!"
    exit 1
}

echo "Copy module software..."
LOCAL_MODHOME=${MODULESHOME#$PSI_PREFIX/}
mkdir -p ${LOCAL_MODHOME} || {
    echo "Error: creating directory for modules software failed!"
    exit 1
}
rsync --recursive --links --perms --delete ${MODULESHOME}/ ${LOCAL_MODHOME}/ || {
    echo "Error: copying modules software failed!"
    exit 1
}

echo "Create directory $PSI_MODULES_ROOT..."
mkdir -p $PSI_MODULES_ROOT || {
    echo "Error: cannot create directory $PSI_MODULES_ROOT!"
    exit 1
}

# echo "Using sudo to set the link $PSI_PREFIX to $ENV_DIR..."
# sudo bash -c "rm -f $PSI_PREFIX && ln -s $ENV_DIR $PSI_PREFIX" || {
#     echo "WARNING: The link $PSI_PREFIX could not be set to $ENV_DIR!"
#     echo "Please set this link manually as root:"
#     echo "   ln -s $ENV_DIR $PSI_PREFIX"
# }

echo "Local module environment created at $ENV_DIR."
echo "To use this environment, execute"
echo "   ln -s $ENV_DIR /opt/psi as root (delete the /opt/psi link if it already exists)"
echo "   source $ENV_DIR/$PSI_CONFIG_DIR/profile.bash"

trap - EXIT
