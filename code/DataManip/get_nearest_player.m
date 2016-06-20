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

function [ seq ] = get_nearest_player( final_tracks, gt )
global time_idx;
global locX; global locY;
global offsetX; global offsetY;
seq = [];
for t=gt.T
    ti = find(time_idx == t);
    np = 0; min_d = 1e6;
    for i=1:length(final_tracks)
        tti = find(final_tracks(i).T == ti);
        if (isempty(tti))
            continue;
        end
        x = locX(final_tracks(i).X(tti)) - offsetX;
        y = locY(final_tracks(i).Y(tti)) - offsetY;
        cur_d = abs( x - gt.X(find(gt.T == t))) + abs(y - gt.Y(find(gt.T == t))) ;
        if (cur_d < min_d)
            min_d = cur_d;
            np = i;
        end
    end
    seq = [seq np];
end
end

