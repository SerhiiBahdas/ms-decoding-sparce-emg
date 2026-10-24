function demeanedChunk = demean(chunk, metaNoise, idSubject, sSignalList)
    % Subtract the centroid.
    %
    % INPUT:
    % chunk - The current chunk of signal values (m x n matrix), where m is the number of signals and n is the number of samples.
    % metaNoise - A structure containing noise filtering parameters for each subject and signal.
    % idSubject - The identifier for the subject.
    % sSignalList - A list of signal names corresponding to the rows of chunk.
    %
    % OUTPUT:
    % demeanedChunk - The denoised chunk after applying noise filtering.

    % Iterate over each signal (row) in the chunk
    for m = 1:size(chunk, 1)

        % Retrieve noise filtering parameters for the current signal
        fitlparams = metaNoise.metaNoise.("S" + idSubject).(sSignalList{m});
        
        % Subtract the centroid from the signal
        chunk(m, :) = abs(chunk(m, :) - fitlparams.centroid);
        
    end
    
    % Return the denoised chunk
    demeanedChunk = chunk;
end
