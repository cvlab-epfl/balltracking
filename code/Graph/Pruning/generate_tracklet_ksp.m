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

function [ tracks_new ] = generate_tracklet_ksp( tracks, max_fill, POM, depth, depth_ort, time_idx )


global FORMAT;

POM_grid = pom_to_grid(POM);

tracks_new = tracks;

add_tr = repmat(FORMAT.TRACK, 1, length(tracks) * length(tracks));
ptr = 0;

for i=1:length(tracks)
    si = tracks(i).T(1);
    fi = tracks(i).T(end);

    prv = max(1, si - max_fill);
    nxt = min(fi + max_fill, length(time_idx));

    [x y z] = generate_viterbi_single(tracks(i).X(1),...
                                      tracks(i).Y(1),...
                                      tracks(i).Z(1),...
                                      si:-1:prv, POM, depth, depth_ort,...
                                      POM_grid);

    track = FORMAT.TRACK;
    track.T = prv:si;
    track.X = x;
    track.Y = y;
    track.Z = z;

    if ((length(x) < 2 || max(abs(x(2:end) - x(1:end-1))) < 2) && ...
        (length(y) < 2 || max(abs(y(2:end) - y(1:end-1))) < 2) && ...
        (length(z) < 2 || max(abs(z(2:end) - z(1:end-1))) < 2))
      ptr = ptr + 1;
      add_tr(ptr) = track;
    end

    [x y z] = generate_viterbi_single(tracks(i).X(end),...
                                      tracks(i).Y(end),...
                                      tracks(i).Z(end),...
                                      fi:nxt, POM, depth, depth_ort,...
                                      POM_grid);

    track.T = fi:nxt;
    track.X = x;
    track.Y = y;
    track.Z = z;

    if ((length(x) < 2 || max(abs(x(2:end) - x(1:end-1))) < 2) && ...
        (length(y) < 2 || max(abs(y(2:end) - y(1:end-1))) < 2) && ...
        (length(z) < 2 || max(abs(z(2:end) - z(1:end-1))) < 2))
      ptr = ptr + 1;
      add_tr(ptr) = track;
    end

end

for i=1:length(tracks)
    for j=1:length(tracks)
         si = tracks(i).T(1);
         fi = tracks(i).T(end);
         sj = tracks(j).T(1);
         fj = tracks(j).T(end);
         if (sj >= fi && sj - fi <= max_fill)
           disp([i,j]);
              [x,y,z] = generate_viterbi_double(...
              tracks(i).X(end), tracks(i).Y(end), tracks(i).Z(end),...
              tracks(j).X(1),   tracks(j).Y(1),   tracks(j).Z(1),...
              fi:sj, POM, depth, depth_ort, POM_grid);
              if (isempty(x))
                  continue;
              end
              x = x(:)'; y = y(:)'; z = z(:)';

              track = FORMAT.TRACK;
              track.T = fi:sj;
              track.X = x;
              track.Y = y;
              track.Z = z;

              if ((length(x) < 2 || max(abs(x(2:end) - x(1:end-1))) < 2) && ...
                  (length(y) < 2 || max(abs(y(2:end) - y(1:end-1))) < 2) && ...
                  (length(z) < 2 || max(abs(z(2:end) - z(1:end-1))) < 2))
                ptr = ptr + 1;
                add_tr(ptr) = track;
              end


    end
end

tracks_new = [tracks_new add_tr(1:ptr)];

end
