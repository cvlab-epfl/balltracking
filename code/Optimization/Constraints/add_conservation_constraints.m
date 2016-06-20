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

function [ ] = add_conservation_constraints( )

    global GRAPH;
    global OPT;
    global CONST;


    for i=1:GRAPH.Edge_cnt
        OPT.Var_cnt = OPT.Var_cnt + 1;
        OPT.Var_type(OPT.Var_cnt) = 'B';
        OPT.Var_name{OPT.Var_cnt} = sprintf('Edge_%d', i);
        GRAPH.Edges(i).VarId = OPT.Var_cnt;
    end

    % Add flow conservation constraints (# entering = # exiting)
    for i=3:GRAPH.Node_cnt
        OPT.Constr_cnt = OPT.Constr_cnt + 1;
        OPT.Constr_name{OPT.Constr_cnt} = sprintf('Node_%d_flow_conservation', i);
        OPT.Constr_sense(OPT.Constr_cnt) = '=';
        OPT.Constr_rhs(OPT.Constr_cnt) = 0;

        for j=1:length(GRAPH.Nodes(i).Outgoing)
            OPT.Coef_cnt = OPT.Coef_cnt + 1;
            OPT.Constr_id(OPT.Coef_cnt) = OPT.Constr_cnt;
            OPT.Var_id(OPT.Coef_cnt) = GRAPH.Edges(GRAPH.Nodes(i).Outgoing(j)).VarId;
            OPT.Coefs(OPT.Coef_cnt) = +1;
        end

        for j=1:length(GRAPH.Nodes(i).Incoming)
            OPT.Coef_cnt = OPT.Coef_cnt + 1;
            OPT.Constr_id(OPT.Coef_cnt) = OPT.Constr_cnt;
            OPT.Var_id(OPT.Coef_cnt) = GRAPH.Edges(GRAPH.Nodes(i).Incoming(j)).VarId;
            OPT.Coefs(OPT.Coef_cnt) = -1;
        end
    end


    % Add spatial exclusion constraints (At most one person enters the
    % location)
    for i=3:GRAPH.Node_cnt
        OPT.Constr_cnt = OPT.Constr_cnt + 1;
        OPT.Constr_name{OPT.Constr_cnt} = sprintf('Node_%d_spatial_exclusion', i);
        OPT.Constr_sense(OPT.Constr_cnt) = '<';
        OPT.Constr_rhs(OPT.Constr_cnt) = 1;

        for j=1:length(GRAPH.Nodes(i).Incoming)
            OPT.Coef_cnt = OPT.Coef_cnt + 1;
            OPT.Constr_id(OPT.Coef_cnt) = OPT.Constr_cnt;
            OPT.Var_id(OPT.Coef_cnt) = GRAPH.Edges(GRAPH.Nodes(i).Incoming(j)).VarId;
            OPT.Coefs(OPT.Coef_cnt) = +1;
        end
    end

    % Add new values to the objective function
    % We always assume that edge (i->j) corresponds to node j,
    % therefore we compute this on incoming edges
     for i=1:GRAPH.Edge_cnt
       if (GRAPH.Nodes(GRAPH.Edges(i).B).Space == CONST.Sink)
           continue;
       end
       var_id = GRAPH.Edges(i).VarId;
       OPT.Obj_function(var_id) = OPT.Obj_function(var_id) + GRAPH.Edges(i).W;
     end

end

