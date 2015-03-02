#
# :TODO:
# switch/swap
# unload modules if parent removed
#

if {[info exists env(PSI_DEBUG)] && $env(PSI_DEBUG)} {
	proc debug {msg} {
		set level [expr [info level] -2] 
		set r [catch {info level ${level}} e]
		if {$r} {
			set caller ""
		} else {
			set caller [lindex [split [info level [expr [info level] - 3]]] 0]
		}
		puts -nonewline stderr "${caller}: "
		puts stderr ${msg}
	}
} else {
	proc debug {msg} {}
}

proc set-family { family } {
	global env
	global name
	global version
	global implementation

	debug $family
	set Implementation [file join {*}${implementation}]

	set	FAMILY [string toupper $family]
	regsub -- "-" ${FAMILY} "_" FAMILY
	setenv	${FAMILY}		$name
	setenv	${FAMILY}_VERSION	$version

	set	::${family}		${name}
	set	::${family}_version	${version}

	lassign [split ${::family} .] caller_family caller_release
	if { "${caller_release}" != "" } {
		set caller_release ".${caller_release}"
	}
	debug "caller family: ${caller_family}, release: ${caller_release}"

	if { [module-info mode load] } {
		debug "mode is load"
		append-path MODULEPATH ${::MODULE_ROOT_PATH}/${family}/${Implementation}
		append-path PSI_LOADEDFAMILIES ${family}
		debug "mode=load: new MODULEPATH=$env(MODULEPATH)"
		debug "mode=load: new PSI_LOADEDFAMILIES=$env(PSI_LOADEDFAMILIES)"
	} elseif { [module-info mode remove] } {
		# remove orphan modules
		debug "remove orphan modules"
		set FAMILY [string toupper $family]
		if { [info exists env(PSI_ACTIVE_MODULES_${FAMILY})] } {
			set modules [split $env(PSI_ACTIVE_MODULES_${FAMILY}) ":"]
			foreach m ${modules} {
				if { ${m} == "--APPMARKER--" } {
					continue
				}
				debug "unloading module: $m"
				module unload ${m}
			}
		}
		remove-path MODULEPATH ${::MODULE_ROOT_PATH}/${family}/${Implementation}
		remove-path PSI_LOADEDFAMILIES ${family}
		debug "mode=remove: $env(MODULEPATH)"
		debug "mode=remove: $env(PSI_LOADEDFAMILIES)"
	}
	if { [module-info mode switch2] } {
		debug "mode=switch2"
		append-path MODULEPATH ${::MODULE_ROOT_PATH}/${family}/[module-info name]
		append-path PSI_LOADEDFAMILIES ${family}
	}
}



proc update_active_modules { family name version } {
	if { ${family} == "--APPMARKER--" } {
		return
	}
	set FAMILY [string toupper $family]
	append-path PSI_ACTIVE_MODULES_${FAMILY} "$name/$version"
	remove-path PSI_ACTIVE_MODULES_${FAMILY} "--APPMARKER--"
}

proc is-avail { m } {
	debug "${m}"
	set output [catch { exec "$::env(MODULESHOME)/bin/modulecmd" bash avail "${m}" } msg]
	if { ${output} != "" } {
		return yes
	} else {
		return no
	}
}


#
# load dependencies, but do *not* unload dependencies
#
proc load_dependencies { fname } {
	if { ! [ file exists ${fname} ] } {
		return
	}
	if { ! [module-info mode load] } {
		return
	}
	debug "load dependencies from: ${fname}"
	#  Slurp up the data file
	set fp [open ${fname} r]
	set file_data [read ${fp}]
	close ${fp}
	set data [split ${file_data} "\n"]
	foreach line ${data} {
		debug "MODULEPATH=$::env(MODULEPATH)"
		set module_name [string trim $line]
		if { ${module_name} == "#" || ${module_name} == "" } {
			continue
		}
		if { [is-loaded ${module_name}] } {
			debug "module already loaded: ${module_name}"
			continue
		}
		debug "module avail: ${module_name}"
		if { ! [is-avail "${module_name}"] } {
			debug "module not in current MODULEPATH: ${module_name}"
			set search_output [exec $::env(PSI_PREFIX)/config/init/extensions/search.bash  "${module_name}"]
			module use $::env(PSI_PREFIX)/modulefiles/[lindex ${search_output} 2]
		}
		debug "module load: ${module_name}"
		module load ${module_name}
     }
}

proc lreverse_n { list n } {
        set res {}
        set i [expr [llength $list] - $n]
        while {$i >= 0} {
                lappend res {*}[lrange $list $i [expr $i+$n-1]]
                incr i -$n
        }
        set res
}



