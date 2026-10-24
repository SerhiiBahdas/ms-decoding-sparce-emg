function reformat_raw_files(sPath, sFolderList_subject, nFolder_rawdata)
% reformat_raw_files Loads and reformats raw EMG and ACC data for each subject.
%
%   reformat_subject_data(sPath, sFolderList_subject, nFolder_rawdata)
%
%   INPUT =================================================================
%
%   sPath (char)
%   Base path where the subject data is stored.
%
%   sFolderList_subject (cell array of char)
%   List of folder names for each subject.
%
%   nFolder_rawdata (char)
%   Name of the folder containing the raw data to be reformatted.
%
%   OUTPUT ================================================================
%
%   No direct output. The function loads and processes the EMG and ACC data,
%   and reformats it for each subject based on the given folder structure.
%
%   ======================================================================

    % Initialize containers for meta signals
    metaSignal_acc = struct();
    metaSignal_emg = struct();

    % Load ACC and EMG meta signals for each subject
    for iSubj = 1:length(sFolderList_subject)
        subjID = "SUBJ" + iSubj;
        
        % Load ACC meta signal
        metaSignal_acc.(subjID) = load_csv('sPath', fullfile(sPath, ...
            sFolderList_subject(iSubj), "accraw"), 'sFile', "accraw_metaSignal.csv");
        
        % Load EMG meta signal
        metaSignal_emg.(subjID) = load_csv('sPath', fullfile(sPath, ...
            sFolderList_subject(iSubj), "emgraw"), 'sFile', "emgraw_metaSignal.csv");
    end

    % Reformat raw data for each subject
    for iSubj = 1:length(sFolderList_subject)
        subjID          = "SUBJ" + iSubj;
        sFolderPath     = fullfile(sPath, sFolderList_subject(iSubj), nFolder_rawdata);
        
        % Extract ACC and EMG signals and rates
        sSignalList_acc = string(metaSignal_acc.(subjID).sSignal);
        sSignalList_acc = sSignalList_acc(sSignalList_acc ~= "tTime");
        nRate_acc       = metaSignal_acc.(subjID).nRate(1);
        
        sSignalList_emg = string(metaSignal_emg.(subjID).sSignal);
        sSignalList_emg = sSignalList_emg(sSignalList_emg ~= "tTime");

        nRate_emg       = metaSignal_emg.(subjID).nRate(1);
        
        cd(sPath); 

        % Reformat raw data
        utils.reformat_rawdata(sFolderPath, sSignalList_emg, sSignalList_acc, nRate_acc, nRate_emg);
    end

    cd(sPath); 
end
