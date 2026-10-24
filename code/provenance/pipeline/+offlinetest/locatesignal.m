function [iStartSampleList, iEndSampleList] = locatesignal(nSig,nTmp,nStep,bFindCommon,bPlot)
%LOCATESIGNAL Locates a signal within a larger signal using dot product.
%
%   [iStartSampleList, iEndSampleList] = locatesignal(nSig,nTmp,nStep,bFindCommon,bPlot)
%
%   This function takes a signal and a template, and finds the location of the 
%   signal within the template using the dot product. The function also allows 
%   for step size customization, finding common locations across multiple signals, 
%   and plotting the results.
%
%   INPUT =================================================================
%
%   nSig (numeric array)
%   The signal to be located within the template. Each row corresponds to a 
%   signal.
%
%   nTmp (numeric array)
%   The template within which the signal is to be located. Each row corresponds 
%   to a template.
%
%   nStep (numeric, optional)
%   The step size for the sliding window. Default is 1.
%
%   bFindCommon (boolean, optional)
%   If true, the function finds common phase shift across multiple signals. 
%   Default is false.
%
%   bPlot (boolean, optional)
%   If true, the function plots the results. Default is false.
%
%   EXAMPLE ===============================================================
%
%   %first:
%   for i = 1:10
%   X(i,:) = cos(i*t + pi/2);
%   Y(i,:) = cos(i*t(ceil(end/1.5):end) + pi/2);
%   end
%   [iStartSampleList, iEndSampleList] = locatesignal(Y,X,1,0,1)
%
%   %second: 
%   for i = 1:10
%   X(i,:) = cos(i*t + pi/2);
%   Y(i,:) = cos(i*t((ceil(end/1.5):end) + pi/2);
%   end
%   [iStartSampleList, iEndSampleList] = locatesignal(Y,X,1,1,1)
%
%   OUTPUT ================================================================
%
%   iStartSampleList (numeric array)
%   The starting sample indices of the located signal within the template. 
%   Each element corresponds to a signal in the input data.
%
%   iEndSampleList (numeric array)
%   The ending sample indices of the located signal within the template. 
%   Each element corresponds to a signal in the input data.
%
%   AUTHOR ================================================================
%
%   S.Bahdasariants, NEL, WVU, https://github.com/SerhiiBahdas
%
%   =======================================================================

% OPTIONAL PARAMETERS:
if nargin < 3
    nStep = 1;
end

if nargin < 4
    bFindCommon = 0;
end

if nargin < 5
    bPlot = 0;
end

% REUSABLE CONSTANTS: 
[numSignals, numSamples_sig] = size(nSig);
[~,          numSamples_tmp] = size(nTmp);
numWindows                   = max(round((numSamples_tmp - numSamples_sig)/nStep),1);
nDotProductList              = zeros(numSignals, numWindows); 

% DOT PRODUCT: 
for iSignal = 1:numSignals
    nSig_norm = norm(nSig(iSignal,:));
    idxStart  = 1;
    for iWindow = 1:numWindows
        idxEnd            = idxStart + numSamples_sig - 1;
        nTmp_segment      = nTmp(iSignal, idxStart:idxEnd);
        nTmp_segment_norm = norm(nTmp_segment);
        nDotProductList(iSignal, iWindow) = dot(nSig(iSignal,:), nTmp_segment)/(nSig_norm*nTmp_segment_norm);
        idxStart          = 1 + nStep*iWindow; 
    end
end

if bFindCommon
    nDotproduct_upd = nanmean(nDotProductList,1);
else
    nDotproduct_upd = nDotProductList;
end

% OUTPUT: 
[~, iStartSampleList] = max(nDotproduct_upd, [], 2);
iStartSampleList      = iStartSampleList*nStep -nStep; 
iEndSampleList        = iStartSampleList+numSamples_sig-1; 

% PLOTTING ================================================================
if bPlot

    figure; 
    for iEntry = 1:numel(iStartSampleList)
        subplot(numel(iStartSampleList), 1, iEntry)
        stem(1:nStep:numWindows, nDotproduct_upd(iEntry,:))
        xlabel("samples")
        ylabel("dot product")
    end

    figure; 

    if bFindCommon

        for iSignal = 1:numSignals
            iStart = iStartSampleList;
            iEnd   = iEndSampleList; 
            subplot(numSignals, 1, iSignal)
            plot(nTmp(iSignal,:), 'k--', LineWidth=2)
            hold on 
            plot(iStart:iEnd, nSig(iSignal,:), 'b', LineWidth = 2)
            xline(iStart, LineWidth = 2, Color="y")
            xline(iEnd, LineWidth = 2, Color="y")
            xlabel('samples')
            ylabel('amplitude')
        end

    else

    for iSignal = 1:numSignals
        iStart = iStartSampleList(iSignal);
        iEnd   = iEndSampleList(iSignal); 
        subplot(numSignals, 1, iSignal)
        plot(nTmp(iSignal,:), 'k--', LineWidth=2)
        hold on 
        plot(iStart:iEnd, nSig(iSignal,:), 'b', LineWidth = 2)
        xline(iStart, LineWidth = 2, Color="y")
        xline(iEnd, LineWidth = 2, Color="y")
        xlabel('samples')
        ylabel('amplitude')
    end

    end
end

end