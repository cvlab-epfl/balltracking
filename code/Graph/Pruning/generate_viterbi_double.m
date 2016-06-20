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

function [ x y z ] = generate_viterbi_double( x1, y1, z1, x2, y2, z2,...
                                             t_idx, BOM, depth, depth_ort, POM_grid)

if (length(t_idx) == 2)
    x = [x1 x2];
    y = [y1 y2];
    z = [z1 z2];
    return;
end

[cost1, prv1] = generate_viterbi_inner(x1, y1, z1, t_idx,...
POM_grid, depth, depth_ort);
[cost2, prv2] = generate_viterbi_inner(x2, y2, z2,...
t_idx(length(t_idx):-1:1), POM_grid, depth, depth_ort);

cost2 = cost2(size(cost2,1):-1:1,:,:,:);
prv2  = prv2(size(prv2,1):-1:1,:,:,:);

cost = cost1 + cost2;

[val,idx] = max(cost(:));
if (val < -1e6)
    x = [];
    y = [];
    z = [];
    return;
end
[ct,cz,cx,cy] = ind2sub(size(cost), idx);

prv1 = prv1(1:ct,:,:,:);
prv2 = prv2(ct:end,:,:,:);
prv1 = prv1(size(prv1,1):-1:1,:,:,:);

[xp1,yp1,zp1] = generate_viterbi_path(cx, cy, cz, prv1, ct);
[xp2,yp2,zp2] = generate_viterbi_path(cx, cy, cz, prv2, length(t_idx) - ct + 1);
if (ct > 1)
x = [xp1(end:-1:2) xp2];
y = [yp1(end:-1:2) yp2];
z = [zp1(end:-1:2) zp2];
else
    x = xp2;
    y = yp2;
    z = zp2;
end

end

