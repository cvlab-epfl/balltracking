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

function [ ] = add_physical_constraints( spaces_free, spaces_posses, baskets)

global CONFIG;
global GRAPH;
global OPT;
global DATASET;
global OPTVARS;
global CONST;

time_idx = CONFIG.Frames;

gZ = DATASET.Grid.Z;

old_var_cnt = OPT.Var_cnt;

for i=1:length(time_idx)
    OPT.Var_cnt = OPT.Var_cnt + 1;
    OPT.Var_type(OPT.Var_cnt) = 'C';
    OPT.Var_name{OPT.Var_cnt} = sprintf('X_%d', i);
    OPT.Var_cnt = OPT.Var_cnt + 1;
    OPT.Var_type(OPT.Var_cnt) = 'C';
    OPT.Var_name{OPT.Var_cnt} = sprintf('Y_%d', i);
    OPT.Var_cnt = OPT.Var_cnt + 1;
    OPT.Var_type(OPT.Var_cnt) = 'C';
    OPT.Var_name{OPT.Var_cnt} = sprintf('Z_%d', i);
end

DELTA = OPTVARS.ContinuousDiscreteDelta;

for t=1:length(time_idx)
    OPT.Constr_cnt = OPT.Constr_cnt + 6;
    constr_x_dn = OPT.Constr_cnt - 5;
    constr_y_dn = OPT.Constr_cnt - 4;
    constr_z_dn = OPT.Constr_cnt - 3;
    constr_x_up = OPT.Constr_cnt - 2;
    constr_y_up = OPT.Constr_cnt - 1;
    constr_z_up = OPT.Constr_cnt - 0;
    OPT.Constr_name{constr_x_dn} = sprintf('X_%d_lower_bound', t);
    OPT.Constr_name{constr_y_dn} = sprintf('Y_%d_lower_bound', t);
    OPT.Constr_name{constr_z_dn} = sprintf('Z_%d_lower_bound', t);
    OPT.Constr_name{constr_x_up} = sprintf('X_%d_upper_bound', t);
    OPT.Constr_name{constr_y_up} = sprintf('Y_%d_upper_bound', t);
    OPT.Constr_name{constr_z_up} = sprintf('Z_%d_upper_bound', t);
    for i=constr_x_dn:constr_z_dn
        OPT.Constr_sense(i) = '>';
        OPT.Constr_rhs(i) = -DELTA;
        OPT.Coef_cnt = OPT.Coef_cnt + 1;
        OPT.Constr_id(OPT.Coef_cnt) = i;
        OPT.Var_id(OPT.Coef_cnt) = old_var_cnt + (t-1) * 3 + 1 + i - constr_x_dn;
        OPT.Coefs(OPT.Coef_cnt) = 1;
    end
    for i=constr_x_up:constr_z_up
        OPT.Constr_sense(i) = '<';
        OPT.Constr_rhs(i) = +DELTA;
        OPT.Coef_cnt = OPT.Coef_cnt + 1;
        OPT.Constr_id(OPT.Coef_cnt) = i;
        OPT.Var_id(OPT.Coef_cnt) = old_var_cnt + (t-1) * 3 + 1 + i - constr_x_up;
        OPT.Coefs(OPT.Coef_cnt) = 1;
    end

    for s=1:length(spaces_free)+length(spaces_posses)
        if (s <= length(spaces_free))
            idx = spaces_free{s}{t};
        else
            idx = spaces_posses{s-length(spaces_free)}{t};
        end
        for i=1:length(idx)
           pos = GRAPH.Nodes(idx(i)).Pos;
            for j=1:length(GRAPH.Nodes(idx(i)).Incoming)
                var = GRAPH.Edges(GRAPH.Nodes(idx(i)).Incoming(j)).VarId;
                for k=constr_x_dn:constr_z_dn
                    OPT.Coef_cnt = OPT.Coef_cnt + 1;
                    OPT.Constr_id(OPT.Coef_cnt) = k;
                    OPT.Var_id(OPT.Coef_cnt) = var;
                    OPT.Coefs(OPT.Coef_cnt) = -1 * pos(1 + k - constr_x_dn);
                end
                for k=constr_x_up:constr_z_up
                    OPT.Coef_cnt = OPT.Coef_cnt + 1;
                    OPT.Constr_id(OPT.Coef_cnt) = k;
                    OPT.Var_id(OPT.Coef_cnt) = var;
                    OPT.Coefs(OPT.Coef_cnt) = -1 * pos(1 + k - constr_x_up);
                end
            end
        end
    end
end

fps = DATASET.Fps;
% |X_(t+2) - 2X_(t+1) + X_(t) - (0,0,G/fps^2)| <= (3 - sum_t..t+2 F + H) * M
%
% 1. -M + (0,0,G\fps^2) <= X_(t+2) - 2X_(t+1) + X_(t) - (sum_t..t+2 F + H) * M
% 2. X_(t+2) - 2X_(t+1) + X_(t) + sum_t..t_2 (F+H) * M <= M + (0,0,G\fps^2)
%


M = OPTVARS.LargeM;

