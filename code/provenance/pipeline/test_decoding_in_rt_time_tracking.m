%% Cleaning functions and files

% CLEAR FUNCTIONS:
delcity.clean_functions(); 
delcity.clear_timers();

% CLOSE AND CLEAR OTHER FILES: 
clear all hidden;
close all hidden;
clc

delcity.clean_functions(); 
delcity.clear_timers();

% CLOSE AND CLEAR OTHER FILES: 
clear all hidden;
close all hidden;
clc
%% Get metadata

boxsci; 

% FETCH SIGNAL LIST: 
sSignalList = getMeta('metaSignal', qry('sTable', 'emgraw'), 'sSignal');
sSignalList = sSignalList(sSignalList~="tTime");

% LOAD FILTER PARAMETERS: 
load('FILTER.mat');

% SPECIFY SUBJ AND TRIAL:
idSubject    = 1; 
sTrialSuffix = "GRASP";

% TRIAL FOR DECODING: 
sTrialType       = char(sTrialSuffix + "25");
idTrialType_exp  = getMeta('metaTrialType', qry('sTrialType', sTrialType), 'idTrialType');
idTrial_exp      = getMeta('metaTrial', qry('idTrialType', idTrialType_exp, 'idSubject', idSubject), 'idTrial');
idSession        = getMeta('metaTrial', qry('idTrial', idTrial_exp), 'idSession');

% GET EMG-S:
Signal.sTable = 'emgraw'; 
nEMG_raw      = offlinetest.create_signal_matrix(Signal.sTable, sSignalList, sTrialType, idSubject);

% STATE SIGNALS:
Signal.sTable = 'state'; 
sSignalList = getMeta('metaSignal', qry('sTable', Signal.sTable), 'sSignal');
sSignalList = sSignalList(sSignalList~="tTime");
nState      = offlinetest.create_signal_matrix(Signal.sTable, sSignalList, sTrialType, idSubject);

% RESAMPLE STATE SIGNALS: 
nSampleList_old = linspace(0,1,length(nState));
nSampleList_new = linspace(0,1,length(nEMG_raw));
for iSignal = 1:size(nState,1)
    nState_resampled(iSignal,:) = interp1(nSampleList_old, nState(iSignal,:), nSampleList_new, 'linear');
end

% Make sure that after the resampling state remained a binary signal 
nState_resampled(1, nState_resampled(1,:) > 0) = 1; 
nSwitch = nState_resampled(1,:); 
nPhase  = nState_resampled(2,:); 

% INFORMATION FOR TEMPLATES:
sTrialType_template = char(sTrialSuffix + "25");
idTrialType         = getMeta('metaTrialType', qry('sTrialType', sTrialType_template), 'idTrialType');
idTrial             = getMeta('metaTrial', qry('idTrialType', idTrialType, 'idSubject', idSubject), 'idTrial');

nRate = 1925.925926; 

save('CURRENTWORKSPACE.mat')

%% Decode distal muscle activations 

% CLEAR FUNCTIONS:
delcity.clean_functions(); 
delcity.clear_timers();

% CLOSE AND CLEAR OTHER FILES: 
clear all hidden;
close all hidden;

load('CURRENTWORKSPACE.mat')

global tDecoding

% START STREAMING DATA:
hTimer     = offlinetest.stream_emg_and_phase_then_zeros('EMG', nEMG_raw, 'ACC', nSwitch, 'PHASE', nPhase);
COMPMA     = offlinetest.compute_ma('idSubject', idSubject, 'idTrial', idTrial);

%PLOT_CONTROL_SIG = offlinetest.plot_control_signal();
%PLOTREF          = offlinetest.plot_emg();
%PLOTMA           = offlinetest.plot_ma_hardcoded_limits();

% START DECODING:
DECODER          = offlinetest.decode_phase_object();
%PLOTPHASES       = offlinetest.plot_phases();


% % Pause while the decoder is working:
% pause(length(nPhase)/nRate*1.5)
% 
% % Fetch the predicted and streamed phases:
% nPhase_streamed  = offlinetest.box_phase([], 'nSampleOut', length(nPhase));
% nPhase_predicted = offlinetest.box_predicted_phase([], 'nSampleOut', length(nPhase));
% 
% figure; subplot(2,1,1); plot(nPhase_streamed); subplot(2,1,2); plot(nPhase_predicted);

%%

save("FIG7_B_decod_all4.mat", 'tDecoding');

%% Resample the predicted phase to match the original sampling

% Find where the first movement starts/last movement ends in predicted phase.
idxList            = find(nPhase_predicted~=0);
idxStart_predicted = idxList(1);
idxEnd_predicted   = idxList(end)+1;

% Find where the first movement starts/last movement ends in phase.
idxList  = find(nPhase~=0);
idxStart = idxList(1);
idxEnd   = idxList(end)+1;

nSample_segment           = idxStart:idxEnd; 
nSample_segment_predicted = idxStart_predicted:idxEnd_predicted; 

% Define the normalized time vectors
t_streamed  = linspace(0, 1, length(nSample_segment));
t_predicted = linspace(0, 1, length(nSample_segment_predicted));

nPhase_segment_predicted_resampled = interp1(t_predicted, nPhase_predicted(nSample_segment_predicted), t_streamed, 'linear');

nPhase_pred_full = nPhase; 
nPhase_pred_full(nSample_segment) = nPhase_segment_predicted_resampled; 

figure; plot(nPhase); hold on; plot(nPhase_pred_full)
% Get screen size
screenSize = get(0, 'ScreenSize');

