function filteredChunk = movemean_rt(chunk, nWindow)
    % movmean_causal_rt applies a real-time causal moving average filter to chunks of signal data (m x n matrix)
    %
    % INPUT:
    %   chunk      - Current chunk of signal values (m x n matrix).
    %   nWindow    - Window size for the moving average (integer scalar).
    %
    % OUTPUT:
    %   filteredChunk - Filtered chunk after applying the moving average (m x n matrix).
    
    % Declare persistent buffer
    persistent buffer;
    
    % Get dimensions of the chunk
    [m, n] = size(chunk);
    
    % Initialize buffer on first call
    if isempty(buffer)
        buffer = zeros(m, nWindow - 1); % Initialize buffer with zeros for initial padding
    end
    
    % Append current chunk to buffer
    extendedChunk = [buffer, chunk]; % m x (nWindow -1 + n)
    
    % Compute moving average using convolution
    kernel        = ones(1, nWindow) / nWindow;
    filtered_full = conv2(extendedChunk, kernel, 'valid'); % m x n
    
    % Extract the filtered chunk
    filteredChunk = filtered_full; % m x n
    
    % Update buffer to hold the last (nWindow -1) samples from the current chunk
    buffer = extendedChunk(:, end - (nWindow -1) +1 : end); % m x (nWindow -1)
end
