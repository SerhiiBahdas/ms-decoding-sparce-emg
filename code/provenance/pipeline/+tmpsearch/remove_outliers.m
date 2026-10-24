% zscoring = remove_outliers Removes outliers from specified signals in a trial list using z-score method.
%
%   zscoring = remove_outliers(idTrialList, sSignalList, nRate, sTable_old, sTable_new, bSetSignal, bPlot)
%
%   INPUT =================================================================
%
%   idTrialList (array of numeric)
%       List of trial identifiers to process.
%
%   sSignalList (cell array of char)
%       List of signal names to process.
%
%   nRate (numeric)
%       Sampling rate of the signals.
%
%   sTable_old (char)
%       Name of the table with original signal data.
%
%   sTable_new (char)
%       Name of the table where processed signals will be saved.
%
%   bSetSignal (logical)
%       Flag indicating whether to save the processed signals to the database.
%
%   bPlot (logical)
%       Flag indicating whether to plot the signals after outlier removal.
%
%   OUTPUT ================================================================
%
%   zscoring (structure)
%   Contains mean-s and std-s used for z-scoring. 
%
%   ======================================================================

function zscoring = remove_outliers(idTrialList, sSignalList, nRate, sTable_old, sTable_new, bSetSignal, bPlot)
    % Parameters for z-score outlier detection
    zThreshold = 4;       % Z-score threshold for identifying outliers
    replacementMethod = 'interpolate'; % Options: 'NaN', 'zero', 'interpolate'
    
    % Calculate total number of iterations for progress bar
    totalIterations = length(idTrialList) * length(sSignalList);
    
    % Initialize progress bar
    hWaitBar = waitbar(0, 'Removing outliers...', 'Name', 'Progress');
    cleanupObj = onCleanup(@() closeWaitBar(hWaitBar));  % Ensure waitbar closes on function exit
    
    currentIteration = 0;  % Initialize iteration counter
    
    try
        for iTrial = 1:length(idTrialList)
            idTrial = idTrialList(iTrial);
    
            for iSignal = 1:length(sSignalList)
                Signal.sSignal = sSignalList{iSignal};
                Signal.sTable = string(sTable_old);
    
                if strcmp(Signal.sSignal, "tTime")
                    currentIteration = currentIteration + 1;
                    updateWaitBar(hWaitBar, currentIteration, totalIterations);
                    continue;
                end
    
                % Retrieve metadata
                idTrialType  = getMeta('metaTrial', qry('idTrial', idTrial), 'idTrialType');
                idSession    = getMeta('metaTrial', qry('idTrial', idTrial), 'idSession');
                idSubject    = getMeta('metaTrial', qry('idTrial', idTrial), 'idSubject');
    
                % Retrieve the signal
                nSignal = getSignal(idTrial, Signal, []);
    
                % Calculate z-scores
                meanSignal = mean(nSignal, 'omitnan');
                stdSignal = std(nSignal, 'omitnan');
                zScores = (nSignal - meanSignal) / stdSignal;

                zscoring.("S" + idSubject).("TRIAL" + idTrial).(Signal.sSignal).mean = meanSignal;
                zscoring.("S" + idSubject).("TRIAL" + idTrial).(Signal.sSignal).std  = stdSignal;
                
                % Identify outliers
                outliers = abs(zScores) > zThreshold;
    
                % Handle outliers based on the chosen replacement method
                cleanedEMG = nSignal; % Initialize cleaned signal
                
                switch replacementMethod
                    case 'NaN'
                        cleanedEMG(outliers) = NaN;
                    case 'zero'
                        cleanedEMG(outliers) = 0;
                    case 'interpolate'
                        % Interpolate outliers
                        idx = find(~outliers);
                        if length(idx) < 2
                            warning('Not enough points to interpolate for trial %d, signal %s.', idTrial, Signal.sSignal);
                            cleanedEMG(outliers) = NaN; % Fallback to NaN
                        else
                            cleanedEMG(outliers) = interp1(idx, nSignal(idx), find(outliers), 'linear', 'extrap');
                        end
                    otherwise
                        error('Invalid replacement method: %s', replacementMethod);
                end
    
                % Optionally plot the original and cleaned signals
                if bPlot
                    figure('Name', sprintf('Trial %d - Signal %s', idTrial, Signal.sSignal), 'NumberTitle', 'off');
                    subplot(2,1,1);
                    plot(nSignal, 'b');
                    hold on;
                    plot(find(outliers), nSignal(outliers), 'ro');
                    title(sprintf('Original EMG Data (Trial %d - %s)', idTrial, Signal.sSignal));
                    xlabel('Time');
                    ylabel('Amplitude');
                    legend('Original Signal', 'Outliers');
                    hold off;
    
                    subplot(2,1,2);
                    plot(cleanedEMG, 'g');
                    title('Cleaned EMG Data');
                    xlabel('Time');
                    ylabel('Amplitude');
                    legend('Cleaned Signal');
                end
    
                % Save the cleaned signal if required
                if bSetSignal
                    setSignal(cleanedEMG, qry('sTable', sTable_new, 'sSignal', Signal.sSignal), idTrial, ...
                        'nRate', nRate, ...
                        'sUnit', 'V', ...
                        'idSession', idSession, ...
                        'idTrialType', idTrialType, ...
                        'tSync', 0);
                end
    
                % Update progress bar
                currentIteration = currentIteration + 1;
                updateWaitBar(hWaitBar, currentIteration, totalIterations);
            end
        end
    catch ME
        % Ensure the waitbar is closed in case of an error
        delete(hWaitBar);
        rethrow(ME);  % Re-throw the error after cleanup
    end
    
    % Close the progress bar upon completion
    close(hWaitBar);
end

% Helper function to update the waitbar
function updateWaitBar(hWaitBar, current, total)
    if isvalid(hWaitBar)
        waitbar(current / total, hWaitBar, sprintf('Progress: %d/%d', current, total));
    end
end

% Helper function to safely close the waitbar
function closeWaitBar(hWaitBar)
    if isvalid(hWaitBar)
        close(hWaitBar);
    end
end
