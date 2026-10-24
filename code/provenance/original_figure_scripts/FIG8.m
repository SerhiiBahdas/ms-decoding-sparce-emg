% CLOSE AND CLEAR OTHER FILES: 
%clear all hidden
%close all hidden
close all 

boxsci; 

RMSE  = @(x,y) sqrt(sum((x(:) - y(:)).*(x(:) - y(:)))/numel(x));

nRate = 1925.93;

% Create the table and a counter:
rmsetable = table(); 
iCount    = 1; 

clear signals_predicted signal M_RMSE M_PEARSON

idSubjectList   = [1];
sSignalList     = ["BRR" "FDS" "FCU" "ECR" "EDC" "ECU" "ADP"];
%sSignalList     = ["BRR" "FCR" "FDS" "FCU" "ECR" "EDC" "ECU" "ADP"];

sTemplateName   = 'TMP100';

nSigLen = 100;

signals_predicted = struct();
signal           = struct();

tmp = load('TEMPLATE.mat');
tmp = tmp.TEMPLATE.template.(sTemplateName);

Signal_ref.sTable  = 'state';
Signal_ref.sSignal = 'phase';

Signal_prediction.sTable  = 'refined_prediction_only_prox';
Signal_prediction.sSignal = 'phase';

Signal_switch.sTable  = 'refined_state';
Signal_switch.sSignal = 'switch';

Signal_EMG.sTable = 'emg_smooth_mean300thresholded_rm_outliers_scaled';

sTrialTypeList  = {'GRASP25', 'GRIP25', 'PRONATE25'};

nRate_acc       = getMeta('metaSignal', qry('sTable', Signal_ref.sTable, 'sSignal', Signal_ref.sSignal), 'nRate');
nRate_emg       = getMeta('metaSignal', qry('sTable', Signal_prediction.sTable, 'sSignal', Signal_prediction.sSignal), 'nRate');
        
