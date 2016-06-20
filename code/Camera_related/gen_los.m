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
%%/* Written by Bo Chen. Modified by Andrii Maksai.                       */
%%/*                                                                      */
%%/* http://cvlab.epfl.ch/research/balltracking                           */
%%/* Contact <andrii.maksai@epfl.ch> for comments & bug reports.          */
%%/************************************************************************/

function [p_start, p_end] = gen_los(cam, centers)
n_point = size(centers, 1);
if n_point == 0
    p_start = zeros(3,0);
    p_end = zeros(3,0);
    return;
end
u = centers(:, 1);
v = centers(:, 2);
xd = (u-cam.cx)*cam.dx/cam.sx;
yd = (v-cam.cy)*cam.dy;
r2 = xd.^2+yd.^2;
xu = xd.*(1+cam.kappa*r2);
yu = yd.*(1+cam.kappa*r2);
scale = [xu, yu, cam.f*ones(n_point, 1)];

%inverse rotate
rx = cam.rx; ry = cam.ry; rz = cam.rz;
rot_mat = zeros(3,3);
rot_mat(1,1) = cos(ry)*cos(rz);
rot_mat(1,2) = cos(rz)*sin(rx)*sin(ry) - cos(rx)*sin(rz);
rot_mat(1,3) = sin(rx)*sin(rz)+cos(rx)*cos(rz)*sin(ry);
rot_mat(2,1) = cos(ry)*sin(rz);
rot_mat(2,2) = sin(rx)*sin(ry)*sin(rz)+cos(rx)*cos(rz);
rot_mat(2,3) = cos(rx)*sin(ry)*sin(rz)-cos(rz)*sin(rx);
rot_mat(3,1) = -sin(ry);
rot_mat(3,2) = cos(ry)*sin(rx);
rot_mat(3,3) = cos(rx)*cos(ry);
rot_mat = inv(rot_mat)';

scale = scale*rot_mat;
offset = [cam.tx, cam.ty, cam.tz]*rot_mat;

p_start = bsxfun(@minus, scale, offset);
p_end = bsxfun(@minus, 2*scale, offset);
end
