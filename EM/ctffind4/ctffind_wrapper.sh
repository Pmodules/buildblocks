#!/usr/bin/bash
#  
#  This is a exec wrapper around the ctffind binary that
#  simply sets the session environment to use the C locale.
#  Otherwise the binary will likely segfault due to expecting
#  a completely different locale.
#

export LC_ALL="C"
exec "@CTFFINDPATH@" "$@" 
