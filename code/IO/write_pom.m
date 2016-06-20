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

function [ ] = write_pom( POM, file_fmt, gZ )
%    fprintf('Write POM file #');
    parfor f_idx=1:length(POM)
%        fprintf(' %d', f_idx);
        fname = sprintf(file_fmt, f_idx);
        fid = fopen(fname, 'w');
        ftable = [POM(f_idx).Loc * gZ + POM(f_idx).Z - 1,...
                  POM(f_idx).Z - 1, POM(f_idx).Loc, POM(f_idx).W];
        fprintf(fid, '%d %d %d %f\n', ftable');
        fclose(fid);
    end
%    fprintf('Done!\n');
end

