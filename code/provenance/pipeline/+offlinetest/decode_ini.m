function params = decode_ini()

% DECODER_INI Initializes parameters for the decoding.
%
%   params = decode_ini()
%
%   OUTPUT ============================================================
%   
%   params (structure)
%   Structure with parameters for the decoder.
%
%   AUTHOR ============================================================
%
%   S.Bahdasariants, NEL, WVU, https://github.com/SerhiiBahdas
%
%   ===================================================================

    % SIGNAL NAMES:
    params.sSignalList      = {'DELT_A', 'DELT_P', 'DELT_M', 'BIC_SH', 'BIC_LO', 'TRI_LAT', 'TRI_LO', 'BRR', 'FCR', 'FDS', 'FCU', 'ECR', 'EDC', 'ECU', 'ADP', 'FSR'};
    params.sSignalList_p    = {'DELT_A', 'DELT_P', 'DELT_M', 'BIC_SH', 'BIC_LO', 'TRI_LAT', 'TRI_LO'};
    params.sSignalList_d    = {'BRR', 'FCR', 'FDS', 'FCU', 'ECR', 'EDC', 'ECU', 'ADP'};

    % SIGNAL METADATA: 
    params.idSensor_FSR    = find(params.sSignalList == "FSR");   % FSR is 16th sensor 
    params.idSensor_DELT_A = 1;                                   % Anterior deltoid
    params.nRate           = 1925.92592592592;                    % EMG rate, Hz
    params.tHistory        = 50e-3;                               % EMG history for decoder, ms
    params.nHistory        = round(params.tHistory*params.nRate); % EMG history for decoder, ms

    params.numDist         = length(params.sSignalList_d);        % number of distal musc.

end
