function scale_emg_per_trial(idTrialList, sSignalList, scalors, nRate, sTable_old, sTable_new, bSetSignal, bPlot)
% scale_emg_per_trial Normalizes EMG signals using precomputed scalars for each trial.
%
%   scale_emg_per_trial(idTrialList, sSignalList, scalors, nRate, sTable_old, sTable_new, bSetSignal, bPlot)
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
%   Structure containing precomputed scalars for each signal, subject, and trial.
%   Organized as scalors.("S<idSubject>").("TRIAL<idTrial>").<SignalName>.
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
%   names. Each signal is normalized using precomputed scalars (mean + 4σ)
%   specific to the trial and subject, and can optionally be saved to a new
%   table or plotted. Signals named "tTime" are ignored.
%
%   AUTHOR ================================================================
%
%   S. Bahdasariants, NEL, WVU, sb0220@mix.wvu.edu
%
%   =======================================================================

% Iterate through each trial
for iTrial = 1:length(idTrialList)
    idTrial = idTrialList(iTrial);

    % Retrieve metadata for the trial
    idSubject = getMeta('metaTrial', qry('idTrial', idTrial), 'idSubject');
    idTrialType = getMeta('metaTrial', qry('idTrial', idTrial), 'idTrialType');
    idSession = getMeta('metaTrial', qry('idTrial', idTrial), 'idSession');

    % Trial-level scalar field
    trialField = "TRIAL" + idTrial;

    % Iterate through each signal
    for iSignal = 1:length(sSignalList)
        Signal.sSignal = sSignalList{iSignal};
        Signal.sTable = string(sTable_old);

        % Skip signals named "tTime"
        if strcmp(Signal.sSignal, "tTime")
            continue;
        end

        % Retrieve and normalize the signal
        nSignal = getSignal(idTrial, Signal, []);

        % Check if scalar exists for the trial and signal
        if ~isfield(scalors.("S" + idSubject), trialField) || ...
           ~isfield(scalors.("S" + idSubject).(trialField), Signal.sSignal)
            error("Scalar not found for Subject %d, Trial %d, Signal %s", idSubject, idTrial, Signal.sSignal);
        end

        nScalar = scalors.("S" + idSubject).(trialField).(Signal.sSignal);
        nSignal = nSignal ./ nScalar;

        % Plot the normalized signal if requested
        if bPlot
            figure;
            plot(nSignal);
            title("Subject " + idSubject + " - Trial " + idTrial + " - Signal: " + Signal.sSignal);
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
