##########################################################################
#  (C) Copyright 2006-2011 Barcelona Supercomputing Center               #
#                          Centro Nacional de Supercomputacion           #
#                                                                        #
#  This file is part of Mercurium C/C++ source-to-source compiler.       #
#                                                                        #
#  See AUTHORS file in the top level directory for information           #
#  regarding developers and contributors.                                #
#                                                                        #
#  This library is free software; you can redistribute it and/or         #
#  modify it under the terms of the GNU Lesser General Public            #
#  License as published by the Free Software Foundation; either          #
#  version 3 of the License, or (at your option) any later version.      #
#                                                                        #
#  Mercurium C/C++ source-to-source compiler is distributed in the hope  #
#  that it will be useful, but WITHOUT ANY WARRANTY; without even the    #
#  implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR       #
#  PURPOSE.  See the GNU Lesser General Public License for more          #
#  details.                                                              #
#                                                                        #
#  You should have received a copy of the GNU Lesser General Public      #
#  License along with Mercurium C/C++ source-to-source compiler; if      #
#  not, write to the Free Software Foundation, Inc., 675 Mass Ave,       #
#  Cambridge, MA 02139, USA.                                             #
##########################################################################


include ../../../../Makefile.phases

END=

phases_LTLIBRARIES=libtlnanox-cuda.la

device_flags=$(tl_cflags) -I$(srcdir)/../.. \
             -I$(srcdir)/../../../core \
             -I$(srcdir)/../../../nanos-common

libtlnanox_cuda_la_CFLAGS = $(device_flags)
libtlnanox_cuda_la_CXXFLAGS = $(device_flags)

libtlnanox_cuda_la_LDFLAGS = $(tl_ldflags)

libtlnanox_cuda_la_SOURCES = \
       nanox-cuda.hpp \
       nanox-cuda.cpp \
       $(END)
