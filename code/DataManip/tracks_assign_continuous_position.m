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

function [ tracks ] = tracks_assign_continuous_position( tracks, POM )

if (isempty(POM(1).Grid))
    for i=1:length(POM)
        POM(i) = pom_assign_grid(POM(i), max(POM(i).X), max(POM(i).Y), max(POM(i).Z));
     end
end

for i=1:length(tracks)
    for j=1:length(tracks(i).T)
         [tracks(i).Pos(j,:), tracks(i).W(j)] = discrete_location_to_continuous(tracks(i).T(j),...
                                                                 tracks(i).X(j),...
                                                                  tracks(i).Y(j),...
                                                                  tracks(i).Z(j),...
                                                                  POM,...
                                                                  tracks(i).Space);
    end
end

end

