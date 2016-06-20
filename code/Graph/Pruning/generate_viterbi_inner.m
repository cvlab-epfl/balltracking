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

function [cost_grid, prv_grid] = generate_viterbi_inner(xs, ys, zs, t_idx, BOM_grid, depth, depth_ort)
BOM_sub = BOM_grid(t_idx,:,:,:);
%eval('mex generate_viterbi_inner_c.c');
[cost_grid, prv_grid] = generate_viterbi_inner_c(BOM_sub, [xs, ys, zs, depth, depth_ort, size(BOM_sub)]);
cost_grid = reshape(cost_grid, size(BOM_sub));
prv_grid = reshape(prv_grid, size(BOM_sub));
end
