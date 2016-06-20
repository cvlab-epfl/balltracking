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

create_graph_vars();

%% Create people graph & none ball graph

[PeopleSpace, people_tracks] =...
add_tracklets_2(people_tracks, CONST.People, CONFIG.Frames, 1e9, 0);

none_track = FORMAT.TRACK;
none_track.X = ones(1, length(CONFIG.Frames));

none_track.Y = ones(1, length(CONFIG.Frames));
none_track.Z = ones(1, length(CONFIG.Frames));
none_track.T = 1:length(CONFIG.Frames);
none_track.Pos = zeros(length(CONFIG.Frames), 3);
none_track.Space = CONST.NoBall;
none_track.W = zeros(1, length(CONFIG.Frames));
none_track.Node = 1:length(CONFIG.Frames);

[NoneSpace, none_track] = add_tracklets_2(none_track, CONST.NoBall, CONFIG.Frames, 0, 0);

%% Possession graph

possession_tracks = cell(0, 1);
for i=1:length(CONST.PossessionHeights)
  possession_tracks{i} = people_tracks;
end

possession_mids = -CONST.PossessionHeights;

dxy = CONST.PossessionVicinity + OPTVARS.ContinuousDiscreteDelta;
MODEL = load(CONFIG.TrainedModel);

global GRAPH;
for k = 1:length(possession_tracks)
   node_cnt = 1;
   for i=1:length(people_tracks)
      possession_tracks{k}(i).PeopleNode = zeros(1, length(people_tracks(i).T));
      for j=1:length(people_tracks(i).T)
        px = people_tracks(i).Pos(j, 1);
        py = people_tracks(i).Pos(j, 2);
        possession_tracks{k}(i).Node(j) = node_cnt; node_cnt = node_cnt + 1;
        possession_tracks{k}(i).Pos(j,:) = [px py possession_mids(k)];
        possession_tracks{k}(i).W(j) = 0;
        possession_tracks{k}(i).Space = CONST.Possession;
        possession_tracks{k}(i).PeopleNode(j) = people_tracks(i).Node(j);

        for l = 1:length(ball_detections(people_tracks(i).T(j)).W)
              bx = ball_detections(people_tracks(i).T(j)).Pos(l, 1);
              by = ball_detections(people_tracks(i).T(j)).Pos(l, 2);
              bz = ball_detections(people_tracks(i).T(j)).Pos(l, 3);
              bw = ball_detections(people_tracks(i).T(j)).W(l);
              if (abs(bx - px) < dxy && abs(by - py) < dxy &&...
                  abs(bz - possession_mids(k)) < max(MODEL.Max_dz) &&...
                  bw > possession_tracks{k}(i).W(j))
                possession_tracks{k}(i).W(j) = bw;
                possession_tracks{k}(i).Pos(j,:) = [bx by bz];
              end
         end
     end
  end
end


list_of_spaces = cell(0, 1);
list_of_names = cell(0, 1);
for k=1:length(possession_tracks)
  [possessionSpace, possessionTracks] = ...
  add_tracklets_2(possession_tracks{k},...
  CONST.Possession, CONFIG.Frames, 1e9, max(MODEL.Max_dz));

  list_of_spaces{length(list_of_spaces) + 1} = possessionSpace;
  list_of_names{length(list_of_names) + 1} = CONST.Possession;

  possession_tracks{k} = possessionTracks;
end

%% Create ball graph

for space = CONST.StatesForClassifier
  if (space == CONST.Possession)
    continue;
  end
[FlyingSpace, flying_tracks] = add_tracklets_2(ball_tracks_new, space,...
   CONFIG.Frames,...
   MODEL.Max_dxy(space) + OPTVARS.ContinuousDiscreteDelta,...
   MODEL.Max_dz(space) + OPTVARS.ContinuousDiscreteDelta);
  list_of_spaces{length(list_of_spaces) + 1} = FlyingSpace;
  list_of_names{length(list_of_names) + 1} = space;
end

list_of_spaces{length(list_of_spaces) + 1} = NoneSpace;
list_of_names{length(list_of_names) + 1} = CONST.NoBall;

% Create edges between nodes from different spaces

 add_interspace_edges_2(...
        list_of_spaces,...
        list_of_names,...
        CONST.PossessionVicinity, CONST.PossessionVicinity,...
        DATASET.baskets);

% Compute edge costs

compute_edge_costs_2(POM, CONST.MIN_OCCUR, CONST.MAX_OCCUR, NoneSpace);
