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
  mxArray *x_ptr, *y_ptr, *z_ptr, *t_ptr, *other_ptr, *dx_ptr, *dy_ptr, *dz_ptr, *hit_ptr;
  double *x, *y, *z, *t, *other, *dx, *dy, *dz, *hit;



  x_ptr = mxDuplicateArray(prhs[0]);
  y_ptr = mxDuplicateArray(prhs[1]);
  z_ptr = mxDuplicateArray(prhs[2]);
  t_ptr = mxDuplicateArray(prhs[3]);
  other_ptr = mxDuplicateArray(prhs[4]);

  x = mxGetPr(x_ptr);
  y = mxGetPr(y_ptr);
  z = mxGetPr(z_ptr);
  t = mxGetPr(t_ptr);
  other = mxGetPr(other_ptr);

  double fps = other[0];
  double max_dx = other[1];
  double max_dy = other[2];
  double max_dz = other[3];
  double max_tspan = other[4];
  int n = (int)other[5], i, j, tot = 0;

  double G = 9810;

  for(i = n - 1; i >= 0; --i) {
      t[i] -= t[0];
      t[i] /= fps;
      z[i] = z[i] * (-1);
      z[i] -= G * t[i] * t[i] / 2;
  }

  for (i = 0; i < n; ++i) {
      j = i;
      while(j < n && t[j] - t[i] < 1e-7) {
          ++j;
      }
      while(j < n && t[j] - t[i] < max_tspan) {
          ct = t[j] - t[i];

          cx = (x[j] - x[i]) / ct;
          cy = (y[j] - y[i]) / ct;
          cz = (z[j] - z[i]) / ct + G * (t[1] - t[0]) * (t[1] - t[0]) / 2;

          if (abs(cx) < max_dx && abs(cy) < max_dy && abs(cz) < max_dz)
            ++tot;
          end
          ++j;
      }
  }

  dx_ptr = plhs[0] = mxCreateDoubleMatrix(1,tot,mxREAL);
  dy_ptr = plhs[1] = mxCreateDoubleMatrix(1,tot,mxREAL);
  dz_ptr = plhs[2] = mxCreateDoubleMatrix(1,tot,mxREAL);
  hit_ptr = plhs[3] = mxCreateDoubleMatrix(1,tot,mxREAL);

  dx = mxGetPr(dx_ptr);
  dy = mxGetPr(dy_ptr);
  dz = mxGetPr(dz_ptr);
  hit = mxGetPr(hit_ptr);

  tot = 0;
  for (i = 0; i < n; ++i) {
      j = i;
      while(j < n && t[j] - t[i] < 1e-7) {
          ++j;
      }
      while(j < n && t[j] - t[i] < max_tspan) {
          ct = t[j] - t[i];

          cx = (x[j] - x[i]) / ct;
          cy = (y[j] - y[i]) / ct;
          cz = (z[j] - z[i]) / ct + G * (1 / fps) * (1 / fps) / 2;

          if (abs(cx) < max_dx && abs(cy) < max_dy && abs(cz) < max_dz)
            slope_z = (z[j] - z[i]) / ct;
            // Z_i + Slope_Z * t - G*t^2 / 2 = 0;
            // A = - G / 2; B = Slope_Z; C = Z_i;
            // Tmax = (-B + sqrt(B^2 - 4AC)) / 2A
            // Tmax = (Slope_Z + sqrt(Slope_Z^2 + 2 * G * Z_i)) / G
            ct = (slope_z + sqrt(slope_z * slope_z + 2 * G * z[i])) / G;

            dx[tot] = cx;
            dy[tot] = cy;
            dz[tot] = cz;
            hit[tot] = ct;

            ++tot;
          end
          ++j;
      }
  }

}
