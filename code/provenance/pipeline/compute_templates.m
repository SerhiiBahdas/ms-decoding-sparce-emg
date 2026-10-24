%% SECTION 1. Session setup and data reformatting 

% CLOSE AND CLEAR OTHER FILES: 
clear all hidden;
close all hidden;
clc

% Set the base directory path to the current directory
sPath = cd;

% Define the folder name where raw data is stored
nFolder_rawdata = "rawdata";

% List of subject folders to be processed
sFolderList_subject = ["S01_2024_11_17", "S02_2024_11_15", "S03_2024_11_17", "S04_2024_11_27", "S05_2024_11_28"];

% Call the function to reformat raw files for each subject
% tmpsearch.reformat_raw_files(sPath, sFolderList_subject, nFolder_rawdata);

%% SECTION 2. Loading reformatted data in/from boxsci

boxsci; 

bPlot = 0;

% Flag indicating whether to save the processed signals to the new table
bSetSignal = 1; 

% Define the sampling rate of the signals
nRate = 148.1481;

% Cutoff frequency, Hz. 
nRate_cutoff = 10; 

% List of trial types to process
sTrialTypeList = {'GRASP10', 'GRASP25', 'GRIP10', 'GRIP25', 'PRONATE10', 'PRONATE25', 'RELAX'};

% Retrieve the list of signal names from 'emgraw'.
sSignalList = getMeta('metaSignal', qry('sTable', 'accraw'), 'sSignal');

% Retrieve the list of trial IDs corresponding to the specified trial types
idTrialList = getMeta('metaTrial', qry('sTrialType', sTrialTypeList), 'idTrial');

% Table where processed EMG signals will be stored
sTable_old = 'accraw';
sTable_new = char("accproc" + nRate_cutoff + "Hz");

tmpsearch.smooth_acc(idTrialList, sSignalList, nRate, nRate_cutoff, sTable_old, sTable_new, bSetSignal, bPlot)

%% SECTION 3. Find noise boundaries from relaxed trial

% Set the flag to 0--no plots for the signals and noise bounds.
bPlot       = 0;

sFolderList_subject = ["S01_2024_11_17", "S02_2024_11_15", "S03_2024_11_17", "S04_2024_11_27", "S05_2024_11_28"];

% Specify the trial type as "RELAX" for querying the subject data.
sTrialType  = "RELAX";

% Retrieve the list of signal names from 'emgraw'.
sSignalList = getMeta('metaSignal', qry('sTable', 'emgraw'), 'sSignal');

% Compute noise bounds for the signals in subject.
metaNoise   = tmpsearch.get_noise_statistics(sFolderList_subject, sTrialType, sSignalList, bPlot);

%% Smooth signals with a time window 

nWindow = 300; % Samples 

% Flag indicating whether to save the processed signals to the new table
bSetSignal = 1; 

% Define the sampling rate of the signals
nRate = 1925.925926;

% List of trial types to process
sTrialTypeList = {'GRASP10', 'GRASP25', 'GRIP10', 'GRIP25', 'PRONATE10', 'PRONATE25', 'RELAX'};

% Retrieve the list of trial IDs corresponding to the specified trial types
idTrialList = getMeta('metaTrial', qry('sTrialType', sTrialTypeList), 'idTrial');

% Retrieve the list of signal names from 'emgraw'.
sSignalList = getMeta('metaSignal', qry('sTable', 'emgraw'), 'sSignal');

% Table where processed EMG signals will be stored
sTable_new = char("emg_smooth_mean" + nWindow);

tmpsearch.smooth_emg(idTrialList, sSignalList, metaNoise, nRate, 'emgraw', sTable_new, nWindow, 'mean', bSetSignal, 1, bPlot)

%% Establish noise thresholds using Sergiy's method

bPlot          = 0; 

% Table name. 
sTable         = char("emg_smooth_mean" + nWindow);

% List of trial types to process
sTrialTypeList = {'GRASP10', 'GRASP25', 'GRIP10', 'GRIP25', 'PRONATE10', 'PRONATE25', 'RELAX'};

% Retrieve the list of trial IDs corresponding to the specified trial types
idTrialList    = getMeta('metaTrial', qry('sTrialType', sTrialTypeList), 'idTrial');

% Retrieve the list of signal names from 'emgraw'.
sSignalList    = getMeta('metaSignal', qry('sTable', 'emgraw'), 'sSignal');

% Fetch all singals in one matrix. 
signals        = tmpsearch.collect_all_data(sTable, idTrialList, sSignalList);

% Get thresholds with Sergiy's method.
thresholds     = tmpsearch.compute_signal_thresholds(signals, bPlot);
%scalors        = tmpsearch.compute_signal_scalors(signals, bPlot);

%% Establish noise thresholds using Sergiy's method

% Table where processed EMG signals will be stored
sTable_old = char("emg_smooth_mean" + nWindow);
sTable_new = char("emg_smooth_mean" + nWindow + "thresholded");

