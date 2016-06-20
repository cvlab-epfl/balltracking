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
%%/* Written by Bo Chen. Modified by Andrii Maksai.                       */
%%/*                                                                      */
%%/* http://cvlab.epfl.ch/research/balltracking                           */
%%/* Contact <andrii.maksai@epfl.ch> for comments & bug reports.          */
%%/************************************************************************/

function [pt2, r] = project_3d(cam_config, RBALL, pts3d)
    pt2 = tsai_project(cam_config, pts3d);
    r1 = tsai_project(cam_config, bsxfun(@plus, pts3d, [RBALL; 0; 0]))...
        - tsai_project(cam_config, bsxfun(@plus, pts3d, -[RBALL; 0; 0]));
    r1 = sqrt(sum(r1.^2));
    r2 = tsai_project(cam_config, bsxfun(@plus, pts3d, [0; RBALL; 0]))...
        - tsai_project(cam_config, bsxfun(@plus, pts3d, -[0; RBALL; 0]));
    r2 = sqrt(sum(r2.^2));
    r3 = tsai_project(cam_config, bsxfun(@plus, pts3d, [0; 0; RBALL]))...
        - tsai_project(cam_config, bsxfun(@plus, pts3d, -[0; 0; RBALL]));
    r3 = sqrt(sum(r3.^2));
    r = max([r1;r2;r3])/2;
end
