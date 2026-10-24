%% Figs 7 and 8. Predicted versus measured muscle activity in the unobserved participant (subject 4)
% Data files: data/fig07_predicted_distal.mat   (distal muscles predicted from proximal EMG channels)
%             data/fig08_predicted_proximal.mat (proximal muscles predicted from distal EMG channels)
%   measured.(task).(muscle)   100 samples x repetitions, normalized muscle activity (n.u.)
%   predicted.(task).(muscle)  100 samples x repetitions, task template read out at the decoded phase
%   muscles                    database muscle names ("ADP" is APB in the manuscript)
% Each panel shows mean +/- s.d. of measured (black) and predicted (coloured) activity. The
% correlation coefficient r and the RMSE are computed between the two mean traces, as in the
% manuscript, and printed as tables.

here = fileparts(mfilename('fullpath'));
sets = {'fig07_predicted_distal',   'Fig7', [0.85 0.1 0.1], 'distal muscles predicted from proximal EMG';
        'fig08_predicted_proximal', 'Fig8', [0.2 0.7 0.5],  'proximal muscles predicted from distal EMG'};
tasks = {'grasp', 'grip', 'pronate'};
x = linspace(0, 1, 100);

for is = 1:size(sets, 1)
    S = load(fullfile(here, 'data', [sets{is, 1} '.mat']));
    muscles = S.muscles;
    labels  = muscles;
    for im = 1:numel(muscles)
        if isfield(S.muscle_labels, muscles{im}), labels{im} = S.muscle_labels.(muscles{im}); end
    end
    R = zeros(numel(muscles), numel(tasks)); E = R;

    figure('Color', 'w', 'Name', sets{is, 2}, 'Position', [50 50 720 120 * numel(muscles) + 60]);
    tl = tiledlayout(numel(muscles), numel(tasks), 'TileSpacing', 'compact', 'Padding', 'compact');
    for im = 1:numel(muscles)
        for it = 1:numel(tasks)
            M = S.measured.(tasks{it}).(muscles{im});
            P = S.predicted.(tasks{it}).(muscles{im});
            mM = mean(M, 2)'; sM = std(M, 0, 2)';
            mP = mean(P, 2)'; sP = std(P, 0, 2)';
            cc = corrcoef(mM, mP); r = cc(1, 2);   % base MATLAB, no toolbox needed
            e  = sqrt(mean((mM - mP).^2));
            R(im, it) = r; E(im, it) = e;

            ax = nexttile; hold(ax, 'on');
            fill(ax, [x fliplr(x)], [mM - sM, fliplr(mM + sM)], [0 0 0], 'FaceAlpha', 0.2, 'EdgeColor', 'none');
            fill(ax, [x fliplr(x)], [mP - sP, fliplr(mP + sP)], sets{is, 3}, 'FaceAlpha', 0.2, 'EdgeColor', 'none');
            plot(ax, x, mM, 'k', 'LineWidth', 1.5);
            plot(ax, x, mP, 'Color', sets{is, 3}, 'LineWidth', 1.5);
            text(ax, 0.03, 0.95, sprintf('r = %.2f   RMSE = %.2f', r, e), 'Units', 'normalized', 'VerticalAlignment', 'top', 'FontSize', 8);
            ylim(ax, [0 1]); xlim(ax, [0 1]); box(ax, 'off');
            if im == 1, title(ax, tasks{it}); end
            if it == 1, ylabel(ax, labels{im}); end
            if im == numel(muscles), xlabel(ax, 'time, n.u.'); end
        end
    end
    title(tl, sprintf('%s: %s (black measured, coloured predicted; mean and s.d. over %d repetitions)', ...
        sets{is, 2}, sets{is, 4}, size(M, 2)));

    fprintf('\n%s (%s)\n', sets{is, 2}, sets{is, 4});
    fprintf('%-8s', 'r'); fprintf('%10s', tasks{:}); fprintf('\n');
    for im = 1:numel(muscles), fprintf('%-8s', labels{im}); fprintf('%10.2f', R(im, :)); fprintf('\n'); end
    fprintf('%-8s', 'RMSE'); fprintf('%10s', tasks{:}); fprintf('\n');
    for im = 1:numel(muscles), fprintf('%-8s', labels{im}); fprintf('%10.2f', E(im, :)); fprintf('\n'); end
end
