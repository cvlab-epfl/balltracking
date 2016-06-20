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

function pt2 = tsai_project(cam, pt3_world)
% TSAI_PROJECT Projects points 3D to 2D
% cam - camera_config object, like one read using Read_Camera_Calibration_From_Xml
% pt3_world - 3xN array of points
% pt2 - 2xN output on the camera image plane
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

pt3_camera = rot_mat*pt3_world;
pt3_camera = bsxfun(@plus, pt3_camera, [cam.tx; cam.ty; cam.tz]);

xu = cam.f*pt3_camera(1,:)./pt3_camera(3,:);
yu = cam.f*pt3_camera(2,:)./pt3_camera(3,:);

c = xu./yu;
xd = zeros(size(xu));
yd = zeros(size(yu));
coef2 = 0;
coef1 = 1;
for i = 1:size(yu,2)
    coef3 = cam.kappa*(c(i)^2+1);
    coef0 = -yu(i);
    cubic_root = roots([coef3, coef2, coef1, coef0]);
    min_dist = 1e8;
    for j = 1:size(cubic_root,1)
        if isreal(cubic_root(j)) && (yu(i)-cubic_root(j))^2 < min_dist
            min_dist = (yu(i)-cubic_root(j))^2;
            yd(i) = cubic_root(j);
            xd(i) = yd(i)*c(i);
        end
    end
end

u = xd*cam.sx/cam.dx+cam.cx;
v = yd/cam.dy+cam.cy;
pt2 = [u;v];
end

