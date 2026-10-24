function template = get_templates(idSubjectList, nTemplateLenList, sTrialTypeList, sSignalList, phase_percent, Signal, Signal_event1, Signal_event2)
% get_templates Interpolates and organizes signal data into templates.
%
%   get_templates(nTemplateLenList, sTrialTypeList, sSignalList, phase_percent, nRate, Signal)
%
%   INPUT =================================================================
%
%   nTemplateLenList (numeric array)
%   List of template lengths to iterate over.
%
%   sTrialTypeList (cell array of char)
%   List of trial types for which the signal data is processed.
%
%   sSignalList (cell array of char)
%   List of signal names to process.
%
%   phase_percent (struct)
%   Structure containing the percentage of each phase for each trial type.
%
%   nRate (numeric)
%   Sampling rate for signal processing.
%
%   Signal (struct)
%   Structure containing signal information for processing.
%
%   ======================================================================
global nTempLenList

numPhases = length(fieldnames(phase_percent));

for iTmpLen = 1:length(nTemplateLenList)

    nTemplateLen = nTemplateLenList(iTmpLen);

    for iTrialType = 1:length(sTrialTypeList)
    
        sTrialType = sTrialTypeList{iTrialType};
    
        % Retrieve the list of trial IDs corresponding to the specified trial type and subjects
        idTrialList = getMeta('metaTrial', qry('sTrialType', sTrialType, 'idSubject', idSubjectList), 'idTrial');
        
        tEvent1 = getEvent(idTrialList, Signal_event1, 1, []);
        tEvent2 = getEvent(idTrialList, Signal_event2, 1, []);
        tEvent3 = getEvent(idTrialList, Signal_event2, 2, []);
        tEvent4 = getEvent(idTrialList, Signal_event1, 2, []);
        
        % Half the number of block grasps (experimenter moved the block back)
        tEvent2 = tEvent2(1:2:end,:);
        tEvent3 = tEvent3(1:2:end,:); 
        
        for iTrial = 1:length(idTrialList)

            idTrial = idTrialList(iTrial);
    
            disp("TRIAL ID :" + idTrial)

            for iSignal = 1:length(sSignalList)
    
                Signal.sSignal = sSignalList{iSignal};

                disp("SIGNAL :" + Signal.sSignal)

                nSignal       = getSignal(idTrial, Signal, [tEvent1(:,iTrial), tEvent4(:,iTrial)]);

                numReps = length(tEvent1(~isnan(tEvent1(:,iTrial)), iTrial));

                nSignal_all_reps = [];

                for iRepetition = 1:numReps

                    disp("REP :" + iRepetition)

                    nRep    = nSignal(:,iRepetition);
                    nRep    = nRep(~isnan(nRep));
                    nSample = length(nRep);

                    nSignal_resampled = []; 
    
                    for iPhase = 1:numPhases

                        disp("PHASE :" + iPhase)
                        
                        if iPhase == 1
                            tEventList = [tEvent1(iRepetition, iTrial), tEvent2(iRepetition, iTrial)];
                        elseif iPhase == 2
                            tEventList = [tEvent2(iRepetition, iTrial), tEvent3(iRepetition, iTrial)];
                        elseif iPhase == 3
                            tEventList = [tEvent3(iRepetition, iTrial), tEvent4(iRepetition, iTrial)];
                        end
    
                        nSamples     = round(nSample*phase_percent.(sTrialType)(iPhase));
                        nSignal_part = getSignal(idTrial, Signal, tEventList);
                        nPoints      = length(nSignal_part);
        
                        tOriginal = linspace(0, phase_percent.(sTrialType)(iPhase), nPoints);
        
                        % Target time vector for interpolation
                        tTarget = linspace(0, phase_percent.(sTrialType)(iPhase), nSamples);

                        % Interpolate the signal
                        nSignal_resampled = [nSignal_resampled, interp1(tOriginal, nSignal_part, tTarget, 'linear')];
    
                    end

                   nPoints           = length(nSignal_resampled);
                   tOriginal         = linspace(0, 1, nPoints);
                   tTarget           = linspace(0, 1, nTemplateLen);
                   nSignal_resampled = interp1(tOriginal, nSignal_resampled, tTarget, 'linear');

                   nSignal_all_reps(iRepetition,:)  = nSignal_resampled;

                   nTempLenList = [nTempLenList, nPoints];
      
                end   

                template.("TMP" + nTemplateLen).(sTrialType).(Signal.sSignal) = mean(nSignal_all_reps,1);

            end
        end
    end

end