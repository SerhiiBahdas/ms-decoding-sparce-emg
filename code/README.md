# Figure code

All MATLAB scripts are self-contained: they read a `.mat` file from `data/`, draw the panels of one figure and print the statistics quoted in the paper. None of them needs the lab database or the boxsci toolbox. `run_all_figures.m` runs them in order and writes every figure to `output/` as PNG (200 dpi) and PDF.

Requirements. MATLAB R2024b or newer (the scripts use `violinplot`, `boxchart`, `swarmchart` and `tiledlayout`; verified in R2026a). The Statistics and Machine Learning Toolbox provides `kruskalwallis`, `multcompare` and `corr`; `fig03cde_chunk_durations.m` and `fig06_phase_rmse.m` skip the tests when the toolbox is missing, and `fig07_fig08_predicted_activity.m` uses `corrcoef` from base MATLAB. Python 3.13.5 with the exact package versions in `requirements.txt` (`environment.yml` creates the same environment with conda) for `fig10_pca_umap.py`; UMAP output varies between library versions, so use the pinned versions to reproduce the published numbers.

| Script | Figure | Data | Prints |
|---|---|---|---|
| `fig03ab_events.m` | 3a, b | `fig03ab_events.mat` | rest, peak and trough acceleration; normalized grasp and release times |
| `fig03cde_chunk_durations.m` | 3c to e | `fig03cde_chunk_durations.mat` | Kruskal-Wallis and Tukey-Kramer p values per task and chunk |
| `fig04_templates.m` | 4 | `task_templates.mat` | nothing (two figures, TMP100 and TMP1000; the paper shows TMP1000) |
| `fig05_phase_traces.m` | 5c to n | `fig05_phase_traces.mat` | nothing |
| `fig06_phase_rmse.m` | 6 | `fig06_phase_rmse.mat` | mean, s.d., median and n of the RMSE per task and configuration; Kruskal-Wallis across tasks |
| `fig07_fig08_predicted_activity.m` | 7, 8 | `fig07_predicted_distal.mat`, `fig08_predicted_proximal.mat` | tables of r and RMSE between mean measured and mean predicted traces |
| `fig09_timing.m` | 9 | `fig09_timing_processing.mat`, `fig09_timing_decoding_{all,proximal,distal}.mat` | median, mean and s.d. of processing and decoding time |
| `fig10_pca_umap.py` | 10 | `task_templates.mat` | Bartlett's test, KMO (overall and per muscle), explained variance, shared occupancy bins; writes the two-panel Fig 10 itself |

## Data files

Every file carries a `readme` variable (or a header comment in its script) that documents its variables. In short:

- `fig03ab_events.mat`: `UserData(1).meanData` accelerometer (g, y axis of the sensor over FDS, 10 Hz low-pass, 148.15 Hz), `UserData(2).meanData` force-sensitive resistor (% full scale, 1925.9 Hz), `tSTARTMOV`, `tGRASP`, `tRELEASE`, `tENDMOV` event times (s) of 25 repetitions of the grasp task by one subject.
- `fig03cde_chunk_durations.mat`: `phase_duration.(SUBJ2|SUBJ3|SUBJ5).(GRASP25|GRIP25|PRONATE25)`, 25 repetitions x [reach, transfer, return] durations in seconds.
- `task_templates.mat`: `TEMPLATE.template.TMP1000.(task).(channel)`, the 1000-sample task templates (n.u.) of all 16 channels; `TMP100` is the 100-sample version used by the decoder. Read by the Fig 4 and Fig 10 scripts and by `provenance/export_figure_data.m`.
- `fig05_phase_traces.mat`: `traces.(all|proximal|distal).(S2|S3|S5|S1).(grasp|grip|pronate).prediction` and `.reference`, repetitions x 1000 samples of decoded and reference phase (n.u.).
- `fig06_phase_rmse.mat`: `rmse`, a struct of column arrays (`config`, `subject_id`, `subject`, `task`, `repetition`, `rmse`), one entry per repetition.
- `fig07_predicted_distal.mat`, `fig08_predicted_proximal.mat`: `measured.(task).(muscle)` and `predicted.(task).(muscle)`, 100 samples x 25 repetitions (n.u.) for the unobserved participant; `template.(task).(muscle)`; `muscles`; `muscle_labels` (ADP is APB).
- `fig09_timing_*.mat`: `tProcessing` or `tDecoding`, seconds per 14 ms packet; the scripts use packets 1001 to 6000.
- Fig 10 projects the `TMP1000` templates of `task_templates.mat`. The published analysis uses the seven proximal muscles; set `SIGNALS = ALL_SIGNALS` in the script to use all 15.

Subject ids inside the files are database ids: 2, 3, 5 are manuscript subjects 1, 2, 3 and 1 is subject 4 (unobserved).

## Provenance

`provenance/export_figure_data.m` documents how `fig05` to `fig08` data were extracted from the study database with the boxsci toolbox; `provenance/original_figure_scripts/` are the scripts used for the paper's figures (they query the database directly; one copy per figure, with the per-panel variants described in its README), and `provenance/pipeline/` holds the EMG processing, template construction and real-time decoding code. See `provenance/DATASET.md`.
