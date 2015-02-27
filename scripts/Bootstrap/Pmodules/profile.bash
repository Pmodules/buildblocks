#!/bin/bash

#############################################################################
# read Pmodules configuration
#
_init_env_file="$(dirname ${BASH_SOURCE})/environment.bash"
if [[ ! -r "${_init_env_file}" ]]; then
	echo "Oops: cannot initialize Modules!"
	echo "${_init_env_file}: file does not exist or is not readable."
	return 1
fi
source "${_init_env_file}"
unset _init_env_file

############################################################################
# check configuration
#
if [[ ! -d ${PSI_PREFIX} ]] || [[ ! -d ${PMODULES_HOME} ]]; then
	echo "Oops: cannot initialize module environment !"
	return 1
fi

############################################################################
# inititialize Pmodules for bash
#
_init_bash="${PMODULES_HOME}/init/bash"
if [[ ! -r "${_init_bash}" ]]; then
	echo "Oops: cannot initialize Modules!"
	echo "${_init_bash}: File does not exist or is not readable."
	return 1
fi
source "${_init_bash}"
unset _init_bash

# Local Variables:
# mode: sh
# sh-basic-offset: 8
# tab-width: 8
# End:
