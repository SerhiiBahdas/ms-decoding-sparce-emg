function hTimer = stream_emg_and_phase_then_zeros(varargin)
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
    in.nRate   = 1925.92592592592; % sampling rate
end

nEMG   = in.EMG; 
nACC   = in.ACC; 
nPhase = in.PHASE; 

% Create a timer
hTimer = timer('StartDelay', 0, ...
               'Period', in.tUpd, ...
               'ExecutionMode', 'fixedRate');

hTimer.TimerFcn = @(~, ~) streamData();
hTimer.BusyMode = "drop"; 
start(hTimer);

    function streamData()
        persistent idxCurrent  
        
        if isempty(idxCurrent)
            idxCurrent = 1;  % Initialize the sample index on first call
        end
    
        numSamplesPerInterval = round(in.nRate * in.tUpd); 
        numSamples = size(nEMG, 2);  % Total number of samples in EMG
        
        % Check if we still have samples available
        if idxCurrent > numSamples
            % No samples left, output all zeros
            nEMGSegment   = zeros(size(nEMG,1), numSamplesPerInterval);
            nPhaseSegment = zeros(size(nPhase,1), numSamplesPerInterval);
            nACCSegment   = zeros(size(nACC,1), numSamplesPerInterval);
        else
            % Calculate ending sample index
            idxEnd = idxCurrent + numSamplesPerInterval - 1;
            
            if idxEnd <= numSamples
                % We have enough samples for this interval
                nEMGSegment   = nEMG(:, idxCurrent:idxEnd);
                nPhaseSegment = nPhase(:, idxCurrent:idxEnd);
                nACCSegment   = nACC(:, idxCurrent:idxEnd);
            else
                % Partial data available; fill the remainder with zeros
                samplesLeft = numSamples - idxCurrent + 1;
                zerosNeeded = numSamplesPerInterval - samplesLeft;
                
                nEMGSegment   = [nEMG(:, idxCurrent:end), ...
                                 zeros(size(nEMG,1), zerosNeeded)];
                nPhaseSegment = [nPhase(:, idxCurrent:end), ...
                                 zeros(size(nPhase,1), zerosNeeded)];
                nACCSegment   = [nACC(:, idxCurrent:end), ...
                                 zeros(size(nACC,1), zerosNeeded)];
            end
            
            % Update the sample index to beyond the end of this segment
            idxCurrent = idxEnd + 1;
        end

        offlinetest.box_emg(nEMGSegment, 'nRate', in.nRate);
        offlinetest.box_phase(nPhaseSegment, 'nRate', in.nRate);
        offlinetest.box_control_signal(nACCSegment, 'nRate', in.nRate);
    end
end
