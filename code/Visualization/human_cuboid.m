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

function [ pts ] = human_cuboid( X, Y, DATASET )

    human_dx = DATASET.Human.X;
    human_dy = DATASET.Human.Y;
    human_dz = DATASET.Human.Z;

    offsetX = DATASET.Offset.X;
    offsetY = DATASET.Offset.Y;

    pX = [X - human_dx / 2., X - human_dx / 2.,...
          X + human_dx / 2., X + human_dx / 2.,...
          X - human_dx / 2., X - human_dx / 2.,...
          X + human_dx / 2., X + human_dx / 2.];
    pY = [Y - human_dy / 2., Y + human_dy / 2.,...
          Y + human_dy / 2., Y - human_dy / 2.,...
          Y - human_dy / 2., Y + human_dy / 2.,...
          Y + human_dy / 2., Y - human_dy / 2.];
    pZ = [0 0 0 0 -human_dz -human_dz -human_dz -human_dz];

    pts = [pX - offsetX; pY - offsetY; pZ];
end

