#!/bin/bash

declare -r BASE_DIR=$(cd "$(dirname $0)/../.." && pwd)
declare -r BOOTSTRAP_DIR="${BASE_DIR}/scripts/Bootstrap"

source "${BOOTSTRAP_DIR}/Pmodules_version.conf"

unset PMODULES_HOME
source "/opt/psi/config/environment.bash"

${BOOTSTRAP_DIR}/coreutils/build --bootstrap --disable-cleanup        || { echo "compiling 'coreutils' failed!"; exit 1; }
${BOOTSTRAP_DIR}/gettext/build   --bootstrap --disable-cleanup        || { echo "compiling 'gettext' failed!"; exit 1; }
${BOOTSTRAP_DIR}/getopt/build    --bootstrap --disable-cleanup        || { echo "compiling 'getopt' failed!"; exit 1; }
${BOOTSTRAP_DIR}/dialog/build    --bootstrap --disable-cleanup        || { echo "compiling 'dialog' failed!"; exit 1; }
${BOOTSTRAP_DIR}/bash/build      --bootstrap --disable-cleanup 4.3.30 || { echo "compiling 'bash' failed!"; exit 1; }
${BOOTSTRAP_DIR}/Tcl/build       --bootstrap --disable-cleanup        || { echo "compiling 'Tcl' failed!"; exit 1; }

# we have to remove the init directory - otherwise the next build will fail...
rm -rf "${PMODULES_HOME}/init"
${BOOTSTRAP_DIR}/Modules/build --bootstrap || { echo "compiling 'Modules' failed!"; exit 1; }
mv -v "${PMODULES_HOME}/bin/modulecmd" "${PMODULES_HOME}/bin/modulecmd.tcl"
