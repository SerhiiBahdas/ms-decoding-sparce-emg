% compute_relative_phase_duration Computes normalized phase durations for movement phases.
%
%   compute_relative_phase_duration(idSubjectList, sTrialTypeList, Signal1, Signal2)
%
%   INPUT =================================================================
%
%   idSubjectList (numeric array)
%   List of subject IDs.
%
%   sTrialTypeList (cell array of char)
%   List of trial types to process (e.g., {'Type1', 'Type2'}).
%
%   Signal1 (char)
%   Name of the signal used to identify Phase 1 start and Movement end.
%
%   Signal2 (char)
%   Name of the signal used to identify Phase 2 and Phase 3 start times.
%
%   OUTPUT ================================================================
%
%   relative_phase_duration (struct)
%   Structure with fields for each trial type in `sTrialTypeList`. Each field 
%   contains a matrix where rows correspond to trials and columns represent 
%   the relative durations of Phase 1, Phase 2, and Phase 3.
%
%   AUTHOR ================================================================
%   
%   S.Bahdasariants, NEL, WVU, sb0220@mix.wvu.edu
%
%   See also GETMETA, QRY, GETEVENT, COMPUTE_AVERAGE_PHASE_DURATION
%
%   =======================================================================

function phase_duration = compute_phase_duration(idSubjectList, sTrialTypeList, Signal1, Signal2, SignalBackup)

    % Initialize the output structure
    phase_duration = struct();

    % Loop through each trial type
    for iTrialType = 1:length(sTrialTypeList)

        sTrialType = sTrialTypeList{iTrialType};
        
        % Initialize an empty array to accumulate phase durations for the current trial type
        phase_duration.(sTrialType) = [];

        % Retrieve the list of trial IDs corresponding to the specified trial type and subjects
        idTrialList = getMeta('metaTrial', qry('sTrialType', sTrialType, 'idSubject', idSubjectList), 'idTrial');
    
        % Loop through each trial
        for iTrial = 1:length(idTrialList)
            idTrial = idTrialList(iTrial);

            disp("ID TRIAL " + idTrial)

            idSubject = getMeta('metaTrial', qry('idTrial', idTrial), 'idSubject');
            
            % Retrieve event times for the phases
            tPhase1_on = getEvent(idTrial, Signal1, 1, []);  % Phase 1 start
            tPhase2_on = getEvent(idTrial, Signal2, 1, []);  % Phase 2 start
            tPhase3_on = getEvent(idTrial, Signal2, 2, []);  % Phase 3 start
            tMovmt_end = getEvent(idTrial, Signal1, 2, []);  % Movement end

            if isempty(tPhase1_on) || isempty(tPhase2_on)
                tPhase1_on = getEvent(idTrial, SignalBackup, 1, []);  % Phase 1 start
                tMovmt_end = getEvent(idTrial, SignalBackup, 2, []);  % Movement end
            end

            % Ensure that the event times are properly paired
            if isempty(tPhase1_on) || isempty(tPhase2_on) || isempty(tPhase3_on) || isempty(tMovmt_end)
                warning("Incomplete event data for trial ID " + idTrial + ". Skipping this trial.");
                continue;
            end
            
            % Take every second element to ensure pairing
            tPhase2_on = tPhase2_on(1:2:end);
            tPhase3_on = tPhase3_on(1:2:end);
            
            % Ensure that all phase events have the same number of occurrences
            minLength = min([length(tPhase1_on), length(tPhase2_on), length(tPhase3_on), length(tMovmt_end)]);
            tPhase1_on = tPhase1_on(1:minLength);
            tPhase2_on = tPhase2_on(1:minLength);
            tPhase3_on = tPhase3_on(1:minLength);
            tMovmt_end = tMovmt_end(1:minLength);
            
            % Calculate phase durations
            nDurPhase = [tPhase2_on - tPhase1_on, ...
                        tPhase3_on - tPhase2_on, ...
                        tMovmt_end - tPhase3_on];
            
            % Normalize phase durations by total movement duration
            normalized_durations = nDurPhase;
            
            % Append the normalized durations to the trial type field
            phase_duration.("SUBJ" + idSubject).(sTrialType) = [phase_duration.(sTrialType); normalized_durations];
        end
    end
end
