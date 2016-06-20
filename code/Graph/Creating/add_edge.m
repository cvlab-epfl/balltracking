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

function [ ] = add_edge_function( i, j )

global GRAPH;
global FORMAT;

% Prevent duplicate edges
for k=1:length(GRAPH.Nodes(i).Outgoing)
    if (GRAPH.Edges(GRAPH.Nodes(i).Outgoing(k)).B == j)
        return;
    end
end

GRAPH.Edge_cnt = GRAPH.Edge_cnt + 1;
GRAPH.Edges(GRAPH.Edge_cnt) = FORMAT.EDGE;
GRAPH.Edges(GRAPH.Edge_cnt).A = i;
GRAPH.Edges(GRAPH.Edge_cnt).B = j;
GRAPH.Edges(GRAPH.Edge_cnt).W = 0;
GRAPH.Nodes(i).Outgoing = [GRAPH.Nodes(i).Outgoing GRAPH.Edge_cnt];
GRAPH.Nodes(j).Incoming = [GRAPH.Nodes(j).Incoming GRAPH.Edge_cnt];
end

