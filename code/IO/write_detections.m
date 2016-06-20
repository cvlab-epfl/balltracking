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

function [] = write_detections(fpath, frame_idx, ball_detections)
  tot_det = sum(arrayfun(@(x) length(x.W), ball_detections));
  ftable = zeros(tot_det, 6);

  fid = fopen(fpath, 'w');
  fprintf(fid, '%d\n', tot_det);
  for idx=1:length(ball_detections)
    f_idx = frame_idx(idx);

    if (length(ball_detections(idx).W) == 0)
      continue;
    end

    state_val = 0;
    if (length(ball_detections(idx).Space) == 0)
      state_val = zeros(length(ball_detections(idx).W), 1);
    else
      state_val = ball_detections(idx).Space - 'a' + 1;
    end

    fcur   = [repmat(f_idx, length(ball_detections(idx).W), 1)...
              ball_detections(idx).Pos(:, 1)...
              ball_detections(idx).Pos(:, 2)...
              ball_detections(idx).Pos(:, 3)...
              ball_detections(idx).W(:)...
              state_val];
    fprintf(fid, '%d %0.3f %0.3f %0.3f %0.6f %d\n', fcur');
  end
  fclose(fid);
end
