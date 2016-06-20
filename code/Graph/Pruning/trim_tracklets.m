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

function [ tracks_new ] = trim_tracklets( tracks )

    global DATASET;
    global FORMAT;

    courtX = DATASET.Court.X;
    courtY = DATASET.Court.Y;
    courtZ = DATASET.Court.Z;
    offsetX = DATASET.Offset.X;
    offsetY = DATASET.Offset.Y;

    is_good = @(x,y,z) (x + offsetX >= 0 && x + offsetX <= courtX &&...
                      y + offsetY >= 0 && y + offsetY <= courtY &&...
                      -z >= 0 && -z <= courtZ);
    is_valid = @(i,j) is_good(tracks(i).Pos(j,1), tracks(i).Pos(j,2), tracks(i).Pos(j,3));

    tracks_new = [];

    for i=1:length(tracks)
        j = 1;
        while(j <= length(tracks(i).T))
            k = j;
            while(k <= length(tracks(i).T) && is_valid(i, k))
                k = k + 1;
            end

            k = k - 1;
            if (k >= j)
                track = FORMAT.TRACK;
                track.T = tracks(i).T(j:k);
                track.Pos = tracks(i).Pos(j:k,:);
                track.Node = tracks(i).Node(j:k);
                track.W = tracks(i).W(j:k);
                tracks_new = [tracks_new track];
            end
            j = k + 2;
        end
    end
end

