function signals = collect_all_data(sTable, idTrialList, sSignalList)
% collect_all_data Processes EMG signals for specified trial types and signals.
%
%   signals = collect_all_data(sTable, nRate, sTrialTypeList, idTrialList, sSignalList)
%
%   INPUT =================================================================
%
%   sTable (char)
%   Name of the table containing signal data (e.g., 'emg_smooth_mean').
%
%   nRate (double)
%   Sampling rate of the signals in Hz.
%
%   sTrialTypeList (cell array of char)
%   List of trial types to process (e.g., {'GRASP10', 'RELAX'}).
%
%   idTrialList (array of integers)
%   List of trial IDs corresponding to the specified trial types.
%
%   sSignalList (cell array of char)
%   List of signal names to retrieve from the table (e.g., {'Signal1', 'Signal2'}).
%
%   OUTPUT ================================================================
%
%   signals (struct)
%   Nested structure where data is organized as signals.(subjectField).(signalField),
%   where subjectField corresponds to "S" + idSubject and signalField is the name
%   of the signal being processed.
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

    % Retrieve subject, trial type, and session IDs
    idSubject   = getMeta('metaTrial', qry('idTrial', idTrial), 'idSubject');
    
    for iSignal = 1:length(sSignalList)

        Signal.sSignal = sSignalList{iSignal};
        Signal.sTable  = sTable;

        if strcmp(Signal.sSignal, "tTime")
            continue; 
        end
        
        % Retrieve signal data
        nSignal = getSignal(idTrial, Signal, []);

        % Define substructure fields
        subjectField = "S" + idSubject;
        signalField  = string(Signal.sSignal);
        
        % Check and update the structure
        if isfield(signals, subjectField) && isfield(signals.(subjectField), signalField)
            signals.(subjectField).(signalField) = [signals.(subjectField).(signalField); nSignal(:)];
        else
            signals.(subjectField).(signalField) = nSignal(:);
        end
    end

end

end
