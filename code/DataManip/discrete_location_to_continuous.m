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

function [ xyz, w ] = discrete_location_to_continuous( t, x, y, z, POM, space )

    if (isempty(space))
        space = -1;
    end

    global CONST;
    global SPACE;

    if (~ismember(space, [CONST.Possession, CONST.PossessionHigh, CONST.PossessionLow]))
        w = POM(t).W(POM(t).Grid(x,y,z));
        xyz = POM(t).Pos(POM(t).Grid(x,y,z),:);
        return;
    end

    if (space == CONST.Possession)
        dx = SPACE.Possession.VicinityX;
        dy = SPACE.Possession.VicinityY;
        dz = SPACE.Possession.MinZ:SPACE.Possession.MaxZ;
    end
    if (space == CONST.PossessionLow)
        dx = SPACE.PossessionLow.VicinityX;
        dy = SPACE.PossessionLow.VicinityY;
        dz = SPACE.PossessionLow.MinZ:SPACE.PossessionLow.MaxZ;
    end
    if (space == CONST.PossessionHigh)
        dx = SPACE.PossessionHigh.VicinityX;
        dy = SPACE.PossessionHigh.VicinityY;
        dz = SPACE.PossessionHigh.MinZ:SPACE.PossessionHigh.MaxZ;
    end

    lx = max(1, x - dx):min(size(POM(1).Grid, 1), x + dx);
    ly = max(1, y - dy):min(size(POM(1).Grid, 2), y + dy);
    lz = dz;

    [mx,my,mz] = meshgrid(lx,ly,lz);

    idxes = POM(t).Grid(sub2ind(size(POM(t).Grid), mx(:), my(:), mz(:)));
    [w,num] = max(POM(t).W(idxes));
    xyz = POM(t).Pos(idxes(num),:);
end

