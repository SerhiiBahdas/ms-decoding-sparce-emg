function hTimer = decode_phase_object(varargin)
%
%   AUTHOR ================================================================
%
%   S.Bahdasariants, NEL, WVU, https://github.com/SerhiiBahdas
%
%   =======================================================================z
    persistent in

    if ~isfield(in, 'tUpd')
        in.tUpd   = 14e-3;
    end

    if ~isfield(in, 'nRate')
        in.nRate   = 1925.92592592592;
    end

    if ~isfield(in, 'sTrialType')
        in.sTrialType = 'PRONATE25'; 
    end

    % Create a timer
    hTimer = timer('StartDelay', 0, ...
                   'Period', in.tUpd, ...
                   'ExecutionMode', 'fixedRate');

    hTimer.TimerFcn = @(~, ~) update_phase_box();
    hTimer.BusyMode = "drop"; 
    start(hTimer);

    function update_phase_box()

        persistent nMA nPhase nACC bGrab bGo params

        if isempty(bGo)
            bGo = 0; 
        end

        if isempty(params)
            params = offlinetest.decode_ini();
        end

        % BEGIN/TERMINATE TRIAL: 
        nACC          = offlinetest.box_control_signal([], 'nSampleOut', 1);
        bGrab         = nACC > 0;
        [bGo]         = offlinetest.reset_phase(bGrab, bGo);
    
        if bGo 

            nMA    = offlinetest.box_ma([], 'nSampleOut', params.nHistory);

            nPhase = offlinetest.dls_decode(nMA);
        else
            nPhase = offlinetest.dls_decode([]);
        end

        offlinetest.box_predicted_phase(nPhase);

    end
end
