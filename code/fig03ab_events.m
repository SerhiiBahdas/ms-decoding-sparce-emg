%% Fig 3a,b. Accelerometer and contact-force signals used to segment the movement sequence
% Data file: data/fig03ab_events.mat (one representative subject, 25 repetitions of the grasp task)
%   UserData(1).meanData  accelerometer, y axis of the sensor over FDS, low-pass filtered at 10 Hz,
%                         sampled at nRate_acc (148.15 Hz), in g
%   UserData(2).meanData  force-sensitive resistor on the object, % of full scale, sampled at nRate_emg (1925.9 Hz)
%   tSTARTMOV, tGRASP, tRELEASE, tENDMOV   event times (s) of each repetition
% Each repetition is cut from movement start to movement end, resampled to 1000 samples and averaged.
% Acceleration is converted from g to m/s^2 (x 9.81).

here = fileparts(mfilename('fullpath'));
S = load(fullfile(here, 'data', 'fig03ab_events.mat'));

G_TO_MS2 = 9.81;
nSamples = 1000;
acc = fillmissing(double(S.UserData(1).meanData(:)), 'linear') * G_TO_MS2;
fsr = fillmissing(double(S.UserData(2).meanData(:)), 'linear');

segAcc = cutRepetitions(acc, S.nRate_acc, S.tSTARTMOV, S.tENDMOV, nSamples);
segFsr = cutRepetitions(fsr, S.nRate_emg, S.tSTARTMOV, S.tENDMOV, nSamples);
tGrasp   = mean((S.tGRASP   - S.tSTARTMOV) ./ (S.tENDMOV - S.tSTARTMOV));   % reach ends
tRelease = mean((S.tRELEASE - S.tSTARTMOV) ./ (S.tENDMOV - S.tSTARTMOV));   % return starts
t = linspace(0, 1, nSamples);

fprintf('Fig 3a: acceleration rest %.2f, peak %.2f, trough %.2f m/s^2; reach ends at %.3f, return starts at %.3f n.u.\n', ...
    mean(segAcc(:, 1)), max(mean(segAcc, 1)), min(mean(segAcc, 1)), tGrasp, tRelease);

figure('Color', 'w', 'Name', 'Fig3ab', 'Position', [100 100 560 540]);
tiledlayout(2, 1, 'TileSpacing', 'compact');
ax = nexttile;
plotMeanSd(ax, t, segAcc, [0.29 0.55 0.94], tGrasp, tRelease);
ylabel('acceleration, m/s^2'); title('a. accelerometer (sensor over FDS)');
ax = nexttile;
plotMeanSd(ax, t, segFsr, [0 0 0], tGrasp, tRelease);
ylabel('contact force, % full scale'); xlabel('time, n.u.'); title('b. force-sensitive resistor');

function seg = cutRepetitions(x, rate, t0, t1, n)
    seg = zeros(numel(t0), n);
    for i = 1:numel(t0)
        y = x(round(t0(i) * rate):round(t1(i) * rate));
        seg(i, :) = interp1(linspace(0, 1, numel(y)), y, linspace(0, 1, n));
    end
end

function plotMeanSd(ax, t, seg, c, tG, tR)
    hold(ax, 'on');
    m = mean(seg, 1); s = std(seg, 0, 1);
    yl = [min(0, min(m - s)), max(m + s) * 1.05];
    patch(ax, [0 tG tG 0], [yl(1) yl(1) yl(2) yl(2)], [0.94 0.94 0.94], 'EdgeColor', 'none');
    patch(ax, [tR 1 1 tR], [yl(1) yl(1) yl(2) yl(2)], [0.94 0.94 0.94], 'EdgeColor', 'none');
    fill(ax, [t fliplr(t)], [m - s, fliplr(m + s)], c, 'FaceAlpha', 0.3, 'EdgeColor', 'none');
    plot(ax, t, m, 'Color', c, 'LineWidth', 2);
    text(ax, tG / 2, yl(2), 'reach', 'HorizontalAlignment', 'center', 'VerticalAlignment', 'top');
    text(ax, (tG + tR) / 2, yl(2), 'transfer', 'HorizontalAlignment', 'center', 'VerticalAlignment', 'top');
    text(ax, (tR + 1) / 2, yl(2), 'return', 'HorizontalAlignment', 'center', 'VerticalAlignment', 'top');
    xlim(ax, [0 1]); ylim(ax, yl); box(ax, 'off');
end
