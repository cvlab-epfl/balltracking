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

function [ POM ] = read_pom_output( file_fmt, idx, gX, gY, gZ, filter_func )
%READ_POM_OUTPUT Summary of this function goes here
%   Detailed explanation goes here
Per_file = cell(length(idx), 1);
parfor f_idx=1:length(idx)
    fname = sprintf(file_fmt, idx(f_idx));
    fid = fopen(fname);
    ftable = fscanf(fid, '%f', [2 gX * gY * gZ])';
    fclose(fid);
    ftable = filter_func(ftable);
    ftable = [ftable mod(ftable(:,1), gX), fix(ftable(:,1) / gX)];
    Per_file{f_idx} = ftable;
end

tot = 0;
for f_idx=1:length(idx)
    tot = tot + size(Per_file{f_idx}, 1);
end

POM = struct('x', zeros(tot, 1),...
             'y', zeros(tot, 1),...
             'z', zeros(tot, 1),...
             'w', zeros(tot, 1),...
             't', zeros(tot, 1));

tot = 0;
for f_idx=1:length(idx)
    cur = tot + (1:size(Per_file{f_idx}, 1));
    POM.x(cur) = Per_file{f_idx}(:,5) + 1;
    POM.y(cur) = Per_file{f_idx}(:,6) + 1;
    POM.z(cur) = Per_file{f_idx}(:,2) + 1;
    POM.w(cur) = Per_file{f_idx}(:,4);
    POM.t(cur) = repmat(idx(f_idx), length(cur), 1);
    tot = tot + length(cur);
end

end

