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

function [ ] = add_interspace_edges_2( spaces,  space_names, depth, depth_z, baskets)
    global CONST;
    global GRAPH;
    global DATASET;
    global CONFIG;

    fprintf('Adding interspace edges:\n');

    for a=1:length(spaces)
        gT = length(spaces{a});
        for t=1:(gT - 1)
            n1 = spaces{a}{t};
            x1 = zeros(1, length(n1));
            y1 = zeros(1, length(n1));
            z1 = zeros(1, length(n1));
            for i = 1:length(spaces{a}{t})
                x1(i) = GRAPH.Nodes(spaces{a}{t}(i)).X;
                y1(i) = GRAPH.Nodes(spaces{a}{t}(i)).Y;
                z1(i) = GRAPH.Nodes(spaces{a}{t}(i)).Z;
            end
            for b=1:length(spaces)
                % Forbidden transitions - different modes of flying
                if (space_names{a} ~= CONST.Possession &&...
                    space_names{a} ~= CONST.NoBall &&...
                    space_names{b} ~= CONST.Possession &&...
                    space_names{b} ~= CONST.NoBall &&...
                    space_names{a} ~= space_names{b})
                  continue;
                end

                n2 = spaces{b}{t+1};
                x2 = zeros(1, length(n2));
                y2 = zeros(1, length(n2));
                z2 = zeros(1, length(n2));
                for i = 1:length(spaces{b}{t+1})
                    x2(i) = GRAPH.Nodes(spaces{b}{t+1}(i)).X;
                    y2(i) = GRAPH.Nodes(spaces{b}{t+1}(i)).Y;
                    z2(i) = GRAPH.Nodes(spaces{b}{t+1}(i)).Z;
                end

                % None -> border
                if (space_names{a} == CONST.NoBall)
                    for i=1:length(n1)
                        for j=1:length(n2)
                            if (x2(j) <= depth || x2(j) + depth >= DATASET.Court.X || y2(j) <= depth || y2(j) + depth >= DATASET.Court.Y)
                                add_edge(n1(i), n2(j));
                            end
                        end
                    end
                    continue;
                end

                % Border -> None
                if (space_names{b} == CONST.NoBall)
                    for i=1:length(n1)
                        for j=1:length(n2)
                            if (x1(i) <= depth || x1(i) + depth >= DATASET.Court.X || y1(i) <= depth || y1(i) + depth >= DATASET.Court.Y)
                                add_edge(n1(i), n2(j));
                            end
                        end
                    end
                    continue;
                end

                pairs = find_close_nodes(x1, y1, z1, n1, x2, y2, z2, n2, [depth depth_z length(n1) length(n2)]);

                for i=1:2:length(pairs)
                    % Special conditions when edges within the same space
                    % are allowed because physical constraints needn't hold
                    % Even when these edges are not in
                    can_join = 1;
                    if (a == b)
                        can_join = 0;
                        if (GRAPH.Nodes(pairs(i)).Pos(:,3) > -CONST.GroundLevel || ...
                            GRAPH.Nodes(pairs(i + 1)).Pos(:,3) > -CONST.GroundLevel)

                        end
                        for l=1:size(baskets, 1)
                            if (...
                              GRAPH.Nodes(pairs(i)).Pos(1) >= baskets(l, 1) &&...
                              GRAPH.Nodes(pairs(i)).Pos(1) <= baskets(l, 4) &&...
                              GRAPH.Nodes(pairs(i)).Pos(2) >= baskets(l, 2) &&...
                              GRAPH.Nodes(pairs(i)).Pos(2) <= baskets(l, 5) &&...
                              GRAPH.Nodes(pairs(i)).Pos(3) >= baskets(l, 3) &&...
                              GRAPH.Nodes(pairs(i)).Pos(3) <= baskets(l, 6))
                                can_join = 1;
                            end
                        end
                    end
                    if (can_join)
                        add_edge(pairs(i), pairs(i + 1));
                    end
                end
            end
        end
        %fprintf('\n');
    end

    fprintf('Done: new # of edges: %d\n', GRAPH.Edge_cnt);
    %disp(parts);
end

