function process_emg(idTrialList, sSignalList, metaNoise, nRate, sTable_new, bSetSignal, bPlot)
% process_emg Processes EMG signals.
%
%   process_emg(idTrialList, sSignalList, metaNoise, nRate, sTable_new, bSetSignal, bPlot)
%
%   INPUT =================================================================
%
%   idTrialList (array of numeric)
%   List of trial identifiers to process.
%
%   sSignalList (cell array of char)
%   List of signal names to process.
%
%   metaNoise (struct)
%   Structure containing noise metadata with fields for each subject and signal.
%
%   bSetSignal (logical)
%   Flag indicating whether to save the processed signals.
%
%   nRate (numeric)
%   Sampling rate of the signals.
%
%   sTable_new (char)
%   Name of the table where processed signals will be saved.
%
%   bPlot (boolean)
%   Flag to plot. 
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
        Signal.sTable = 'emgraw';

        if strcmp(Signal.sSignal, "tTime")
            continue;
        end

        idSubject   = getMeta('metaTrial', qry('idTrial', idTrial), 'idSubject');
        idTrialType = getMeta('metaTrial', qry('idTrial', idTrial), 'idTrialType');
        idSession   = getMeta('metaTrial', qry('idTrial', idTrial), 'idSession');

        nSignal = getSignal(idTrial, Signal, []);

        nUpperBound = metaNoise.("S" + idSubject).(Signal.sSignal).upperBound;
        nLowerBound = metaNoise.("S" + idSubject).(Signal.sSignal).lowerBound;
        nCentroid   = metaNoise.("S" + idSubject).(Signal.sSignal).centroid;

        if bPlot
            figure;
            plot(nSignal);
            hold on;
            yline(nLowerBound);
            yline(nUpperBound);
            yline(nCentroid);
        end

        nSignal = abs(nSignal - nCentroid);
        nSignal(nSignal < max([abs(nUpperBound), abs(nLowerBound)])) = 0;

        if bPlot
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
