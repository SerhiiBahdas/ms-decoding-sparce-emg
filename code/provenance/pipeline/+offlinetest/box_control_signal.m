% BOX_EMG(): ---------------------------------------------------------------
% Create a DataCollector for DELSYS EMG signals.
%   out = box_emg(data, PROPERTIES)
%
% REFLEXES
% 1) When buffer is full (Index>nSize), buffer is saved into a MAT file (sName) and
% buffer is reset (Index=0)
% 2) Timestamps recorded starting with buffer initialization and with every
% buffer save (every min).
%
% PROPERTIES
% in.sDataType    = 'single';
% in.sName        = ['emg_',char(sprintf('%f',now)),'.mat']; % file name
% in.nRate        = 1925.92592592592; % signal rate
% in.nSignal      = 16; % number of signals
% in.nSize        = 1*60*in.nRate; % maximum buffer size for 1 min
% in.nSampleOut   = 1; % number of samples to return (default: 1)
% in.bWrite       = true; % enable writing when buffer is full
% in.bWriteForce  = false; % force writing to file 
%
% OUTPUT ------------------------------------------------------------------
% nData <nSignal x 1> for call with empty input >nData = box_emg([]);
% nData <nSignal x nSample> for call >nData = box_emg([],'bOutLast',false);
%
% EXAMPLE/TESTING ---------------------------------------------------------
%
% % WRITE DATA organized as a matrix [nSignal x nSample]
% nIndex = box_emg(data_rec); % where nIndex is the current buffer index 
% nData = box_emg([]); % reads last sample
% nData = box_emg([],'nSampleOut',20); % return 20 last samples
% nData = box_emg([],'nSampleOut',[]); % return full buffer
% box_emg([],'bWriteForce',true) % force data write 
% clear box_emg; % Clear persistent buffer in function
%
% AUTHORS ------------------------------------------------------------------
% S.Yakovenko, NEL, WVU, https://github.com/neurowired
% S.Bahdasariants, NEL, WVU, https://github.com/SerhiiBahdas

function out = box_control_signal(nData,varargin)

% INITIALIZATION ----------------------------------------------------------

persistent in nBuffer nSampleData nSampleTime

% ASSIGN PROPERTIES -----------------------------------------------------------------
if isempty(in) % Run only once
    in.sDataType    = 'single';
    in.sName        = ['emg_',char(sprintf('%f',now)),'.mat']; % file name
    in.nRate        = 148.148; % signal rate
    in.nSignal      = 1; % number of signals
    in.nSize        = int64(1*60*in.nRate); % maximum buffer size for 1 min
    in.nSampleOut   = 1; % number of samples to return (default: 1)
    in.bWrite       = false; % enable writing when buffer is full
    in.bWriteForce  = false; % force writing to file 

    % Internal variables
    in.iCurrent     = 0; % index in buffer
end 

if ~isempty(varargin)
   for i = 1:numel(varargin)/2
      in.(varargin{(i-1)*2+1}) = varargin{i*2};
   end
end

% BOX 1.2 ---------------------------------------------------------------------------
if isempty(nBuffer)
    nBuffer             = coder.nullcopy(zeros(in.nSignal,in.nSize,in.sDataType));
    if in.bWrite
        in.mat          = matfile(in.sName,'Writable',true); % initiate writing to file
        in.mat.nData    = []; % initiate writing into nData variable
        in.mat.nTime    = sprintf('%f',now);
    end
    nSampleData = 0; % number of written data samples
    nSampleTime = 1; % number of written timestamps
end

if ~isempty(nData) % Add new data to buffer

    nIndexNew = in.iCurrent + size(nData,2); % Get the input size for buffer assignment

    if nIndexNew > in.nSize % WRITE BUFFER TO FILE, IF FULL
        if in.bWrite

            % Write timestamps to file
            in.mat.nTime(nSampleTime+1,:) = sprintf('%f',now);
            % Write all samples in nBuffer to file
            in.mat.nData(1:in.nSignal, nSampleData+1:nSampleData+in.iCurrent) = nBuffer(:,1:in.iCurrent);

        end
        nSampleData     = nSampleData + in.iCurrent; % num of samples written to file
        nSampleTime     = nSampleTime + 1; % num of samples written to file
        in.iCurrent     = 0; % Reset the buffer index
        nIndexNew       = size(nData,2); % Add new data in the beginning
    end

    nBuffer(:,in.iCurrent+1:nIndexNew)  = nData; % Concatenate the input data to the buffer
    in.iCurrent                         = nIndexNew; % Update the buffer index
    out                                 = in.iCurrent; % return current sample index, if everything is done

else % OUTPUT DATA

    % Provide additional output
    if in.iCurrent>0
        switch true
            case in.iCurrent-in.nSampleOut>0 % return a given number of samples
                out = nBuffer(:,in.iCurrent-in.nSampleOut+1:in.iCurrent);
            
            case isempty(in.nSampleOut) % return all data 
                out = nBuffer(:,1:in.iCurrent);

            otherwise % warning: truncated output because not enough data 
                out = nBuffer(:,1:in.iCurrent);

        end
    else 
        disp('WARNING: no data in BOX_CONTROL_SIGNAL')
        out = nan;
    end

    if in.bWriteForce % Force=write data in buffer

        if in.bWrite

            % Write timestamps to file
            in.mat.nTime(nSampleTime+1,:) = sprintf('%f',now);
            % Write all samples in nBuffer to file
            in.mat.nData(1:in.nSignal, nSampleData+1:nSampleData+in.iCurrent) = nBuffer(:,1:in.iCurrent);

        else
            disp('EMG_BOX: WRITING IS NOT ENABLED, assign bWrite,true')
        end
        nSampleData     = nSampleData + in.iCurrent; % num of samples written to file
        nSampleTime     = nSampleTime + 1; % num of samples written to file
        in.iCurrent     = 0; % Reset the buffer index
    end

    in.bWriteForce = false;

end
% ---------------------------------------------------------------------------END BOX
