function hTimer = compute_ma(varargin)
% COMPUTE_MA Initializes and starts a timer to compute moving average.
%
%   hTimer = compute_ma('ParameterName', ParameterValue, ...)
%
%   Parameters:
%       'tUpd'              - Timer update latency in seconds (default: 14e-3)
%       'nRate'             - Sampling rate (default: 1925.92592592592)
%       'sFileFiltParams'   - Path to FILTER.mat file (default: 'FILTER.mat')
%       'sFileScaleParams'  - Path to SCALORS.mat file (default: 'SCALORS.mat')
%       'nWindow'           - Window size for moving average (default: 100)
%       'idSubject'         - Subject ID (default: 1)
%       'sSignalList'       - Cell array of signal names (default as defined)
%
%   AUTHOR
%       S. Bahdasariants, NEL, WVU, https://github.com/SerhiiBahdas

    persistent in

    % Initialize input structure
    in = struct; 

    % Parse varargin into name-value pairs
    if ~isempty(varargin)
        if mod(numel(varargin),2) ~= 0
            error('Arguments should be in name-value pairs.');
        end
        for i = 1:2:numel(varargin)
            paramName = varargin{i};
            paramValue = varargin{i+1};
            if ischar(paramName) || isstring(paramName)
                in.(paramName) = paramValue;
            else
                error('Parameter names must be strings.');
            end
        end
    end

    % Set default parameters if not provided
    if ~isfield(in, 'tUpd')
        in.tUpd = 14e-3;  % Timer update latency in seconds
    end

    if ~isfield(in, 'nRate')
        in.nRate = 1925.92592592592;  % Sampling rate
    end

    if ~isfield(in, 'sFileFiltParams')
        in.sFileFiltParams = 'FILTER.mat';  % Path to FILTER.mat
    end

    if ~isfield(in, 'nWindow')
        in.nWindow = 300;  % Window size for moving average
    end

    if ~isfield(in, 'idSubject')
        in.idSubject = 1;  % Subject ID
    end

    if ~isfield(in, 'sSignalList')
        in.sSignalList = {
            'DELT_A', 'DELT_M', 'DELT_P', ...
            'BIC_SH', 'BIC_LO', 'TRI_LAT', ...
            'TRI_LO', 'BRR', 'FCR', ...
            'FDS', 'FCU', 'ECR', 'EDC', ...
            'ECU', 'ADP', 'FSR'
        };
    end


    % Load metaNoise from FILTER.mat if not already provided
    if ~isfield(in, 'filtparams')
        in.filtparams = load(in.sFileFiltParams);
    end

    if ~isfield(in, 'idTrial')
        in.idTrial = 1;
    end

    % Create a timer
    hTimer = timer(...
        'StartDelay', 0, ...
        'Period', in.tUpd, ...
        'ExecutionMode', 'fixedRate', ...
        'TimerFcn', @(~, ~) update_ma_box(), ...
        'BusyMode', 'drop' ...
    );

    % Start the timer
    start(hTimer);

    % Nested function to update moving average
    function update_ma_box()

        persistent nEMG nMA

        % Setup EMG box with the given update window
        nEMG = offlinetest.box_emg([], 'nSampleOut', round(in.tUpd*in.nRate));

        try
            % Demean and rectify EMG signal 
            nMA = utils.demean(nEMG, in.filtparams, in.idSubject, in.sSignalList);

            % Compute moving average
            nMA = utils.movemean_rt(nMA, in.nWindow);

            if any(nMA< 0)
                disp("Catch: Movmean muscle activations are negative! Check compute_ma")
            end

            % Demean and scale MA
            nMA = utils.denoise_and_scale(nMA, in.filtparams, in.idSubject, in.idTrial, in.sSignalList, 'threshold');

            nMA(nMA>1) = 1; 

            % Update the offline test box with the moving average
            offlinetest.box_ma(nMA);
            
        catch ME
            warning(['An error occurred in update_ma_box: ', ME.message]);
        end
    end
end
