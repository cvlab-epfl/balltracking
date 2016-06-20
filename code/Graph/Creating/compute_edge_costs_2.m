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

function [] = compute_edge_costs_2(POM, MIN_OCCUR, MAX_OCCUR, NoneSpace)

    fprintf('Creating dataset for classification\n');

    POM_grid = pom_to_grid(POM);

    limited = @(x,l,h) x(x >= l & x <= h);

    global GRAPH;
    global DATASET;
    global CONST;
    global SPACE;
    global CONFIG;

    gX = DATASET.Grid.X;
    gY = DATASET.Grid.Y;


    spaces = arrayfun(@(x) x.Space, GRAPH.Nodes(1:GRAPH.Node_cnt));
    idxes = zeros(1, GRAPH.Node_cnt);
    bad = [CONST.Source, CONST.Sink, CONST.NoBall];
    parfor i=1:GRAPH.Node_cnt
        idxes(i) = ~ismember(spaces(i), bad);
    end
    idxes = find(idxes);

    spaces = arrayfun(@(x) x.Space, GRAPH.Nodes(idxes));
    x = arrayfun(@(x) x.Pos(1), GRAPH.Nodes(idxes));
    y = arrayfun(@(x) x.Pos(2), GRAPH.Nodes(idxes));
    z = arrayfun(@(x) x.Pos(3), GRAPH.Nodes(idxes));
    t = arrayfun(@(x) x.Time, GRAPH.Nodes(idxes));
    w = arrayfun(@(x) x.Info, GRAPH.Nodes(idxes));
    const = CONST;
    dataset = DATASET;

    L = length(idxes);


    peop1000 = zeros(L, 1);
    mes = repmat(' ', L, 1);
    for id=1:L
        %disp(id);

        dx = abs(x(id) - POM(t(id)).X);
        dy = abs(y(id) - POM(t(id)).Y);
        p1000 = sum(POM(t(id)).W(find((dx.^2 + dy.^2 <= CONST.PossessionVicinity^2))));
        peop1000(id) = p1000;

    end

    MODEL = load(CONFIG.TrainedModel);

    tmp = zeros(1, L);
    tmp(mes == 'f') = 1;
    tmp(mes == 'p') = 2;
    tmp(mes == 'h') = 3;

    fprintf('Computing node probabilities\n');

    Px_z = zeros(1, GRAPH.Node_cnt);
    Px_z(idxes) = w;

    log_Px_z = zeros(1, GRAPH.Node_cnt);
    local_Px_z = zeros(1, GRAPH.Node_cnt);
    Pm_xz = zeros(1, GRAPH.Node_cnt);

    bounded = @(x) min(MAX_OCCUR, max(MIN_OCCUR, x));

    wmod = w;

    sum_log_not_Px_z_for_t = zeros(1, length(CONFIG.Frames));
    for i=1:L
      sum_log_not_Px_z_for_t(t(i)) =...
      sum_log_not_Px_z_for_t(t(i)) + log(bounded(1 - wmod(i)));
    end

    % All - false = probability for NoneSpace
    for i=1:length(CONFIG.Frames)
        idx = NoneSpace{i};
        log_Px_z(idx)  = sum_log_not_Px_z_for_t(i);
        local_Px_z(idx) = 0;
        Pm_xz(idx) = 1;
    end

    % For all the rest reverse detection at current location
    for i=1:L
      log_Px_z(idxes(i))  =...
      sum_log_not_Px_z_for_t(t(i)) -...
      log(bounded(1 - wmod(i))) +...
      log(bounded(wmod(i)));
       local_Px_z(idxes(i)) = w(i);
    end

    fprintf('Classifying\n');

    X_all = [x y z w peop1000];
    [~,Pm_xz_out] = predict(MODEL.Class_m_xz, X_all);

    fprintf('Using node probabilities\n');

    for i=1:L
        pos = find(spaces(i) == CONST.StatesForClassifier);
        if (~isempty(pos))
          Pm_xz(idxes(i)) = bounded(Pm_xz_out(i,pos));
        end
    end

    % Special conditions on SINK node
    Pm_xz(2) = 1;

    E = GRAPH.Edge_cnt;
    N = GRAPH.Node_cnt;
    As = arrayfun(@(x) x.A, GRAPH.Edges(1:E));
    Bs = arrayfun(@(x) x.B, GRAPH.Edges(1:E));
    spaces = arrayfun(@(x) x.Space, GRAPH.Nodes(1:N));

    space = SPACE;

    fprintf('Computing edge costs\n');


    ws = zeros(1, E);
    for i=1:E
        a = As(i);
        b = Bs(i);

        ws(i) = 0;

        if (spaces(a) == const.Source || spaces(b) == const.Sink)
            continue;
        end

        if (spaces(b) == const.People)
            ws(i) = log(bounded(Px_z(b)) / bounded(1 - Px_z(b)));
            continue;
        end

        % Transition
        ws(i) = ws(i) + log(MODEL.Transition_pro(spaces(a), spaces(b)));

        % Detection
        val = local_Px_z(b);
        ws(i) = ws(i) + log(bounded(val)) - log(bounded(1 - val));

        % Classifier
        ws(i) = ws(i) + log(bounded(Pm_xz(b)));

    end

    for i=1:E
        GRAPH.Edges(i).W = ws(i);
    end

end

