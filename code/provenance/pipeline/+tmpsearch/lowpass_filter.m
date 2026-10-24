function filteredData = lowpass_filter(data, nRate, nRate_cutoff)
%LOWPASS_FILTER Applies a low-pass filter with a user-specified cutoff frequency.
%   filteredData = LOWPASS_FILTER(data, nRate, nRate_cutoff) filters the 
%   input data sampled at rate nRate using a low-pass filter with a 
%   cutoff frequency of nRate_cutoff.
%
%   INPUTS:
%       data         - (vector or matrix) Input signal to be filtered. If a 
%                      matrix, filtering is applied column-wise.
%       nRate        - (scalar) Sampling rate of the input signal in Hz.
%       nRate_cutoff - (scalar) Cutoff frequency of the low-pass filter in Hz.
%
%   OUTPUTS:
%       filteredData - Filtered signal with the same dimensions as the input.
%
%   EXAMPLE:
%       fs = 100; % Sampling rate in Hz
%       cutoff = 10; % Cutoff frequency in Hz
%       t = 0:1/fs:5; % Time vector
%       signal = sin(2*pi*1*t) + 0.5*sin(2*pi*20*t); % Signal with 1 Hz and 20 Hz components
%       filteredSignal = lowpass_filter(signal, fs, cutoff);
%       plot(t, signal, t, filteredSignal);
%       legend('Original Signal', 'Filtered Signal');
%

    % Validate inputs
    if nargin ~= 3
        error('lowpass_filter requires three inputs: data, nRate, and nRate_cutoff.');
    end
    if ~isnumeric(data) || ~isnumeric(nRate) || ~isscalar(nRate) || ~isnumeric(nRate_cutoff) || ~isscalar(nRate_cutoff)
        error('Input data must be numeric, and nRate and nRate_cutoff must be scalars.');
    end
    if nRate_cutoff >= nRate / 2
        error('Cutoff frequency must be less than half the sampling rate (Nyquist frequency).');
    end
    
    % Design low-pass filter
    nyquistFreq = nRate / 2; % Nyquist frequency
    [b, a] = butter(4, nRate_cutoff / nyquistFreq, 'low'); % 4th-order Butterworth filter
    
    % Apply filter
    filteredData = filtfilt(b, a, data);
end
