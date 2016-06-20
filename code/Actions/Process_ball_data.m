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

% Create ball occupancy map
BOM = detections_to_pom(ball_detections, DATASET.Grid.X,...
                        DATASET.Grid.Y, DATASET.Grid.Z);

%% Filter double bounding box detection
% If a detection appears in such a location that is covered by several
% people detection peaks, we could not have seen such a location, therefore
% remove such a detection.
ball_detections = remove_double_bounding_box_detections(ball_detections, ...
people_tracks_ksp);

ball_f = ball_detections;

% Obtain tracklets, either with simple connector, or using KSP
if (KSP.Ball.UseKSP == 0)
  ball_tracks = Parabolic_hof(ball_f, ...
  DATASET.Loc.X(2) - DATASET.Loc.X(1),...
  DATASET.Loc.Y(2) - DATASET.Loc.Y(1),...
  DATASET.Loc.Z(2) - DATASET.Loc.Z(1));
else
  ball_tracks = run_ksp(BOM, DATASET.Grid.X, DATASET.Grid.Y, DATASET.Grid.Z,...
     CONFIG.Frames, KSP.Ball.BatchSize, KSP.Ball.Depth,...
     KSP.Binary, KSP.Ball.MinPathCost, 1);
end

% Keep tracklets of size at least 2
ball_tracks = ball_tracks(cellfun('length',{ball_tracks.W}) > 2);



% Break tracklets into linear / parabolic segments
ERROR = OPTVARS.ContinuousDiscreteDelta;
ball_tracks_linear = delineate_tracklets(ball_tracks, ERROR, DATASET.Fps);

[xs, ys, zs, ts, is] = tracks_apriori([], [], [], [], [],...
ball_tracks_linear, 9810, DATASET.Fps, ERROR, DATASET.Fps);

% Hypothesize about extensions of single tracklets
apriori_tracks = repmat(FORMAT.TRACK, length(xs), 1);
node_cnt = 0;
tc = 0;
for i=1:length(xs)
    if (isempty(xs{i})) continue; end
    bad = 0;
    for j=1:(i-1)
        if (length(intersect(is{j}, is{i})) == length(is{i}))
            bad = 1;
            break;
        end
    end
    if (bad == 1)
        continue;
    end
    track = FORMAT.TRACK;
    myG = 9810;
    if (min(zs{i}) > -CONST.GroundLevel)
        myG = 0;
    end
    [x,y,z,~] = Parabolic_fit(xs{i}, ys{i}, zs{i}, ts{i}, 1:length(CONFIG.Frames),...
    myG, DATASET.Fps);
    track = check_track(x,y,z,min(ts{i}),max(ts{i}),0);
    if (isempty(track.W))
        continue;
    end
    [x,y,z,~] = Parabolic_fit(xs{i}, ys{i}, zs{i}, ts{i}, 1:length(CONFIG.Frames),...
    myG, DATASET.Fps);
    track = check_track(x,y,z,min(ts{i}),max(ts{i}),1);
    if (isempty(track.W))
        continue;
    end
    track.Node = (node_cnt + 1):(node_cnt + length(track.W));
    node_cnt = node_cnt + length(track.W);
    tc = tc + 1;
    apriori_tracks(tc) = track;
end

apriori_tracks = apriori_tracks(1:tc);
apriori_assoc = associate_detections(apriori_tracks, ball_detections,...
OPTVARS.ContinuousDiscreteDelta * 2);
ball_tracks_new = apriori_assoc;

% Hypothesize about connections between pairs of tracklets
pairwise_tracks = repmat(FORMAT.TRACK, 1, tc * tc);
tc2 = 0;

TR = KSP.Ball.MaxJoinLimit;

lowlim = CONST.GroundLevel;

for i=1:length(ball_tracks)
    for j=1:tc
        fi = ball_tracks(i).T(end);
        sj = apriori_tracks(j).T(1);
        if (fi < sj && sj - fi <= TR * DATASET.Fps && length(ball_tracks(i).W) >= 2)

            if (apriori_tracks(j).Pos(1, 3) < -lowlim)
                myG = 9810;
            else
                myG = 0;
            end
            [x,y,z,~] = Parabolic_fit([ball_tracks(i).Pos(end,1);...
                                       apriori_tracks(j).Pos(1,1)],...
                                      [ball_tracks(i).Pos(end,2);...
                                       apriori_tracks(j).Pos(1,2)],...
                                      [ball_tracks(i).Pos(end,3);...
                                       apriori_tracks(j).Pos(1,3)],...
                                      [fi sj], 1:length(CONFIG.Frames), myG,...
                                      DATASET.Fps);
             track = check_track(x,y,z,fi,sj,0);
             if (isempty(track.W))
                 continue;
             end
             track.Node = [(node_cnt + 1):(node_cnt + length(track.W))];
             node_cnt = node_cnt + length(track.W);
             tc2 = tc2 + 1;
             pairwise_tracks(tc2) = track;
        end
    end
    mlen = 5;
    for j=1:length(ball_tracks)
        fi = ball_tracks(i).T(end);
        sj = ball_tracks(j).T(1);
        if (fi < sj && sj - fi <= TR * DATASET.Fps &&...
          (length(ball_tracks(i).W) > mlen || length(ball_tracks(j).W) > mlen))
            if (ball_tracks(j).Pos(1, 3) < -lowlim)
                myG = 9810;
            else
                myG = 0;
            end
            [x,y,z,~] = Parabolic_fit([ball_tracks(i).Pos(end,1);...
                                       ball_tracks(j).Pos(1,1)],...
                                      [ball_tracks(i).Pos(end,2);...
                                       ball_tracks(j).Pos(1,2)],...
                                      [ball_tracks(i).Pos(end,3);...
                                       ball_tracks(j).Pos(1,3)],...
                                      [fi sj], 1:length(CONFIG.Frames), myG,...
                                      DATASET.Fps);
             track = check_track(x,y,z,fi,sj,0);
             if (isempty(track.W))
                 continue;
             end
             track.Node = [(node_cnt + 1):(node_cnt + length(track.W))];
             node_cnt = node_cnt + length(track.W);
             tc2 = tc2 + 1;
             pairwise_tracks(tc2) = track;
        end
    end
end
pairwise_tracks = pairwise_tracks(1:tc2);

% For each newly formed hypothesis, find closest ball detection
% and associate hypothesized location with detection
% With margin of 2 x reconstruction error
pairwise_assoc = associate_detections(pairwise_tracks, ball_detections,...
OPTVARS.ContinuousDiscreteDelta * 2);
ball_tracks_new = [apriori_assoc' pairwise_assoc];
