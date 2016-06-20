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

function [] = train_classifier()

global CONFIG;
global CONST;
global DATASET;

fprintf('Reading input data\n');

gt = read_detections(CONFIG.TrainingGT, CONFIG.Frames);

BOM = detections_to_pom(gt, DATASET.Grid.X, DATASET.Grid.Y, DATASET.Grid.Z);

POM = read_pom(CONFIG.DetPeople ,DATASET.Grid.X, DATASET.Grid.Y,...
               DATASET.Grid.Z, CONFIG.Frames, 4);

for i=1:length(CONFIG.Frames)
  POM(i) = pom_assign_grid(POM(i), DATASET.Grid.X, DATASET.Grid.Y, 1);
end

fprintf('Creating dataset\n');

data = zeros(length(CONFIG.Frames), 6);

[GridX, GridY] = meshgrid(1:DATASET.Grid.X, 1:DATASET.Grid.Y);

for i=1:length(CONFIG.Frames)
    x = gt(i).Pos(1);
    y = gt(i).Pos(2);
    z = gt(i).Pos(3);
    w = gt(i).W;

    dx = abs(DATASET.Loc.X(POM(i).X) - (x + DATASET.Offset.X));
    dy = abs(DATASET.Loc.Y(POM(i).Y) - (y + DATASET.Offset.Y));

    p = sum(POM(i).W(find((dx.^2 + dy.^2 <= CONST.PossessionVicinity^2))));

    c = gt(i).Space - 'a' + 1;
    data(i,:) = [x y z w p c];
end

% Ignore cases where the ball is not present
data = data(find(data(:, 6) ~= CONST.NoBall), :);

fprintf('Learning classifier and priors\n');
%%

Data = data(:,1:5);
Resp = data(:,6);
N = 150;
Class_m_xz = TreeBagger(N, Data, Resp, 'OOBPrediction', 'on');

Transition_pro = zeros(26, 26);

for i=[CONST.StatesForClassifier CONST.NoBall]
    for j=[CONST.StatesForClassifier CONST.NoBall]
      Transition_pro(i, j) = CONST.TransitionPrior;
    end
end

Max_dxy = zeros(26, 1);
Max_dz = zeros(26, 1);
% Replace with under-the-hood prior
for i=1:length(CONFIG.Frames) - 1
  Transition_pro(gt(i).Space - 'a' + 1, gt(i + 1).Space - 'a' + 1) = ...
  Transition_pro(gt(i).Space - 'a' + 1, gt(i + 1).Space - 'a' + 1) + 1;

  if (gt(i).Space - 'a' + 1 ~= CONST.NoBall && ...
      gt(i + 1).Space - 'a' + 1 ~= CONST.NoBall)
    dx = gt(i).Pos(1) - gt(i + 1).Pos(1);
    dy = gt(i).Pos(2) - gt(i + 1).Pos(2);
    dz = gt(i).Pos(3) - gt(i + 1).Pos(3);

    Max_dxy(gt(i).Space - 'a' + 1) =...
    max(Max_dxy(gt(i).Space - 'a' + 1), max(abs(dx), abs(dy)));
    Max_dz(gt(i).Space - 'a' + 1) =...
    max(Max_dz(gt(i).Space - 'a' + 1), max(abs(dz)));
  end

end

for i=[CONST.StatesForClassifier CONST.NoBall]
  row_sum = sum(Transition_pro(i, :));
  if (row_sum > 0)
    Transition_pro(i, :) = Transition_pro(i, :) / row_sum;
  end
end

save(CONFIG.TrainedModel, 'Class_m_xz', 'Max_dxy', 'Max_dz', 'Transition_pro');
fprintf('Done!\n');
