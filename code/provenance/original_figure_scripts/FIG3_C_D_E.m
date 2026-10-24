load("FIG_3_C_D_E.mat");

% Initialize empty arrays to store the table data
subjNames  = {};
trialTypes = {};
signals    = [];
samples    = [];
values     = [];

% Get all subject names from the structure
subjects = fieldnames(phase_duration);

% Loop through each subject
for s = 1:length(subjects)
    subj = subjects{s};
    % Get all trial types for the current subject
    trialTypesList = fieldnames(phase_duration.(subj));
    
    % Loop through each trial type
    for t = 1:length(trialTypesList)
        trialType = trialTypesList{t};
        % Get the data matrix for the current trial type
        dataMatrix = phase_duration.(subj).(trialType);
        
        % Get the number of signals (rows) and samples (columns)
        [numSamples, numSignals] = size(dataMatrix);
        
        % Flatten the data into table rows
        for sig = 1:numSignals
            for samp = 1:numSamples
                % Append data to arrays
                subjNames{end+1,1} = subj;                % Subject name
                trialTypes{end+1,1} = trialType;          % Trial type
                signals(end+1,1) = sig;                   % Signal index
                samples(end+1,1) = samp;                  % Sample index
                values(end+1,1) = dataMatrix(samp,sig);  % Value at [sig, samp]
            end
        end
    end
end

% Combine into a table
dataTable = table(subjNames, trialTypes, signals, samples, values, ...
    'VariableNames', {'subjName', 'trialType', 'signal', 'sample', 'value'});

%% Plotting

dataTable.trialType = categorical(dataTable.trialType);
dataTable.subjName  = categorical(dataTable.subjName);


cSubjNameList   = unique(dataTable.subjName);
cTrialLTypeList = unique(dataTable.trialType);
idPhaseList      = unique(dataTable.signal);

iCount          = 1; 
clear nData


for iTrialType = 1:length(cTrialLTypeList)

    cTrialLType  = cTrialLTypeList(iTrialType);
    idxTrialType = int8(dataTable.trialType == cTrialLType);

    disp(cTrialLType)

    for iPhase = 1:length(idPhaseList)
    
        idPhase   = idPhaseList(iPhase);
        disp("PHASE" + idPhase)
        idxPhase = int8(dataTable.signal == idPhase);

        for iSubj = 1:length(cSubjNameList)
    
            cSubjName = cSubjNameList(iSubj);
        
            disp(cSubjName)
            idxSubj   = int8(dataTable.subjName == cSubjName);
            
            idxList  = find(idxSubj.*idxTrialType.*idxPhase);
        
            nData(iCount, :) = dataTable.value(idxList);
        
            iCount = iCount+1; 

        end
    end
end

for iDim = 1:size(nData, 1)
    h = adtest(nData(iDim, :));
    disp(h)
end

