function scalors = compute_scalors_per_trial(signals, bPlot)
% compute_scalors_per_trial Computes 4 standard deviations for signals across trials.
%
%   scalors = compute_scalors_per_trial(signals, bPlot)
%
%   INPUT =================================================================
%
%   signals (struct)
%   A structure where the top-level fields correspond to subjects, the
%   second-level fields represent trial IDs, and the third-level fields
%   contain signal names. Each signal contains data as arrays.
%
%   bPlot (boolean, optional)
%   Flag to plot signals with computed 4-std lines. Defaults to false if not provided.
%
%   OUTPUT ================================================================
%
%   scalors (struct)
%   A structure with the same hierarchy as the input, containing the
%   computed 4 standard deviation scalars for each signal.
%
%   DESCRIPTION ===========================================================
%
%   This function calculates 4 standard deviations (4σ) for all signals
%   within a given structure organized by trial. The output scalar is 
%   defined as the mean of the signal plus four times its standard deviation.
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

    % Get list of subjects
    sSubjectList = string(fieldnames(signals));

    % Initialize output structure
    scalors = struct();

    for iSubject = 1:length(sSubjectList)
        sSubject = sSubjectList(iSubject);
        sTrialList = string(fieldnames(signals.(sSubject)));

        for iTrial = 1:length(sTrialList)
            sTrial = sTrialList(iTrial);
            sSignalList = string(fieldnames(signals.(sSubject).(sTrial)));

            for iSignal = 1:length(sSignalList)
                sSignal = string(sSignalList(iSignal));

                % Extract signal data
                signalData = signals.(sSubject).(sTrial).(sSignal);

                % Compute mean and 4 standard deviations
                nMean   = mean(signalData);
                nStd    = std(signalData);
                nScalor = nMean + 4 * nStd;

                % Store result
                scalors.(sSubject).(sTrial).(sSignal) = nScalor;

                % Optional plotting
                if bPlot
                    figure; 
                    plot(signalData);
                    hold on;
                    yline(nScalor, 'r--', '4σ');
                    title(sprintf('Signal: %s | Trial: %s | Subject: %s', sSignal, sTrial, sSubject));
                    xlabel('Sample Index');
                    ylabel('Signal Amplitude');
                end
            end
        end
    end
end
