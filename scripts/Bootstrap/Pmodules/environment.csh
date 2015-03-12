#!/bin/tcsh

setenv PSI_PREFIX "/opt/psi"

if ( "$PMODULES_VERSION" == "" ) then
	setenv PMODULES_VERSION "0.99.1"
endif
setenv PMODULES_HOME "$PSI_PREFIX/Tools/Pmodules/$PMODULES_VERSION"

setenv PSI_CONFIG_DIR "config"
setenv PSI_MODULES_ROOT 'modulefiles'
setenv PSI_TEMPLATES_DIR 'templates'

setenv PSI_DEFAULT_FAMILIES 'Tools Programming'

setenv PSI_RELEASES ':unstable:stable:deprecated:'
setenv PSI_USED_RELEASES 'stable'
