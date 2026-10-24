function hTimer = stream_emg_and_phase(varargin)
%
%   AUTHOR ================================================================
%
%   S.Bahdasariants, NEL, WVU, https://github.com/SerhiiBahdas
%
%   =======================================================================

persistent in 

    in = struct; 

    if ~isempty(varargin)
        for i = 1:numel(varargin)/2
            in.(varargin{(i-1)*2+1}) = varargin{i*2};
        end
    end

    if ~isfield(in, 'tUpd')
        in.tUpd   = 14e-3;           % timer update latency, s
    end

    if ~isfield(in, 'nRate')
        in.nRate   = 1925.92592592592; % timer update latency, s
    end

    nEMG   = in.EMG; 
    nACC   = in.ACC; 
    nPhase = in.PHASE; 

    % Create a timer
    hTimer = timer('StartDelay', 0, ...
                   'Period', in.tUpd, ...
                   'ExecutionMode', 'fixedRate');

    hTimer.TimerFcn = @(~, ~) carousel();
    hTimer.BusyMode = "drop"; 
    start(hTimer);

    function carousel()

        persistent idxCurrent  
        
        if isempty(idxCurrent)
            idxCurrent = 1;  % Initialize the sample index on first call
        end
    
        numSamplesPerInterval = round(in.nRate * in.tUpd);  % Convert ms to samples
        numSamples = size(nEMG, 2);  % Total number of samples in emgData
    
        if idxCurrent > numSamples  % Reset if the index exceeds the data length
            idxCurrent = 1;
        end
    
        % Calculate the ending sample index
        idxEnd = idxCurrent + numSamplesPerInterval - 1;
    
        % Check if the data wraps around the matrix
        if idxEnd > numSamples
            % Number of samples needed from the beginning of the matrix
            numSamplesFromStart = idxEnd - numSamples;
            nEMGSegment   = [nEMG(:, idxCurrent:end), nEMG(:, 1:numSamplesFromStart)];
            nPhaseSegment = [nPhase(:, idxCurrent:end), nPhase(:, 1:numSamplesFromStart)];
            nACCSegment = [nACC(:, idxCurrent:end), nACC(:, 1:numSamplesFromStart)];
            idxCurrent = numSamplesFromStart + 1;  % Update index to the new position
        else
            nEMGSegment   = nEMG(:, idxCurrent:idxEnd);
            nPhaseSegment = nPhase(:, idxCurrent:idxEnd);
            nACCSegment   = nACC(:, idxCurrent:idxEnd);
            idxCurrent    = idxEnd + 1;  % Update the sample index
        end

        offlinetest.box_emg(nEMGSegment, 'nRate', in.nRate);
        offlinetest.box_phase(nPhaseSegment, 'nRate', in.nRate);
        offlinetest.box_control_signal(nACCSegment, 'nRate', in.nRate);

    end
end
