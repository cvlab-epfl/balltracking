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

% Compile necessary MEX files, C++ code, add Gurobi license
eval('!rm code/Graph/Pruning/generate_viterbi_inner_c.mexmaci64 &');
eval('!rm code/Graph/Pruning/generate_viterbi_inner_c.mexa64 &');
eval('mex code/Graph/Pruning/generate_viterbi_inner_c.c');
eval('!mv generate_viterbi_inner_c.* code/Graph/Pruning/');

eval('!cd code/KSP && make');
eval('!mkdir tmp');

% Modify these lines to correctly add your Gurobi distribution and license file
addpath(genpath('/Library/gurobi604/mac64/matlab/'));
setenv('GRB_LICENSE_FILE',...
'/Users/andriimaksai/Desktop/OneDrive/PhD/Useful/gurobi_licences/gurobi.lic');
gurobi_setup();

addpath(genpath('code/'));
define_data_format();
global FORMAT;
addpath('configs/');

