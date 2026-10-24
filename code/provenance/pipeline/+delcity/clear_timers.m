function clear_timers()
%__________________________________________________________________________
% function CLEAR_TIMERS()
% STOP AND REMOVE ALL TIMER OBJECTS. CLEANUP MATLAB ENVIRONMENT.
%
% DESCRIPTION --------------------------------------------------------------
% This function finds all active timer objects in the MATLAB environment, 
% stops them if they are running, deletes them, and clears their variables. 
% It is useful for ensuring that no background timers interfere with subsequent 
% operations or hold onto system resources. Additionally, it closes all open 
% figures and clears all variables from the workspace, providing a clean slate.
%
% INPUTS ------------------------------------------------------------------
% No input arguments.
%
% OUTPUT ------------------------------------------------------------------
% No return values. The function cleans up timers, figures, and clears the workspace.
%
% EXAMPLE -----------------------------------------------------------------
% clear_timers();
%
% SEE ALSO: 
% timerfind   - Find timer objects
% stop        - Stop timer objects
% delete      - Delete objects
% clear       - Clear variables and functions from memory
% close       - Close figures
%
% AUTHOR ------------------------------------------------------------------
% S.Bahdasariants, NEL, WVU, https://github.com/SerhiiBahdas

    % Get all timers
    allTimers = timerfind;

    % If there are any timers, stop, delete, and clear them
    if ~isempty(allTimers)
        stop(allTimers);
        delete(allTimers);
    end
    clear allTimers;

end
