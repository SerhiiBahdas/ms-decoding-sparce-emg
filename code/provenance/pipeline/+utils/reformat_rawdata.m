function reformat_rawdata(folderPath, sSignalList_emg, sSignalList_acc, nRate_acc, nRate_emg)
% REFORMAT_RAWDATA Processes and renames EMG and ACC data in .mat files.
%
%   reformat_rawdata(folderPath, sSignalList_emg, sSignalList_acc, nRate_acc, nRate_emg)
%
%   INPUT =================================================================
%
%   folderPath (char)
%   Path to the folder containing the raw .mat files.
%
%   sSignalList_emg (cell array of char)
%   List of EMG signal names to be extracted from the data.
%
%   sSignalList_acc (cell array of char)
%   List of ACC signal names to be extracted from the data.
%
%   nRate_acc (numeric)
%   Sampling rate for ACC signals.
%
%   nRate_emg (numeric)
%   Sampling rate for EMG signals.
%
%   OUTPUT ================================================================
%
%   No direct output. The function processes and renames the EMG and ACC data,
%   saving the results into separate "emgraw" and "accraw" folders.
%
%   ======================================================================


    % Define the new directory path for processed files
    parentFolder = fileparts(folderPath); % Get the parent directory
    procDataFolder_emg = fullfile(parentFolder, 'emgraw'); % Create path for procdata folder
    procDataFolder_acc = fullfile(parentFolder, 'accraw'); % Create path for procdata folder

    % Create the procdata folder if it does not exist
    if ~exist(procDataFolder_emg, 'dir')
        mkdir(procDataFolder_emg);
    end

    if ~exist(procDataFolder_acc, 'dir')
        mkdir(procDataFolder_acc);
    end

    % Get a list of all .mat files in the folder
    files = dir(fullfile(folderPath, '*.mat'));
    
    for i = 1:length(files)
        % Full path to the current file
        filePath = fullfile(folderPath, files(i).name);
        
        % Load the .mat file
        data = load(filePath);
        
        % Determine the new variable name and output file name based on substring
        if contains(files(i).name, 'emg', 'IgnoreCase', true)
            nData = data.nData;
            
            for iSignal = 1:length(sSignalList_emg)
                sSignal = sSignalList_emg(iSignal);
                emgraw.(sSignal) = nData(iSignal,:);
            end

            emgraw.tTime = 0:1/nRate_emg:(length(nData) - 1)/nRate_emg; 
    
            newFileName = fullfile(procDataFolder_emg, files(i).name);

            save(newFileName, 'emgraw');

        elseif contains(files(i).name, 'acc', 'IgnoreCase', true)
            nData = data.nData;

            for iSignal = 1:length(sSignalList_acc)
                sSignal = sSignalList_acc(iSignal);
                accraw.(sSignal) = nData(iSignal,:);
            end

            accraw.tTime = 0:1/nRate_acc:(length(nData) - 1)/nRate_acc; 

            newFileName = fullfile(procDataFolder_acc, files(i).name);

            save(newFileName, 'accraw');
        end
    end
end
