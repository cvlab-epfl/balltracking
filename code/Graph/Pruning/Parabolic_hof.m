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

function [ tracks ] = Parabolic_hof(ball_detections, max_dx, max_dy, max_dz)

    global FORMAT;
    global CONST;
    tracks = repmat(FORMAT.TRACK, 10000, 1);
    tc = 0;

    for t=1:length(ball_detections)
        x = ball_detections(t).Pos(:,1);
        y = ball_detections(t).Pos(:,2);
        z = ball_detections(t).Pos(:,3);
        w = ball_detections(t).W;
        u = zeros(1, length(x));
        for i=1:tc
            if (tracks(i).Space == -1)
                continue;
            end
            idx = [];
            tlen = tracks(i).tmp;
            for j=1:length(x)
                if (u(j) == 1)
                    continue;
                end
                dx = abs(x(j) - tracks(i).Pos(tlen,1));
                dy = abs(y(j) - tracks(i).Pos(tlen,2));
                dz = abs(z(j) - tracks(i).Pos(tlen,3));
                if (dx > max_dx || dy > max_dy || dz > max_dz)
                    continue;
                end
                idx = [idx j];
            end
            if (~isempty(idx))
                [~,pos] = max(w(idx));
                idx = idx(pos);

                u(idx) = 1;
                tracks(i).tmp = tlen + 1;
                tracks(i).Pos(tlen + 1,:) = [x(idx) y(idx) z(idx)];
                tracks(i).W(tlen + 1) = w(idx);
                tracks(i).T(tlen + 1) = t;
            else
                tracks(i).Space = -1;
            end
        end
        for j=1:length(x)
            if (u(j) == 0)
                tc = tc + 1;
                tracks(tc).Pos = zeros(5000, 3);
                tracks(tc).tmp = 1;
                tracks(tc).X = zeros(5000, 1);
                tracks(tc).Y = zeros(5000, 1);
                tracks(tc).Z = zeros(5000, 1);
                tracks(tc).W = zeros(5000, 1);
                tracks(tc).T = zeros(5000, 1);

                tracks(tc).Pos(1,:) = [x(j) y(j) z(j)];
                tracks(tc).W(1) = w(j);
                tracks(tc).T(1) = t;
            end
        end
    end

    tracks = tracks(1:tc);
    for i=1:tc
        tlen = tracks(i).tmp;
        tracks(i).Pos = tracks(i).Pos(1:tlen,:);
        tracks(i).X = tracks(i).X(1:tlen);
        tracks(i).Y = tracks(i).Y(1:tlen);
        tracks(i).Z = tracks(i).Z(1:tlen);
        tracks(i).W = tracks(i).W(1:tlen);
        tracks(i).T = tracks(i).T(1:tlen);
        tracks(i).Space = CONST.NoBall;
    end
end
