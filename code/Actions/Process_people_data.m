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

% Read people occupancy map (POM) data
   POM = read_pom('data/apidis_pom/%d.pom',DATASET.Grid.X, DATASET.Grid.Y,...
   DATASET.Grid.Z, CONFIG.Frames, 4);

if (KSP.People.UseTracklets == 1)
  % Compute tracklets for people
  people_tracks_ksp = run_ksp(POM, DATASET.Grid.X, DATASET.Grid.Y, 1,...
     CONFIG.Frames, KSP.People.BatchSize, KSP.People.Depth, KSP.Binary,...
     KSP.People.MinPathCost, 1);

  % Compute possible connections between tracklets
  join_tracks = generate_tracklet_ksp(people_tracks_ksp, KSP.People.MaxJoinLimit,...
                                     POM, 1, 0, CONFIG.Frames);

  % Tracklets and possible connections form hypotheses about people locations
  people_tracks = [people_tracks_ksp join_tracks];
  for i=1:length(people_tracks)
    if (isempty(people_tracks(i).Pos))
      people_tracks(i).Pos = [...
      DATASET.Loc.X(people_tracks(i).X)'...
      DATASET.Loc.Y(people_tracks(i).Y)'...
      zeros(length(people_tracks(i).T), 1)];

    end
    % +5 - safe precaution, not to overwrite Nodes 1 and 2
    % Namely source and sink
    people_tracks(i).Node = ...
    people_tracks(i).T * DATASET.Grid.X * DATASET.Grid.Y + ...
    people_tracks(i).X * DATASET.Grid.Y + ...
    people_tracks(i).Y + 5;
  end
else
  people_tracks_ksp = run_ksp(POM, DATASET.Grid.X, DATASET.Grid.Y, 1,...
     CONFIG.Frames, length(CONFIG.Frames), KSP.People.Depth, KSP.Binary,...
     KSP.People.MinPathCost, 0);
  people_tracks = people_tracks_ksp;
end

for i=1:length(people_tracks)
  for j=1:length(people_tracks(i).T)
    ct = people_tracks(i).T(j);
    pos = find(POM(ct).X == people_tracks(i).X(j) &...
               POM(ct).Y == people_tracks(i).Y(j));
    people_tracks(i).W(j) = POM(ct).W(pos);
  end
end

