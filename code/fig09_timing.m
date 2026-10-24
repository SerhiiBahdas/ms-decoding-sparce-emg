%% Fig 9. Processing and decoding time per 14 ms packet
% Data files: data/fig09_timing_processing.mat        tProcessing (s), EMG processing pipeline per packet
%             data/fig09_timing_decoding_all.mat      tDecoding (s), phase decoding with all channels
%             data/fig09_timing_decoding_proximal.mat tDecoding (s), proximal channels only
%             data/fig09_timing_decoding_distal.mat   tDecoding (s), distal channels only
% As in the original analysis, packets 1001-6000 (5000 packets) of each recording are used.
% violinplot requires MATLAB R2024b or newer.

here = fileparts(mfilename('fullpath'));
sel = 1001:6000;
P = load(fullfile(here, 'data', 'fig09_timing_processing.mat'));
tProcessing = P.tProcessing(sel);
names = {'all', 'proximal', 'distal'};
files = {'fig09_timing_decoding_all.mat', 'fig09_timing_decoding_proximal.mat', 'fig09_timing_decoding_distal.mat'};
tDecoding = []; grp = {};
for k = 1:3
    D = load(fullfile(here, 'data', files{k}));
    v = D.tDecoding(sel);
    tDecoding = [tDecoding; v(:)]; %#ok<AGROW>
    grp = [grp; repmat(names(k), numel(v), 1)]; %#ok<AGROW>
    fprintf('decoding, %-8s channels: median %.2f ms, mean %.2f +/- %.2f ms (n = %d)\n', names{k}, 1e3 * median(v), 1e3 * mean(v), 1e3 * std(v), numel(v));
end
fprintf('processing: median %.2f ms, mean %.2f +/- %.2f ms (n = %d)\n', 1e3 * median(tProcessing), 1e3 * mean(tProcessing), 1e3 * std(tProcessing), numel(tProcessing));
grp = categorical(grp, names);

figure('Color', 'w', 'Name', 'Fig9', 'Position', [100 100 700 400]);
tiledlayout(1, 2, 'TileSpacing', 'compact');
ax = nexttile; hold(ax, 'on');
g = categorical(repmat({'all muscles'}, numel(tProcessing), 1));
violinplot(ax, g, 1e3 * tProcessing, 'FaceColor', [0.75 0.85 1]);
s = swarmchart(ax, g, 1e3 * tProcessing, 2, [0.3 0.6 1], 'filled'); s.MarkerFaceAlpha = 0.5;
b = boxchart(ax, g, 1e3 * tProcessing, 'BoxFaceColor', 'k'); b.MarkerStyle = 'none';
ylabel(ax, 'processing time, ms'); title(ax, 'a. EMG processing per packet'); box(ax, 'off');

ax = nexttile; hold(ax, 'on');
violinplot(ax, grp, 1e3 * tDecoding, 'FaceColor', [0.9 0.8 1]);
s = swarmchart(ax, grp, 1e3 * tDecoding, 2, [0.6 0.4 0.9], 'filled'); s.MarkerFaceAlpha = 0.5;
b = boxchart(ax, grp, 1e3 * tDecoding, 'BoxFaceColor', 'k'); b.MarkerStyle = 'none';
ylim(ax, [-1 40]); ylabel(ax, 'decoding time, ms'); title(ax, 'b. phase decoding per packet'); box(ax, 'off');
