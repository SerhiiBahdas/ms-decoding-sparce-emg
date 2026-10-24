%% Fig 6. Phase-decoding error (RMSE) per repetition, by task and channel configuration
% Data file: data/fig06_phase_rmse.mat
%   rmse.config      EMG channels used for decoding: all | proximal | distal
%   rmse.subject_id  database id (2, 3, 5 = manuscript subjects 1-3; 1 = subject 4, unobserved)
%   rmse.task        grasp | grip | pronate
%   rmse.repetition  repetition index within the trial
%   rmse.rmse        root-mean-square error between decoded and reference phase (n.u.)
% Prints the mean +/- s.d. and median per task that are quoted in the Results, then draws the
% six violin panels of Fig 6 (violinplot requires MATLAB R2024b or newer). The Kruskal-Wallis
% test and Tukey-Kramer post hoc comparisons of the original analysis run when the
% Statistics and Machine Learning Toolbox is available.

here = fileparts(mfilename('fullpath'));
S = load(fullfile(here, 'data', 'fig06_phase_rmse.mat'));
T = struct2table(S.rmse);
T.config = categorical(T.config);
T.task   = categorical(T.task, {'grasp', 'grip', 'pronate'});

configs  = {'all', 'proximal', 'distal'};
cfgTitle = {'using all muscles', 'using proximal arm muscles', 'using distal arm muscles'};
groups   = {'observed subjects 1-3 (10 withheld repetitions each)', [2 3 5];
            'unobserved subject 4 (25 repetitions)',                 1};
subjColor = containers.Map({2, 3, 5, 1}, {[0.19 0.51 0.74], [0.20 0.20 0.20], [0.55 0.75 0.90], [0.6 0.6 0.6]});
hasStats  = license('test', 'Statistics_Toolbox') && exist('kruskalwallis', 'file') == 2;

figure('Color', 'w', 'Name', 'Fig6', 'Position', [50 50 1000 620]);
tl = tiledlayout(2, 3, 'TileSpacing', 'compact', 'Padding', 'compact');
for ig = 1:size(groups, 1)
    for ic = 1:numel(configs)
        sub = T(T.config == configs{ic} & ismember(T.subject_id, groups{ig, 2}), :);
        ax = nexttile; hold(ax, 'on');
        violinplot(ax, sub.task, sub.rmse, 'FaceColor', [0.92 0.92 0.92], 'EdgeColor', [0.5 0.5 0.5]);
        b = boxchart(ax, sub.task, sub.rmse, 'BoxFaceColor', 'w', 'BoxEdgeColor', 'k', 'LineWidth', 1.2);
        b.MarkerStyle = 'none';
        c = cell2mat(arrayfun(@(id) subjColor(id), sub.subject_id, 'UniformOutput', false));
        swarmchart(ax, sub.task, sub.rmse, 14, c, 'filled', 'MarkerFaceAlpha', 0.8);
        ylabel(ax, 'RMSE, n.u.'); title(ax, cfgTitle{ic}); box(ax, 'off');
        if ic == 1, text(ax, 0.02, 0.98, groups{ig, 1}, 'Units', 'normalized', 'VerticalAlignment', 'top', 'FontSize', 8); end

        fprintf('\n%s, %s\n', groups{ig, 1}, cfgTitle{ic});
        for tk = categories(sub.task)'
            v = sub.rmse(sub.task == tk{1});
            fprintf('   %-8s mean %.3f +/- %.3f  median %.3f  n = %d\n', tk{1}, mean(v), std(v), median(v), numel(v));
        end
        if hasStats
            [p, ~, stats] = kruskalwallis(sub.rmse, sub.task, 'off');
            fprintf('   Kruskal-Wallis across tasks: p = %.4f\n', p);
            if p < 0.05
                cmp = multcompare(stats, 'CType', 'tukey-kramer', 'Display', 'off');
                for r = 1:size(cmp, 1)
                    fprintf('      %s vs %s: p = %.4f\n', stats.gnames{cmp(r, 1)}, stats.gnames{cmp(r, 2)}, cmp(r, 6));
                end
            end
        end
    end
end
title(tl, 'Phase-decoding error of withheld movement sequences');