for iSignal_emg = 1:length(sSignalList)

    sSignal = char(sSignalList(iSignal_emg));

    for iSubject = 1:length(idSubjectList)
    
        idSubject          = idSubjectList(iSubject);
    
        idTrialTypeList    = getMeta('metaTrialType', qry('sTrialType', sTrialTypeList, 'idSubject', idSubject), 'idTrialType');
        idTrialList        = getMeta('metaTrial', qry('idTrialType', idTrialTypeList, 'idSubject', idSubject), 'idTrial');
        
        nData_ref          = getSignal(idTrialList, Signal_ref,[]);
        nData_prediction   = getSignal(idTrialList, Signal_prediction,[]);
        
        Signal_EMG.sSignal = sSignal;

        nEMG_fullsignal    = getSignal(idTrialList, Signal_EMG,[]);
        
        for iTrial = 1:length(idTrialList)
        
            idTrial     = idTrialList(iTrial);

            disp("IDTRIAL" + idTrial)
            disp("SIG:" + string(sSignal))
    
            sTrialType  = getMeta('metaTrial', qry('idTrial', idTrial), 'sTrialType');
    
            nTemplate   = tmp.(char(sTrialType)).(sSignal);  

            nReference = nData_ref(:,iTrial);
            nReference(isnan(nReference)) = []; 
        
            nPrediction = nData_prediction(:,iTrial);
            nPrediction(isnan(nPrediction)) = []; 

            nEMG    = nEMG_fullsignal(:,iTrial);
            nEMG(isnan(nEMG)) = []; 

            nSampleList_ref       = linspace(0,1,length(nReference));
            nSampleList_predicted = linspace(0,1,length(nPrediction));
            nSampleList_emg       = linspace(0,1,length(nEMG));
 
            nEMG       = interp1(nSampleList_emg, nEMG,       nSampleList_predicted);
            nReference = interp1(nSampleList_ref, nReference, nSampleList_predicted);

            [tEvent,~,~,~] = getEvent(idTrial,Signal_switch,1,[]);
            idxStartList   = round(tEvent*nRate_emg);

            [tEvent,~,~,~] = getEvent(idTrial,Signal_switch,2,[]);
            idxEndList     = round(tEvent*nRate_emg);

            nReference_cut   = []; 
            nPrediction_cut  = [];
    
            for iRep = 1:length(idxStartList)

                if (iRep == 1) && strcmp(sSignal, "FCU") && strcmp(sTrialType, "GRIP25")
                    disp("")
                end

                idxStart = idxStartList(iRep);
                idxEnd   = idxEndList(iRep);
            
                nReference_tmp  = nReference(idxStart:idxEnd);
                nPrediction_tmp = nPrediction(idxStart:idxEnd);

                nEMG_tmp = nEMG(idxStart:idxEnd);
            
                % Resample to 100 points
                numPoints = length(nReference_tmp);
                newPoints = linspace(1, numPoints, nSigLen); % New indices for 1000 points
                originalPoints = 1:numPoints;
            
                % Interpolation for resampling
                nReference_tmp  = interp1(originalPoints, nReference_tmp,  newPoints, 'linear');
                nPrediction_tmp = interp1(originalPoints, nPrediction_tmp, newPoints, 'linear');

                %figure; plot(nReference_tmp); hold on; plot(nPrediction_tmp);plot(linspace(1,length(nPrediction_tmp), length(nPrediction_tmp)/10), nPrediction_tmp(1:10:end));
                
                % This is the recorded EMG
                nEMG_tmp        = interp1(originalPoints, nEMG_tmp, newPoints, 'linear');
                nEMG_predicted  = nTemplate(min(nSigLen, round(nPrediction_tmp*nSigLen)+1));
                nEMG_predicted(nEMG_predicted>1) = 1; 

                %figure; plot(nEMG_tmp); hold on; plot(nEMG_predicted);

                % ASSIGNING PREDICTED DATA: 

                % Define the field names based on input variables
                subjField      = "SUBJ" + idSubject;
                trialTypeField = char(sTrialType);          
                signalField    = sSignal; 
                
                % Check if the subject field exists; if not, create it as an empty struct
                if ~isfield(signals_predicted, subjField)
                    signals_predicted.(subjField) = struct();
                end
                
                % Check if the trial type field exists within the subject field; if not, create it
                if ~isfield(signals_predicted.(subjField), trialTypeField)
                    signals_predicted.(subjField).(trialTypeField) = struct();
                end
                
                % Check if the signal field exists within the trial type field
                if ~isfield(signals_predicted.(subjField).(trialTypeField), signalField)
                    % If the signal field does not exist, assign the data directly
                    signals_predicted.(subjField).(trialTypeField).(signalField) = nEMG_predicted(:);
                else
                    % If the signal field exists, append the new data as a new column
                    existingData = signals_predicted.(subjField).(trialTypeField).(signalField);
                    
                    % Ensure existing data is a column vector for consistent concatenation
                    if isrow(existingData)
                        existingData = existingData';
                    end
                    
                    % Append the new data as a new column
                    signals_predicted.(subjField).(trialTypeField).(signalField) = [existingData, nEMG_predicted(:)];
                end

                % ASSIGNING RECORDED DATA: 

                if ~isfield(signal, subjField)
                    signal.(subjField) = struct();
                end
                
                % Check if the trial type field exists within the subject field; if not, create it
                if ~isfield(signal.(subjField), trialTypeField)
                    signal.(subjField).(trialTypeField) = struct();
                end
                
                % Check if the signal field exists within the trial type field
                if ~isfield(signal.(subjField).(trialTypeField), signalField)
                    % If the signal field does not exist, assign the data directly
                    signal.(subjField).(trialTypeField).(signalField) = nEMG_tmp(:);
                else
                    % If the signal field exists, append the new data as a new column
                    existingData = signal.(subjField).(trialTypeField).(signalField);
                    
                    % Ensure existing data is a column vector for consistent concatenation
                    if isrow(existingData)
                        existingData = existingData';
                    end
                    
                    % Append the new data as a new column
                    signal.(subjField).(trialTypeField).(signalField) = [existingData, nEMG_tmp(:)];
                end

            end
    
            title("SUBJ" + idSubject + "TRIALTYPE: " + sTrialType)
    
            %figure; plot(nReference_cut); hold on; plot(nPrediction_cut)
            disp("TRIAL" + iTrial + " DONE")
        
        end
    end
end




notes.GRASP25   = plotMeanAndSD(signal, signals_predicted, 'GRASP25');
notes.GRIP25    = plotMeanAndSD(signal, signals_predicted, 'GRIP25');
notes.PRONATE25 = plotMeanAndSD(signal, signals_predicted, 'PRONATE25');

for iTrialType = 1:length(sTrialTypeList)
    sTrialType = sTrialTypeList(iTrialType);
    for iMuscle = 1:length(sSignalList)
        M_RMSE(iMuscle, iTrialType)    = round(notes.(string(sTrialType)).("SUBJ" + idSubjectList).(sSignalList(iMuscle)).RMSE,2);
        M_PEARSON(iMuscle, iTrialType) = round(notes.(string(sTrialType)).("SUBJ" + idSubjectList).(sSignalList(iMuscle)).Pearson,2);
    end
end

figure; heatmap(M_PEARSON, 'ColorLimits',[0 1]);
colormap(flip(sky))
figure; heatmap(M_RMSE,    'ColorLimits',[0 1]);
colormap(flip(gray))

