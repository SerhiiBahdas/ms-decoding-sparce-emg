function denoisedChunk = denoise_and_scale(chunk, params, idSubject, idTrial, sSignalList, replacementMethod)
    % Denoise and scale the input chunk in real-time with minimal variables.
    %
    % INPUT:
    % chunk - (m x n) matrix of signal values.
    % params - Structure with noise filtering parameters.
    % idSubject - Subject identifier.
    % idTrial - Trial identifier.
    % sSignalList - Cell array of signal names.
    % replacementMethod - Outlier handling method ('NaN', 'zero', 'threshold').
    %
    % OUTPUT:
    % denoisedChunk - The denoised and scaled chunk.

    % Persistent variable for Z-scoring threshold
    persistent nZscoringThreshold subjectKey trialKey

    if isempty(nZscoringThreshold)
        nZscoringThreshold = 4;
    end

    if isempty(subjectKey)
        subjectKey = "S" + idSubject;
    end

    if isempty(trialKey)
        trialKey = "TRIAL" + idTrial;
    end

    % Number of signals
    numSignals = size(chunk, 1);

    % Process each signal
    for m = 1:numSignals
        signalName = sSignalList{m};

        % Retrieve parameters
        nThreshold = params.thresholds.(subjectKey).(signalName);
        nScalor    = params.scalors.(subjectKey).(trialKey).(signalName);
        nMean      = params.zscoring.(subjectKey).(trialKey).(signalName).mean;
        nSTD       = params.zscoring.(subjectKey).(trialKey).(signalName).std;

        % Reference to current signal
        signalData = chunk(m, :);

        % Set values below threshold to zero
        signalData(signalData < nThreshold) = 0;

        % Scale amplitude
        signalData = signalData / nScalor;

        % % Z-score normalization and outlier detection
        % zScores = (signalData - nMean) / nSTD;
        % idxOutlier = abs(zScores) > nZscoringThreshold;

        % % Handle outliers
        % if any(idxOutlier)
        %     switch replacementMethod
        %         case 'NaN'
        %             signalData(idxOutlier) = NaN;
        %         case 'zero'
        %             signalData(idxOutlier) = 0;
        %         case 'threshold'
        %             % Replace outliers with the value corresponding to z-score of ±nZscoringThreshold
        %             signalData(idxOutlier & zScores > 0) = nMean + nSTD * nZscoringThreshold;
        %         otherwise
        %             error('Invalid replacement method: %s', replacementMethod);
        %     end
        % end

        % Update the chunk with processed signal
        chunk(m, :) = signalData;
    end

    % Return the denoised chunk
    denoisedChunk = chunk;
end
