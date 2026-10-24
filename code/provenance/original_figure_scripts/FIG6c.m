% CLOSE AND CLEAR OTHER FILES: 
%clear all hidden
%close all hidden


boxsci; 

RMSE  = @(x,y) sqrt(sum((x(:) - y(:)).*(x(:) - y(:)))/numel(x));

nRate = 1925.93;

% Create the table and a counter:
rmsetable = table(); 
iCount    = 1; 

clear signals

idSubjectList   = [2];

for iSubject = 1:length(idSubjectList)

    idSubject       = idSubjectList(iSubject);

    sTrialTypeList  = {'GRASP10', 'GRIP10', 'PRONATE10'};
    idTrialTypeList = getMeta('metaTrialType', qry('sTrialType', sTrialTypeList, 'idSubject', idSubject), 'idTrialType');
    idTrialList     = getMeta('metaTrial', qry('idTrialType', idTrialTypeList, 'idSubject', idSubject), 'idTrial');
    
    Signal_ref.sTable  = 'state';
    Signal_ref.sSignal = 'phase';
    
    Signal_prediction.sTable  = 'refined_prediction';
    Signal_prediction.sSignal = 'phase';
    
    Signal_switch.sTable  = 'refined_state';
    Signal_switch.sSignal = 'switch';
    
    nRate_acc = getMeta('metaSignal', qry('sTable', Signal_ref.sTable, 'sSignal', Signal_ref.sSignal), 'nRate');
    nRate_emg = getMeta('metaSignal', qry('sTable', Signal_prediction.sTable, 'sSignal', Signal_prediction.sSignal), 'nRate');
    
    nData_ref         = getSignal(idTrialList, Signal_ref,[]);
    nData_prediction  = getSignal(idTrialList, Signal_prediction,[]);
    bData_switch      = getSignal(idTrialList, Signal_switch,[]);

    for iTrial = 1:length(idTrialList)
    
        idTrial     = idTrialList(iTrial);

        idTrialType = getMeta('metaTrial', qry('idTrial', idTrial), 'idTrialType');
    
        sTrialType  = getMeta('metaTrial', qry('idTrial', idTrial), 'sTrialType');

        nReference = nData_ref(:,iTrial);
        nReference(isnan(nReference)) = []; 
    
        nPrediction = nData_prediction(:,iTrial);
        nPrediction(isnan(nPrediction)) = []; 
    
        bSwitch = bData_switch(:,iTrial);
        bSwitch(isnan(bSwitch)) = []; 
    
        nSampleList_ref       = linspace(0,1,length(nReference));
        nSampleList_predicted = linspace(0,1,length(nPrediction));
    
        nReference = interp1(nSampleList_ref, nReference, nSampleList_predicted);
        bSwitch    = interp1(nSampleList_ref, bSwitch, nSampleList_predicted);
        bSwitch(bSwitch>0) = 1; 
    
        [~,idxStartList] = findpeaks(diff([0, bSwitch])); 
        [~,idxEndList]   = findpeaks(-diff([0, bSwitch])); 

        nReference_cut   = []; 
        nPrediction_cut  = [];

        for iRep = 1:length(idxStartList)
    
            idxStart = idxStartList(iRep);
            idxEnd   = idxEndList(iRep);
        
            nReference_tmp  = nReference(idxStart:idxEnd);
            nPrediction_tmp = nPrediction(idxStart:idxEnd);
            nPrediction_tmp(end) = 0; 
        
            % Resample to 1000 points
            numPoints = length(nReference_tmp);
            newPoints = linspace(1, numPoints, 1000); % New indices for 1000 points
            originalPoints = 1:numPoints;
        
            % Interpolation for resampling
            nReference_tmp = interp1(originalPoints, nReference_tmp, newPoints, 'linear');
            nPrediction_tmp = interp1(originalPoints, nPrediction_tmp, newPoints, 'linear');

            nReference_cut   = [nReference_cut; nReference_tmp]; 
            nPrediction_cut  = [nPrediction_tmp; nPrediction_cut];

        end

        signals.("SUBJ" + idSubject).(string(sTrialType)).nReference  = nReference_cut; 
        signals.("SUBJ" + idSubject).(string(sTrialType)).nPrediction = nPrediction_cut; 

        title("SUBJ" + idSubject + "TRIALTYPE: " + sTrialType)

        %figure; plot(nReference_cut); hold on; plot(nPrediction_cut)
        disp("TRIAL" + iTrial + " DONE")
    
    end
