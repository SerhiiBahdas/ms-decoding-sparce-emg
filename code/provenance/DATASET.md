# Dataset and provenance

## What the study recorded

Five healthy adults (database ids 1 to 5; the manuscript uses ids 2, 3, 5 as subjects 1 to 3 and id 1 as subject 4; id 4 was not used) performed three object-transfer tasks (grasp, grip, pronate) in two trials each, of 15 and 30 repetitions. Sixteen Delsys Trigno sensors recorded surface EMG (15 muscles) plus a force-sensitive resistor on the object, with the sensors' accelerometers. Raw recordings, one `_emg_` and one `_acc_` file per trial, sit in per-subject folders (`S01_2024_11_17`, `S02_2024_11_15`, `S03_2024_11_17`, `S04_2024_11_27`, `S05_2024_11_28`; about 0.9 GB).

## The study database (boxsci)

The analysis used the boxsci toolbox (MATLAB, https://github.com/Neural-Engineering-Laboratory/boxsci), which keeps metadata in `dbData.mat` (32 kB) and signals in one file per trial, `S0x_YYYY_MM_DD_TrialN.mat` (35 files, 1.7 GB). Each trial file stores named tables, each a struct with one field per channel:

| Table | Content |
|---|---|
| `emgraw`, `accraw` | raw EMG (1925.9 Hz) and accelerometer (148.15 Hz) |
| `accproc10Hz` | accelerometer low-pass filtered at 10 Hz |
| `emg_smooth_mean300`, `..._thresholded`, `..._rm_outliers`, `..._scaled` | the processing steps of Fig 2 (demean, rectify, smooth, threshold, artifact removal, scaling) |
| `state` | reference phase (`phase`) and the on/off `switch` marking each repetition |
| `refined_state` | the switch signal used to cut repetitions |
| `prediction`, `refined_prediction` | decoded phase with all channels |
| `refined_prediction_only_prox`, `refined_prediction_only_dist` | decoded phase with proximal or distal channels only |

Trial types are `GRASP10`, `GRIP10`, `PRONATE10` (first trials, 15 repetitions reduced to 10) and `GRASP25`, `GRIP25`, `PRONATE25` (second trials, 30 reduced to 25), plus `RELAX` (resting baseline). Channel names: `DELT_A`, `DELT_M`, `DELT_P`, `BIC_SH`, `BIC_LO`, `TRI_LAT`, `TRI_LO`, `BRR`, `FCR`, `FDS`, `FCU`, `ECR`, `EDC`, `ECU`, `ADP` (= APB) and `FSR`.

## Regenerating the figure data

`export_figure_data.m` reproduces the data-assembly part of the original figure scripts and writes `fig05_phase_traces.mat`, `fig06_phase_rmse.mat`, `fig07_predicted_distal.mat` and `fig08_predicted_proximal.mat`:

```matlab
addpath(genpath('/path/to/boxsci'))
export_figure_data('/path/to/dbData.mat', '/path/to/trial_files', '../data/task_templates.mat', '../data')
```

It needs the boxsci toolbox, `dbData.mat`, the 35 trial files and the task templates (`code/data/task_templates.mat`). The remaining data files (`fig03ab`, `fig03cde`, `task_templates`, `fig09`) were saved by the original pipeline and are included as is.

## Pipeline code

`pipeline/` contains the MATLAB packages used to process the recordings and run the decoder: `+utils` (reformatting, demeaning, moving-average, denoising and scaling), `+tmpsearch` (EMG processing, thresholds, template construction, chunk durations), `+offlinetest` (the simulated real-time stream and the phase decoder, `dls_decode.m` and `decode_phase_object.m`), `+plotting` and `+delcity` (helpers), with the driver scripts `compute_templates.m`, `test_decoding_in_rt.m`, `test_decoding_in_rt_time_tracking.m` (timing data of Fig 9) and `create_on_off_switch_signal.m`, and the filter and template files they read. They are provided for inspection; running them requires the database and the boxsci toolbox.
