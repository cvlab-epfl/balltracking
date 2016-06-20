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

function [POM] = read_pom(pom_file_fmt, gX, gY, gZ, frame_idx, no_of_cols)

    global FORMAT;
    global DATASET;

    locX = DATASET.Loc.X;
    locY = DATASET.Loc.Y;
    locZ = DATASET.Loc.Z;

    offsetX = DATASET.Offset.X;
    offsetY = DATASET.Offset.Y;

    POM = repmat(FORMAT.POM, 1, length(frame_idx));
    %fprintf('Reading POM frame # ');
    for f_idx=1:length(frame_idx)
    %    fprintf(' %d', f_idx);
        fname = sprintf(pom_file_fmt, frame_idx(f_idx));
        fid = fopen(fname);
        ftable = fscanf(fid, '%f', [no_of_cols gX * gY * gZ])';

        % LOC W
        if (no_of_cols == 2)
            loc = ftable(:,1);
            ort = zeros(size(loc));
            gloc = loc;
            w = ftable(:,2);
        end

        %GLOC ORT LOC W
        if (no_of_cols == 4)
            loc = ftable(:,3);
            ort = ftable(:,2);
            gloc = ftable(:,1);
            w = ftable(:,4);
        end

        lx = mod(loc, gX);
        ly = fix(loc/ gX);

        fclose(fid);

        POM(f_idx).Loc = loc;
        POM(f_idx).W = w;
        POM(f_idx).X = lx + 1;
        POM(f_idx).Y = ly + 1;
        POM(f_idx).Z = ort + 1;
        POM(f_idx).Gloc = gloc;
        POM(f_idx).Ort = ort;
        POM(f_idx).Pos = [locX(lx + 1) - offsetX;...
                          locY(ly + 1) - offsetY;...
                          locZ(ort + 1) * (-1)]';
    end
    %fprintf('Done\n');
end

