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

function [ tracks ] = run_ksp( POM,...
    gX, gY, gZ, frame_idx, batch_size, ...
    depth, exec_file, min_cost, all_ap)

    % Part I - clean tmp dir
    eval('!rm -rf tmp/*');
    write_pom(POM, 'tmp/tmp%d.pom', gZ);
    % Part II - create scripts for parallel KSP running
    AP = '';
    if (all_ap == 1)
      for i=1:(gX * gY)
          AP = [AP,',',int2str(i-1)];
      end
    else
      for x=0:(gX-1)
          AP = [AP,',',int2str(x)];
          AP = [AP,',',int2str((gY-1)*gX + x)];
      end
      for y=1:(gY-1)
          AP = [AP,',',int2str(y * gX)];
          AP = [AP,',',int2str(y * gX + gX - 1)];
      end
    end
    AP(1) = ' ';

    fbash = fopen('tmp/run_exec.sh','w');

    for f_idx=1:batch_size:length(frame_idx)
        f_end = min(length(frame_idx), f_idx + batch_size - 1);
        fname = sprintf('tmp/config_%d_%d.ksp', f_idx, f_end);

        fid = fopen(fname, 'w');

        fprintf(fid, 'GRID %d %d\n', gX, gY);

        fprintf(fid, 'FRAMES %d %d\n', f_idx, f_end);
        fprintf(fid, 'ACCESS_POINTS %s\n', AP);
        fprintf(fid, sprintf('DEPTH %d\n', depth));
        fprintf(fid, 'MAX_TRAJ 1000\n');
        fprintf(fid, sprintf('NBR_ORT %d\n', gZ));
        fprintf(fid, 'INPUT_FORMAT tmp/tmp%%d.pom\n');
        fclose(fid);

        fprintf(fbash, './%s %s -s %d -o tmp/ksp_%05d_%05d.out > log.txt &\n',...
            exec_file, fname, min_cost, f_idx, f_end);
    end

    fclose(fbash);
    % Part III - Run
    eval('!chmod a+x tmp/run_exec.sh');
    eval('!tmp/run_exec.sh');
    pause(5);
    fprintf('Running ksps left:');
    cnt = 3;

    [~,exec_fname,~] = fileparts(exec_file);

    while(cnt > 2)
        [~, cnt] = system(sprintf('ps axu | grep %s | wc -l', exec_fname));
        cnt = str2num(cnt);
        if (cnt > 2)
            fprintf(' %d', cnt - 2);
            pause(5);
        end
    end
    fprintf('Done\nReading ksp output:');
   % Part IV - read tracklets
    tracks = [];
    for f_idx=1:batch_size:length(frame_idx)
        f_end = min(length(frame_idx), f_idx + batch_size - 1);
        fname = sprintf('tmp/ksp_%05d_%05d.out', f_idx, f_end);
        if (isempty(tracks))
            tracks = read_ksp_output(fname, f_idx:f_end, gX, gY, gZ);
        else
            tracks = [tracks read_ksp_output(fname, f_idx:f_end, gX, gY, gZ)];
        end
    end
    eval('!rm -rf tmp/*');
    fprintf('Done\n');
 end

