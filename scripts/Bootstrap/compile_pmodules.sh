#!/bin/bash

declare -r BASE_DIR=$(cd "$(dirname $0)/../.." && pwd)
declare -r BOOTSTRAP_DIR="${BASE_DIR}/scripts/Bootstrap"

source "${BASE_DIR}/config/Pmodules.conf"

unset PMODULES_HOME
source "/opt/psi/config/environment.bash"

${BOOTSTRAP_DIR}/gettext/build --bootstrap || { echo "compiling 'gettext' failed!"; exit 1; }
${BOOTSTRAP_DIR}/getopt/build --bootstrap  || { echo "compiling 'getopt' failed!"; exit 1; }
${BOOTSTRAP_DIR}/dialog/build --bootstrap  || { echo "compiling 'dialog' failed!"; exit 1; }
${BOOTSTRAP_DIR}/bash/build --bootstrap    || { echo "compiling 'bash' failed!"; exit 1; }
${BOOTSTRAP_DIR}/Tcl/build --bootstrap     || { echo "compiling 'Tcl' failed!"; exit 1; }

# we have to remove the init directory - otherwise the next build will fail...
rm -rf "${PMODULES_HOME}/init"
${BOOTSTRAP_DIR}/Modules/build --bootstrap || { echo "compiling 'Modules' failed!"; exit 1; }
mv -v "${PMODULES_HOME}/bin/modulecmd" "${PMODULES_HOME}/bin/modulecmd.tcl"
