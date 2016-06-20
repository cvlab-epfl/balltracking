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

function [ x y z ] = generate_viterbi_single( xs, ys, zs, t_idx, ...
                                             BOM, depth, depth_ort, POM_grid)

[cost_grid, prv_grid] = generate_viterbi_inner(xs, ys, zs,...
t_idx, POM_grid, depth, depth_ort);

prv_grid = prv_grid(size(prv_grid, 1):-1:1,:,:,:);

tmp = cost_grid(end,:,:,:);
[~,idx] = max(tmp(:));
[~,cz,cx,cy] = ind2sub(size(tmp), idx);

[x,y,z] = generate_viterbi_path(cx, cy, cz, prv_grid, length(t_idx));
end

