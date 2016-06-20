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
#define BOM(t,z,x,y) BOM[(t)+((z) + ((x) + ((y))*X)*Z)*T]
#define cost(t,z,x,y) cost[(t)+((z) + ((x) + ((y))*X)*Z)*T]
#define prev(t,z,x,y) prev[(t)+((z) + ((x) + ((y))*X)*Z)*T]
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
  mxArray *val_ptr, *BOM_ptr, *cost_ptr, *prev_ptr;
  double *vals, *BOM, *cost, *prev;

  BOM_ptr = mxDuplicateArray(prhs[0]);
  val_ptr = mxDuplicateArray(prhs[1]);

  BOM = mxGetPr(BOM_ptr);
  vals = mxGetPr(val_ptr);

  int xs = (int)vals[0] - 1;
  int ys = (int)vals[1] - 1;
  int zs = (int)vals[2] - 1;
  int depth = (int)vals[3];
  int depth_ort = (int)vals[4];
  int T = (int)vals[5];
  int Z = (int)vals[6];
  int X = (int)vals[7];
  int Y = (int)vals[8];

  cost_ptr = plhs[0] = mxCreateDoubleMatrix(1,T*Z*X*Y,mxREAL);
  prev_ptr = plhs[1] = mxCreateDoubleMatrix(1,T*Z*X*Y,mxREAL);

  cost = mxGetPr(cost_ptr);
  prev = mxGetPr(prev_ptr);

  int id = 0;
  while(id < T*Z*X*Y) {
      cost[id] = -1e9;
      prev[id] = -1;
      ++id;
  }
  cost(0,zs,xs,ys) = 0;

  int t = 1;
  while(t < T) {
      int z = 0;
      while(z < Z) {
          int x = 0;
          while(x < X) {
              int y = 0;
              while(y < Y) {
                  double add = BOM(t,z,x,y);
                  if (add < 0.001) add = 0.001;
                  if (add > 0.999) add = 0.999;
                  add = log(add);

                  int sx = -depth;
                  while(sx <= depth) {
                      int sy = -depth;
                      while(sy <= depth) {
                          int sz = -depth_ort;
                          while(sz <= depth) {
                              int nx = x + sx;
                              int ny = y + sy;
                              int nz = z + sz;
                              if (nx < 0 || nx >= X || ny < 0 || ny >= Y || nz < 0 || nz >= Z) {} else {
                                  double nv = cost(t - 1,nz,nx,ny) + add;
                                  if (nv > cost(t,z,x,y)) {
                                      cost(t,z,x,y) = nv;
                                      prev(t,z,x,y) = 1 + ((nz) + ((nx) + ((ny))*X)*Z);
                                  }
                              }
                              ++sz;
                          }
                          ++sy;
                      }
                      ++sx;
                  }
                  ++y;
              }
              ++x;
          }
          ++z;
      }
      ++t;
  }
}
