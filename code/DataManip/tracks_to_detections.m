
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

function [detections] = tracks_to_detections(tracks)

global DATASET;
global FORMAT;
global CONFIG;

time_idx = CONFIG.Frames;

detections = repmat(FORMAT.DETECTION, 1, length(time_idx));

for i=1:length(tracks)
   if (isstr(tracks(i).tmp))
        parts = strsplit(tracks(i).tmp, '!');
        parts = parts(2:end);
    else
        parts = [];
    end
    for j=1:length(tracks(i).T)
         lt = tracks(i).T(j);
        if (~isempty(tracks(i).X))
            lx = tracks(i).X(j);
            ly = tracks(i).Y(j);
            lz = tracks(i).Z(j);
            ls = tracks(i).Space;
            detections(lt).X = [detections(lt).X; lx];
            detections(lt).Y = [detections(lt).Y; ly];
            detections(lt).Z = [detections(lt).Z; lz];
            detections(lt).Space = [detections(lt).Space; ls];
        end


        if (~isempty(tracks(i).W(j)))
            detections(lt).W = [detections(lt).W tracks(i).W(j)];
        else
            detections(lt).W = [detections(lt).W 0];
        end
        detections(lt).Space = tracks(i).Space;

        if (~isempty(tracks(i).Cost))
            detections(lt).Cost = [detections(lt).Cost tracks(i).Cost(j)];
        else
             detections(lt).Cost = [detections(lt).Cost 0];
        end

        detections(lt).Pos = [detections(lt).Pos; tracks(i).Pos(j,:)];

        if (length(parts) >= j)
            detections(lt).tmp = [detections(lt).tmp parts{j}];
        end
    end
end

end

