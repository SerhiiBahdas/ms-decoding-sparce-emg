function process_emg_with_hist_filt(idTrialList, sSignalList, metaNoise, sTable_new, nRate, bSetSignal,  bPlot)
% process_emg_with_wavelets Processes and denoises EMG signals for each trial using wavelets.
%
%   process_emg_with_hist_filt(idTrialList, sSignalList, metaNoise, sTable_new, nRate, bSetSignal,  bPlot)
%
%   INPUT =================================================================
%
%   idTrialList (array)
%   List of trial IDs to process.
%
%   sSignalList (cell array of char)
%   List of signal names to process.
%
%   metaNoise (struct)
%   Structure containing the median noise level for each signal and subject.
%
%   bPlot (logical)
%   Whether to plot the signals during processing (true/false).
%
%   bSetSignal (logical)
%   Whether to save the processed signal (true/false).
%
%   sTable_new (char)
%   Name of the new table where the processed signals are saved.
%
%   nRate (double)
%   Sampling rate of the signals.
%
%   OUTPUT ================================================================
%
%   None. 
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

        nCentroid = metaNoise.("S" + idSubject).(Signal.sSignal).centroid;

        if bPlot
            figure;
            plot(nSignal);
            hold on;
        end

        nSignal = nSignal - nCentroid;
        nSignal = abs(nSignal);

        [N,nEdgeList ]  = histcounts(nSignal);
        [~, idBin_max]  = max(N);
        idBin_max       = max(idBin_max, 2);

        idBinList       = [1:idBin_max, idBin_max-1:-1:1]; 
        nEdgeList_noise = nEdgeList(idBinList);

        nSTD = std(nEdgeList_noise);

        nSignal(nSignal<3*nSTD) = 0; 

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
