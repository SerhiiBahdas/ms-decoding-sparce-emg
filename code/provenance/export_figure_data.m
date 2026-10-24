function export_figure_data(dbFile, dataDir, templateFile, outDir)
% EXPORT_FIGURE_DATA  Extract the per-repetition data behind Figs 5-8 from the lab database.
%
%   export_figure_data(dbFile, dataDir, templateFile, outDir)
%
%   This is a provenance script. It reproduces the data-assembly steps of the
%   original figure scripts (FIG5a-f.m, FIG6c-n.m, FIG8.m, FIG9.m) and writes
%   small .mat files that the reviewer-facing plotting scripts load. Running it
%   requires the boxsci toolbox (https://github.com/Neural-Engineering-Laboratory/boxsci), the
%   study database (dbData.mat) and the 35 trial files (S0x_YYYY_MM_DD_TrialN.mat).
%
%   dbFile        path to dbData.mat
%   dataDir       folder with the trial files
%   templateFile  task_templates.mat (code/data) holding TEMPLATE.template.TMP100
%   outDir        destination folder for fig05..fig08 .mat files
%
%   Subject ids in the database map onto the manuscript as follows:
%   id 2 -> subject 1, id 3 -> subject 2, id 5 -> subject 3 (templates built from
%   their 25-repetition trials, tested on their 10-repetition trials), and
%   id 1 -> subject 4, the unobserved participant (25-repetition trials).

global dbData
S = load(dbFile);
dbData = S.dbData;
dbData.metaFile.sPath(:) = {dataDir};
tables = fieldnames(dbData.metaLoad);
for i = 1:numel(tables)
    dbData.metaLoad.(tables{i})(:) = false;   % force reading from the trial files
end
if ~exist(outDir, 'dir'), mkdir(outDir); end

RMSE = @(x, y) sqrt(mean((x(:) - y(:)).^2));
subjectLabel = containers.Map({2, 3, 5, 1}, {'subject 1', 'subject 2', 'subject 3', 'subject 4 (unobserved)'});

%% ---------------------------------------------------------------- Figs 5 and 6
configs = {'all',      'refined_prediction';
           'proximal', 'refined_prediction_only_prox';
           'distal',   'refined_prediction_only_dist'};
groups  = {[2 3 5], {'GRASP10', 'GRIP10', 'PRONATE10'};      % observed subjects, withheld 10-rep trials
           1,       {'GRASP25', 'GRIP25', 'PRONATE25'}};     % unobserved subject, 25-rep trials

rows   = {};
traces = struct();
for ic = 1:size(configs, 1)
    cfg = configs{ic, 1};
    Signal_ref        = struct('sTable', 'state',          'sSignal', 'phase');
    Signal_prediction = struct('sTable', configs{ic, 2},   'sSignal', 'phase');
    Signal_switch     = struct('sTable', 'refined_state',  'sSignal', 'switch');
    for ig = 1:size(groups, 1)
        for idSubject = groups{ig, 1}
            sTrialTypeList  = groups{ig, 2};
            idTrialTypeList = getMeta('metaTrialType', qry('sTrialType', sTrialTypeList, 'idSubject', idSubject), 'idTrialType');
            idTrialList     = getMeta('metaTrial', qry('idTrialType', idTrialTypeList, 'idSubject', idSubject), 'idTrial');
            nData_ref        = getSignal(idTrialList, Signal_ref, []);
            nData_prediction = getSignal(idTrialList, Signal_prediction, []);
            bData_switch     = getSignal(idTrialList, Signal_switch, []);
            for iTrial = 1:numel(idTrialList)
                idTrial    = idTrialList(iTrial);
                sTrialType = char(string(getMeta('metaTrial', qry('idTrial', idTrial), 'sTrialType')));
                task       = lower(regexprep(sTrialType, '\d+$', ''));

                nReference = nData_ref(:, iTrial);        nReference(isnan(nReference)) = [];
                nPrediction = nData_prediction(:, iTrial); nPrediction(isnan(nPrediction)) = [];
                bSwitch = bData_switch(:, iTrial);         bSwitch(isnan(bSwitch)) = [];

                nSampleList_ref       = linspace(0, 1, numel(nReference));
                nSampleList_predicted = linspace(0, 1, numel(nPrediction));
                nReference = interp1(nSampleList_ref, nReference, nSampleList_predicted);
                bSwitch    = interp1(nSampleList_ref, bSwitch,    nSampleList_predicted);
                bSwitch(bSwitch > 0) = 1;

                [~, idxStartList] = findpeaks(diff([0, bSwitch]));
                [~, idxEndList]   = findpeaks(-diff([0, bSwitch]));

                ref1000 = []; pred1000 = [];
                for iRep = 1:numel(idxStartList)
                    a = idxStartList(iRep); b = idxEndList(iRep);
                    r = nReference(a:b);  p = nPrediction(a:b);
                    rows(end + 1, :) = {cfg, idSubject, subjectLabel(idSubject), task, iRep, RMSE(r, p)}; %#ok<AGROW>
                    p2 = p; p2(end) = 0;                       % as in FIG6c-n.m
                    ref1000(end + 1, :)  = interp1(1:numel(r),  r,  linspace(1, numel(r),  1000), 'linear'); %#ok<AGROW>
                    pred1000(end + 1, :) = interp1(1:numel(p2), p2, linspace(1, numel(p2), 1000), 'linear'); %#ok<AGROW>
                end
                sid = sprintf('S%d', idSubject);
                traces.(cfg).(sid).(task).reference  = ref1000;
                traces.(cfg).(sid).(task).prediction = pred1000;
                fprintf('phase  %-8s %s %-10s %2d repetitions\n', cfg, sid, sTrialType, numel(idxStartList));
            end
        end
    end
end
rmse = struct('config', {rows(:, 1)}, 'subject_id', cell2mat(rows(:, 2)), 'subject', {rows(:, 3)}, ...
              'task', {rows(:, 4)}, 'repetition', cell2mat(rows(:, 5)), 'rmse', cell2mat(rows(:, 6)));
readme = ['rmse: struct of column arrays, one entry per movement repetition (struct2table(rmse) gives a table). config = EMG channels used for decoding ' ...
          '(all, proximal, distal); subject_id = database id; subject = manuscript label; ' ...
          'rmse = root-mean-square error between decoded and reference phase (n.u.).'];
save(fullfile(outDir, 'fig06_phase_rmse.mat'), 'rmse', 'readme');
readme = ['traces.(config).(S<id>).(task).reference / .prediction: repetitions x 1000 samples of ' ...
          'reference and decoded phase (n.u.), each repetition resampled to 1000 samples.'];
save(fullfile(outDir, 'fig05_phase_traces.mat'), 'traces', 'readme');

%% ---------------------------------------------------------------- Figs 7 and 8
T = load(templateFile);
tmp = T.TEMPLATE.template.TMP100;
sets = {'fig07_predicted_distal',   'refined_prediction_only_prox', ["BRR" "FDS" "FCU" "ECR" "EDC" "ECU" "ADP"];
        'fig08_predicted_proximal', 'refined_prediction_only_dist', ["DELT_A" "DELT_M" "DELT_P" "BIC_SH" "BIC_LO" "TRI_LAT"]};
nSigLen = 100;
idSubject = 1;                                     % manuscript subject 4
sTrialTypeList = {'GRASP25', 'GRIP25', 'PRONATE25'};
Signal_ref    = struct('sTable', 'state',         'sSignal', 'phase');
Signal_switch = struct('sTable', 'refined_state', 'sSignal', 'switch');
Signal_EMG    = struct('sTable', 'emg_smooth_mean300thresholded_rm_outliers_scaled', 'sSignal', '');
for is = 1:size(sets, 1)
    Signal_prediction = struct('sTable', sets{is, 2}, 'sSignal', 'phase');
    muscles   = sets{is, 3};
    nRate_emg = getMeta('metaSignal', qry('sTable', Signal_prediction.sTable, 'sSignal', 'phase'), 'nRate');
    idTrialTypeList = getMeta('metaTrialType', qry('sTrialType', sTrialTypeList, 'idSubject', idSubject), 'idTrialType');
    idTrialList     = getMeta('metaTrial', qry('idTrialType', idTrialTypeList, 'idSubject', idSubject), 'idTrial');
    nData_ref        = getSignal(idTrialList, Signal_ref, []);
    nData_prediction = getSignal(idTrialList, Signal_prediction, []);
    measured = struct(); predicted = struct(); template = struct();
    for iMuscle = 1:numel(muscles)
        sSignal = char(muscles(iMuscle));
        Signal_EMG.sSignal = sSignal;
        nEMG_fullsignal = getSignal(idTrialList, Signal_EMG, []);
        for iTrial = 1:numel(idTrialList)
            idTrial    = idTrialList(iTrial);
            sTrialType = char(string(getMeta('metaTrial', qry('idTrial', idTrial), 'sTrialType')));
            task       = lower(regexprep(sTrialType, '\d+$', ''));
            nTemplate  = tmp.(sTrialType).(sSignal);
            template.(task).(sSignal) = nTemplate(:);

            nReference = nData_ref(:, iTrial);         nReference(isnan(nReference)) = [];
            nPrediction = nData_prediction(:, iTrial); nPrediction(isnan(nPrediction)) = [];
            nEMG = nEMG_fullsignal(:, iTrial);         nEMG(isnan(nEMG)) = [];

            nSampleList_predicted = linspace(0, 1, numel(nPrediction));
            nEMG       = interp1(linspace(0, 1, numel(nEMG)),       nEMG,       nSampleList_predicted);
            nReference = interp1(linspace(0, 1, numel(nReference)), nReference, nSampleList_predicted); %#ok<NASGU>

            tEvent = getEvent(idTrial, Signal_switch, 1, []);  idxStartList = round(tEvent * nRate_emg);
            tEvent = getEvent(idTrial, Signal_switch, 2, []);  idxEndList   = round(tEvent * nRate_emg);

            for iRep = 1:numel(idxStartList)
                a = idxStartList(iRep); b = idxEndList(iRep);
                n = numel(a:b); newPoints = linspace(1, n, nSigLen);
                nPrediction_tmp = interp1(1:n, nPrediction(a:b), newPoints, 'linear');
                nEMG_tmp        = interp1(1:n, nEMG(a:b),        newPoints, 'linear');
                nEMG_predicted  = nTemplate(min(nSigLen, round(nPrediction_tmp * nSigLen) + 1));
                nEMG_predicted(nEMG_predicted > 1) = 1;
                if ~isfield(measured, task) || ~isfield(measured.(task), sSignal)
                    measured.(task).(sSignal)  = nEMG_tmp(:);
                    predicted.(task).(sSignal) = nEMG_predicted(:);
                else
                    measured.(task).(sSignal)(:, end + 1)  = nEMG_tmp(:);
                    predicted.(task).(sSignal)(:, end + 1) = nEMG_predicted(:);
                end
            end
        end
        fprintf('emg    %-26s %-8s done\n', sets{is, 1}, sSignal);
    end
    muscle_labels = struct('ADP', 'APB');               % database name -> manuscript name
    muscles = cellstr(muscles);
    readme = ['measured.(task).(muscle) and predicted.(task).(muscle): 100 samples x repetitions of ' ...
              'normalized muscle activity (n.u.) for the unobserved participant (subject 4, database id 1). ' ...
              'predicted = task template indexed by the phase decoded from the ' ...
              strrep(sets{is, 2}, 'refined_prediction_only_', '') ' channels only. ' ...
              'template.(task).(muscle): the 100-sample template. The database calls APB "ADP".'];
    save(fullfile(outDir, [sets{is, 1} '.mat']), 'measured', 'predicted', 'template', 'muscles', 'muscle_labels', 'readme');
end
disp('export complete');
end
