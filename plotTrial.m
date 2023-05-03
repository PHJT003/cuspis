function plotTrial(D, signal, MpSys, plotTitle)
arguments
    D(1,1) struct;
    signal(1,:) {mustBeNumeric};
    MpSys(1,1) struct;
    plotTitle {mustBeText} = 'Trial';
end
%% DESCRIPTION

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
    txt = {strcat('SOA', 32, num2str(i), ':'), ...         % soa
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