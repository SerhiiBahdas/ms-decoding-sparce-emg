boxsci

idSubjectList = [1,2,3,5];

% Define the event signal and the table where the event information is stored
Signal_event.sTable  = 'accproc10Hz';
Signal_event.sSignal = 'ADP_y';

% If the ADP signal is missing try this one: 
SignalBackup.sTable  = 'accproc10Hz';
SignalBackup.sSignal = 'FDS_y';

Signal_set.sTable  = 'state';
Signal_set.sSignal = 'switch';

nRate = getMeta('metaSignal', qry('sTable', Signal_event.sTable, 'sSignal', Signal_event.sSignal), 'nRate');

% List of trial types to process
sTrialTypeList = {'GRASP10', 'GRASP25', 'GRIP10', 'GRIP25', 'PRONATE10', 'PRONATE25'};

% Retrieve the list of trial IDs corresponding to the specified trial types
idTrialList = getMeta('metaTrial', qry('sTrialType', sTrialTypeList), 'idTrial');

idSessionList     = getMeta('metaTrial', qry('idTrial', idTrialList), 'idSession');
idTrialTypeList   = getMeta('metaTrial', qry('idTrial', idTrialList), 'idTrialType');

for iTrial = 1:length(idTrialList)

    disp("TRIAL" + iTrial)

    idTrial = idTrialList(iTrial);

    nEventList_on  = round(getEvent(idTrial,Signal_event,1,[])*nRate);
    nEventList_off = round(getEvent(idTrial,Signal_event,2,[])*nRate);

    if isempty(nEventList_on) || isempty(nEventList_off)
        nEventList_on  = round(getEvent(idTrial,SignalBackup,1,[])*nRate);
        nEventList_off = round(getEvent(idTrial,SignalBackup,2,[])*nRate);
    end

    nSignal        = getSignal(idTrial, Signal_event, []);
    nLength        = length(nSignal);

    nSwitch        = zeros(nLength,1);
    
    for iPair = 1:length(nEventList_on)
        nSwitch(nEventList_on(iPair):nEventList_off(iPair)) = 1; 
    end

    nPhase = nSwitch;

    % Define the maximum ramp value (e.g., 1 for normalization)
    maxRamp = 1;
    
    for iPair = 1:length(nEventList_on)
        onIdx = nEventList_on(iPair);
        offIdx = nEventList_off(iPair);
        duration = offIdx - onIdx + 1; % Number of points in the ramp
        
        % Generate a linear ramp from 0 to maxRamp
        ramp = linspace(0, maxRamp, duration);
        
        % Assign the ramp to nSwitch
        nPhase(onIdx:offIdx) = ramp;
    end
   
    setSignal(nSwitch, qry('sTable', Signal_set.sTable, 'sSignal', Signal_set.sSignal), idTrial, ...
                    'nRate', nRate, ...
                    'sUnit', 'n.u.', ...
                    'idSession', idSessionList(iTrial), ...
                    'idTrialType', idTrialTypeList(iTrial), ...
                    'tSync', 0);

    setSignal(nPhase, qry('sTable', Signal_set.sTable, 'sSignal', 'phase'), idTrial, ...
                    'nRate', nRate, ...
                    'sUnit', 'n.u.', ...
                    'idSession', idSessionList(iTrial), ...
                    'idTrialType', idTrialTypeList(iTrial), ...
                    'tSync', 0);
end