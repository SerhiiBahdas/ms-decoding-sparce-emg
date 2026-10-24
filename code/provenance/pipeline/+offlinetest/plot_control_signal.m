function timerObj = plot_control_signal(varargin)
%__________________________________________________________________________
% function PLOT_EMG(varargin)
% REAL-TIME PLOTTING OF EMG SIGNALS USING A TIMER OBJECT.
%
% DESCRIPTION --------------------------------------------------------------
% This function sets up a real-time plotting environment for EMG signals using 
% a timer object. It initializes a plot for each EMG signal specified and updates 
% the plots at a rate specified by the user. The function allows customization of 
% signal list, line style, line width, and Y-axis limits through name-value pairs.
%
% INPUTS ------------------------------------------------------------------
% varargin <Parameter, Value pairs> (optional)
%     Allows customization of plotting parameters:
%     'nRate'       - Sampling rate for plot updates (default: 1000 Hz).
%     'sSignalList' - Cell array of signal names (default: {'emg1' to 'emg16'}).
%     'sLineStyle'  - Style of the plot line (default: 'r-').
%     'nLineWidth'  - Width of the plot line (default: 0.5).
%     'nYlim'       - Y-axis limits for the plots (default: [-0.2e-3, 0.2e-3]).
%
% OUTPUT ------------------------------------------------------------------
% timerObj <timer object> 
%     A timer object that updates the EMG plots at a fixed rate. The timer can be 
%     stopped and deleted via a GUI button.
%
% EXAMPLE -----------------------------------------------------------------
% % Start plotting with default settings:
% timerObj = plot_emg();
%
% % Start plotting with customized settings:
% timerObj = plot_emg('nRate', 2000, 'sLineStyle', 'b--');
%
% SEE ALSO: 
% timer           - Timer object for scheduling execution of MATLAB commands.
% plot            - Basic plotting function.
% subplot         - Create axes in tiled positions.
%
% AUTHOR ------------------------------------------------------------------
% S.Bahdasariants, NEL, WVU, https://github.com/SerhiiBahdas
% S.Yakovenko, NEL, WVU, https://github.com/neurowired

% Assign PROPERTIES
in.nRate        = 60;
in.sSignalList  = {'control signal'};
in.sLineStyle   = 'r-';
in.nLineWidth   = .5;

if ~isempty(varargin)
   for i = 1:numel(varargin)/2
      in.(varargin{(i-1)*2+1}) = varargin{i*2};
   end
end

in.nYlim        = [0,1]; 

timerObj               = timer;
timerObj.Period        = round(1/in.nRate,3); % 5 ms interval
timerObj.ExecutionMode = 'fixedRate'; % execute at fixed rate
timerObj.BusyMode      = "drop";
timerObj.TimerFcn      = @update_plot; % callback function

% PLOT GUI
nData           = offlinetest.box_control_signal([],'nSampleOut',1);
nSignal         = numel(nData);

% Create graphical objects ------------------------------------------------
hFigure = figure;
uicontrol('Parent'  , hFigure, ... % Specify the parent as the figure handle
    'Style'         , 'pushbutton', ... % Specify the style as push button
    'Position'      , [0 0 100 20], ... % Specify the position and size in pixels
    'String'        , 'Stop', ... % Specify the text on the button
    'Callback'      , @(src, evt)delete_timer(timerObj)); % Specify the callback function
hPlot = zeros(nSignal,1);
for i = 1:nSignal
    subplot(nSignal,1,i)
    hPlot(i) = plot(zeros(350,1),...
        in.sLineStyle,'LineWidth',in.nLineWidth);
    ylim(in.nYlim(i,:))
    % Add axes information
    if i~=nSignal
        hAxes       = gca;
        hAxes.XTick = [];
    end
    ylabel(in.sSignalList{i})
end
% ------------------------------------------------ Create graphical objects

start(timerObj);

    function delete_timer (timerObj)
        stop (timerObj);% Stop the timer
        delete (timerObj);% Delete the timer
    end

    function update_plot(~, ~)
        try
            nData   = offlinetest.box_control_signal([],'nSampleOut',1);
            if ~isempty(nData)
                nSignal     = numel(nData);
                for iSignal = 1:nSignal
                    ydata   = get(hPlot(iSignal),'YData');
                    set(hPlot(iSignal),'YData',[ydata(2:end) nData(iSignal)])
                end
            end
        catch 
            disp('ERROR: in plot_ma.update_plot()')
        end
    end

end
