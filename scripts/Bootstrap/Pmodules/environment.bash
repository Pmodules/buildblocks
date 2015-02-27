#!/bin/bash

declare -x PSI_PREFIX=$(cd $(dirname "${BASH_SOURCE}")/.. && pwd)
declare -x PSI_CONFIG_DIR=$(basename $(cd $(dirname "${BASH_SOURCE}") && pwd))

if [[ -z ${PMODULES_VERSION} ]]; then
	declare -x PMODULES_VERSION="0.99.1"
fi

declare -x PMODULES_HOME="${PSI_PREFIX}/Tools/Pmodules/${PMODULES_VERSION}"

declare -A PSI_FAMILIES=( 
	['Legacy']=0
	['Libraries']=0
	['Programming']=0
	['Numeric']=0
	['System']=0
	['Tools']=0
	['Compiler']=2
	['MPI']=4
	['HDF5_serial']=4
	['HDF5']=6
)

declare -x PSI_MODULES_ROOT='modulefiles'

declare -x PSI_DEFAULT_FAMILIES='Tools Programming'

declare -x PSI_RELEASES=':unstable:stable:deprecated:'
declare -x PSI_USED_RELEASES='stable'
