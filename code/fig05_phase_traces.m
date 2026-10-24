%% Fig 5c-n. Decoded movement-sequence phase versus reference phase
% Data file: data/fig05_phase_traces.mat
%   traces.(config).(subject).(task).prediction   repetitions x 1000, decoded phase (n.u.)
%   traces.(config).(subject).(task).reference    repetitions x 1000, reference phase (n.u.)
%   config  = all | proximal | distal (EMG channels used for decoding)
%   subject = S2, S3, S5 (manuscript subjects 1-3, 10 withheld repetitions per task)
%             S1 (manuscript subject 4, the unobserved participant, 25 repetitions per task)
% Each panel shows the mean decoded phase per task with its 95% confidence band against the
% diagonal (perfect decoding), as in Fig 5 of the manuscript.

here = fileparts(mfilename('fullpath'));
S = load(fullfile(here, 'data', 'fig05_phase_traces.mat'));
traces = S.traces;

configs   = {'all', 'proximal', 'distal'};
cfgLabel  = {'all muscles', 'proximal arm muscles', 'distal arm muscles'};
subjects  = {'S2', 'S3', 'S5', 'S1'};
subjLabel = {'subject 1', 'subject 2', 'subject 3', 'subject 4 (unobserved)'};
tasks     = {'grasp', 'grip', 'pronate'};
col       = [0 0 0; 0.80 0.55 0.75; 0.25 0.75 0.60];
t = linspace(0, 1, 1000);

figure('Color', 'w', 'Name', 'Fig5', 'Position', [50 50 1000 760]);
tl = tiledlayout(3, 4, 'TileSpacing', 'compact', 'Padding', 'compact');
for ic = 1:numel(configs)
    for is = 1:numel(subjects)
        ax = nexttile; hold(ax, 'on');
        h = gobjects(1, numel(tasks));
        for it = 1:numel(tasks)
            P  = traces.(configs{ic}).(subjects{is}).(tasks{it}).prediction;
            m  = mean(P, 1);
            ci = 1.96 * std(P, 0, 1) / sqrt(size(P, 1));
            fill(ax, [t fliplr(t)], [m - ci, fliplr(m + ci)], col(it, :), 'FaceAlpha', 0.25, 'EdgeColor', 'none');
            h(it) = plot(ax, t, m, 'Color', col(it, :), 'LineWidth', 1.5);
        end
        plot(ax, [0 1], [0 1], 'k--');
        xlim(ax, [0 1]); ylim(ax, [0 1]); box(ax, 'off');
        if ic == 1, title(ax, subjLabel{is}); end
        if is == 1, ylabel(ax, {['using ' cfgLabel{ic}], 'decoded phase, n.u.'}); end
        if ic == numel(configs), xlabel(ax, 'time, n.u.'); end
        if ic == 1 && is == 1, legend(ax, h, tasks, 'Location', 'northwest', 'Box', 'off'); end
    end
end
title(tl, 'Average decoded phase of withheld movement sequences (mean and 95% CI)');
