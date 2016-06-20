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

function [ball_detections] = read_detections(fpath, frame_idx)

  fid = fopen(fpath, 'r');
  tot_det = fscanf(fid, '%d', [1 1]);
  ftable = fscanf(fid, '%f', [6 tot_det])';
  fclose(fid);


  global FORMAT;
  ball_detections = repmat(FORMAT.DETECTION, 1, length(frame_idx));

  for idx=1:length(frame_idx)
    f_idx = frame_idx(idx);
    pos = find(ftable(:, 1) == f_idx);
    ball_detections(idx).Pos = [ftable(pos, 2) ftable(pos, 3) ftable(pos, 4)];
    ball_detections(idx).W = ftable(pos, 5);
    if (ftable(pos, 6) ~= 0)
      ball_detections(idx).Space = char('a' + ftable(pos, 6) - 1);
    end
  end

end
