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

function [ BOM ] = detections_to_pom(detections, gX,gY, gZ)

    global CONFIG;
    global DATASET;
    global FORMAT;

    frame_idx = CONFIG.Frames;
    locX = DATASET.Loc.X;
    locY = DATASET.Loc.Y;
    locZ = DATASET.Loc.Z;

    offsetX = DATASET.Offset.X;
    offsetY = DATASET.Offset.Y;

    courtX = DATASET.Court.X;
    courtY = DATASET.Court.Y;
    courtZ = DATASET.Court.Z;

    tmp = FORMAT.POM;

    tmp.Loc = repmat((1:(gX * gY)) - 1, gZ, 1); tmp.Loc = tmp.Loc(:);
    tmp.W = zeros(size(tmp.Loc));
    tmp.X = mod(tmp.Loc, gX) + 1;
    tmp.Y = fix(tmp.Loc/ gX) + 1;
    tmp.Z = repmat((1:gZ) - 1, 1, gX * gY)' + 1;
    tmp.Gloc = ((1:(gX * gY * gZ)) - 1)';
    tmp.Pos = zeros(length(tmp.Loc), 3);

    tmp.Pos(:,1) = locX(tmp.X) - offsetX;
    tmp.Pos(:,2) = locY(tmp.Y) - offsetY;
    tmp.Pos(:,3) = locZ(tmp.Z) * (-1);

    BOM = repmat(tmp, 1, length(frame_idx));

    for f = 1:length(frame_idx)
        for i=1:length(detections(f).W)
            x = detections(f).Pos(i,1) + offsetX;
            y = detections(f).Pos(i,2) + offsetY;
            z = detections(f).Pos(i,3) * (-1);
            w = detections(f).W(i);
            if (x < 0 || x > courtX || y < 0 || y > courtY || z < 0 || z > courtZ)
                continue;
            end
            [~,lx] = min(abs(x - locX));
            [~,ly] = min(abs(y - locY));
            [~,lz] = min(abs(z - locZ));
            idx = find(tmp.Z == lz & tmp.X == lx & tmp.Y == ly);
            if (w > tmp.W(idx))
                BOM(f).W(idx) = w;
                BOM(f).Pos(idx,:) = detections(f).Pos(i,:);
            end
        end
    end
end

