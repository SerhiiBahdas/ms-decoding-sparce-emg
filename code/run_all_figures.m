%% RUN_ALL_FIGURES  Regenerate every MATLAB figure panel of the manuscript and save them to output/.
% Usage: open MATLAB (R2024b or newer), cd to this folder and run   run_all_figures
% Fig 10 is produced separately by fig10_pca_umap.py (Python).

here = fileparts(mfilename('fullpath'));
cd(here);
outDir = fullfile(here, 'output');
if ~exist(outDir, 'dir'), mkdir(outDir); end
scripts = {'fig03ab_events', 'fig03cde_chunk_durations', 'fig04_templates', 'fig05_phase_traces', ...
           'fig06_phase_rmse', 'fig07_fig08_predicted_activity', 'fig09_timing'};
for k = 1:numel(scripts)
    close all force
    fprintf('\n==================== %s ====================\n', scripts{k});
    run(scripts{k});
    figs = flipud(findall(groot, 'Type', 'figure'));
    for f = 1:numel(figs)
        name = figs(f).Name;
        if isempty(name), name = sprintf('%s_%d', scripts{k}, f); end
        exportgraphics(figs(f), fullfile(outDir, [name '.png']), 'Resolution', 200);
        exportgraphics(figs(f), fullfile(outDir, [name '.pdf']), 'ContentType', 'vector');
        fprintf('saved output/%s.png and .pdf\n', name);
    end
end
close all force
fprintf('\nAll MATLAB figures written to %s\n', outDir);
