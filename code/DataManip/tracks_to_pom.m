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

function [ POM ] = tracks_to_pom( tracks, gZ, swap_xy )

    global time_idx; frame_idx = time_idx;
    global gX; global gY;

    tmp = struct('Loc',[],'Gloc',[],'X',[],'Y',[],'Z',[],'W',[]);
    tmp.Loc = repmat((1:(gX * gY)) - 1, gZ, 1); tmp.Loc = tmp.Loc(:);
    tmp.W = zeros(size(tmp.Loc));
    if (swap_xy == 1)
        tmp.X = fix(tmp.Loc / gY) + 1;
        tmp.Y = mod(tmp.Loc, gY) + 1;
    else
        tmp.X = mod(tmp.Loc , gX) + 1;
        tmp.Y = fix(tmp.Loc / gX) + 1;
    end
    tmp.Z = repmat((1:gZ) - 1, 1, gX * gY)' + 1;
    tmp.Gloc = ((1:(gX * gY * gZ)) - 1)';

    POM = repmat(tmp, 1, length(frame_idx));

    for i=1:length(tracks)
        for j=1:length(tracks(i).T)
            lx = tracks(i).X(j);
            ly = tracks(i).Y(j);
            lt = tracks(i).T(j);
            POM(lt).W((POM(lt).X == lx & POM(lt).Y == ly)) = 1;
        end
    end
end