tmpsearch.threshold_emg(idTrialList, sSignalList, thresholds, nRate, sTable_old, sTable_new, bSetSignal, bPlot)

%% Remove outliers in the smoothed data. 

% Table where processed EMG signals will be stored

sTable_old = char("emg_smooth_mean" + nWindow + "thresholded");
sTable_new = char("emg_smooth_mean" + nWindow + "thresholded_" + "rm_outliers");

zscoring = tmpsearch.remove_outliers(idTrialList, sSignalList, nRate, sTable_old, sTable_new, bSetSignal, 0);

%% Scale the data 

sTable_old = char("emg_smooth_mean" + nWindow + "thresholded_" + "rm_outliers");
sTable_new = char("emg_smooth_mean" + nWindow + "thresholded_" + "rm_outliers_" + "scaled");

signals    = tmpsearch.collect_all_trials(sTable_old, idTrialList, sSignalList);
scalors    = tmpsearch.compute_scalors_per_trial(signals, bPlot);

tmpsearch.scale_emg_per_trial(idTrialList, sSignalList, scalors, nRate, sTable_old, sTable_new, bSetSignal, bPlot)

%% Find average phase durations

% Define the list of trial types to analyze
sTrialTypeList = {'GRASP25', 'GRIP25', 'PRONATE25'}; 

% Specify the signal to be processed (e.g., 'FDS_y') and the table ('accproc')
Signal1.sTable  = 'accproc10Hz';
Signal1.sSignal = 'ADP_y';

% If the ADP signal is missing try this one: 
SignalBackup.sTable  = 'accproc10Hz';
SignalBackup.sSignal = 'FDS_y';

Signal2.sTable  = 'emgraw';
Signal2.sSignal = 'FSR';

idSubjectList   = [2, 3, 5];

% Compute the relative phase duration for the specified trial types and subjects
relative_phase_duration = tmpsearch.compute_relative_phase_duration(idSubjectList, sTrialTypeList, Signal1, Signal2, SignalBackup);

phase_duration = tmpsearch.compute_phase_duration(idSubjectList, sTrialTypeList, Signal1, Signal2, SignalBackup);

% Compute the average relative phase duration across trials and subjects
phase_percent = tmpsearch.compute_average_phase_duration(relative_phase_duration);

save('FIG_PHASE_DURATION.mat', 'phase_duration');

%% Get templates

clear template 

nWindow = 300; 

bPlot         = 1;
idSubjectList = [2, 3, 5]; %ATTENTION!!! CHANGE THIS BACK TO [2, 3, 5]

% Define the list of trial types to analyze
sTrialTypeList = {'GRASP25', 'GRIP25', 'PRONATE25'}; 

% Define the event signal and the table where the event information is stored
Signal_event1.sTable  = 'accproc10Hz';
Signal_event1.sSignal = 'ADP_y';

Signal_event2.sTable  = 'emgraw';
Signal_event2.sSignal = 'FSR';

% Define the table for EMG signals and the corresponding window size
Signal.sTable  = char("emg_smooth_mean" + nWindow + "thresholded_" + "rm_outliers_" + "scaled");

% Retrieve the sampling rate from the metadata for the signal table
nRate = getMeta('metaSignal', qry('sTable', 'emgraw'), 'nRate'); 
nRate = nRate(1);

% Retrieve the list of signals (EMG signals) from the metadata for the specified table
sSignalList = getMeta('metaSignal', qry('sTable', Signal.sTable), 'sSignal');

% List of template lengths (number of samples) to be used for interpolation
nTemplateLenList = [100, 1000];

% Call the get_templates function to interpolate and retrieve the signal templates
template = tmpsearch.get_templates(idSubjectList, nTemplateLenList, sTrialTypeList, sSignalList, phase_percent, Signal, Signal_event1, Signal_event2);

clear nTempLenList
global nTempLenList

mean(nTempLenList)

tmpsearch.plot_templates(template);


%% Save templates

sSignalList      = ["DELT_A" "DELT_M" "DELT_P" "BIC_SH" "BIC_LO" "TRI_LAT" "TRI_LO" "BRR" "FCR" "FDS" "FCU" "ECR" "EDC" "ECU" "ADP" "FSR"];
sSignalList_prox = ["DELT_A" "DELT_M" "DELT_P" "BIC_SH" "BIC_LO" "TRI_LAT" "TRI_LO"];
sSignalList_dist = ["BRR" "FCR" "FDS" "FCU" "ECR" "EDC" "ECU" "ADP"];

idProxList       = find(contains(sSignalList, sSignalList_prox));
idDistList       = find(contains(sSignalList, sSignalList_dist));

TEMPLATE.template    = template;
TEMPLATE.sSignalList = sSignalList;
TEMPLATE.idProxList  = idProxList;
TEMPLATE.idDistList  = idDistList;

save('TEMPLATE.mat', "TEMPLATE")
save('FILTER.mat', 'metaNoise', 'thresholds', 'scalors', 'zscoring')