[p,tbl,stats] = kruskalwallis(nData');
figure; 
multcompare(stats, 'CType', "tukey-kramer");


%%

cSubjNameList   = unique(dataTable.subjName);
cTrialLTypeList = categorical("GRASP25");
idPhaseList      = 1;

iCount          = 1; 
clear nData

for iPhase = 1:length(idPhaseList)

    idPhase   = idPhaseList(iPhase);
    disp("PHASE" + idPhase)
    idxPhase = int8(dataTable.signal == idPhase);

    for iTrialType = 1:length(cTrialLTypeList)
    
        cTrialLType  = cTrialLTypeList(iTrialType);
        idxTrialType = int8(dataTable.trialType == cTrialLType);
    
        disp(cTrialLType)

        for iSubj = 1:length(cSubjNameList)
    
            cSubjName = cSubjNameList(iSubj);
        
            disp(cSubjName)
            idxSubj   = int8(dataTable.subjName == cSubjName);
            
                
        
            idxList  = find(idxSubj.*idxTrialType.*idxPhase);
        
            nData(iCount, :) = dataTable.value(idxList);
        
            iCount = iCount+1; 

        end
    end
end

for iDim = 1:size(nData, 1)
    h = adtest(nData(iDim, :));
    disp(h)
end

[p,tbl,stats] = kruskalwallis(nData');
figure; 
multcompare(stats, 'CType', "tukey-kramer");

%%

cSubjNameList   = unique(dataTable.subjName);
cTrialLTypeList = categorical("GRIP25");
idPhaseList      = 1;

iCount          = 1; 
clear nData

for iPhase = 1:length(idPhaseList)

    idPhase   = idPhaseList(iPhase);
    disp("PHASE" + idPhase)
    idxPhase = int8(dataTable.signal == idPhase);

    for iTrialType = 1:length(cTrialLTypeList)
    
        cTrialLType  = cTrialLTypeList(iTrialType);
        idxTrialType = int8(dataTable.trialType == cTrialLType);
    
        disp(cTrialLType)

        for iSubj = 1:length(cSubjNameList)
    
            cSubjName = cSubjNameList(iSubj);
        
            disp(cSubjName)
            idxSubj   = int8(dataTable.subjName == cSubjName);
            
                
        
            idxList  = find(idxSubj.*idxTrialType.*idxPhase);
        
            nData(iCount, :) = dataTable.value(idxList);
        
            iCount = iCount+1; 

        end
    end
end

for iDim = 1:size(nData, 1)
    h = adtest(nData(iDim, :));
    disp(h)
end

[p,tbl,stats] = kruskalwallis(nData');
figure; 
multcompare(stats, 'CType', "tukey-kramer");

%%

cSubjNameList   = unique(dataTable.subjName);
cTrialLTypeList = categorical("PRONATE25");
idPhaseList      = 1;

iCount          = 1; 
clear nData

for iPhase = 1:length(idPhaseList)

    idPhase   = idPhaseList(iPhase);
    disp("PHASE" + idPhase)
    idxPhase = int8(dataTable.signal == idPhase);

    for iTrialType = 1:length(cTrialLTypeList)
    
        cTrialLType  = cTrialLTypeList(iTrialType);
        idxTrialType = int8(dataTable.trialType == cTrialLType);
    
        disp(cTrialLType)

        for iSubj = 1:length(cSubjNameList)
    
            cSubjName = cSubjNameList(iSubj);
        
            disp(cSubjName)
            idxSubj   = int8(dataTable.subjName == cSubjName);
            
                
        
            idxList  = find(idxSubj.*idxTrialType.*idxPhase);
        
            nData(iCount, :) = dataTable.value(idxList);
        
            iCount = iCount+1; 

        end
    end
end

for iDim = 1:size(nData, 1)
    h = adtest(nData(iDim, :));
    disp(h)
end

[p,tbl,stats] = kruskalwallis(nData');
figure; 
multcompare(stats, 'CType', "tukey-kramer");



%%

cSubjNameList   = unique(dataTable.subjName);
cTrialLTypeList = categorical("GRASP25");
idPhaseList      = 2;

iCount          = 1; 
clear nData

for iPhase = 1:length(idPhaseList)

    idPhase   = idPhaseList(iPhase);
    disp("PHASE" + idPhase)
    idxPhase = int8(dataTable.signal == idPhase);

    for iTrialType = 1:length(cTrialLTypeList)
    
        cTrialLType  = cTrialLTypeList(iTrialType);
        idxTrialType = int8(dataTable.trialType == cTrialLType);
    
        disp(cTrialLType)

        for iSubj = 1:length(cSubjNameList)
    
            cSubjName = cSubjNameList(iSubj);
        
            disp(cSubjName)
            idxSubj   = int8(dataTable.subjName == cSubjName);
            
                
        
            idxList  = find(idxSubj.*idxTrialType.*idxPhase);
        
            nData(iCount, :) = dataTable.value(idxList);
        
            iCount = iCount+1; 

        end
    end
end

for iDim = 1:size(nData, 1)
    h = adtest(nData(iDim, :));
    disp(h)
end

[p,tbl,stats] = kruskalwallis(nData');
figure; 
multcompare(stats, 'CType', "tukey-kramer");



%%

cSubjNameList   = unique(dataTable.subjName);
cTrialLTypeList = categorical("GRIP25");
idPhaseList      = 2;

iCount          = 1; 
clear nData

for iPhase = 1:length(idPhaseList)

    idPhase   = idPhaseList(iPhase);
    disp("PHASE" + idPhase)
    idxPhase = int8(dataTable.signal == idPhase);

    for iTrialType = 1:length(cTrialLTypeList)
    
        cTrialLType  = cTrialLTypeList(iTrialType);
        idxTrialType = int8(dataTable.trialType == cTrialLType);
    
        disp(cTrialLType)

        for iSubj = 1:length(cSubjNameList)
    
            cSubjName = cSubjNameList(iSubj);
        
            disp(cSubjName)
            idxSubj   = int8(dataTable.subjName == cSubjName);
            
                
        
            idxList  = find(idxSubj.*idxTrialType.*idxPhase);
        
            nData(iCount, :) = dataTable.value(idxList);
        
            iCount = iCount+1; 

        end
    end
end

for iDim = 1:size(nData, 1)
    h = adtest(nData(iDim, :));
    disp(h)
end

[p,tbl,stats] = kruskalwallis(nData');
figure; 
multcompare(stats, 'CType', "tukey-kramer");



%%

cSubjNameList   = unique(dataTable.subjName);
cTrialLTypeList = categorical("PRONATE25");
idPhaseList      = 2;

iCount          = 1; 
clear nData

for iPhase = 1:length(idPhaseList)

    idPhase   = idPhaseList(iPhase);
    disp("PHASE" + idPhase)
    idxPhase = int8(dataTable.signal == idPhase);

    for iTrialType = 1:length(cTrialLTypeList)
    
        cTrialLType  = cTrialLTypeList(iTrialType);
        idxTrialType = int8(dataTable.trialType == cTrialLType);
    
        disp(cTrialLType)

        for iSubj = 1:length(cSubjNameList)
    
            cSubjName = cSubjNameList(iSubj);
        
            disp(cSubjName)
            idxSubj   = int8(dataTable.subjName == cSubjName);
            
                
        
            idxList  = find(idxSubj.*idxTrialType.*idxPhase);
        
            nData(iCount, :) = dataTable.value(idxList);
        
            iCount = iCount+1; 

        end
    end
end

for iDim = 1:size(nData, 1)
    h = adtest(nData(iDim, :));
    disp(h)
end

[p,tbl,stats] = kruskalwallis(nData');
figure; 
multcompare(stats, 'CType', "tukey-kramer");

%%

cSubjNameList   = unique(dataTable.subjName);
cTrialLTypeList = categorical("GRASP25");
idPhaseList      = 3;

iCount          = 1; 
clear nData

for iPhase = 1:length(idPhaseList)

    idPhase   = idPhaseList(iPhase);
    disp("PHASE" + idPhase)
    idxPhase = int8(dataTable.signal == idPhase);

    for iTrialType = 1:length(cTrialLTypeList)
    
        cTrialLType  = cTrialLTypeList(iTrialType);
        idxTrialType = int8(dataTable.trialType == cTrialLType);
    
        disp(cTrialLType)

        for iSubj = 1:length(cSubjNameList)
    
            cSubjName = cSubjNameList(iSubj);
        
            disp(cSubjName)
            idxSubj   = int8(dataTable.subjName == cSubjName);
            
                
        
            idxList  = find(idxSubj.*idxTrialType.*idxPhase);
        
            nData(iCount, :) = dataTable.value(idxList);
        
            iCount = iCount+1; 

        end
    end
end

for iDim = 1:size(nData, 1)
    h = adtest(nData(iDim, :));
    disp(h)
end

[p,tbl,stats] = kruskalwallis(nData');
figure; 
multcompare(stats, 'CType', "tukey-kramer");





%%
cSubjNameList   = unique(dataTable.subjName);
cTrialLTypeList = categorical("GRIP25");
idPhaseList      = 3;

iCount          = 1; 
clear nData

for iPhase = 1:length(idPhaseList)

    idPhase   = idPhaseList(iPhase);
    disp("PHASE" + idPhase)
    idxPhase = int8(dataTable.signal == idPhase);

    for iTrialType = 1:length(cTrialLTypeList)
    
        cTrialLType  = cTrialLTypeList(iTrialType);
        idxTrialType = int8(dataTable.trialType == cTrialLType);
    
        disp(cTrialLType)

        for iSubj = 1:length(cSubjNameList)
    
            cSubjName = cSubjNameList(iSubj);
        
            disp(cSubjName)
            idxSubj   = int8(dataTable.subjName == cSubjName);
            
                
        
            idxList  = find(idxSubj.*idxTrialType.*idxPhase);
        
            nData(iCount, :) = dataTable.value(idxList);
        
            iCount = iCount+1; 

        end
    end
end

for iDim = 1:size(nData, 1)
    h = adtest(nData(iDim, :));
    disp(h)
end

[p,tbl,stats] = kruskalwallis(nData');
figure; 
multcompare(stats, 'CType', "tukey-kramer");




%%


cSubjNameList   = unique(dataTable.subjName);
cTrialLTypeList = categorical("PRONATE25");
idPhaseList      = 3;

iCount          = 1; 
clear nData

for iPhase = 1:length(idPhaseList)

    idPhase   = idPhaseList(iPhase);
    disp("PHASE" + idPhase)
    idxPhase = int8(dataTable.signal == idPhase);

    for iTrialType = 1:length(cTrialLTypeList)
    
        cTrialLType  = cTrialLTypeList(iTrialType);
        idxTrialType = int8(dataTable.trialType == cTrialLType);
    
        disp(cTrialLType)

        for iSubj = 1:length(cSubjNameList)
    
            cSubjName = cSubjNameList(iSubj);
        
            disp(cSubjName)
            idxSubj   = int8(dataTable.subjName == cSubjName);
            
                
        
            idxList  = find(idxSubj.*idxTrialType.*idxPhase);
        
            nData(iCount, :) = dataTable.value(idxList);
        
            iCount = iCount+1; 

        end
    end
end

for iDim = 1:size(nData, 1)
    h = adtest(nData(iDim, :));
    disp(h)
end

[p,tbl,stats] = kruskalwallis(nData');
figure; 
multcompare(stats, 'CType', "tukey-kramer");















































































































































































