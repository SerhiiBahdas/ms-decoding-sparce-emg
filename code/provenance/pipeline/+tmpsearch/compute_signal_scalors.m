function scalors = compute_signal_scalors(signals, bPlot)
% compute_signal_scalors Computes 4 standard deviations for signals across subjects.
%
%   scalors = compute_signal_scalors(signals, bPlot)
%
%   INPUT =================================================================
%
%   signals (struct)
%   A structure where the top-level fields correspond to subjects, and
%   subfields represent signal names. Each signal contains data as arrays.
%
%   bPlot (boolean, optional)
%   Flag to plot signals with computed 4-std lines. Defaults to false if not provided.
%
%   OUTPUT ================================================================
%
%   scalors (struct)
%   A structure with the same hierarchy as the input, containing the
%   computed 4 standard deviation scalors for each signal.
%
%   DESCRIPTION ===========================================================
%
%   This function calculates 4 standard deviations (4σ) for all signals
%   within a given structure. The output scalar is defined as the mean of
%   the signal plus three times its standard deviation.
%
%   AUTHOR ================================================================
%
%   S. Bahdasariants, NEL, WVU, sb0220@mix.wvu.edu
%
%   =======================================================================

    % Validate inputs
    if nargin < 2
        bPlot = false;
    end

    % Get list of subjects and signal names
    sSubjectList = string(fieldnames(signals));
    sSignalList  = string(fieldnames(signals.(sSubjectList(1))));

    % Initialize output structure
    scalors = struct();

    for iSubject = 1:length(sSubjectList)
        sSubject = sSubjectList(iSubject);

        for iSignal = 1:length(sSignalList)
            sSignal = sSignalList(iSignal);

            % Extract signal data
            signalData = signals.(sSubject).(sSignal);

            % Compute mean and 4 standard deviations
            nMean   = mean(signalData);
            nStd    = std(signalData);
            nScalor = nMean + 4 * nStd;

            % Store result
            scalors.(sSubject).(sSignal) = nScalor;

            % Optional plotting
            if bPlot
                figure; 
                plot(signalData);
                hold on;
                yline(nScalor, 'r--', '4σ');
                title(sprintf('Signal: %s | Subject: %s', sSignal, sSubject));
                xlabel('Sample Index');
                ylabel('Signal Amplitude');
            end
        end
    end
end
