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

function [ track ] = check_track( x, y, z, s, f, extend )

 global DATASET;
 courtX = DATASET.Court.X;
 courtY = DATASET.Court.Y;
 courtZ = DATASET.Court.Z;
 offsetX = DATASET.Offset.X;
 offsetY = DATASET.Offset.Y;

 global CONST;

    is_good = @(x,y,z) (x + offsetX >= -CONST.GroundLevel &&...
                        x + offsetX <= courtX + CONST.GroundLevel &&...
                        y + offsetY >= -CONST.GroundLevel &&...
                        y + offsetY <= courtY + CONST.GroundLevel &&...
                        -z >= -CONST.GroundLevel &&...
                        -z <= courtZ + CONST.GroundLevel);
    global FORMAT;

    if (max(-z) > courtZ)
        track = FORMAT.TRACK;
        return;
    end

    for i=s:f
        if (~is_good(x(i), y(i), z(i)))
            track = FORMAT.TRACK;
            return;
        end
    end

    if (extend == 1)
        while(s > 0 && is_good(x(s), y(s), z(s)))
            s = s - 1;
        end
        s = s + 1;

        while(f <= length(x) && is_good(x(f), y(f), z(f)))
            f = f + 1;
        end
        f = f - 1;
    end

    track = FORMAT.TRACK;
    track.Pos = [x(s:f)' y(s:f)' z(s:f)'];
    track.T   = s:f;
    track.Node = zeros(1, length(s:f));
    track.W    = zeros(1, length(s:f));
    track.X    = zeros(1, length(s:f));
    track.Y    = zeros(1, length(s:f));
    track.Z    = zeros(1, length(s:f));


end
