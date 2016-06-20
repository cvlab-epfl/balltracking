%%/************************************************************************/
%%/* (c) 2016 Ecole Polytechnique Federale de Lausanne                    */
%%/* All rights reserved.                                                 */
%%/*                                                                      */
%%/* EPFL grants a non-exclusive and non-transferable license for non     */
%%/* commercial use of the Software for education and research purposes   */
%%/* only. Any other use of the Software is expressly excluded.           */
%%/*                                                                      */
%%/* Redistribution of the Software in source and binary forms, with or   */
%%/* without modification, is not permitted.                              */
%%/*                                                                      */
%%/* Written by Andrii Maksai.                                            */
%%/*                                                                      */
%%/* http://cvlab.epfl.ch/research/balltracking                           */
%%/* Contact <andrii.maksai@epfl.ch> for comments & bug reports.          */
%%/************************************************************************/

function [ fx2, fy2, fz2, max_error ] = Parabolic_fit( xx, yy, zz, tt, nt, G, fps )
% Finds best parabolic fit through xx, yy, zz at times tt
% Returns max squared error of fit in max error
% Given nt times of new points,
% finds fitted = their best fit given xx, yy, zz
% G = accel


tt = tt(:)'; nt = nt(:)';

tt = tt / fps;
nt = nt / fps;

mt = min([tt, nt]);

 tt = tt - mt;
 nt = nt - mt;

 gt2 = G * (tt.^2) / 2;
 gt2 = gt2';
 lz = zz - gt2;

 X = [ones(length(xx), 1) tt'];

 wx = (X' * X) \ (X' * xx);
 wy = (X' * X) \ (X' * yy);
 wz = (X' * X) \ (X' * lz);

 fx = X * wx;
 fy = X * wy;
 fz = X * wz + gt2;

 errs = sqrt((xx-fx).^2 + (yy - fy).^2 + (zz-fz).^2);
 max_error = max(errs);

 X = [ones(length(nt), 1) nt'];
 gt2 = G * (nt.^2) / 2;
 gt2 = gt2';

 if (size(X, 1) > 0)
    fx2 = X * wx;
    fy2 = X * wy;
    fz2 = X * wz + gt2;
 else
     fx2 = []; fy2 = []; fz2 = [];
 end

 fx2 = fx2'; fy2 = fy2'; fz2 = fz2';


end

