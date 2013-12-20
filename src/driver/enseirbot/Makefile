##############################################################################
#
#    file                 : Makefile
#    created              : Mon Dec 16 10:57:15 CET 2013
#    copyright            : (C) 2002 enseirb robot
#
##############################################################################
#
#   This program is free software; you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation; either version 2 of the License, or
#   (at your option) any later version.
#
##############################################################################


ROBOT       = enseirbot
MODULE      = ${ROBOT}.so
MODULEDIR   = drivers/${ROBOT}
SOURCES     = ${ROBOT}.cpp drive.o

SHIPDIR     = drivers/${ROBOT}
SHIP        = ${ROBOT}.xml logo.rgb
SHIPSUBDIRS = $(shell find * -maxdepth 0 -type d -print | grep -v CVS)

PKGSUBDIRS  = ${SHIPSUBDIRS}
src-robots-base_PKGFILES =# $(shell find * -maxdepth 0 -type f -print)
src-robots-base_PKGDIR   = ${PACKAGE}-${VERSION}/$(subst ${TORCS_BASE},,$(shell pwd))



drive.o:  wrapper.ll drive.ll 
	cat $^ > .drive.ll
	llc -march=x86 -mcpu=i386 -filetype=obj -o $@ .drive.ll


include ${MAKE_DEFAULT}