end

plot_signals(signals)

%%

function plot_signals(signals)
    % plot_signals Visualizes mean and confidence intervals for signals.
    %
    %   plot_signals(signals) takes a structured input 'signals' where each
    %   subject has multiple trial types, and each trial type contains
    %   nReference and nPrediction matrices. The function generates a figure
    %   with subplots for each subject, displaying the mean and 95% confidence
    %   intervals for each trial type's nReference and nPrediction data.

    % Retrieve all subject field names
    subjectNames = fieldnames(signals);
    numSubjects = length(subjectNames);

    % Determine subplot grid size (approx. square layout)
    nRows = ceil(sqrt(numSubjects));
    nCols = ceil(numSubjects / nRows);

    % Create a new figure
    figure('Name', 'Signal Means and Confidence Intervals', 'NumberTitle', 'off');
    
    % Loop through each subject
    for i = 1:numSubjects
        subj = subjectNames{i};
        trialTypes = fieldnames(signals.(subj));
        numTrialTypes = length(trialTypes);
        
        % Select subplot
        subplot(nRows, nCols, i);
        hold on;
        
        % Define color map for plotting (different colors for each trial type)
        cmap = lines(numTrialTypes * 2); % Two colors per trial type (Reference & Prediction)
        
        % Loop through each trial type
        for j = 1:numTrialTypes
            trial = trialTypes{j};
            
            % Extract nReference and nPrediction matrices
            nRef = signals.(subj).(trial).nReference;   % m x n
            nPred = signals.(subj).(trial).nPrediction; % m x n

            % Cut the reset for better visualization. 
            % nRef = nRef(:, 1:end-5);
            % nPred = nPred(:, 1:end-5);
            
            % Ensure matrices are non-empty
            if isempty(nRef) || isempty(nPred)
                warning('Empty data for %s - %s. Skipping.', subj, trial);
                continue;
            end
            
            % Compute mean and standard error for nReference
            meanRef = mean(nRef, 1);
            semRef = std(nRef, 0, 1) / sqrt(size(nRef,1));
            ciRef = 1.96 * semRef; % 95% CI
            
            % Compute mean and standard error for nPrediction
            meanPred = mean(nPred, 1);
            semPred = std(nPred, 0, 1) / sqrt(size(nPred,1));
            ciPred = 1.96 * semPred; % 95% CI
            
            % Define x-axis (sample indices)
            x = 1:size(nRef,2);
            
            % Plot nReference mean
            plot(x, meanRef, 'Color', cmap(2*j-1,:), 'LineWidth', 1.5, 'DisplayName', [trial ' Reference']);
            % Plot nReference confidence interval as shaded area
            fill([x fliplr(x)], [meanRef - ciRef fliplr(meanRef + ciRef)], ...
                 cmap(2*j-1,:), 'FaceAlpha', 0.2, 'EdgeColor', 'none');
             
            % Plot nPrediction mean
            plot(x, meanPred, 'Color', cmap(2*j,:), 'LineWidth', 1.5, 'DisplayName', [trial ' Prediction']);
            % Plot nPrediction confidence interval as shaded area
            fill([x fliplr(x)], [meanPred - ciPred fliplr(meanPred + ciPred)], ...
                 cmap(2*j,:), 'FaceAlpha', 0.2, 'EdgeColor', 'none');
        end
        
        % Customize subplot
        title(subj, 'Interpreter', 'none');
        xlabel('Sample Index');
        ylabel('Signal Value');
        legend('Location', 'best', 'Interpreter', 'none');
        hold off;
        ylim([0,1]);
    end
    
    % Add a super title to the figure
    sgtitle('Mean and 95% Confidence Intervals for Each Subject and Trial Type');
    
end
