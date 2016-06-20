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

function [NodeSpace] = add_nodes_2( x, y, z, t, w, pn, space, frames)

fprintf('Adding nodes:\n');

global GRAPH;
global DATASET;

NodeSpace = cell(frames, 1);

for i=1:length(t)
    GRAPH.Node_cnt = GRAPH.Node_cnt + 1;
    GRAPH.Nodes(GRAPH.Node_cnt).Time = t(i);

    GRAPH.Nodes(GRAPH.Node_cnt).Pos = [x(i) y(i) z(i)];
    GRAPH.Nodes(GRAPH.Node_cnt).Info = w(i);

    GRAPH.Nodes(GRAPH.Node_cnt).Space = space;

    GRAPH.Nodes(GRAPH.Node_cnt).PeopleNode = pn(i);

    GRAPH.Nodes(GRAPH.Node_cnt).X = x(i) + DATASET.Offset.X;
    GRAPH.Nodes(GRAPH.Node_cnt).Y = y(i) + DATASET.Offset.Y;
    GRAPH.Nodes(GRAPH.Node_cnt).Z = z(i) * (-1);

    NodeSpace{t(i)} = [NodeSpace{t(i)} GRAPH.Node_cnt];
end

fprintf('Done: new # of nodes = %d\n', GRAPH.Node_cnt);

end

