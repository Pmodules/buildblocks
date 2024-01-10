# 
# ------ MAKEFILE FILE FOR Linux FREALIGN -----------
# 
# Using: gnu compiler
#
# Thanks to: Shixin Yang & Dr Edward Egelman at University of Virginia
#    for providing this file
#
# Notes:  To create executable: make -f Makefile_linux_amd64_gnu
#

SHELL  = /bin/sh

FFLAGS = -m64 -O3 -s -fomit-frame-pointer -Wall -falign-functions=4 \
	 -funroll-loops -fexpensive-optimizations -fschedule-insns2 \
	 -D_FILE_OFFSET_BITS=64 -D_LARGEFILE_SOURCE \
	 -cpp -w -c

CFLAGS = -m64 -O3 -DPROTOTYPE -D_FILE_OFFSET_BITS=64 \
	 -D_LARGEFILE_SOURCE -cpp -w -c

COMP   = gfortran

CC     = gcc

ifeq ($(MKLROOT),"")
  LF   = -D_FILE_OFFSET_BITS=64 -D_LARGEFILE_SOURCE
else
  LF   = -D_FILE_OFFSET_BITS=64 -D_LARGEFILE_SOURCE -Wl,--start-group $(MKLROOT)/lib/intel64/libmkl_intel_lp64.a $(MKLROOT)/lib/intel64/libmkl_core.a $(MKLROOT)/lib/intel64/libmkl_sequential.a -Wl,--end-group -ldl -lpthread
endif

PGM    = finddqe

LIB    = $(PGM).a

.PRECIOUS :  $(PGM) $(LIB) 

include Makefile.inc

ioc.o : ioc.c
	$(CC) $(CFLAGS) -o ioc.o ioc.c
	$(AR) r $(LIB) ioc.o
	@\rm ioc.o

$(LIB) : ioc.o $(ELEMENTS)
	@echo all object files placed in library

.f.a:
	$(COMP) $(FFLAGS) $<
	$(AR) r $(LIB) $*.o
	@\rm $*.o
