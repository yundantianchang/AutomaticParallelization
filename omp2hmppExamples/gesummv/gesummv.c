#include <string.h>
#include <math.h>

/* Default problem size. */
#ifndef Y
# define Y 8000
#endif



double alpha;
double beta;
double A[Y][Y];
double B[Y][Y];
double x[Y];
double y[Y];
double tmp[Y];

static void init_array() {
  int i, j;

  alpha = 43532;
  beta = 12313;
  for (i = 0; i < Y; ) {
    x[i] = ((double)i) / Y;
    for (j = 0; j < Y; ) {
      A[i][j] = ((double)i * j) / Y;
      j++;
    }
    i++;
  }
}



int main(int argc, char** argv) {
  int i, j;
  int n = Y;

  /* Initialize array. */
  init_array();

#pragma omp parallel fixed(9,1,0)
{
 #pragma omp for private (j)
  for (i = 0; i < n; i++) {
    tmp[i] = 0;
    y[i] = 0;
    for (j = 0; j < n; j++) {
      tmp[i] = A[i][j] * x[j] + tmp[i];
      y[i] = B[i][j] * x[j] + y[i];
    }
    y[i] = alpha * tmp[i] + beta * y[i];
  }

}



  return 0;
}
