function clean_functions()
%__________________________________________________________________________
% function cleanFunctions()
% CLEAN FUNCTIONS FROM MEMORY. IMPROVE SYSTEM PERFORMANCE.
% 
% DESCRIPTION ---------------------------------------------------------
% This function searches for all MATLAB function files (.m) within the 
% current directory and its subdirectories. It then clears persistent 
% variables within these functions.
% 
% INPUTS --------------------------------------------------------------
% No input arguments.
% 
% OUTPUT --------------------------------------------------------------
% No return values. However, it provides a visual confirmation in the 
% Command Window indicating that all functions have been cleared.
% 
% EXAMPLE -------------------------------------------------------------
% clean_functions()
% 
% SEE ALSO: 
% clear       - Clear variables and functions from memory
% dir         - List folder contents
% 
% AUTHOR --------------------------------------------------------------
% S.Bahdasariants, NEL, WVU, https://github.com/SerhiiBahdas
% 

    % Get the list of all .m files in the current directory and subdirectories
    files = dir('**/*.m');

    % Loop over the files
    for i = 1:length(files)
        
        % Get the full file name
        fullFileName = fullfile(files(i).folder, files(i).name);

        % Clear persistent variables within a funciton
        clear(fullFileName);
    end

    disp('PERSISTENT VARIABLES WITHIN FUNCTIONS WERE CLEARED.');
end
