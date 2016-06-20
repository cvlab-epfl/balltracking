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

function [ ] = visualise_result(frame_idx, cam_id, people_tracks, ball_detections)

    global CONFIG;
    global DATASET;
    global CONST;

    cam_config = DATASET.Cam;
    source_fmt = DATASET.Source_fmt;
    all_frame_idx = CONFIG.Frames;

    for f=frame_idx
        disp(f);
        fname = sprintf(source_fmt, cam_id - 1, f);
        if (exist(fname) ~= 2)
            disp(fname);
            continue;
        end
        im = imread(fname);


        imshow(im);
        hold on;

        new_f_idx = find(all_frame_idx == f);
        if (isempty(new_f_idx))
            continue;
        end

        if (~isempty(people_tracks))
            for i=1:length(people_tracks)
                c_idx = find(people_tracks(i).T == new_f_idx);
                if (isempty(c_idx))
                    continue;
                end
                pts = human_cuboid(people_tracks(i).Pos(c_idx, 1) + DATASET.Offset.X,...
                                   people_tracks(i).Pos(c_idx, 2) + DATASET.Offset.Y,...
                                   DATASET);
                proj = tsai_project(cam_config(cam_id), pts);
                plot(proj(1,[1:4 1]), proj(2,[1:4 1]), '-r');
                plot(proj(1,[5:8 5]), proj(2,[5:8 5]), '-r');
                for idx=1:4
                     plot(proj(1,[idx idx + 4]), proj(2,[idx idx + 4]), '-r');
                end
                text(proj(1,5), proj(2,5), sprintf('%d', i),'FontSize', 20);
            end
        end

        if (~isempty(ball_detections))
            for i=1:length(ball_detections(new_f_idx).W)
                w = ball_detections(new_f_idx).W(i);
                proj = tsai_project(cam_config(cam_id), ball_detections(new_f_idx).Pos(i,:)');
                viscircles(proj', 10, 'EdgeColor', [w 0 0]);
            end

        end
        text(30, 30, sprintf('Frame: %d (%d)', f, new_f_idx), 'FontSize', 30, 'Color', 'red');
        disp(ball_detections(new_f_idx).Space);

        hold off;
        key = waitforbuttonpress;
        if (key == 1)
            cam_id = cam_id + 1;
            if (cam_id > length(cam_config))
                cam_id = 1;
            end
        end
    end
end

