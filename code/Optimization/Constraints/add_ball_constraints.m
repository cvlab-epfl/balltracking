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

function [ ] = add_ball_constraints(PeopleSpace, PossessionSpaces )
    global GRAPH;
    global OPT;
    global CONST;
    global CONFIG;

    time_idx = CONFIG.Frames;

    Constr_old = OPT.Constr_cnt;

    for i=1:length(time_idx)
        OPT.Constr_cnt = OPT.Constr_cnt + 1;
        OPT.Constr_sense(OPT.Constr_cnt) = '=';
        OPT.Constr_rhs(OPT.Constr_cnt) = 1;
        OPT.Constr_name{OPT.Constr_cnt} = sprintf('Ball_uniqueness_frame_%d', i);
    end


    for i=1:GRAPH.Edge_cnt
        if (GRAPH.Nodes(GRAPH.Edges(i).B).Space == CONST.Sink)
            continue;
        end
        if (GRAPH.Nodes(GRAPH.Edges(i).B).Space == CONST.People)
            continue;
        end
        OPT.Coef_cnt = OPT.Coef_cnt + 1;
        OPT.Constr_id(OPT.Coef_cnt) = Constr_old + GRAPH.Nodes(GRAPH.Edges(i).B).Time;
        OPT.Var_id(OPT.Coef_cnt) = GRAPH.Edges(i).VarId;
        OPT.Coefs(OPT.Coef_cnt) = 1;
    end

    for t=1:length(PeopleSpace)
        for n=PeopleSpace{t}
            OPT.Constr_cnt = OPT.Constr_cnt + 1;
            OPT.Constr_sense(OPT.Constr_cnt) = '>';
            OPT.Constr_rhs(OPT.Constr_cnt) = 0;
            OPT.Constr_name{OPT.Constr_cnt} = sprintf('Possession_constraint_possession_node_%d', n);
            GRAPH.Nodes(n).tmp = OPT.Constr_cnt;

             for j=1:length(GRAPH.Nodes(n).Incoming)
                OPT.Coef_cnt = OPT.Coef_cnt + 1;
                OPT.Constr_id(OPT.Coef_cnt) = OPT.Constr_cnt;
                OPT.Var_id(OPT.Coef_cnt) = GRAPH.Edges(GRAPH.Nodes(n).Incoming(j)).VarId;
                OPT.Coefs(OPT.Coef_cnt) = +1;
             end
        end
    end

    for l=1:length(PossessionSpaces)
        for t=1:length(PossessionSpaces{l})
            for n = PossessionSpaces{l}{t}
             %   disp([l t n]);
                for j=1:length(GRAPH.Nodes(n).Incoming)
                    OPT.Coef_cnt = OPT.Coef_cnt + 1;
                    OPT.Constr_id(OPT.Coef_cnt) =...
                    GRAPH.Nodes(GRAPH.Nodes(n).PeopleNode).tmp;
                    OPT.Var_id(OPT.Coef_cnt) =...
                    GRAPH.Edges(GRAPH.Nodes(n).Incoming(j)).VarId;
                    OPT.Coefs(OPT.Coef_cnt) = -1;
                end
            end
        end
    end

end

