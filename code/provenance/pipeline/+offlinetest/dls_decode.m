function [out] = dls_decode(nEMG, varargin)
%DLS_DECODE Decodes distal muscle activations from EMG signals.
%
%   [out] = dls_decode(nEMG, varargin)
%
%   This function uses a pre-loaded template to decode distal muscle acti-
%   vations from electromyography (EMG) signals. It applies cross-correla-
%   tion in a sliding window to match EMG data with a template, and calcu-
%   lates the phase and muscle activation levels.
%
%   INPUT =================================================================
%
%   nEMG (matrix)
%   Matrix containing EMG. Signals are in rows.
%   Example: randn(16, 100)
%
%   varargin (name-value pairs)
%   Optional parameters specified as name-value pairs. Can include para-
%   meters to override template defaults, such as 'nMean_p' for average 
%   proximal activations, 'nMean_d' for average distal activations, or 
%   'tWindow' for search window size.
%   Example: 'nMean_p', 1, 'tWindow', 0.4
%
%   OUTPUT ================================================================
%
%   out (structure)
%   Contains decoded muscle activations and phase information. 'nDist' 
%   field contains the muscle activation levels, normalized between 0 and
%   1. 'nPhase' field indicates the phase shift applied to align the 
%   signal with the template.
%
%   AUTHOR ================================================================
%
%   S.Bahdasariants, NEL, WVU, https://github.com/SerhiiBahdas
%
%   =======================================================================
%
%   See also FFT, IFFT, LOAD, MAX.
%
%   =======================================================================

% INITIALIZATION ----------------------------------------------------------

persistent in

if isempty(in)

    % TEMPLATE FILE: 
    in.sFile     = "TEMPLATE.mat";
    TEMPLATE     = load(in.sFile);
    template     = TEMPLATE.TEMPLATE.template; 

    % TEMPLATE PARAMETERS: 
    in.TMPLen    = 'TMP1000';
    sTrialType   = 'PRONATE25';

    for iSig = 1:length(TEMPLATE.TEMPLATE.sSignalList)
        sSignal = TEMPLATE.TEMPLATE.sSignalList(iSig);
        in.nTmp(iSig,:) =  template.(in.TMPLen).(sTrialType).(sSignal);
    end

    in.idDistList = TEMPLATE.TEMPLATE.idDistList; 
    in.idProxList = TEMPLATE.TEMPLATE.idProxList; 

    in.idxDecodeSignals = [in.idProxList, in.idDistList];

    % SIGNAL PARAMETERS: 
    in.nRate     = 1925.925926;  
    in.nPhase    = 0;                  % phase, in samples
    in.nSkipStep = 6;                  % for downsampling EMG

    % DECODER PARAMETERS:
    in.tWindow   = 150e-3;             % search window, s
    in.bReset    = 0;                  % reset the phase

    in.idxProx    = TEMPLATE.TEMPLATE.idProxList;
end

% Update input structure with varargin.
if ~isempty(varargin)
    for i = 1:numel(varargin)/2
        in.(varargin{(i-1)*2+1}) = varargin{i*2};
    end
end

% DECODER -----------------------------------------------------------------

nTemplate  = in.nTmp;
numSamples = length(nTemplate);
nWindow    = round(in.tWindow*in.nRate/in.nSkipStep);

if ~isempty(nEMG)

    % DEFINE SEARCH WINDOW:
    if in.bReset
        in.nPhase   = 0; 
        in.bReset   = 0;  
    end

    nEMG_resampled  = nEMG(:,1:in.nSkipStep:end);
    nProj           = nEMG_resampled;%(nEMG_resampled' * in.Loadings)';

    idxSample_start = max(in.nPhase - round(0.5*nWindow), 1);
    idxSample_end   = min(in.nPhase + round(0.5*nWindow), numSamples);
    idxSample_start = min([idxSample_start, abs(numSamples - length(nProj))]);
    idxSample_end   = max(length(nEMG_resampled), idxSample_end);

    % X-CORRELATION:
    nTmp_segment   = nTemplate(:,idxSample_start:idxSample_end);%in.nFactors(idxSample_start:idxSample_end, :)';

    [~, in.nPhase] = offlinetest.locatesignal(nProj(in.idxDecodeSignals, 1:min(size(nProj,2), length(nTmp_segment)-1)),nTmp_segment(in.idxDecodeSignals,:),1,1,0);

    in.nPhase      = in.nPhase + idxSample_start;
    in.nPhase      = max(min(in.nPhase, numSamples),0)+1;

    out = in.nPhase/numSamples; 

else

    in.nPhase = 0;
    out = in.nPhase;
end

end