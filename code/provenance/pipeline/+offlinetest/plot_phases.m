function timerObj = plot_phases(varargin)

persistent hPlot1 hPlot2 hPlot3

in.nRate        = 60;
in.sSignalList  = {'$\psi$'};

if ~isempty(varargin)
   for i = 1:length(varargin)/2
      in.(varargin{(i-1)*2+1}) = varargin{i*2};
   end
end

timerObj               = timer;
timerObj.Period        = round(1/in.nRate,3); % 5 ms interval
timerObj.ExecutionMode = 'fixedRate'; % execute at fixed rate
timerObj.BusyMode      = "drop";
timerObj.TimerFcn      = @update_plot; % callback function

% PLOT GUI
nData1  = offlinetest.box_phase([], 'nSampleOut', 1); % EMG pre-proceesed into MA       
nSignal = length(nData1);

% Create graphical objects ------------------------------------------------
hFigure = figure;
uicontrol('Parent'  , hFigure, ... % Specify the parent as the figure handle
    'Style'         , 'pushbutton', ... % Specify the style as push button
    'Position'      , [0 0 100 20], ... % Specify the position and size in pixels
    'String'        , 'Stop', ... % Specify the text on the button
    'Callback'      , @(src, evt)delete_timer(timerObj)); % Specify the callback function
hPlot1 = zeros(nSignal,1);
hPlot2 = zeros(nSignal,1);
hPlot3 = zeros(nSignal,1);

for i = 1:nSignal
    subplot(nSignal,1,i)
    hPlot1(i) = plot(zeros(1000,1),...
        'LineWidth',4, 'Color',[0.8500 0.3250 0.0980, 0.4]);
    hold on 
    hPlot2(i) = plot(zeros(1000,1),...
        'LineWidth',2, 'Color', [0 0.4470 0.7410, 0.6]);

    hold on 
    hPlot3(i) = plot(zeros(1000,1),...
        'LineWidth',0.5, 'Color', [0.6350 0.0780 0.1840]);

    % Add axes information
    if i~=nSignal
        hAxes       = gca;
        hAxes.XTick = [];
    end
    ylabel(in.sSignalList{i}, 'Interpreter','latex', 'FontSize',20)
    ylim([0,1])
end
% ------------------------------------------------ Create graphical objects

start(timerObj);

    function delete_timer (timerObj)
        stop (timerObj);% Stop the timer
        delete (timerObj);% Delete the timer
    end

    function update_plot(~, ~)
        try
            nData1   = offlinetest.box_phase([], 'nSampleOut', 1);
            nData2   = offlinetest.box_predicted_phase([], 'nSampleOut');
            if ~isempty(nData1)
                nSignal     = length(nData1);
                for iSignal = 1:nSignal
                    ydata   = get(hPlot1(iSignal),'YData');
                    set(hPlot1(iSignal),'YData',[ydata(2:end) nData1(iSignal, 1)])
                    ydata   = get(hPlot2(iSignal),'YData');
                    set(hPlot2(iSignal),'YData',[ydata(2:end) nData2(iSignal, 1)])
                    ydata   = get(hPlot3(iSignal),'YData');
                    set(hPlot3(iSignal),'YData',[ydata(2:end) abs(nData1(iSignal, 1)-nData2(iSignal, 1))])
                    
                end
            end
        catch 
            disp('ERROR: in plot_phase.update_plot()')
        end
    end

end
