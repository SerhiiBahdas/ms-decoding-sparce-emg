function polarPlotTwoSignals(signal1, signal2, nRate, tInterval)
    % Function to plot two signals in polar coordinates with custom time-based angle labels
    % Inputs:
    %   signal1: First signal amplitude vector
    %   signal2: Second signal amplitude vector
    %   nRate: Sampling rate (in Hz)
    %   tInterval: Time interval (in seconds) for the angle labels

    % Ensure both signals have the same length
    if length(signal1) ~= length(signal2)
        error('Both signals must have the same length');
    end

    % Compute the time vector based on the sampling rate
    nSamples = length(signal1);
    time = (0:nSamples-1) / nRate; % Time in seconds

    % Convert time to angles (radians)
    maxTime = max(time);
    theta = (2 * pi * time) / maxTime;

    % Create a polar plot for both signals
    figure;
    polarplot(theta, signal1, 'r', 'LineWidth', 1.5); % Plot first signal in red
    hold on;
    polarplot(theta, signal2, 'b', 'LineWidth', 1.5); % Plot second signal in blue

    % Set custom time labels on the polar plot
    ax = gca; % Get current axis
    numTicks = ceil(maxTime / tInterval) + 1; % Calculate the number of ticks
    tickPositions = linspace(0, 360, numTicks); % Tick positions in degrees
    tickLabels = arrayfun(@num2str, 0:tInterval:maxTime, 'UniformOutput', false); % Generate time labels

    ax.ThetaTick = tickPositions; % Apply custom tick positions
    ax.ThetaTickLabel = tickLabels; % Apply custom tick labels
    ax.RLim = [0 max(max(signal1), max(signal2))]; % Adjust radial limits
    title('Polar Plot of Two Signals');
    legend('Signal 1', 'Signal 2');
    hold off;
end
