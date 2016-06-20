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

function [ NodeSpace, tracks ] = add_tracklets_2(tracks, space_id, frame_idx, depth, depth_z)

global DATASET;
global CONST;

fprintf('Creating tracklets:\n');

node_cnt = 0;

for i=1:length(tracks)
   if (isempty(tracks(i).Node))
        tracks(i).Node = zeros(size(tracks(i).Z));
    end
   node_cnt = max(node_cnt, max(tracks(i).Node));
%   disp([i node_cnt]);
end

for i=1:length(tracks)
    for j=1:length(tracks(i).Node)
        if (tracks(i).Node(j) == 0)
            node_cnt = node_cnt + 1;
            tracks(i).Node(j) = node_cnt;
        end
    end
end

remap = zeros(1, node_cnt);
x = []; y = []; z = []; t = []; w = []; pn = [];

global GRAPH;

node_cnt = GRAPH.Node_cnt + 1;
for i=1:length(tracks)
    for j=1:length(tracks(i).Node)
       if (remap(tracks(i).Node(j)) == 0)
            remap(tracks(i).Node(j)) = node_cnt;
            node_cnt = node_cnt + 1;
            x = [x tracks(i).Pos(j,1)];
            y = [y tracks(i).Pos(j,2)];
            z = [z tracks(i).Pos(j,3)];
            t = [t tracks(i).T(j)];
            w = [w tracks(i).W(j)];
            if (isfield(tracks(i), 'PeopleNode') && ~isempty(tracks(i).PeopleNode))
                pn = [pn tracks(i).PeopleNode(j)];
            else
                pn = [pn 0];
            end
        end
        tracks(i).Node(j) = remap(tracks(i).Node(j));
    end
end

NodeSpace = add_nodes_2(x, y, z, t, w, pn, space_id, length(frame_idx));

for i=1:length(tracks)
    for j=1:(length(tracks(i).T))


        x1 = tracks(i).Pos(j, 1);
        y1 = tracks(i).Pos(j, 2);
        z1 = tracks(i).Pos(j, 3);
        t = tracks(i).T(j);
        A = tracks(i).Node(j);

        if (t == 1|| (space_id == CONST.People &&...
                (tracks(i).X(j) == 1 || tracks(i).X(j) == DATASET.Grid.X ||...
                 tracks(i).Y(j) == 1 || tracks(i).Y(j) == DATASET.Grid.Y)))
            add_edge(1, A);
        end

        if (t == length(frame_idx) || (space_id == CONST.People &&...
                (tracks(i).X(j) == 1 || tracks(i).X(j) == DATASET.Grid.X ||...
                 tracks(i).Y(j) == 1 || tracks(i).Y(j) == DATASET.Grid.Y)))
            add_edge(A, 2);
        end

        if (j == length(tracks(i).T))
            continue;
        end

        x2 = tracks(i).Pos(j + 1, 1);
        y2 = tracks(i).Pos(j + 1, 2);
        z2 = tracks(i).Pos(j + 1, 3);
        B = tracks(i).Node(j + 1);

        if (abs(x1 - x2) <= depth && abs(y1 - y2) <= depth && abs(z1 - z2) <= depth_z)
            add_edge(A, B);
        else
        %    disp('error');
        end

    end
end

fprintf('Done: New #of edges %d\n', GRAPH.Edge_cnt);

end

