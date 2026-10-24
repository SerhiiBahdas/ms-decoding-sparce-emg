load(fullfile(fileparts(mfilename('fullpath')), 'data', 'task_templates.mat'))
plot_templates(TEMPLATE.template);

% plot_templates Plots signal data for each template with trial types in colors and muscles in subplots.
%
%   concatenatedData = plot_templates(template)
%
%   INPUT =================================================================
%
%   template (struct)
%       Structured array containing signal data organized by template names,
%       trial types, and muscles. The structure should follow the hierarchy:
%       template.TemplateName.TrialType.Muscle = signalData;
%
%   OUTPUT ================================================================
%
%   concatenatedData (struct)
%       A structure to store any concatenated or processed data from the
%       plotting process. This can be customized based on specific needs.
%
%   AUTHOR ================================================================
%   
%   S.Bahdasariants, NEL, WVU, sb0220@mix.wvu.edu
%
%   See also divideArrayByPercentage, normalizeSignal, interp1
%
%   =======================================================================

function concatenatedData = plot_templates(template)
    % plot_templates: Plots signal data from a structured template.
    %
    %   concatenatedData = plot_templates(template) 
    %   - template: A structured array containing signal data organized by
    %               template names, trial types, and muscles.
    %   - concatenatedData: A structure that can store or return processed data
    %                       if needed for further analysis.
    %
    % The function creates separate figures for each template name. Within each
    % figure, it creates subplots for each muscle. Different trial types are
    % plotted in distinct colors for easy differentiation.

    % Initialize output structure
    concatenatedData = struct();

    % Get all template names (e.g., TMP10, TMP20, etc.)
    templateNames = fieldnames(template);

    % Loop through each template
    for t = 1:length(templateNames)
        currentTemplateName = templateNames{t};
        currentTemplate = template.(currentTemplateName);
        
        % Get all trial types within the current template
        trialTypes = fieldnames(currentTemplate);
        numTrialTypes = length(trialTypes);
        
        % Define a set of colors for trial types using MATLAB's 'lines' colormap
        colors = lines(numTrialTypes); 
        
        % Get all muscles from the first trial type (assuming consistency across trial types)
        firstTrialType = currentTemplate.(trialTypes{1});
        muscles = fieldnames(firstTrialType);
        numMuscles = length(muscles);
        
        % Create a new figure for the current template
        figure('Name', currentTemplateName, 'NumberTitle', 'off');
        
        % Determine subplot grid size (adjust as needed)
        numCols = ceil(sqrt(numMuscles));
        numRows = ceil(numMuscles / numCols);
        
        % Loop through each muscle to create subplots
        for m = 1:numMuscles
            muscleName = muscles{m};
            
            % Create subplot
            subplot(numRows, numCols, m);
            hold on; % Hold on to plot multiple trial types on the same subplot
            
            % Loop through each trial type to plot data
            for c = 1:numTrialTypes
                trialType = trialTypes{c};
                muscleData = currentTemplate.(trialType).(muscleName);
                
                % Check if muscleData exists and is non-empty
                if isempty(muscleData)
                    warning('Empty data for Template: %s, TrialType: %s, Muscle: %s', ...
                        currentTemplateName, trialType, muscleName);
                    continue;
                end
                
                % Normalize the signal in time from 0 to 1 and interpolate to nTmpLen points
                nTmpLen = 100; % Desired number of interpolated points (modify as needed)
                nPoints = length(muscleData);
                tOriginal = linspace(0, 1, nPoints);
                tTarget = linspace(0, 1, nTmpLen);
                muscleData_normalized = interp1(tOriginal, muscleData, tTarget, 'linear');
                
                % Plot the normalized signal
                plot(tTarget, muscleData_normalized, 'Color', colors(c,:), 'LineWidth', 1.5, ...
                    'DisplayName', trialTypes{c});
            end
            
            % Enhance subplot aesthetics
            title(muscleName, 'Interpreter', 'none', 'FontWeight', 'bold');
            xlabel('Normalized Time');
            ylabel('Signal Amplitude');
            grid on;
            box on;
            ylim([0,1])
            
            % Add legend only once per subplot if multiple trial types exist
            if numTrialTypes > 1
                legend('show', 'Location', 'best');
            end
            
            hold off; % Release hold for the next subplot
        end
        
        % Optional: Adjust figure properties for better visualization
        sgtitle(['Template: ', currentTemplateName], 'FontSize', 14, 'FontWeight', 'bold');
        set(gcf, 'Color', 'w'); % Set figure background to white
        
        % Optionally, save or process concatenatedData as needed
        % Example: Concatenate all normalized signals for each muscle
        for m = 1:numMuscles
            muscleName = muscles{m};
            for c = 1:numTrialTypes
                trialType = trialTypes{c};
                muscleData = currentTemplate.(trialType).(muscleName);
                if isempty(muscleData)
                    continue;
                end
                % Normalize and interpolate
                nPoints = length(muscleData);
                tOriginal = linspace(0, 1, nPoints);
                tTarget = linspace(0, 1, nTmpLen);
                muscleData_normalized = interp1(tOriginal, muscleData, tTarget, 'linear');
                
                % Store in concatenatedData
                concatenatedData.(currentTemplateName).(muscleName).(trialType) = muscleData_normalized;
            end
        end
    end
end