#
# set standard environment variables
#
proc set_std_environment { PREFIX name version } {
	#
	# Hack for supporting legacy modules
	if { "${::family}" == "Legacy" } {
		debug "this is a legacy module..."
		return
	}


	set		NAME			[string toupper $name]
	regsub -- "-" ${NAME} "_" NAME

	if { ! [info exist ::dont-setenv] } {
		set ::dont-setenv {}
	}

	if { ${version} != "" } {
		if { [lsearch ${::dont-setenv} "${NAME}_VERSION"] == -1 } {
			setenv		${NAME}_VERSION		$version
		}
	}

	if { [file isdirectory "$PREFIX"] } {
		if { [lsearch ${::dont-setenv} "${NAME}_PREFIX"] == -1 } {
			setenv		${NAME}_PREFIX		$PREFIX
		}
		if { [lsearch ${::dont-setenv} "${NAME}_DIR"] == -1 } {
			setenv		${NAME}_DIR		$PREFIX
		}
		if { [lsearch ${::dont-setenv} "${NAME}_HOME"] == -1 } {
			setenv		${NAME}_HOME		$PREFIX
		}
	}

	if { [file isdirectory "$PREFIX/bin"] } {
		if { [lsearch ${::dont-setenv} "PATH"] == -1 } {
			prepend-path	PATH			$PREFIX/bin
		}
	}

	if { [file isdirectory "$PREFIX/sbin"] } {
		if { [lsearch ${::dont-setenv} "PATH"] == -1 } {
			prepend-path	PATH			$PREFIX/sbin
		}
	}

	if { [file isdirectory "$PREFIX/share/man"] } {
		if { [lsearch ${::dont-setenv} "MANPATH"] == -1 } {
			prepend-path	MANPATH			$PREFIX/share/man
		}
	}

	# set various environment variables - as long as they are not blacklisted
	debug "prepend to include paths"
	if { [file isdirectory "$PREFIX/include"] } {
		if { [lsearch ${::dont-setenv} "C_INCLUDE_PATH"] == -1 } {
			prepend-path	C_INCLUDE_PATH		$PREFIX/include
		}
		if { [lsearch ${::dont-setenv} "CPLUS_INCLUDE_PATH"] == -1 } {
			prepend-path	CPLUS_INCLUDE_PATH	$PREFIX/include
		}
		if { [lsearch ${::dont-setenv} "${NAME}_INCLUDE_DIR"] == -1 } {
			setenv		${NAME}_INCLUDE_DIR	$PREFIX/include
		}
	}

	debug "prepend to library paths"
	if { [file isdirectory "$PREFIX/lib"] } {
		if { [lsearch ${::dont-setenv} "LIBRARY_PATH"] == -1 } {
			prepend-path	LIBRARY_PATH		$PREFIX/lib
		}
		if { [lsearch ${::dont-setenv} "LD_LIBRARY_PATH"] == -1 } {
			prepend-path	LD_LIBRARY_PATH		$PREFIX/lib
		}
		if { [lsearch ${::dont-setenv} "${NAME}_LIBRARY_DIR"] == -1 } {
			setenv		${NAME}_LIBRARY_DIR	$PREFIX/lib
		}
	}

	debug "prepend to library paths (64bit)"
	if { [file isdirectory "$PREFIX/lib64"] } {
		if { [lsearch ${::dont-setenv} "LIBRARY_PATH"] == -1 } {
			prepend-path	LIBRARY_PATH		$PREFIX/lib64
		}
		if { [lsearch ${::dont-setenv} "LD_LIBRARY_PATH"] == -1 } {
			prepend-path	LD_LIBRARY_PATH		$PREFIX/lib64
		}
		if { [lsearch ${::dont-setenv} "${NAME}_LIBRARY_DIR"] == -1 } {
			setenv		${NAME}_LIBRARY_DIR	$PREFIX/lib64
		}
	}

}

#
# What's the game plan here?
# Determine from path of module to be loaded:
#	- name,
#	- version
#	- installation PREFIX 
#
set	current_modulefile	[file split $ModulesCurrentModulefile]
set	psi_prefix		[file split $env(PSI_PREFIX)]

# return, if module is not in $env(PSI_PREFIX)
set	module_prefix		[file join {*}[lrange ${current_modulefile} 0 [llength ${psi_prefix}]-1]]
if { $env(PSI_PREFIX) != ${module_prefix} } {
	debug "stop sourcing: $env(PSI_PREFIX) != ${module_prefix}"
	return
} 

set	MODULE_ROOT_PATH	$env(PSI_PREFIX)/$env(PSI_MODULES_ROOT)
set	module_root_path	[file split ${MODULE_ROOT_PATH}]
set	len			[llength $module_root_path]

set	name			[lindex $current_modulefile end-1]
set	version			[lindex $current_modulefile end]
set	family			[lrange $current_modulefile $len $len]
set	implementation		[lrange $current_modulefile [expr $len + 1] end]

set	prefix			"$psi_prefix [regsub "(.unstable|.deprecated)" $family ""] [lreverse_n [lrange $current_modulefile $len end] 2]"
set	PREFIX			[file join {*}$prefix]

debug "PREFIX=$PREFIX"
debug "family of module $name: $family"

#
# we cannot load another module with the same name
#
conflict	$name

if { [module-info mode load] } {
	debug "${name}/${version}: loading ... "
	if { [ string match "*.deprecated" ${family} ] == 1 } {
		puts stderr "${name}/${version}: this module is deprecated!"
	}

	for {set i [expr [llength ${prefix}] - 1]} {$i >= ${len}} {incr i -2} {
		set info_file [lrange ${prefix} 0 $i]
		lappend info_file ".info"
		set fname [file join {*}${info_file}]
		if { [ file exists "${fname}" ] } {
			set fp [open "${fname}" r]
			set info_data [read $fp]
			close $fp
			puts stderr ${info_data}
		}
	}
	load_dependencies "${PREFIX}/.dependencies"
}

set_std_environment ${PREFIX} ${name} ${version}
update_active_modules ${family} ${name} ${version}

proc ModulesHelp { } {
	if { [info exists ::whatis] } {
		puts stderr "${::whatis}"
	}
	if { [info exists ::version] } {
		puts stderr "Version:    ${::version}"
	}
	if { [info exists ::url] } {
		puts stderr "Homepage:   ${::url}"
	}
	if { [info exists ::license] } {
		puts stderr "License:    ${::license}"
	}
	if { [info exists ::maintainer] } {
		puts stderr "Maintainer: ${::maintainer}"
	}
	if { [info exists ::help] } {
		puts stderr "${::help}\n"
	}
}

if { [info exists ::whatis] } {
	module-whatis	"$whatis"
}
