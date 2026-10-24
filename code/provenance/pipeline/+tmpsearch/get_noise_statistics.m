function metaNoise = get_noise_statistics(sFolderList_subject, sTrialType, sSignalList, bPlot)
% get_noise_statistics Calculates EMG signals' noise centroid and bounds .
%
%   metaNoise = get_noise_statistics(sFolderList_subject, sTrialType, sSignalList, bPlot)
%
%   INPUT =================================================================
%
%   sFolderList_subject (cell array of char)
%   List of folder names for each subject.
%
%   sTrialType (char)
%   Type of trial used for querying subject data.
%
%   sSignalList (cell array of char)
%   List of signal names to be processed (e.g., EMG signals).
%
%   bPlot (logical)
%   Flag to plot the signals and noise bounds for each signal.
%
%   OUTPUT ================================================================
%
%   metaNoise (struct)
%   Structure containing the calculated centroid, lower, and upper noise bounds 
%   for each signal of each subject.
%
%   ======================================================================

    for iSubject = 1:length(sFolderList_subject)

        sSubject    = sFolderList_subject{iSubject};
        idSubject   = getMeta('metaSession', qry('sSession', char(sSubject)), 'idSubject');
        idTrial_rlx = getMeta('metaTrial', qry('idSubject', idSubject, 'sTrialType', char(sTrialType)), 'idTrial');

        for iSignal = 1:length(sSignalList)
            Signal.sSignal = sSignalList{iSignal};
            Signal.sTable = 'emgraw';

            if strcmp(Signal.sSignal, "tTime")
                continue
            end

            nSignal = getSignal(idTrial_rlx, Signal, []);

            nMean = nanmean(nSignal(:));

            nSignal = nSignal-nMean; 

            % Outliers are defined as elements more than three scaled MAD 
            % from the median. The scaled MAD is defined as c*median
            % (abs(A-median(A))), where c=-1/(sqrt(2)*erfcinv(3/2)).

            [~,~,~,lowerBound,upperBound,~] = rmoutliers(nSignal, "median");

            metaNoise.("S"+idSubject).(Signal.sSignal).centroid   = nMean;
            metaNoise.("S"+idSubject).(Signal.sSignal).lowerBound = 1.5*lowerBound;
            metaNoise.("S"+idSubject).(Signal.sSignal).upperBound = 1.5*upperBound;

            if bPlot
                figure;
                plot(nSignal);
                hold on;
                yline(lowerBound);
                yline(upperBound);
                yline(median(nSignal(:)));
                title(Signal.sSignal);
            end

        end

    end

end
