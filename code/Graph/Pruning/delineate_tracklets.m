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

function [ tracks_new ] = delineate_tracklets( tracks, err_lim, fps )

    global FORMAT;
    global DATASET;
    global CONST;

    node_num = 1;

    tracks_new = [];
    for i=1:length(tracks)
        pts = [tracks(i).Pos(:,1) tracks(i).Pos(:,2) tracks(i).Pos(:,3)];
        st = 1;
        fn = st;

        while(st < size(pts, 1))

            if (size(pts, 1) - st + 1 < 1)
                break;
            end
            fn = fn + 1;

            xs = pts(st:fn, 1);
            ys = pts(st:fn, 2);
            zs = pts(st:fn, 3);

            [~,~,~,max_error] = Parabolic_fit(xs, ys, zs, st:fn, [], 9810, fps);
            if (max_error > err_lim && min(zs) >= -CONST.GroundLevel)
                [~,~,~,max_error] = Parabolic_fit(xs, ys, zs, st:fn, [], 0, fps);
            end
             if (max_error > err_lim && fn - st + 1 < 1)
                 st = st + 1;
                 fn = st;
                 continue;
             end

             if (max_error < err_lim && fn ~= size(pts, 1))
                 continue;
             end

             if (max_error > err_lim)
                 fn = fn - 1;
             end

             if (fn - st + 1 < 1)
                 st = fn + 1;
                 continue;
             end

            track = FORMAT.TRACK;
            track.T = tracks(i).T(st:fn);
            track.W = tracks(i).W(st:fn);

            x = tracks(i).Pos(st:fn, 1);
            y = tracks(i).Pos(st:fn, 2);
            z = tracks(i).Pos(st:fn, 3);
            t = st:fn;
            [nx, ny, nz, err] = Parabolic_fit(x, y, z, t, t, 9810, DATASET.Fps);
            if (err > err_lim && min(z) > -CONST.GroundLevel)
                [nx, ny, nz] = Parabolic_fit(x, y, z, t, t, 0, DATASET.Fps);
            end
            nx = x'; ny = y'; nz = z';

            track.Pos = [nx' ny' nz'];
            track.Node = node_num:(node_num + length(t) - 1);
            node_num = node_num + length(t);
            tracks_new = [tracks_new track];
            st = fn + 1;
            fn = st;

        end
    end
end