for t=1:(length(time_idx)-2)
    OPT.Constr_cnt = OPT.Constr_cnt + 6;
    constr_x_dn = OPT.Constr_cnt - 5;
    constr_y_dn = OPT.Constr_cnt - 4;
    constr_z_dn = OPT.Constr_cnt - 3;
    constr_x_up = OPT.Constr_cnt - 2;
    constr_y_up = OPT.Constr_cnt - 1;
    constr_z_up = OPT.Constr_cnt - 0;
    OPT.Constr_name{constr_x_dn} = sprintf('X_%d_accel_lower_bound', t);
    OPT.Constr_name{constr_y_dn} = sprintf('Y_%d_accel_lower_bound', t);
    OPT.Constr_name{constr_z_dn} = sprintf('Z_%d_accel_lower_bound', t);
    OPT.Constr_name{constr_x_up} = sprintf('X_%d_accel_upper_bound', t);
    OPT.Constr_name{constr_y_up} = sprintf('Y_%d_accel_upper_bound', t);
    OPT.Constr_name{constr_z_up} = sprintf('Z_%d_accel_upper_bound', t);
    for i=constr_x_dn:constr_z_dn
        OPT.Constr_sense(i) = '>';
        OPT.Constr_rhs(i) = -M * 3;
        if (i == constr_z_dn)
            OPT.Constr_rhs(i) = OPT.Constr_rhs(i) + 9810 / fps / fps;
        end
        OPT.Coef_cnt = OPT.Coef_cnt + 1;
        OPT.Constr_id(OPT.Coef_cnt) = i;
        OPT.Var_id(OPT.Coef_cnt) = old_var_cnt + (t-1) * 3 + 1 + i - constr_x_dn;
        OPT.Coefs(OPT.Coef_cnt) = +1;

        OPT.Coef_cnt = OPT.Coef_cnt + 1;
        OPT.Constr_id(OPT.Coef_cnt) = i;
        OPT.Var_id(OPT.Coef_cnt) = old_var_cnt + (t-0) * 3 + 1 + i - constr_x_dn;
        OPT.Coefs(OPT.Coef_cnt) = -2;

        OPT.Coef_cnt = OPT.Coef_cnt + 1;
        OPT.Constr_id(OPT.Coef_cnt) = i;
        OPT.Var_id(OPT.Coef_cnt) = old_var_cnt + (t+1) * 3 + 1 + i - constr_x_dn;
        OPT.Coefs(OPT.Coef_cnt) = +1;
    end
    for i=constr_x_up:constr_z_up
        OPT.Constr_sense(i) = '<';
        OPT.Constr_rhs(i) = +M * 3;
        if (i == constr_z_up)
            OPT.Constr_rhs(i) = OPT.Constr_rhs(i) + 9810 / fps / fps;
        end
        OPT.Coef_cnt = OPT.Coef_cnt + 1;
        OPT.Constr_id(OPT.Coef_cnt) = i;
        OPT.Var_id(OPT.Coef_cnt) = old_var_cnt + (t-1) * 3 + 1 + i - constr_x_up;
        OPT.Coefs(OPT.Coef_cnt) = +1;

        OPT.Coef_cnt = OPT.Coef_cnt + 1;
        OPT.Constr_id(OPT.Coef_cnt) = i;
        OPT.Var_id(OPT.Coef_cnt) = old_var_cnt + (t-0) * 3 + 1 + i - constr_x_up;
        OPT.Coefs(OPT.Coef_cnt) = -2;

        OPT.Coef_cnt = OPT.Coef_cnt + 1;
        OPT.Constr_id(OPT.Coef_cnt) = i;
        OPT.Var_id(OPT.Coef_cnt) = old_var_cnt + (t+1) * 3 + 1 + i - constr_x_up;
        OPT.Coefs(OPT.Coef_cnt) = +1;
    end

    for nt=t:(t+2)
        for s=1:length(spaces_free)
            idx = spaces_free{s}{nt};
            for i=1:length(idx)
                for j=1:length(GRAPH.Nodes(idx(i)).Incoming)
                    var = GRAPH.Edges(GRAPH.Nodes(idx(i)).Incoming(j)).VarId;
                    skip_node = 0;
                    for l=1:size(baskets, 1)
                      if (...
                        GRAPH.Nodes(idx(i)).Pos(1) >= baskets(l, 1) &&...
                        GRAPH.Nodes(idx(i)).Pos(1) <= baskets(l, 4) &&...
                        GRAPH.Nodes(idx(i)).Pos(2) >= baskets(l, 2) &&...
                        GRAPH.Nodes(idx(i)).Pos(2) <= baskets(l, 5) &&...
                        GRAPH.Nodes(idx(i)).Pos(3) >= baskets(l, 3) &&...
                        GRAPH.Nodes(idx(i)).Pos(3) <= baskets(l, 6))
                        skip_node = 1;
                      end
                    end
                    if (skip_node == 1)
                      continue;
                    end
                    for k=constr_x_dn:constr_z_dn
                        if (k == constr_z_dn && GRAPH.Nodes(idx(i)).Pos(3) > -CONST.GroundLevel)
                            continue;
                        end

                        OPT.Coef_cnt = OPT.Coef_cnt + 1;
                        OPT.Constr_id(OPT.Coef_cnt) = k;
                        OPT.Var_id(OPT.Coef_cnt) = var;
                        OPT.Coefs(OPT.Coef_cnt) = -M;
                    end
                    for k=constr_x_up:constr_z_up
                        if (k == constr_z_up && GRAPH.Nodes(idx(i)).Pos(3) > -CONST.GroundLevel)
                          %  disp(idx(i));
                            continue;
                        end
                        OPT.Coef_cnt = OPT.Coef_cnt + 1;
                        OPT.Constr_id(OPT.Coef_cnt) = k;
                        OPT.Var_id(OPT.Coef_cnt) = var;
                        OPT.Coefs(OPT.Coef_cnt) = +M;
                    end
                end
            end
        end
    end
end


end

