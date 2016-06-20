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

function [ tracks ] = tracks_assign_discrete_position(tracks)

    global DATASET;

    locX = DATASET.Loc.X;
    locY = DATASET.Loc.Y;
    locZ = DATASET.Loc.Z;
    offsetX = DATASET.Offset.X;
    offsetY = DATASET.Offset.Y;

    for i=1:length(tracks)
        for j=1:length(tracks(i).T)
            ox = tracks(i).Pos(j,1) + offsetX;
            oy = tracks(i).Pos(j,2) + offsetY;
            oz = tracks(i).Pos(j,3) * (-1);
            [~,ix] = min(abs(locX - ox));
            [~,iy] = min(abs(locY - oy));
            [~,iz] = min(abs(locZ - oz));
            tracks(i).X(j) = ix;
            tracks(i).Y(j) = iy;
            tracks(i).Z(j) = iz;
        end
    end
end

