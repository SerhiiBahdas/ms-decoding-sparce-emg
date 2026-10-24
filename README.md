# Continuously decoding movement sequence phase to reconstruct missing muscle activity

Serhii Bahdasariants and Sergiy Yakovenko

This repository holds the figures of the paper and everything a reader needs to regenerate the data figures (Figs 3 to 10) from the underlying numbers. Figs 1 and 2 are illustrations with no data behind them.

## Quick start for reviewers

MATLAB (R2024b or newer; the Statistics and Machine Learning Toolbox is used for the Kruskal-Wallis and Tukey-Kramer tests and is skipped automatically when absent):

```matlab
cd code
run_all_figures          % writes Fig3ab, Fig3cde, TMP100/TMP1000 (Fig 4), Fig5 to Fig9 as PNG and PDF into code/output/
```

Python 3.13.5 with the pinned packages in `code/requirements.txt` (or `code/environment.yml` for conda), for Fig 10:

```bash
cd code
pip install -r requirements.txt
python fig10_pca_umap.py   # writes Fig10.pdf, Fig10.png and the overlap matrices into code/output/
```

Each script prints the statistics quoted in the paper (mean and s.d. of the phase RMSE, the r and RMSE of every predicted muscle, decoding times, Bartlett and KMO values, numbers of shared occupancy bins). The whole MATLAB run takes about two minutes on a laptop.

## What is where

| Folder | Content |
|---|---|
| `figures/` | `Fig1.tif` to `Fig10.tif` and `S1_Fig.tif`, the figures of the paper (RGB, LZW, 600 dpi, at most 7.5 in wide). `figures/source/` keeps the vector originals they were made from. Fig 10 is the output of `code/fig10_pca_umap.py` run in the pinned environment. |
| `code/` | One self-contained script per figure, the data they read (`code/data/`), and reference outputs (`code/output/`). |
| `code/provenance/` | How the figure data were derived: `export_figure_data.m` (reads the study database), the original figure scripts used for the paper, and the processing and decoding pipeline (`pipeline/`). See `code/provenance/DATASET.md`. |

## Figures, scripts and data

| Figure | Script | Data file(s) in `code/data/` | What is checked |
|---|---|---|---|
| 3a, b | `fig03ab_events.m` | `fig03ab_events.mat` | accelerometer (m/s^2) and contact force (% full scale) of 25 repetitions, reach and return shading from grasp and release times |
| 3c to e | `fig03cde_chunk_durations.m` | `fig03cde_chunk_durations.mat` | chunk durations per subject and task, Kruskal-Wallis and Tukey-Kramer p values |
| 4 | `fig04_templates.m` | `task_templates.mat` | task templates of all 16 recorded channels (TMP1000 is the 1000-sample template of the paper) |
| 5 | `fig05_phase_traces.m` | `fig05_phase_traces.mat` | decoded versus reference phase, 3 channel configurations x 4 subjects |
| 6 | `fig06_phase_rmse.m` | `fig06_phase_rmse.mat` | per-repetition phase RMSE; prints the mean and s.d. values of the Results |
| 7, 8 | `fig07_fig08_predicted_activity.m` | `fig07_predicted_distal.mat`, `fig08_predicted_proximal.mat` | measured versus predicted activity of the unobserved participant; prints r and RMSE of every panel |
| 9 | `fig09_timing.m` | `fig09_timing_*.mat` | processing and decoding time per 14 ms packet |
| 10 | `fig10_pca_umap.py` | `task_templates.mat` | PCA and UMAP projections of the seven proximal-muscle templates, Bartlett, KMO, shared bins |

Figs 3 to 9 were assembled from these panels in a graphics editor (colours, layout and labels were edited there), so for them the scripts reproduce the content and the numbers rather than the exact artwork. Fig 10 is produced directly by the script. Every number printed by the scripts was checked against the manuscript and agrees. UMAP results depend on the library version, which is why the Python environment is pinned exactly: with umap-learn 0.5.12 and seed 12 the grip and pronate templates share 2 occupancy bins (an earlier version gave 4), and the manuscript reports the pinned result.

FCR and TriLo are absent from Figs 7 and 8 because, in the unobserved participant, the TriLo recordings in all tasks and the FCR recording in the grip task contained no activity above the noise threshold; the Methods state this.

## Subjects, tasks and names inside the data

The database numbers participants differently from the manuscript. Database ids 2, 3 and 5 are manuscript subjects 1, 2 and 3 (template subjects); database id 1 is manuscript subject 4, the unobserved participant. Trial types ending in 25 are the 30-repetition trials reduced to 25 repetitions, those ending in 10 are the 15-repetition trials reduced to 10. The database calls the abductor pollicis brevis channel `ADP`; `FSR` is the force-sensitive resistor. The decoded channel configurations are `all`, `proximal` (7 channels) and `distal` (8 channels).

## Raw recordings

The raw Delsys recordings, the per-trial processed data and the study database (`dbData.mat`) are not part of this repository. The files in `code/data/` are the data behind every figure and every statistic in the paper, and `code/provenance/DATASET.md` describes how `export_figure_data.m` derived them from the study database.

## Citing

Please cite the paper named in the title and this repository. `CITATION.cff` carries the authors, ORCID iDs and keywords in a machine-readable form, and GitHub shows it under "Cite this repository".

## Licence

Code: MIT. Data and figures: CC BY 4.0. See `LICENSE`.
