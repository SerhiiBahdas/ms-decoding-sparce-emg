% This script plots FIG 3A, B. 

load("FIG3_A_B.mat");

nSampleList_acc = 1:length(UserData(1).meanData);
nSampleList_emg = 1:length(UserData(2).meanData);


nSTARTMOV_acc = round(tSTARTMOV*nRate_acc); 
nENDMOV_acc   = round(tENDMOV*nRate_acc); 

nSTARTMOV_emg = round(tSTARTMOV*nRate_emg); 
nENDMOV_emg   = round(tENDMOV*nRate_emg); 


numReps = length(nSTARTMOV_acc);

numSamples = 1000; 

nACC = []; nEMG = []; 

for iRep = 1:numReps

    iStart_acc = nSTARTMOV_acc(iRep);
    iEnd_acc   = nENDMOV_acc(iRep);

    nACC_tmp = UserData(1).meanData(iStart_acc:iEnd_acc);
    nACC_tmp = interp1(linspace(0,1,length(nACC_tmp)), nACC_tmp, linspace(0,1,numSamples));

    nACC = [nACC; nACC_tmp];


    iStart_emg = nSTARTMOV_emg(iRep);
    iEnd_emg   = nENDMOV_emg(iRep);

    nEMG_tmp = UserData(2).meanData(iStart_emg:iEnd_emg);
    nEMG_tmp = interp1(linspace(0,1,length(nEMG_tmp)), nEMG_tmp, linspace(0,1,numSamples));

    nEMG = [nEMG; nEMG_tmp];

end

plot_signals_with_std(nACC, nEMG)

function plot_signals_with_std(nEMG, nACC)
    % Input:
    % nEMG: mxn matrix (m trials, n samples per trial) for nEMG signal
    % nACC: pxq matrix (p trials, q samples per trial) for nACC signal

    % Compute statistics for nEMG
    mean_nEMG = mean(nEMG, 1);
    std_nEMG = std(nEMG, 0, 1);

    % Compute statistics for nACC
    mean_nACC = mean(nACC, 1);
    std_nACC = std(nACC, 0, 1);

    % Create the plot
    figure;

    % Subplot for nEMG
    subplot(2, 1, 1);
    x_nEMG = 1:size(nEMG, 2);
    hold on;
    fill([x_nEMG, fliplr(x_nEMG)], ...
         [mean_nEMG + std_nEMG, fliplr(mean_nEMG - std_nEMG)], ...
         [0.9 0.9 0.9], 'EdgeColor', 'none'); % Standard deviation as shaded area
    plot(x_nEMG, mean_nEMG, 'b', 'LineWidth', 2); % Plot mean signal
    hold off;
    xlabel('Samples');
    ylabel('FSR, V');
    legend('Standard Deviation', 'Mean Signal');
    grid on;

    % Subplot for nACC
    subplot(2, 1, 2);
    x_nACC = 1:size(nACC, 2);
    hold on;
    fill([x_nACC, fliplr(x_nACC)], ...
         [mean_nACC + std_nACC, fliplr(mean_nACC - std_nACC)], ...
         [0.9 0.9 0.9], 'EdgeColor', 'none'); % Standard deviation as shaded area
    plot(x_nACC, mean_nACC, 'r', 'LineWidth', 2); % Plot mean signal
    hold off;
    xlabel('Samples');
    ylabel('ACC, g');
    legend('Standard Deviation', 'Mean Signal');
    grid on;

end
