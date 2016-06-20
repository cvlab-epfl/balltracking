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

clear all; close all; clc;

Compile_and_setup;

% Create YOUR config file in configs directory
% and call it from this line!!
apidis;

% Check whether there is a classifier / priors file and create if none exists
if (exist(CONFIG.TrainedModel, 'file') == 0)
  train_classifier();
end

Process_people_data;

ball_detections = read_detections(CONFIG.DetBall, CONFIG.Frames);

Process_ball_data;

Create_tracking_graph;

Formulate_optimization_problem;

result = gurobi(model, params);

Reconstruct_save_solution;

visualise_result(CONFIG.Frames(1:5:length(CONFIG.Frames)),...
DATASET.DefaultCam, final_tracks_people, final_tracks_det);
