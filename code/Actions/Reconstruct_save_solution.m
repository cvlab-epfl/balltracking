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

%% Interpret
[final_tracks,ball_pos_cont] = get_tracklets_from_mip(result);
final_tracks_people = [];
final_tracks_ball = [];
for i=1:length(final_tracks)
    if (final_tracks(i).Space == CONST.People)
        if (isempty(final_tracks_people))
            final_tracks_people = final_tracks(i);
        else
            final_tracks_people = [final_tracks_people final_tracks(i)];
        end
    else
        if (isempty(final_tracks_ball))
            final_tracks_ball = final_tracks(i);
        else
            final_tracks_ball = [final_tracks_ball final_tracks(i)];
        end
    end
end

final_tracks_real = associate_detections(final_tracks_ball, ball_detections,...
OPTVARS.ContinuousDiscreteDelta * 2, 1);

final_tracks_det = tracks_to_detections(final_tracks_real);

fid = fopen(CONFIG.Output, 'w');
for t=1:length(CONFIG.Frames)
  cnt = 0;
  for j=1:length(final_tracks_people)
    if (sum(final_tracks_people(j).T == t) > 0)
      cnt = cnt + 1;
    end
  end

  fprintf(fid, '%d %0.3f %0.3f %0.3f %s %d',...
  CONFIG.Frames(t),...
  final_tracks_det(t).Pos(1),...
  final_tracks_det(t).Pos(2),...
  final_tracks_det(t).Pos(3),...
  'a' + final_tracks_det(t).Space - 1,...
  cnt);

  for j=1:length(final_tracks_people)
    pos = find(final_tracks_people(j).T == t);
    if (~isempty(pos))
      fprintf(fid, ' %d %0.3f %0.3f', j,...
      final_tracks_people(j).Pos(pos, 1),...
      final_tracks_people(j).Pos(pos, 2));
    end
  end
  fprintf(fid, '\n');

end
fclose(fid);
