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

function [ ] = create_optimization_vars( )

    global OPT;

    OPT.MAX_COEFS  = OPTVARS.MAX_COEFS;
    OPT.MAX_CONSTR = OPTVARS.MAX_CONSTR;
    OPT.MAX_VARS   = OPTVARS.MAX_VARS;

    OPT.Constr_id = zeros(1, OPT.MAX_COEFS);
    OPT.Var_id    = zeros(1, OPT.MAX_COEFS);
    OPT.Coefs     = zeros(1, OPT.MAX_COEFS);

    OPT.Constr_sense = char(repmat(' ', 1, OPT.MAX_CONSTR));
    OPT.Constr_rhs   = zeros(1, OPT.MAX_CONSTR);
    OPT.Constr_name  = cell(1, OPT.MAX_CONSTR);

    OPT.Var_type = char(repmat(' ', 1, OPT.MAX_VARS));
    OPT.Var_name = cell(1, OPT.MAX_VARS);

    OPT.Coef_cnt  = 0;
    OPT.Var_cnt = 0;
    OPT.Constr_cnt = 0;

    OPT.Obj_function = zeros(1, OPT.MAX_VARS);

end

