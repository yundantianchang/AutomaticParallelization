/*--------------------------------------------------------------------
  (C) Copyright 2006-2011 Barcelona Supercomputing Center 
                          Centro Nacional de Supercomputacion
  
  This file is part of Mercurium C/C++ source-to-source compiler.
  
  See AUTHORS file in the top level directory for information 
  regarding developers and contributors.
  
  This library is free software; you can redistribute it and/or
  modify it under the terms of the GNU Lesser General Public
  License as published by the Free Software Foundation; either
  version 3 of the License, or (at your option) any later version.
  
  Mercurium C/C++ source-to-source compiler is distributed in the hope
  that it will be useful, but WITHOUT ANY WARRANTY; without even the
  implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
  PURPOSE.  See the GNU Lesser General Public License for more
  details.
  
  You should have received a copy of the GNU Lesser General Public
  License along with Mercurium C/C++ source-to-source compiler; if
  not, write to the Free Software Foundation, Inc., 675 Mass Ave,
  Cambridge, MA 02139, USA.
--------------------------------------------------------------------*/


/*
<testinfo>
test_generator=config/mercurium-ss2omp
test_nolink=yes
</testinfo>
*/

#include <stdlib.h>

#pragma css task target device(smp) inout(a[10][20])
void f(int *a)
{
    int (*p)[20] = (int (*)[20]) a;
    int i, j;
    for (i = 0; i < 10; i++)
    {
        for (j = 0; j < 20; j++)
        {
            p[i][j]++;
        }
    }
}

void g(int *b[2][3])
{
  f(b[1][2]);
}

int main(int argc, char *argv[])
{
    int _m1[10][20];

    int i, j;
    for (i = 0; i < 10; i++)
    {
        for (j = 0; j < 20; j++)
        {
            _m1[i][j] = i + j;
        }
    }

    int *c[2][3];
    c[1][2] = &_m1[0][0];
    g(c);
#pragma omp taskwait
    for (i = 0; i < 10; i++)
    {
        for (j = 0; j < 20; j++)
        {
            if (_m1[i][j] != (i + j + 1)) abort();
        }
    }

    return 0;
}
