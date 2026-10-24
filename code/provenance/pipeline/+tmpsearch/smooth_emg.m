function smooth_emg(idTrialList, sSignalList, metaNoise, nRate, sTable_old, sTable_new, nWindow, sMode, bSetSignal, bSubtractCentroid, bPlot)

% smooth_emg Processes EMG signals based on trial list and signal list.
%
%   metaNoise = smooth_emg(idTrialList, sSignalList, nRate, sTable_old, sTable_new, nWindow, sMode, bSetSignal, bPlot)
%
%   INPUT =================================================================
%
%   idTrialList (array of numeric)
%   List of trial identifiers to process.
%
%   sSignalList (cell array of char)
%   List of signal names to process.
%
%   bPlot (logical)
%   Flag indicating whether to plot the processed signals.
%
%   bSetSignal (logical)
%   Flag indicating whether to save the processed signals.
%
%   nRate (numeric)
%   Sampling rate of the signals.
%
%   nWindow (numeric)
%   Smoothing window size. 
%   Example: 50
%
%   metaNoise (structure)
%   A structure with informaiton about noise statistics. 
%
%   sMode (string)
%   Filtering mode. 
%   Example: 'median', 'mean'
%
%   sTable_old (char)
%   Name of the table with EMG data.
%
%   sTable_new (char)
%   Name of the table where processed signals will be saved.
%
%   OUTPUT ================================================================
%
%   No output variables. 
%
%   ======================================================================

for iTrial = 1:length(idTrialList)
    idTrial = idTrialList(iTrial);

    for iSignal = 1:length(sSignalList)
        Signal.sSignal = sSignalList{iSignal};
        Signal.sTable = sTable_old;

        if strcmp(Signal.sSignal, "tTime")
            continue;
        end

        idSubject = getMeta('metaTrial', qry('idTrial', idTrial), 'idSubject');
        idTrialType = getMeta('metaTrial', qry('idTrial', idTrial), 'idTrialType');
        idSession = getMeta('metaTrial', qry('idTrial', idTrial), 'idSession');

        nSignal = getSignal(idTrial, Signal, []);

        if bSubtractCentroid
            nSignal = nSignal - metaNoise.("S" + idSubject).(string(Signal.sSignal)).centroid;
        end

        nSignal = abs(nSignal);

        if strcmp(sMode, "median")
            nSignal = movmedian(nSignal, [nWindow 0], 'Endpoints', 0);
        elseif strcmp(sMode, "mean")
            nSignal = movmean(nSignal, [nWindow, 0], 'Endpoints', 0);
        else
            error('sMode incorrect');
        end

        if bPlot
            figure
            plot(nSignal);
            title("Subject " + idSubject + " " + Signal.sSignal);
        end

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
