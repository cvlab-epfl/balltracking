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

create_optimization_vars();

add_conservation_constraints();

possession_spaces = cell(0, 1);
free_spaces = cell(0, 1);
for space_id = 1:length(list_of_names)
  if (list_of_names{space_id} == CONST.Possession)
    possession_spaces{length(possession_spaces) + 1} = list_of_spaces{space_id};
  end
  if (list_of_names{space_id} ~= CONST.Possession &&...
      list_of_names{space_id} ~= CONST.NoBall)
    free_spaces{length(free_spaces) + 1} = list_of_spaces{space_id};
  end
end

add_ball_constraints(PeopleSpace, possession_spaces);
add_physical_constraints(free_spaces, possession_spaces, DATASET.baskets);

[model,params] = make_model();
gurobi_write(model, 'model.lp');

