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

function [ model, params ] = make_model(  )
    global OPT;

    clear model;

    OPT.Constr_id = OPT.Constr_id(1:OPT.Coef_cnt);
    OPT.Var_id = OPT.Var_id(1:OPT.Coef_cnt);
    OPT.Coefs = OPT.Coefs(1:OPT.Coef_cnt);

    model.A = sparse(OPT.Constr_id, OPT.Var_id, OPT.Coefs, OPT.Constr_cnt, OPT.Var_cnt);

    OPT.Obj_function = OPT.Obj_function(1:OPT.Var_cnt);
    model.obj = OPT.Obj_function;
    model.modelsense = 'max';

    OPT.Constr_sense = OPT.Constr_sense(1:OPT.Constr_cnt);
    OPT.Constr_rhs   = OPT.Constr_rhs(1:OPT.Constr_cnt);
    model.sense = OPT.Constr_sense;
    model.rhs = OPT.Constr_rhs;

    OPT.Var_type = OPT.Var_type(1:OPT.Var_cnt);
    model.vtype = OPT.Var_type;

    OPT.Var_name =  OPT.Var_name(1:OPT.Var_cnt);
    OPT.Constr_name = OPT.Constr_name(1:OPT.Constr_cnt);
    model.varnames = OPT.Var_name;
    model.constrnames = OPT.Constr_name;

    model.lb = repmat(-1e6, 1, OPT.Var_cnt);
    model.ub = repmat(+1e6, 1, OPT.Var_cnt);

    clear params;
    params.method = 1;
    params.TimeLimit = 10000;
    params.Presolve = 0;
end

