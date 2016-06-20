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

function [ rx, ry, rz ] = Parabola_fix(si, i, xi, yi, zi, j, sj, xj, yj, zj, G, fps)
% Given two tracklets (xi, yi, zi) at times si:i
% and (xj, yj, zj) at times (j:sj), find best fitting
% for (i+1):(j-1)
% G = acceleration

    MAX_ERROR = 1000;
    HEIGHT= 1000;

    xx = [xi; xj];
    yy = [yi; yj];
    zz = [zi; zj];

    [~,~,~,max_error] = Parabolic_fit(xx, yy, zz, [si:i j:sj], [], G, fps);

    if (max_error < MAX_ERROR)
        % Fit 1 parabola through missing pts
        disp(['Fixing 1 parabola']);
        [rx,ry,rz,~] = Parabolic_fit(xx, yy, zz, [si:i j:sj], [(i+1):(j-1)], G, fps);
        return;
    end

    [rix,riy,riz,~] = Parabolic_fit(xi, yi, zi, si:i, (i+1):(j-1), G, fps);
    [rjx,rjy,rjz,~] = Parabolic_fit(xj, yj, zj, j:sj, (i+1):(j-1), G, fps);

     diz = sqrt((rix - rjx).^2 + (riy - rjy).^2 + (riz - rjz).^2);
     good_idx = find(diz < MAX_ERROR);

     if (~isempty(good_idx))
        disp(['Merging 2 parabolas']);
        [~,mid] = min(diz);

        rx = [rix(1:mid) rjx((mid+1):end)];
        ry = [riy(1:mid) rjy((mid+1):end)];
        rz = [riz(1:mid) rjz((mid+1):end)];
        return;
     end

     rx = zeros(j - i - 1, 1);
     ry = zeros(j - i - 1, 1);
     rz = zeros(j - i - 1, 1);

    % Fit new parabola (currently line) in the middle
    % after growing sides a little bit
    add_i = 0;
    while(add_i < length(riz) && abs(riz(add_i + 1)) > HEIGHT)
        add_i = add_i + 1;
        rx(add_i) = rix(add_i);
        ry(add_i) = riy(add_i);
        rz(add_i) = riz(add_i);
    end

    add_j = 0;
    while(add_i + add_j < length(riz) && abs(rjz(end - add_j)) > HEIGHT)
        add_j = add_j + 1;
        rx(end - add_j + 1) = rjx(end - add_j + 1);
        ry(end - add_j + 1) = rjy(end - add_j + 1);
        rz(end - add_j + 1) = rjz(end - add_j + 1);
    end

   % if (abs(riz(add_i + 1)) > HEIGHT || abs(rjz(end - add_j)) > HEIGHT)
   %     return;
   % end

    disp(sprintf('Adding parabola and %d pts', add_i + add_j));



    i = i + add_i;
    j = j - add_j;

    if (i + 1 >= j)
        return;
    end

    pi = [xi(end) yi(end) zi(end)];
    if (add_i > 0)
        pi = [rx(add_i) ry(add_i) rz(add_i)];
    end

    pj = [xj(1) yj(1) zj(1)];
    if (add_j > 0)
        pj = [rx(end - add_j + 1) ry(end - add_j + 1) rz(end - add_j + 1)];
    end

    [mx,my,mz,~] = Parabolic_fit([pi(1); pj(1)], [pi(2); pj(2)], [pi(3); pj(3)], [i j], (i+1):(j-1), G, fps);

    rx((add_i + 1):(end - add_j)) = mx;
    ry((add_i + 1):(end - add_j)) = my;
    rz((add_i + 1):(end - add_j)) = mz;

end

