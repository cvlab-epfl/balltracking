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

function [ tracks ] = read_ksp_output( fname, frame_idx, gX, gY, gZ)

    global FORMAT;
    global DATASET;

    locX = DATASET.Loc.X;
    locY = DATASET.Loc.Y;
    locZ = DATASET.Loc.Z;

    offsetX = DATASET.Offset.X;
    offsetY = DATASET.Offset.Y;

    fid = fopen(fname, 'r');
    tcount = fscanf(fid, '%d', [1 1]);
    tracks = repmat(FORMAT.TRACK, 1, tcount);

    for f=frame_idx
        line = fscanf(fid, '%d', [1 tcount + 1]);
        while(line(1) ~= f)
            line = fscanf(fid, '%d', [1 tcount + 1]);
        end
        line = line(2:end);
        for i=1:tcount
            if (line(i) ~= -1)
                lz = mod(line(i), gZ) + 1;
                line(i) = fix(line(i) / gZ);

                lx = mod(line(i), gX) + 1;
                ly = fix(line(i) / gX) + 1;

                tracks(i).T = [tracks(i).T f];
                tracks(i).X = [tracks(i).X lx];
                tracks(i).Y = [tracks(i).Y ly];
                tracks(i).Z = [tracks(i).Z lz];
                tracks(i).Pos = [tracks(i).Pos;...
                                 locX(lx) - offsetX...
                                 locY(ly) - offsetY...
                                 locZ(lz) * (-1)];
                tracks(i).W = [tracks(i).W 0];
            end
        end
    end
    fclose(fid);
end
