function signals = collect_all_trials(sTable, idTrialList, sSignalList)
% collect_all_trials Processes EMG signals and organizes them by trial ID.
%
%   signals = collect_all_trials(sTable, idTrialList, sSignalList)
%
%   INPUT =================================================================
%
%   sTable (char)
%   Name of the table containing signal data (e.g., 'emg_smooth_mean').
%
%   idTrialList (array of integers)
%   List of trial IDs to process.
%
%   sSignalList (cell array of char)
%   List of signal names to retrieve from the table (e.g., {'Signal1', 'Signal2'}).
%
%   OUTPUT ================================================================
%
%   signals (struct)
%   Nested structure where data is organized as signals.(subjectField).(trialField).(signalField),
%   where:
%       - subjectField corresponds to "S" + idSubject.
%       - trialField corresponds to "TRIAL" + idTrial.
%       - signalField is the name of the signal being processed.
%
%   AUTHOR ================================================================
%
%   S.Bahdasariants, NEL, WVU, sb0220@mix.wvu.edu
%
%   See also GETMETA, QRY, GETSIGNAL
%
%   =======================================================================

signals = struct(); 

for iTrial = 1:length(idTrialList)

    idTrial = idTrialList(iTrial);

    % Retrieve subject ID
    idSubject = getMeta('metaTrial', qry('idTrial', idTrial), 'idSubject');
    
    % Define fields
    subjectField = "S" + idSubject;
    trialField = "TRIAL" + idTrial;

    for iSignal = 1:length(sSignalList)

        Signal.sSignal = sSignalList{iSignal};
        Signal.sTable  = sTable;

        if strcmp(Signal.sSignal, "tTime")
            continue; 
        end
        
        % Retrieve signal data
        nSignal = getSignal(idTrial, Signal, []);

        % Create or update structure
        if ~isfield(signals, subjectField)
            signals.(subjectField) = struct();
        end

        if ~isfield(signals.(subjectField), trialField)
            signals.(subjectField).(trialField) = struct();
        end

        signalField = string(Signal.sSignal);
        signals.(subjectField).(trialField).(signalField) = nSignal(:);
    end

end

end
