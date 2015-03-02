#!/usr/bin/env bash

declare -r DEFAULT_SRC="/afs/psi.ch/sys/psi.@sys"
declare -r DEFAULT_DST="/opt/psi.local"

function usage() {
    echo "
$0 [--from=<source>] [--to=<destination>] [--dryrun] [--delete]
    --from    source module installation (default: $DEFAULT_SRC)

    --to      destination module installation (default: $DEFAULT_DST)

    --dryrun  just tell what would be copied and deleted

    --delete  as an additional task, delete modules that are present
              at the destination but not at the source installation
              (destination cleanup)" >&2
}

function die() {
    echo "$1" >&2
    exit 1
}

# check if directory $1 is a valid prefix
function is_module_prefix() {
    if [[ -d "$1" ]] &&
       [[ -d "$1/$PSI_CONFIG_DIR" ]] &&
       [[ -d "$1/$PSI_MODULES_ROOT" ]]
    then
        return 0
    fi
    return 1
}

# set the source and destination module installations
function get_options() {
    local src_dir="$DEFAULT_SRC"
    local dst_dir="$DEFAULT_DST"
    local dryrun=false
    local delete=false
    local option

    while (($# > 0)); do
        if [[ "${1#--from}" != "$1" ]]; then
            option="${1#--from}"
            option="${option#=}"
            [[ -z "$option" ]] && { shift; option="$1"; }
            src_dir="$option"
        elif [[ "${1#--to}" != "$1" ]]; then
            option="${1#--to}"
            option="${option#=}"
            [[ -z "$option" ]] && { shift; option="$1"; }
            dst_dir="$option"
        elif [[ -z "${1#--dryrun}" ]]; then
            dryrun=true
        elif [[ -z "${1#--delete}" ]]; then
            delete=true
        else
            usage > /dev/fd/2
            die "Unknown option: $1"
        fi
        shift
    done

    is_module_prefix "$src_dir" || { die "<$src_dir> is not a Pmodules installation"; }
    is_module_prefix "$dst_dir" || { die "<$dst_dir> is not a Pmodules installation"; }
    src_dir=$( cd "$src_dir"; pwd -P )
    dst_dir=$( cd "$dst_dir"; pwd -P )
    [[ "$src_dir" == "$dst_dir" ]] && { die "same source and destination installations"; }
    local modbin=$( cd "$PMODULES_HOME"; pwd -P )
    local prefix=$( cd "$PSI_PREFIX"; pwd -P )
    modbin=${modbin#"$prefix/"}/bin/modulecmd
    local -r file_type_src=$( file -b "$src_dir/$modbin" 2>&1 || echo err1 )
    local -r file_type_dst=$( file -b "$dst_dir/$modbin" 2>&1 || echo err2 )
    [[ ! "${file_type_src}" == "${file_type_dst}" ]] || {
        die "The file signatures in the source and destination installation do not match!"
    }
    echo "$src_dir" "$dst_dir" "$dryrun" "$delete"
}

# Derive the relative module installation path
#    from the relative module file path
# $1 relative module file path
function get_modpath() {
    local -a comp=( ${1//\// } )    # split rel.path into components
    local -a path		    # result path
    local -i i
    for ((i=0; i<${#comp[@]}; i++)); do
        case $i in
            0) path=( ${comp[0]%.*} );;
            *) path+=( "${comp[$((-i-1))]}/${comp[$((-i))]}" ); i+=1;;
        esac
    done
    echo "${path[*]}"
}

# Derive the relative module release file path
#    from the relative module file path
# $1 relative module file path
function get_release_path() {
    echo "$(dirname "$1")/.release-$(basename "$1")"
}

# $1 dryrun=(true|false)
# $2 relative module file path of destination module to be deleted
# $3 destination prefix
function delete_module() {
    if [[ "$1" != "false" ]]; then
        echo "(dryrun) delete: $2 at $3" 1>&2
        return 0
    fi
    local modpath=$( get_modpath "$2" )
    [[ -z "$modpath" ]] && {
	die "Unable to retrieve module file and installation paths";
    }
    echo "rm -v \"$3/$PSI_MODULES_ROOT/$2\""
    echo "rm -v \"$3/$PSI_MODULES_ROOT/$( get_release_path $2 )\""
    echo "rmdir -vp \"$( dirname "$3/$PSI_MODULES_ROOT/$2" )\""
    echo "rm -vrf \"$3/$modpath\""
    echo "rmdir -vp \"$( dirname "$3/$modpath" )\""
    echo "deleted: $2" 1>&2
}

# $1 dryrun=(true|false)
# $2 relative module file path of source module to be copied to the destination
# $3 source prefix
# $4 destination prefix
function copy_module() {
    if [[ "$1" != "false" ]]; then
        echo "(dryrun) copy: $2 from $3 to $4" 1>&2
        return 0
    fi
    local modpath=$( get_modpath "$2" )
    [[ -z "$modpath" ]] && { die "Unable to retrieve module file and installation paths"; }
    install -d $( dirname "$3/$PSI_MODULES_ROOT/$2" )
    (
        cd $3
        rsync --links --perms --relative --verbose "$PSI_MODULES_ROOT/$2" "$4"
        rsync --links --perms --relative --verbose "$PSI_MODULES_ROOT/$( get_release_path "$2" )" "$4"
        rsync --recursive --links --perms --relative --verbose "$modpath" "$4"
    )
    echo "copied: $2" 1>&2
}

# syncronize modules from source to
# destination module installations
# --from=<source>        default: /afs/psi.ch/sys/psi.@sys
# --to=<destination>     default: /opt/psi.local
function sync_modules() {
    local -a options=( $(get_options "$@") )
    [[ -z "$options" ]] && exit 1
    local src_dir="${options[0]}"
    local dst_dir="${options[1]}"
    local dryrun="${options[2]}"
    local delete="${options[3]}"
    unset options

    local profile_script="$src_dir/$PSI_CONFIG_DIR/profile.bash"
    [[ -r "$profile_script" ]] || {
	die "Unable to find profile script of installation $profile_script";
    }
    local search_script="$src_dir/Tools/Pmodules/${PMODULES_VERSION}/bin/modulecmd"
    [[ -x "$search_script" ]] || {
	die "Unable to find search script of installation $search_script";
    }
    local dialog_script="$src_dir/Tools/Pmodules/${PMODULES_VERSION}/bin/dialog.bash"
    [[ -r "$dialog_script" ]] || {
	die "Unable to find dialog script of installation $dialog_script";
    }

    . "$profile_script"    # set variables for the source installation

    DIALOG_LIB=1           # use dialog script as a library
    . "$dialog_script"     # dialog functions

    local -a selected_modules

    # Redefine module_out to append modules to the selected_modules variable
    function module_out() {
        local -a args=(${modlist[$1]})
        local path=""
        IFS=/
        [[ -n "${args[3]}" ]] && path="/${args[*]:3}"
        unset IFS
        selected_modules+=( "${args[2]}$path/${args[0]}" )
    }

    module_picker "$dst_dir" < <("$search_script" bash search --no-header -a 2>&1)

    local -a destination_modules=( $(cd "$dst_dir/$PSI_MODULES_ROOT"; find -L . -type f | while read f; do echo ${f#./}; done) )

    # redefine set difference, the version in dialog.bash only handles integers
    function set_difference() {  #  $1 \ $2
        local -a operand1=($1)
        local -a operand2=($2)
        local -A members
        local elem
        for elem in "${operand1[@]}"; do
            members[$elem]=1
        done
        for elem in "${operand2[@]}"; do
            unset members[$elem]
        done
        echo ${!members[@]}
    }

    [[ "$delete" == "true" ]] && {
        local -a modules_delete=( $(set_difference "${destination_modules[*]}" "${selected_modules[*]}") )
        for m in "${modules_delete[@]}"; do
            delete_module "$dryrun" "$m" "$dst_dir"
        done
        unset modules_delete
    }


    local -a modules_copy=( $(set_difference "${selected_modules[*]}" "${destination_modules[*]}") )
    [[ -z $modules_copy ]] || {
        if [[ "$dryrun" != "false" ]]; then
            echo "(dryrun) update: $dst_dir/$PSI_CONFIG_DIR from $src_dir/$PSI_CONFIG_DIR" 1>&2
        else
            (
            local -a extraoption="$( [[ "$delete" == "true" ]] && echo --delete )"
            cd "$src_dir"
            rsync --recursive --links --perms --relative $extraoption --verbose --exclude .git "$PSI_CONFIG_DIR" "$dst_dir"
            echo "updated: $PSI_CONFIG_DIR from $src_dir" 1>&2
            )
        fi
        for m in "${modules_copy[@]}"; do
            copy_module "$dryrun" "$m" "$src_dir" "$dst_dir"
        done
    }
    unset modules_copy
}

sync_modules "$@"
