function [bGo] = reset_phase(bGrab, bGo)
    
    if bGrab && ~bGo                                 % if grabbed
        bGo    = 1;                                  % start trial

    elseif ~bGrab && bGo                             % if released
        bGo    = 0;                                  % end trial
        
        % UPDATE STATE: 
        offlinetest.dls_decode([], 'nPhase', 0);

    end

end