function notes = plotMeanAndSD(signal, signal_predict, trialType)
% PLOTMEANANDSD Plots mean and standard deviations of signals for each subject
% 
% Parameters:
% signal: Structure containing subject and trial type data (e.g., signal.SUBJ1.GRASP25.BRR)
% signal_predict: Structure containing predicted data for each subject and trial type
% trialType: String specifying the trial type to visualize (e.g., 'GRASP25')

    notes = struct(); 

    % Get all subject names (fieldnames of the signal structure)
    subjectNames = fieldnames(signal);

    % Iterate through each subject
    for i = 1:numel(subjectNames)
        subject = subjectNames{i};
        
        % Check if the trial type exists for the subject in both structures
        if isfield(signal.(subject), trialType) && isfield(signal_predict.(subject), trialType)
            % Get all signal names (fieldnames under the trial type)
            signalNames = fieldnames(signal.(subject).(trialType));

            % Create a new figure for the subject
            figure;
            
            % Set figure size
            screenSize = get(0, 'ScreenSize'); % Get the screen size in pixels
            figureHeight = screenSize(4); % Use the full screen height
            set(gcf, 'Units', 'pixels', 'Position', [100, 100, 200, figureHeight]);

            numSignals = numel(signalNames);

            for j = 1:numSignals
                signalName = signalNames{j};

                % Extract the data matrix for the specified signal
                dataMatrix = signal.(subject).(trialType).(signalName); % n x m matrix
                predictedMatrix = signal_predict.(subject).(trialType).(signalName); % n x m matrix

                if any(isnan(dataMatrix))
                    disp("nans found");
                end

                % Calculate mean and standard deviations for signal
                [meanSignal, lowerSDSignal, upperSDSignal] = computeMeanAndSD(dataMatrix);

                % Calculate mean and standard deviations for predicted signal
                [meanPredict, lowerSDPredict, upperSDPredict] = computeMeanAndSD(predictedMatrix);

                % Compute Pearson correlation coefficient
                r = corr(meanSignal, meanPredict);
                R = sqrt(sum((meanSignal(:) - meanPredict(:)).*(meanSignal(:) - meanPredict(:)))/numel(meanSignal));

                notes.(subject).(signalName).RMSE    = R; 
                notes.(subject).(signalName).Pearson = r; 

                % Create subplot
                subplot(numSignals, 1, j);
                hold on;
                % Plot actual signal
                plot(meanSignal, 'k', 'LineWidth', 1.5, 'DisplayName', 'Mean (Signal)');
                fill([1:length(meanSignal), fliplr(1:length(meanSignal))], ...
                     [upperSDSignal', fliplr(lowerSDSignal')], ...
                     'k', 'FaceAlpha', 0.2, 'EdgeColor', 'none', 'DisplayName', 'SD (Signal)');

                % Plot predicted signal
                plot(meanPredict, 'r', 'LineWidth', 1.5, 'DisplayName', 'Mean (Predicted)');
                fill([1:length(meanPredict), fliplr(1:length(meanPredict))], ...
                     [upperSDPredict', fliplr(lowerSDPredict')], ...
                     'r', 'FaceAlpha', 0.2, 'EdgeColor', 'none', 'DisplayName', 'SD (Predicted)');

                % Display Pearson correlation
                text(0.1, 0.9, sprintf('r = %.2f', r), 'Units', 'normalized', 'FontSize', 10, 'Color', 'k');
                text(0.3, 0.9, sprintf('RMSE = %.2f', R), 'Units', 'normalized', 'FontSize', 10, 'Color', 'k');

                hold off;

                % Customize subplot
                title([subject ' - ' trialType]);
                xlabel('Samples');
                ylabel(signalName);
                %legend;
                %grid on;
                ylim([0,1])
            end
        else
            warning('Trial type "%s" does not exist for subject "%s" in one or both structures.', trialType, subject);
        end
    end
end

function [meanSignal, lowerSD, upperSD] = computeMeanAndSD(dataMatrix)
% COMPUTEMEANANDSD Computes the mean and standard deviations of the input data
% 
% Parameters:
% dataMatrix: n x m matrix where n is the number of samples and m is the number of trials
% 
% Returns:
% meanSignal: Mean of the signal across trials
% lowerSD: Lower bound of the standard deviation
% upperSD: Upper bound of the standard deviation

    % Calculate the mean across trials (columns)
    meanSignal = mean(dataMatrix, 2);

    % Calculate the standard deviation across trials
    sd = std(dataMatrix, 0, 2);

    % Compute standard deviation bounds
    lowerSD = meanSignal - sd;
    upperSD = meanSignal + sd;
end

