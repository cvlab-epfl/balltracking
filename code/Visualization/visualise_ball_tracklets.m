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

function [ ] = visualise_ball_tracklets( tracks_t, puttext )
global CONFIG;
figure;
plot(1, 0);
hold on;
for j=1:length(tracks_t)
    tracks = tracks_t{j};
    for i=1:length(tracks)
        if (j == 1)
            plot(tracks(i).T, -tracks(i).Pos(:,3), 'or');
            plot(tracks(i).T, -tracks(i).Pos(:,3), '-r');
        end
        if (j == 2)
            plot(tracks(i).T, -tracks(i).Pos(:,3), 'ob');
            plot(tracks(i).T, -tracks(i).Pos(:,3), '-b');
        end
         if (j == 3)
            plot(tracks(i).T, -tracks(i).Pos(:,3), 'og');
            plot(tracks(i).T, -tracks(i).Pos(:,3), '-g');
         end
        if (nargin == 2)
            text(tracks(i).T(1), -tracks(i).Pos(1,3), sprintf('%d', i));
        end
    end
end
hold off;
end

