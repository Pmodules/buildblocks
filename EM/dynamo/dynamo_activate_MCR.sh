# Activates MCR from pmodules

DYNAMO_FOLDER=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
MCR_ROOT=${MATLAB_DIR:?No matlab module loaded}


# Checks  availability of the MCR folder
if ! [ -d $MCR_ROOT ]; then
  echo "ATTENTION:  the Matlab module is not loaded."
  return
fi

echo "MCR for linux has been found in location:" $MCR_ROOT
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$MCR_ROOT/runtime/glnxa64:$MCR_ROOT/bin/glnxa64:$MCR_ROOT/sys/os/glnxa64:$MCR_ROOT/sys/opengl/lib/glnxa64

echo Activating Dynamo as standalone

source $DYNAMO_FOLDER/dynamo_activate_linux.sh
