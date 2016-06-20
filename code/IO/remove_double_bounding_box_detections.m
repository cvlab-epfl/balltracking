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

function [ball_detections] = remove_double_bounding_box_detections(ball_detections, people_tracks)

global DATASET;

good_det_cell = cell(1, length(ball_detections));
for i=1:length(ball_detections)
    good_det = ones(length(ball_detections(i).W), 1);
    for j=1:length(ball_detections(i).W)
        bound = zeros(1, length(DATASET.Cam));
        for c=1:length(DATASET.Cam)
            locD = tsai_project(DATASET.Cam(c), ball_detections(i).Pos(j,:)');

            stick = tsai_project(...
            DATASET.Cam(c), [ball_detections(i).Pos(j,1:2) 0;...
            ball_detections(i).Pos(j,1:2) -1000]');

            D2Cam = sqrt(sum((stick(1,:) - stick(2,:)).^2));
            for p=1:length(people_tracks)
                idx = find(people_tracks(p).T == i);
                if (~isempty(idx))
                    cube = human_cuboid(...
                    people_tracks(p).Pos(idx,1) + DATASET.Offset.X,...
                    people_tracks(p).Pos(idx,2) + DATASET.Offset.Y, DATASET);
                    cube_2D = tsai_project(DATASET.Cam(c), cube);

                    stick = tsai_project(DATASET.Cam(c), ...
                    [people_tracks(p).Pos(idx,1:2) 0;...
                    people_tracks(p).Pos(idx,1:2) -1000]');

                    P2Cam = sqrt(sum((stick(1,:) - stick(2,:)).^2));
                    cx = (min(cube_2D(1,:)) + max(cube_2D(1,:))) / 2.;
                    dx = (max(cube_2D(1,:)) - min(cube_2D(1,:))) / 2.;
                    cy = (min(cube_2D(2,:)) + max(cube_2D(2,:))) / 2.;
                    dy = (max(cube_2D(2,:)) - min(cube_2D(2,:))) / 2.;
                    if (cx - dx <= locD(1) && locD(1) <= cx + dx &&...
                        cy - dy <= locD(2) && locD(2) <= cy + dy &&...
                        D2Cam < P2Cam)
                        bound(c) = p;
                        break;
                    end
                end
            end
        end
        if (sum(bound == 0) < 2)
            good_det(j) = 0;
        end
    end
    good_det_cell{i} = find(good_det);
end

lft = 0;
rm = 0;
for i=1:length(ball_detections)
    lft = lft + length(good_det_cell{i});
    rm = rm + length(ball_detections(i).W) - length(good_det_cell{i});
    ball_detections(i).Pos = ball_detections(i).Pos(good_det_cell{i},:);
    ball_detections(i).W   = ball_detections(i).W(good_det_cell{i});
end

fprintf('Removed %d = %0.2f%% of detections\n', rm, rm * 100. / (rm + lft));

end
