# Original figure scripts

These are the scripts that produced the panels of the published figures. They query the study database through the boxsci toolbox and are kept for provenance; the reviewer-facing scripts in `code/` reproduce the same panels from the exported data without the database. Their numbering predates the final figure order:

| Original script | Manuscript figure |
|---|---|
| `FIG3_A_B.m`, `FIG3_C_D_E.m` | Fig 3 (a, b and c to e) |
| `FIG4.m` | Fig 4 |
| `FIG5a.m` | Fig 6 (phase RMSE violins) |
| `FIG6c.m` | Fig 5 (decoded phase traces) |
| `FIG7.m` | Fig 9 (timing) |
| `FIG8.m` | Fig 7 (distal muscles predicted from proximal EMG) |
| `FIG9.m` | Fig 8 (proximal muscles predicted from distal EMG) |
| `FIGURE10A_V2.py`, `FIGURE10B_V2.py` | Fig 10 (PCA and UMAP; superseded by `code/fig10_pca_umap.py`) |

The panels of Figs 5 and 6 were produced by running one script per panel with a few lines changed. Only one copy of each is kept here; the variants differed as follows.

`FIG5a.m` (Fig 6, six panels): `idSubjectList = [2,3,5]` with `sTrialTypeList = {'GRASP10','GRIP10','PRONATE10'}` for the observed subjects (panels a to c) and `idSubjectList = [1]` with `{'GRASP25','GRIP25','PRONATE25'}` for the unobserved subject (panels d to f); `Signal_prediction.sTable` set to `'refined_prediction'`, `'refined_prediction_only_prox'` or `'refined_prediction_only_dist'` for the all, proximal and distal channel panels; panels d to f added `ylim([-0.05, 0.45])`.

`FIG6c.m` (Fig 5, twelve panels): `idSubjectList` set to `[2]`, `[3]`, `[5]` or `[1]` (manuscript subjects 1 to 4) and `Signal_prediction.sTable` set as above for the three rows.

`code/provenance/export_figure_data.m` loops over exactly these combinations and writes the data the reviewer scripts read.

`TEMPLATE.mat`, which `FIG8.m`, `FIG9.m` and the pipeline scripts load, is the file now kept as `code/data/task_templates.mat`.
