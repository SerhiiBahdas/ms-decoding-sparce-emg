% compute_average_phase_duration Computes average phase durations for each trial type.
%
%   phase_duration = compute_average_phase_duration(relative_phase_duration)
%
%   INPUT =================================================================
%
%   relative_phase_duration (struct)
%   Structure with fields for each trial type. Each field contains a matrix 
%   where rows correspond to trials and columns represent the relative 
%   durations of Phase 1, Phase 2, and Phase 3.
%
%   OUTPUT ================================================================
%
%   phase_duration (struct)
%   Structure with fields for each trial type. Each field contains a vector 
%   representing the averaged phase durations across trials for Phase 1, 
%   Phase 2, and Phase 3.
%
%   AUTHOR ================================================================
%   
%   S.Bahdasariants, NEL, WVU, sb0220@mix.wvu.edu
%
%   See also COMPUTE_RELATIVE_PHASE_DURATION
%
%   =======================================================================
function phase_duration = compute_average_phase_duration(relative_phase_duration)

    % Initialize the output structure
    phase_duration = struct();

    % Get the trial types from the input structure
    sTrialTypeList = fieldnames(relative_phase_duration);

    % Loop through each trial type
    for iTrialType = 1:length(sTrialTypeList)
        sTrialType = sTrialTypeList{iTrialType};

        % Retrieve the relative phase durations for the current trial type
        nDurations = relative_phase_duration.(sTrialType);

        % Compute the average phase durations across trials
        phase_duration.(sTrialType) = mean(nDurations, 1);
    end

end
