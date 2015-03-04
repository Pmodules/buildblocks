#!/bin/bash

declare -r BASE_DIR=$(cd "$(dirname $0)/../.." && pwd)
declare -r BOOTSTRAP_DIR="${BASE_DIR}/scripts/Bootstrap"
declare -r SRC_DIR="${BOOTSTRAP_DIR}/Pmodules"

source "${BASE_DIR}/config/pmodules_version.conf"

unset PMODULES_HOME
source "/opt/psi/config/environment.bash"

sed_cmd="s:@PMODULES_HOME@:${PMODULES_HOME}:g;"
sed_cmd+="s:@PMODULES_VERSION@:${PMODULES_VERSION}:g;"
sed_cmd+="s:@MODULES_VERSION@:${MODULES_VERSION}:g"
sed "${sed_cmd}" "${SRC_DIR}/modulecmd.in" > "${SRC_DIR}/modulecmd"

install -d -m 0755 "${PMODULES_HOME}/bin"
install -d -m 0755 "${PMODULES_HOME}/config"
install -d -m 0755 "${PMODULES_HOME}/init"
install -d -m 0755 "${PMODULES_HOME}/lib"

install -m 0755 "${SRC_DIR}/modulecmd" "${PMODULES_HOME}/bin"
install -m 0755 "${SRC_DIR}/init_local_env.bash" "${PMODULES_HOME}/bin"
install -m 0755 "${SRC_DIR}/modsync.bash" "${PMODULES_HOME}/bin"
install -m 0755 "${SRC_DIR}/dialog.bash" "${PMODULES_HOME}/bin"

install -m 0644 "${SRC_DIR}/bash" "${PMODULES_HOME}/init"
install -m 0644 "${SRC_DIR}/bash_completion" "${PMODULES_HOME}/init"

install -m 0644 "${SRC_DIR}/libmodules.tcl" "${PMODULES_HOME}/lib"
