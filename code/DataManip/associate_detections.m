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

function [ tracks ] = associate_detections( tracks, detections, threshold, remake_pts )

  for i=1:length(tracks)
    if (isempty(tracks(i).W))
      tracks(i).W = zeros(1, size(tracks(i).Pos, 1));
    end
  end
  %return;

  for i=1:length(tracks)
  %  disp(i);
    for j=1:length(tracks(i).T)
      new_pos = [];
      for k=1:length(detections(tracks(i).T(j)).W)
        dst = sum((detections(tracks(i).T(j)).Pos(k,:) - tracks(i).Pos(j,:)).^2);
        if (dst <= threshold^2 && detections(tracks(i).T(j)).W(k) > tracks(i).W(j))
          tracks(i).W(j) = detections(tracks(i).T(j)).W(k);
          new_pos = detections(tracks(i).T(j)).Pos(k,:);
          %                    tracks(i).Node(j) = detections(tracks(i).T(j)).tmp(k);
        end
      end
      if (nargin == 4 && ~isempty(new_pos))
        tracks(i).Pos(j,:) = new_pos;
      end
    end
  end
end
