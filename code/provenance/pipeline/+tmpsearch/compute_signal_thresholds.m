function thresholds = compute_signal_thresholds(signals, bPlot)
% compute_signal_thresholds Computes noise thresholds for signals across subjects.
%
%   thresholds = compute_signal_thresholds(signals)
%
%   INPUT =================================================================
%
%   signals (struct)
%   A structure where the top-level fields correspond to subjects, and
%   subfields represent signal names. Each signal contains data as arrays.
%
%   OUTPUT ================================================================
%
%   thresholds (struct)
%   A structure with the same hierarchy as the input, containing the
%   computed noise thresholds for each signal.
%
%   bPlot (boolean)
%   Flag to plot thresholds and signals. 
%
%   DESCRIPTION ===========================================================
%
%   This function calculates noise thresholds for all signals within a
%   given structure. The noise threshold is defined as the edge at the
%   maximum histogram count plus three times the standard deviation of the
%   edges contributing to the peak bin.
%
%   %   AUTHOR ================================================================
%   
%   S.Bahdasariants, NEL, WVU, sb0220@mix.wvu.edu
%
%   See also OTHER_RELEVANT_FUNCTIONS
%
%   =======================================================================

    % Get list of subjects and signal names
    sSubjectList = string(fieldnames(signals));
    sSignalList  = string(fieldnames(signals.(sSubjectList(1))));

    % Initialize output structure
    thresholds = struct();

    for iSubject = 1:length(sSubjectList)
        sSubject = sSubjectList(iSubject);

        for iSignal = 1:length(sSignalList)
            sSignal = string(sSignalList(iSignal));

            % Compute histogram and identify maximum bin
            [nCounts, nEdges] = histcounts(signals.(sSubject).(sSignal));
            [~, idCounts_max] = max(nCounts);

            % Define noise region and compute threshold
            idList_noise = [1:idCounts_max+1, idCounts_max:-1:1];
            nEdges_noise = nEdges(idList_noise);

            % Calculate Q1, Q3, and IQR
            Q1 = prctile(nEdges_noise, 25);
            Q3 = prctile(nEdges_noise, 75);
            IQR = Q3 - Q1;
            
            % Define threshold using Tukey's criterion
            thresholds.(sSubject).(sSignal) = Q3 + 1.5 * IQR;

            if bPlot 
                figure; plot(signals.(sSubject).(sSignal))
                hold on; 
                yline(thresholds.(sSubject).(sSignal))
            end
        end
    end
end
