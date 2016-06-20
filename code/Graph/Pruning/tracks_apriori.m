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

function [ xs, ys, zs, ts, iss ] = tracks_apriori( x, y, z, t, is, tracks, G,...
interval_frames, err, fps )

    global CONST;

    last_t = max(t);
    xs = cell(0, 1);
    ys = cell(0, 1);
    zs = cell(0, 1);
    ts = cell(0, 1);
    iss = cell(0,1);
    for i = 1:length(tracks)
       if (isempty(t) ||...
           (tracks(i).T(1) > last_t && tracks(i).T(1) < last_t + interval_frames))
            nx = [x; tracks(i).Pos(:,1)];
            ny = [y; tracks(i).Pos(:,2)];
            nz = [z; tracks(i).Pos(:,3)];
            nt = [t tracks(i).T(:)'];
            ns = [is i];
            myG = G;
            if (min(nz) > -CONST.GroundLevel) myG = 0; end
            [~,~,~,me] = Parabolic_fit(nx, ny, nz, nt, nt, myG, fps);
            track = check_track(nx, ny, nz, 1, length(nt), 0);
            if (me < err && ~isempty(track.W))
                [xt, yt, zt, tt, it] = tracks_apriori(nx, ny, nz, nt, ns,...
                                    tracks, G, interval_frames, err, fps);
                for j=1:length(xt)
                    xs{length(xs) + 1} = xt{j};
                    ys{length(ys) + 1} = yt{j};
                    zs{length(zs) + 1} = zt{j};
                    ts{length(ts) + 1} = tt{j};
                    iss{length(iss) + 1} = it{j};
                end
                if (~isempty(t))
                    break;
                end
            end
        end
    end
    if (isempty(xs))
        xs{1} = x;
        ys{1} = y;
        zs{1} = z;
        ts{1} = t;
        iss{1} = is;
    end
end

