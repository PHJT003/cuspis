function plotTrial(D, signal, MpSys, plotTitle)
arguments
    D(1,1) struct;
    signal(1,:) {mustBeNumeric};
    MpSys(1,1) struct;
    plotTitle {mustBeText} = 'Trial';
end
%  PLOTTRIAL Plots the trial and the events for visual inspection.
%   [D, signal] = PLOTTRIAL(D, signal, MpSys) plots the trial's signal and 
%   marks the onsets of events (i.e., peaks and stimuli). The threshold 
%   is displayed too.
%
%   See also TRIGGERTRIAL.
%
%
%
% === DESCRIPTION =========================================================
% This function is used to visualise the signal and the events of one
% trial. For example, it can be used for quality-checking the cardiac cycle
% phase manipulation.
%
% INPUT
% - D           The trial's data.
% - signal      The trial's signal.
% - MpSys       DAQ settings.
% - plotTitle   The title of the generated plot. The default is 'Trial'.
% OUTPUT
% Figure.
%
% ----------
% Author : Valerio Villani
% E-mail : valerio.cn2@gmail.com
% Created: 2023-05-03, using MATLAB 9.10.0.1669831 (R2021a) Update 2
% =========================================================================

%% PREPARE VARIABLES FOR PLOTTING
tsStimOn  = D.stimOnset(~isnan(D.stimOnset))   - D.trialOnset; % timestamps
tsStimOff = D.stimOffset(~isnan(D.stimOffset)) - D.trialOnset;
tsPeak    = D.peakOnset(~isnan(D.peakOnset))   - D.trialOnset;

dpStimOn  = round(MpSys.fs*tsStimOn);                          % data-points
dpStimOff = round(MpSys.fs*tsStimOff);
dpPeak    = round(MpSys.fs*tsPeak);

x = 1:length(signal);
y = signal;

%% PLOT TRIAL

figure(999);
plot(x, y, x(dpPeak), y(dpPeak), 'x', ...                  % signal
    'MarkerSize', 12, 'MarkerEdgeColor', '#FF6200');
hold on;
plot(x(dpStimOff), y(dpStimOff), 'square', ...             % stimulus offset
    'MarkerSize', 12, 'MarkerEdgeColor', '#0CAD3A');
hold off;
for i = 1:length(tsStimOn)
    txt = strcat('Peak', 32, num2str(i), 32, 'onset');     % peaks
    xline(dpPeak(i), '-', 'Label', txt, 'Color', '#FF6200', 'LineWidth', 1, ...
        'LabelVerticalAlignment', 'bottom', 'LabelHorizontalAlignment', 'center');
    txt = strcat('Stimulus', 32, num2str(i), 32, 'onset'); % stimulus onset
    xline(dpStimOn(i), '-', 'Label', txt, 'Color', '#0CAD3A', ...
        'LineWidth', 2, 'LabelVerticalAlignment', 'bottom', 'LabelHorizontalAlignment', 'center');
    txt = {strcat('SOA', 32, num2str(i), ':'), ...         % SOA
        strcat('~', num2str(tsStimOn(i)-tsPeak(i), '%.3f'), ' s')};
    text(quantile([dpPeak(i), dpStimOn(i)], 0.50), max(y)*0.7, txt, ...
        'HorizontalAlignment', 'center', 'Color', 'k');
end
txt = {'Threshold', ...                                    % threshold
    strcat('(~', num2str(D.thresh, '%.3f'), ')')};
yline(D.thresh, '--', 'Label', txt, 'Alpha', 0.5, 'Color', '#808080');

xlabel('Samples');                                         % plot labels
ylabel('Amplitude');
title(plotTitle);
subtitle(sprintf('The SOA from the peak detection was set to %.3f s.', D.soa));

end