%% Fig 3c-e. Durations of the Reach, Transfer and Return chunks per subject and task
% Data file: data/fig03cde_chunk_durations.mat
%   phase_duration.(SUBJ2|SUBJ3|SUBJ5).(GRASP25|GRIP25|PRONATE25)
%       25 repetitions x 3 chunks (reach, transfer, return), durations in seconds
% SUBJ2, SUBJ3 and SUBJ5 are manuscript subjects 1, 2 and 3 (the template subjects, 25-repetition trials).
% For every task and chunk a Kruskal-Wallis test across subjects is followed by Tukey-Kramer post hoc
% comparisons (Statistics and Machine Learning Toolbox); the p-values are printed to the terminal.

here = fileparts(mfilename('fullpath'));
S = load(fullfile(here, 'data', 'fig03cde_chunk_durations.mat'));
pd = S.phase_duration;

subjects  = {'SUBJ2', 'SUBJ3', 'SUBJ5'};
subjLabel = {'subject 1', 'subject 2', 'subject 3'};
col       = [0.2 0.2 0.2; 0.85 0.1 0.3; 1 0.6 0];
tasks     = {'GRASP25', 'GRIP25', 'PRONATE25'};
taskLabel = {'grasp', 'grip', 'pronate'};
chunks    = {'reach', 'transfer', 'return'};
hasStats  = license('test', 'Statistics_Toolbox') && exist('kruskalwallis', 'file') == 2;

figure('Color', 'w', 'Name', 'Fig3cde', 'Position', [100 100 560 720]);
tiledlayout(3, 1, 'TileSpacing', 'compact');
for it = 1:numel(tasks)
    dur = []; ch = []; sb = [];
    for is = 1:numel(subjects)
        M = pd.(subjects{is}).(tasks{it});
        for ic = 1:numel(chunks)
            dur = [dur; M(:, ic)]; ch = [ch; repmat(ic, size(M, 1), 1)]; sb = [sb; repmat(is, size(M, 1), 1)]; %#ok<AGROW>
        end
    end
    ax = nexttile; hold(ax, 'on');
    b = boxchart(ax, categorical(ch, 1:3, chunks), dur, 'GroupByColor', categorical(sb, 1:3, subjLabel), ...
                 'Orientation', 'horizontal', 'Notch', 'on');
    for k = 1:numel(b), b(k).BoxFaceColor = col(k, :); b(k).MarkerColor = col(k, :); end
    xlabel(ax, 'duration, s'); title(ax, sprintf('%s. %s task', char('b' + it), taskLabel{it})); box(ax, 'off');
    if it == 1, legend(ax, subjLabel, 'Location', 'southeast', 'Box', 'off'); end

    if hasStats
        for ic = 1:numel(chunks)
            idx = ch == ic;
            [p, ~, stats] = kruskalwallis(dur(idx), sb(idx), 'off');
            fprintf('%-8s %-9s Kruskal-Wallis across subjects: p = %.4f', taskLabel{it}, chunks{ic}, p);
            if p < 0.05
                cmp = multcompare(stats, 'CType', 'tukey-kramer', 'Display', 'off');
                for r = 1:size(cmp, 1)
                    fprintf('; %s vs %s p = %.4f', subjLabel{cmp(r, 1)}, subjLabel{cmp(r, 2)}, cmp(r, 6));
                end
            end
            fprintf('\n');
        end
    end
end
