% CLOSE AND CLEAR OTHER FILES: 
%clear all hidden
%close all hidden

boxsci

RMSE = @(x,y) sqrt(sum((x(:) - y(:)).*(x(:) - y(:)))/numel(x));

% Create the table and a counter:
rmsetable = table(); 
iCount    = 1; 

idSubjectList   = [2,3,5];

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
    
        for iRep = 1:length(idxStartList)
    
            idxStart = idxStartList(iRep);
            idxEnd   = idxEndList(iRep);
        
            nReference_cut  = nReference(idxStart:idxEnd);
            nPrediction_cut = nPrediction(idxStart:idxEnd);
        
            %figure; plot(nReference_cut); hold on; plot(nPrediction_cut)
            
            rmsetable.subject(iCount)   = idSubject; 
            rmsetable.trialtype(iCount) = idTrialType; 
            rmsetable.rep(iCount)       = iRep; 
            rmsetable.rmse(iCount)      = RMSE(nReference_cut, nPrediction_cut);
    
            iCount = iCount + 1; 
        end
    
    end
end

%% PLOTTING RMSE AND DOING STAT-ANALYSIS

% THE ONLY VARIABLE YOU NEED TO BE LOADED HERE IS rmsetable.

% Ensure the variables are of appropriate types
rmsetable.subject = categorical(rmsetable.subject);
rmsetable.trialtype = categorical(rmsetable.trialtype);

% Extract unique categories
uniqueTrialTypes = unique(rmsetable.trialtype);
uniqueSubjects = unique(rmsetable.subject);

% Print mean ± std for each trial type
fprintf('Mean ± Std for each Trial Type:\n');
for t = 1:numel(uniqueTrialTypes)
    thesePoints = rmsetable(rmsetable.trialtype == uniqueTrialTypes(t), :);
    currMean = mean(thesePoints.rmse);
    currStd = std(thesePoints.rmse);
    fprintf('%s: %.3f ± %.3f\n', string(uniqueTrialTypes(t)), currMean, currStd);
end
fprintf('\n');

% Test Normality for Each Trial Type Using Anderson-Darling.
isNormal = true;
fprintf('Normality Test Results (Anderson-Darling test):\n');
for t = 1:numel(uniqueTrialTypes)
    thesePoints = rmsetable(rmsetable.trialtype == uniqueTrialTypes(t), :);
    dataVals = thesePoints.rmse;
    h = adtest(dataVals); % h=1 means reject normality at 5% level
    
    fprintf('%s: h=%d (1=reject normality, 0=fail to reject)\n', string(uniqueTrialTypes(t)), h);
    
    if h == 1
        isNormal = false;
    end
end
fprintf('\n');

% Depending on normality, choose appropriate statistical test.
if isNormal
    fprintf('All distributions appear normal. Using ANOVA.\n');
    [pAnova, tbl, stats] = anova1(rmsetable.rmse, rmsetable.trialtype, 'off');
    fprintf('ANOVA p-value: %.4f\n', pAnova);
    if pAnova < 0.05
        fprintf('Significant differences found. Performing multiple comparisons...\n');
        figure('Color','w');
        multcompare(stats, 'CType', "tukey-kramer");
    else
        fprintf('No significant difference by ANOVA.\n');
    end
else
    fprintf('Not all distributions are normal. Using Kruskal-Wallis.\n');
    [pKW, tbl, stats] = kruskalwallis(rmsetable.rmse, rmsetable.trialtype, 'off');
    fprintf('Kruskal-Wallis p-value: %.4f\n', pKW);
    if pKW < 0.05
        fprintf('Significant differences found. Performing multiple comparisons...\n');
        figure('Color','w');
        multcompare(stats, 'CType', "tukey-kramer");
    else
        fprintf('No significant difference by Kruskal-Wallis.\n');
    end
end

% Plotting

figure('Color', 'w'); % White background

% Plot the violin plots by trial type
violinplot(rmsetable.trialtype, rmsetable.rmse);
hold on;

% Plot the box chart by trialtype on top of violin plots
b = boxchart(rmsetable.trialtype, rmsetable.rmse, ...
    'BoxFaceColor', 'w', 'BoxEdgeColor', 'k', 'LineWidth', 1.5);
b.MarkerStyle = 'none';

% Assign distinct colors to each subject
numSubs = numel(uniqueSubjects);
cmap = lines(numSubs); 

% Convert subjects into indices for indexing colormap
[~,~,subIdx] = unique(rmsetable.subject);

% For each trial type, plot a swarm of points colored by subject
for t = 1:numel(uniqueTrialTypes)
    thesePoints = rmsetable(rmsetable.trialtype == uniqueTrialTypes(t), :);
    xVal = thesePoints.trialtype;    
    theseSubs = subIdx(rmsetable.trialtype == uniqueTrialTypes(t));
    theseColors = cmap(theseSubs, :);
    swarmchart(xVal, thesePoints.rmse, 36, theseColors, 'filled', 'MarkerFaceAlpha', 0.8);
end

% Label axes and title
xlabel('Trial Type', 'FontName', 'Arial', 'FontSize', 14);
ylabel('RMSE', 'FontName', 'Arial', 'FontSize', 14);
title('RMSE by Trial Type with Subject-wise Color Coding + Violin Plots', 'FontName', 'Arial', 'FontSize', 16);

% Aesthetics for the axes
set(gca, 'FontName', 'Arial', 'FontSize', 12, 'LineWidth', 1.5);
box on;

% Create a legend for the subjects
hold on;
for i = 1:numSubs
    plot(NaN, NaN, 'o', 'MarkerFaceColor', cmap(i,:), 'MarkerEdgeColor', 'none', ...
        'DisplayName', sprintf('Subject %s', string(uniqueSubjects(i))));
end
legend('Location','bestoutside', 'Box', 'off');

hold off;




























