function scale_emg(idTrialList, sSignalList, scalors, nRate, sTable_old, sTable_new, bSetSignal, bPlot)
% scale_emg Normalizes EMG signals using precomputed scalors and processes them for specified trials.
%
%   scale_emg(idTrialList, sSignalList, scalors, nRate, sTable_old, sTable_new, bSetSignal, bPlot)
%
%   INPUT =================================================================
%
%   idTrialList (numeric array)
%   List of trial identifiers to process.
%
%   sSignalList (cell array of char)
%   List of signal names to process. Signals should be present in the table.
%
%   scalors (struct)
%   Structure containing precomputed scalors for each signal and subject.
%   Organized as scalors.("S<idSubject>").<SignalName>.
%
%   nRate (numeric)
%   Sampling rate of the signals (in Hz).
%
%   sTable_old (char)
%   Name of the table containing raw EMG data.
%
%   sTable_new (char)
%   Name of the table where normalized signals will be saved.
%
%   bSetSignal (logical)
%   Flag to determine whether normalized signals should be saved.
%
%   bPlot (logical)
%   Flag to determine whether to plot the normalized signals.
%
%   OUTPUT ================================================================
%
%   None. This function operates on provided data and saves results
%   directly if bSetSignal is true.
%
%   DESCRIPTION ===========================================================
%
%   This function processes EMG signals for a given list of trials and signal
%   names. Each signal is normalized using precomputed scalors (mean + 4σ)
%   and can optionally be saved to a new table or plotted. Signals named
%   "tTime" are ignored.
%
%   The function retrieves metadata such as subject ID, trial type, and
%   session ID to ensure proper association of the processed signals with
%   the original data.
%
%   AUTHOR ================================================================
%
%   S. Bahdasariants, NEL, WVU, sb0220@mix.wvu.edu
%
%   ======================================================================

% Iterate through each trial
for iTrial = 1:length(idTrialList)
    idTrial = idTrialList(iTrial);

    % Iterate through each signal
    for iSignal = 1:length(sSignalList)
        Signal.sSignal = sSignalList{iSignal};
        Signal.sTable = string(sTable_old);

        % Skip signals named "tTime"
        if strcmp(Signal.sSignal, "tTime")
            continue;
        end

        % Retrieve metadata
        idSubject = getMeta('metaTrial', qry('idTrial', idTrial), 'idSubject');
        idTrialType = getMeta('metaTrial', qry('idTrial', idTrial), 'idTrialType');
        idSession = getMeta('metaTrial', qry('idTrial', idTrial), 'idSession');

        % Retrieve and normalize the signal
        nSignal = getSignal(idTrial, Signal, []);
        nSignal = nSignal ./ scalors.("S" + idSubject).(Signal.sSignal);

        % Plot the normalized signal if requested
        if bPlot
            figure;
            plot(nSignal);
            title("Subject " + idSubject + " - Signal: " + Signal.sSignal);
            xlabel('Sample Index');
            ylabel('Normalized Amplitude');
        end

        % Save the normalized signal if requested
        if bSetSignal
            setSignal(nSignal, qry('sTable', sTable_new, 'sSignal', Signal.sSignal), idTrial, ...
                'nRate', nRate, ...
                'sUnit', 'V', ...
                'idSession', idSession, ...
                'idTrialType', idTrialType, ...
                'tSync', 0);
        end
    end
end
end
