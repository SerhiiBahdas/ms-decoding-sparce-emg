function alignedBlueSignal = alignSignals(redSignal, blueSignal)
    % alignSignals Aligns the blue signal bouts to match the red signal bouts
    % while preserving the zeros in the red signal.
    %
    % INPUTS:
    %   redSignal  - A vector representing the red signal
    %   blueSignal - A vector representing the blue signal
    %
    % OUTPUT:
    %   alignedBlueSignal - A vector with blue signal aligned to the red signal

    % Check that the input signals have the same length
    if length(redSignal) ~= length(blueSignal)
        error('Red and Blue signals must have the same length.');
    end

    % Initialize the aligned blue signal
    alignedBlueSignal = zeros(size(blueSignal));
    
    % Find start and end indices of the bouts in the red signal
    redBouts = find(diff([0; redSignal > 0; 0]) ~= 0); % Bout edges
    redBoutPairs = reshape(redBouts, 2, []);  % Start and end indices for red bouts

    % Find start and end indices of the bouts in the blue signal
    blueBouts = find(diff([0; blueSignal > 0; 0]) ~= 0); % Bout edges
    blueBoutPairs = reshape(blueBouts, 2, []); % Start and end indices for blue bouts

    % Ensure the number of bouts in both signals matches
    if size(redBoutPairs, 2) ~= size(blueBoutPairs, 2)
        error('Number of bouts in red and blue signals must match.');
    end

    % Loop through each bout and align the blue signal
    for i = 1:size(redBoutPairs, 2)
        % Get the start and end indices of the current red and blue bouts
        redStart = redBoutPairs(1, i);
        redEnd = redBoutPairs(2, i);
        blueStart = blueBoutPairs(1, i);
        blueEnd = blueBoutPairs(2, i);
        
        % Extract the current bout from the blue signal
        blueSegment = blueSignal(blueStart:blueEnd);
        
        % Interpolate the blue segment to match the length of the red bout
        xBlue = linspace(0, 1, length(blueSegment));
        xRed = linspace(0, 1, redEnd - redStart + 1);
        alignedBlueSegment = interp1(xBlue, blueSegment, xRed, 'linear');
        
        % Assign the aligned blue segment to the output
        alignedBlueSignal(redStart:redEnd) = alignedBlueSegment;
    end

    % Ensure the zero regions from the red signal remain zero
    alignedBlueSignal(redSignal == 0) = 0;
end
