function [nMatrix] = create_signal_matrix(sTableName, sSignalList, sTrialType, idSubject)
% create_signal_matrix Retrieves and creates a matrix of signals from a specific table.
%
%   create_signal_matrix(sTableName, sSignalList, sTrialType, idSubject)
%
%   INPUT =================================================================
%
%   sTableName (char)
%   Name of the table from which signals will be retrieved.
%
%   sSignalList (cell array of char)
%   List of signal names to be retrieved from the specified table.
%
%   sTrialType (char)
%   The type of trial for which the signals will be retrieved (e.g., 'GRASP10').
%
%   idSubject (numeric)
%   The identifier of the subject for which the trial signals are retrieved.
%
%   OUTPUT ================================================================
%
%   nMatrix (numeric array)
%   A matrix where each row corresponds to the signal data for each signal in sSignalList,
%   and columns represent data points across the trials.
%
%   ======================================================================
    
    % Get the trial list based on the subject and trial type
    idTrialList = getMeta('metaTrial', qry('sTrialType', sTrialType, 'idSubject', idSubject), 'idTrial');

    % Initialize matrix
    nMatrix = [];

    % Loop through each signal and retrieve the corresponding signal data
    for iSignal = 1:length(sSignalList)
        % Get the signal for the current trial and signal
        Signal.sTable = sTableName;  % Assign table name
        Signal.sSignal = sSignalList{iSignal};  % Assign signal name
        nMatrix(iSignal, :) = getSignal(idTrialList, Signal, []);  % Get signal and assign to matrix
    end
end
