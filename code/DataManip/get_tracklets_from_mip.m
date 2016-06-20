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

function [ tracks, ball_pos_cont ] = get_tracklets_from_mip( result )
    global GRAPH;
    global FORMAT;
    global CONST;

    for i=1:GRAPH.Edge_cnt
        GRAPH.Edges(i).Marker = result.x(GRAPH.Edges(i).VarId);
    end

    total_tracks = 0;
    for j=1:length(GRAPH.Nodes(1).Outgoing)
        total_tracks = total_tracks + GRAPH.Edges(GRAPH.Nodes(1).Outgoing(j)).Marker;
    end

    tracks = repmat(FORMAT.TRACK, 1, 1000);
    total_tracks = 0;
    for j=1:length(GRAPH.Nodes(1).Outgoing)
        if (GRAPH.Edges(GRAPH.Nodes(1).Outgoing(j)).Marker > 0)

            %e_cost = GRAPH.Edges(GRAPH.Nodes(1).Outgoing(j)).W;
            %e_cost = GRAPH.Nodes(GRAPH.Edges(GRAPH.Nodes(1).Outgoing(j)).B).local_Px_z;
            e_cost = 1;
            tmp    = GRAPH.Edges(GRAPH.Nodes(1).Outgoing(j)).tmp;

            cur = GRAPH.Edges(GRAPH.Nodes(1).Outgoing(j)).B;
            GRAPH.Edges(GRAPH.Nodes(1).Outgoing(j)).Marker = 0;
            total_tracks = total_tracks + 1;
            tracks(total_tracks).Space = GRAPH.Nodes(cur).Space;
            while(cur ~= 2)

                tracks(total_tracks).T = [tracks(total_tracks).T GRAPH.Nodes(cur).Time];
                tracks(total_tracks).X = [tracks(total_tracks).X GRAPH.Nodes(cur).X];
                tracks(total_tracks).Y = [tracks(total_tracks).Y GRAPH.Nodes(cur).Y];
                tracks(total_tracks).Z = [tracks(total_tracks).Z GRAPH.Nodes(cur).Z];
                tracks(total_tracks).Pos = [tracks(total_tracks).Pos; GRAPH.Nodes(cur).Pos];

                tracks(total_tracks).Cost = [tracks(total_tracks).Cost e_cost];

                tracks(total_tracks).tmp = [tracks(total_tracks).tmp '!' tmp];

                upd = 0;
                for i=1:length(GRAPH.Nodes(cur).Outgoing)
                    if (GRAPH.Edges(GRAPH.Nodes(cur).Outgoing(i)).Marker > 0.5)
                        GRAPH.Edges(GRAPH.Nodes(cur).Outgoing(i)).Marker = 0;
                        e_cost = cur;
                        %e_cost = GRAPH.Edges(GRAPH.Nodes(cur).Outgoing(i)).W;
                        %e_cost = GRAPH.Nodes(GRAPH.Edges(GRAPH.Nodes(cur).Outgoing(i)).B).local_Px_z;
                        tmp    = GRAPH.Edges(GRAPH.Nodes(cur).Outgoing(i)).tmp;
                        cur = GRAPH.Edges(GRAPH.Nodes(cur).Outgoing(i)).B;
                        upd = 1;
                        break;
                    end
                end
                if (upd == 0)
                    break;
                end
                if (cur ~= 2 && GRAPH.Nodes(cur).Space ~= tracks(total_tracks).Space)
                    total_tracks = total_tracks + 1;
                     tracks(total_tracks).Space = GRAPH.Nodes(cur).Space;
                end
            end
        end
    end
    tracks = tracks(1:total_tracks);

    global CONFIG;
    global OPT;

    time_idx = CONFIG.Frames;

    ball_pos_cont = repmat(FORMAT.DETECTION, 1, length(time_idx));

    for i=1:length(time_idx)
        var_id = OPT.Var_cnt - 3 * (length(time_idx) - i + 1);
        if (var_id > length(result) || var_id <= 0)
            continue;
        end
        ball_pos_cont(i).Pos = [ball_pos_cont(i).Pos;...
            [result.x(var_id + 1)
            result.x(var_id + 2)
            result.x(var_id + 3)]'];
        ball_pos_cont(i).W = [ball_pos_cont(i).W 1];
        ball_pos_cont(i).T = i;
    end
end

