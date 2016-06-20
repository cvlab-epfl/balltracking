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

function cam_config = Read_Camera_Calibration_From_Xml(xml_files_cell)
% READ_CAMERA_CALIBRATION_FROM_XML generates config object to be used to project points 3D -> 2D. Use function tsai_project.
%    xml_files_cell array of names of xml files to be read
    cam_config = repmat(struct('width', 0, 'height', 0, 'dx', 0, 'dy', 0,...
                               'f', 0, 'kappa', 0, 'cx', 0, 'cy', 0,...
                               'sx', 0, 'tx', 0, 'ty', 0, 'tz', 0,...
                               'rx', 0, 'ry', 0, 'rz', 0),...
                               length(xml_files_cell), 1);
    for cam_idx=1:length(xml_files_cell)
        data = parseXML(xml_files_cell{cam_idx});

        for idx=1:length(data.Children)
            for i=1:length(data.Children(idx).Attributes)
                val = data.Children(idx).Attributes(i).Value;
                switch data.Children(idx).Attributes(i).Name
                    case 'width'
                        cam_config(cam_idx).width = str2double(val);
                    case 'height'
                        cam_config(cam_idx).height = str2double(val);
                    case 'dx'
                        cam_config(cam_idx).dx = str2double(val);
                    case 'dy'
                        cam_config(cam_idx).dy = str2double(val);
                    case 'focal'
                        cam_config(cam_idx).f = str2double(val);
                    case 'kappa1'
                        cam_config(cam_idx).kappa = str2double(val);
                    case 'cx'
                        cam_config(cam_idx).cx = str2double(val);
                    case 'cy'
                        cam_config(cam_idx).cy = str2double(val);
                    case 'sx'
                        cam_config(cam_idx).sx = str2double(val);
                    case 'tx'
                        cam_config(cam_idx).tx = str2double(val);
                    case 'ty'
                        cam_config(cam_idx).ty = str2double(val);
                    case 'tz'
                        cam_config(cam_idx).tz = str2double(val);
                    case 'rx'
                        cam_config(cam_idx).rx = str2double(val);
                    case 'ry'
                        cam_config(cam_idx).ry = str2double(val);
                    case 'rz'
                        cam_config(cam_idx).rz = str2double(val);
                end
            end
        end
    end

end