% Set the figure size to screen width and proportional height
set(gcf, 'Position', [1, 1, screenSize(3), screenSize(4) * 0.5]);

%%

boxsci; 

setSignal(nPhase_pred_full', qry('sTable', 'refined_prediction_only_dist', 'sSignal', 'phase'), idTrial_exp, ...
                'nRate', nRate, ...
                'sUnit', 'n.u.', ...
                'idSession', idSession, ...
                'idTrialType', idTrialType_exp, ...
                'tSync', 0);

%%






























delcity.clean_functions(); 
delcity.clear_timers();

close all hidden 
clear all hidden 
clc

global sFilePredictedPhase sFilePhase bEnd

load('CURRENTWORKSPACE.mat')

bEnd = 0;

tSearchWindowList = [];

notes = table(); 

iCounter = 1; 

% How many EMG samples (time segment, ms) to use for decoding?
tEMGHistoryList = [1e-3, 10e-3, 25e-3, 50e-3, 75e-3, 100e-3, 250e-3];

for iHistory = 1:length(tEMGHistoryList)

    tEMGHistory = tEMGHistoryList(iHistory);

    % Scale search windowns based on the number of samples used for decod.
    tSearchWindowList = (2:5)*tEMGHistory;

    for iWindow = 1:length(tSearchWindowList)

        tSearchWindow = tSearchWindowList(iWindow);

        delcity.clean_functions(); 
        delcity.clear_timers();
        close all hidden 

        while ~bEnd

            hTimer     = offlinetest.stream_emg_and_phase('EMG', nEMG_raw, 'ACC', nSwitch, 'PHASE', nPhase);
            COMPMA     = offlinetest.compute_ma('idSubject', idSubject, 'idTrial', idTrial);
            
            %PLOT_CONTROL_SIG = offlinetest.plot_control_signal();
            %PLOTREF          = offlinetest.plot_emg();
            
            %PLOTMA           = offlinetest.plot_ma_hardcoded_limits();
            
            DECODER          = offlinetest.decode_phase_object();
            PLOTPHASES       = offlinetest.plot_phases();
            

        end

        offlinetest.box_predicted_phase([], 'bWriteForce', true); 
        offlinetest.box_phase([],           'bWriteForce', true); 

        notes.history(iCounter) = tEMGHistory; 
        notes.window(iCounter)  = tSearchWindow; 
        notes.samples(iCounter) = length(nPhase); 

        notes.sFileNamePredictPhase = sFileNamePredictPhase;
        notes.sFileNamePhase        = sFileNamePhase;
        
        bEnd = 0; 

        iCounter = iCounter+1;
    end
end












%%
save("DECODING_DURATION.mat", 'tDur')
%%


load('MOVMEAN_RT_STATS.mat', 'tDur')
tDur = tDur(2000:12000);

figure; boxchart(tDur); hold on; violinplot(tDur); 

numPointsUp75Percent = numel(tDur(tDur>(median(tDur)+iqr(tDur)*2)))
numPointsDown75Percent = numel(tDur(tDur<(median(tDur)+iqr(tDur)*2)))

disp('Mean')
mean(tDur)

dashedLine = median(tDur)+iqr(tDur)*2
yline(dashedLine)

%%


load('DECODING_DURATION.mat', 'tDur')
tDur = tDur(2000:12000);

figure; boxchart(tDur); hold on; violinplot(tDur); 

numPointsUp1MS = numel(tDur(tDur>(median(tDur)+iqr(tDur)*2)))
numPointsDown1MS = numel(tDur(tDur<(median(tDur)+iqr(tDur)*2)))

disp('Mean')
mean(tDur)

dashedLine = median(tDur)+iqr(tDur)*2
yline(dashedLine)
yline(1e-3)

%%
numChunks = 10; 

% Assuming nEMG_raw is an m x (N*10) matrix with 10 chunks of size m x N.
[m, totalSamples] = size(nEMG_raw);  % Get dimensions of nEMG_raw
N = totalSamples / numChunks;  % Number of columns per chunk
smoothedData = zeros(m, totalSamples);  % Preallocate for smoothed data

nWindow = 100; 

% DECODER PARAM-S: 
params    = offlinetest.decode_ini();

% SIMULATION PARAM-S: 
iCount       = 0;               % current trial ID (0)
tDelsys      = 13.5e-3;         % delay of Delsys packet, s

nMAarray = []; 

% REAL-TIME STIMULATOR: 
while iCount <= round(length(nEMG_filt)/(tDelsys*params.nRate)) %params.numTrial

    tStart = tic; 

    if iCount == 1 
        offlinetest.plot_emgs()
    end

    % BUFFER EMG: 
    nEMG_filt_rt = offlinetest.carousel_ma(nEMG_filt, params.nRate, tDelsys);
    offlinetest.box_ma(nEMG_filt_rt);

    nEMG_raw_rt  = offlinetest.carousel_emg(nEMG_raw, params.nRate, tDelsys);

    nEMG_raw_rt   = utils.denoise(nEMG_raw_rt, metaNoise, scalors_filt, idSubject, sSignalList);
    nEMG_filt_rt  = utils.movemean_rt(nEMG_raw_rt, nWindow);

    offlinetest.box_emg(nEMG_filt_rt);

    iCount = iCount + 1; 

    tEnd = toc(tStart); 

    % Check delays to ask for more data. 
    if tEnd < tDelsys
        pause(tDelsys - tEnd)
    end

end































