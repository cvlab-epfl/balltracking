/************************************************************************/
/* (c) 2016 Ecole Polytechnique Federale de Lausanne                    */
/* All rights reserved.                                                 */
/*                                                                      */
/* EPFL grants a non-exclusive and non-transferable license for non     */
/* commercial use of the Software for education and research purposes   */
/* only. Any other use of the Software is expressly excluded.           */
/*                                                                      */
/* Redistribution of the Software in source and binary forms, with or   */
/* without modification, is not permitted.                              */
/*                                                                      */
/* Written by Andrii Maksai.                                            */
/*                                                                      */
/* http://cvlab.epfl.ch/research/balltracking                           */
/* Contact <andrii.maksai@epfl.ch> for comments & bug reports.          */
/************************************************************************/

#include <math.h>
#include <matrix.h>
#include <mex.h>
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
  mxArray *x1_ptr, *y1_ptr, *z1_ptr, *v1_ptr, *x2_ptr, *y2_ptr, *z2_ptr, *v2_ptr, *other_ptr, *pairs_ptr;
  double *x1, *y1, *z1, *v1, *x2, *y2, *z2, *v2, *other, *pairs;



  x1_ptr = mxDuplicateArray(prhs[0]);
  y1_ptr = mxDuplicateArray(prhs[1]);
  z1_ptr = mxDuplicateArray(prhs[2]);
  v1_ptr = mxDuplicateArray(prhs[3]);

  x2_ptr = mxDuplicateArray(prhs[4]);
  y2_ptr = mxDuplicateArray(prhs[5]);
  z2_ptr = mxDuplicateArray(prhs[6]);
  v2_ptr = mxDuplicateArray(prhs[7]);

  other_ptr = mxDuplicateArray(prhs[8]);

  x1 = mxGetPr(x1_ptr);
  y1 = mxGetPr(y1_ptr);
  z1 = mxGetPr(z1_ptr);
  v1 = mxGetPr(v1_ptr);

  x2 = mxGetPr(x2_ptr);
  y2 = mxGetPr(y2_ptr);
  z2 = mxGetPr(z2_ptr);
  v2 = mxGetPr(v2_ptr);

  other = mxGetPr(other_ptr);

  double max_d = other[0];
  double max_z = other[1];
  double max_d2 = max_d * max_d;
  double dst;
  int n1 = (int)other[2];
  int n2 = (int)other[3];

  int tot = 0;
  for(int i = 0; i < n1; ++i) {
      for(int j = 0; j < n2; ++j) {
          dst = (x1[i] - x2[j]) * (x1[i] - x2[j]) + (y1[i] - y2[j]) * (y1[i] - y2[j]);
          if (dst < max_d2 && fabs(z1[i] - z2[j]) < max_z) {
              ++tot;
          }
      }
  }

  pairs_ptr = plhs[0] = mxCreateDoubleMatrix(1,2 * tot,mxREAL);
  pairs = mxGetPr(pairs_ptr);

  tot = 0;
  for(int i = 0; i < n1; ++i) {
      for(int j = 0; j < n2; ++j) {
          dst = (x1[i] - x2[j]) * (x1[i] - x2[j]) + (y1[i] - y2[j]) * (y1[i] - y2[j]);
          if (dst < max_d2 && fabs(z1[i] - z2[j]) < max_z) {
              pairs[tot++] = v1[i];
              pairs[tot++] = v2[j];
          }
      }
  }
}
