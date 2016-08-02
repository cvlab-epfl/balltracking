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

function [] = create_graph_vars()

global FORMAT;
global GRAPH;
global CONST;
global OPTVARS;

GRAPH.MAX_NODES = OPTVARS.MAX_GRAPH;
GRAPH.MAX_EDGES = OPTVARS.MAX_GRAPH;

GRAPH.Nodes = repmat(struct(FORMAT.NODE), GRAPH.MAX_NODES, 1);
GRAPH.Edges = repmat(struct(FORMAT.EDGE), GRAPH.MAX_EDGES, 1);

GRAPH.Node_cnt = 0;
GRAPH.Edge_cnt = 0;

GRAPH.Nodes(1).Space = CONST.Source;
GRAPH.Nodes(2).Space = CONST.Sink;
GRAPH.Nodes(1).Pos = [0 0 0];
GRAPH.Nodes(2).Pos = [0 0 0];
GRAPH.Nodes(1).X = 0; GRAPH.Nodes(1).Y = 0; GRAPH.Nodes(1).Z = 0;
GRAPH.Nodes(2).X = 0; GRAPH.Nodes(2).Y = 0; GRAPH.Nodes(2).Z = 0;
GRAPH.Node_cnt = 2;
end

