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

function [ grid  ] = pom_to_grid(POM )

gT = length(POM);
gZ = max(POM(1).Z);
gX = max(POM(1).X);
gY = max(POM(1).Y);

grid = zeros(gT, gZ, gX, gY);
for t=1:gT
    idx = sub2ind(size(grid), repmat(t, size(POM(t).Z)), POM(t).Z, POM(t).X, POM(t).Y);
    grid(idx) = POM(t).W;
end

end

