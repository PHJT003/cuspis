function [thresh, pks, locs] = getEcgThresh(ecg, MpSys, pctRWave, hrMax, secsToPlot)
arguments
    ecg(1,:) {mustBeVector, mustBeNumeric};
    MpSys(1,1) struct;
    pctRWave(1,1) {mustBeInRange(pctRWave, 0, 1)} = 0.6;
    hrMax(1,1) {mustBeInteger, mustBePositive} = 97; % doi.org/10/b6kkjh
    secsToPlot(1,1) {mustBeInteger, mustBeGreaterThanOrEqual(secsToPlot, 0)} = 5;
end
% GETECGTHRESH Estimates and plots the ECG threshold for triggering a trial.
%   thresh = GETECGTHRESH(ecg, MpSys) estimates and plots the ECG threshold 
%   as 60% of the average peak amplitude. Peaks are detected with the
%   assumption that the maximum heart rate is 97 BPM. Five random seconds
%   of the ECG are plotted.
%
%   thresh = GETECGTHRESH(ecg, MpSys, 0.9, 60, 0) estimates the ECG
%   threshold as 90% of the average peak amplitude. Peaks are detected with
%   the assumption that the maximum heart rate is 60 BPM. No data are
%   plotted.
%
%   See also RECSIGNAL, FINDPEAKS.
%
%
%
% === DESCRIPTION =========================================================
% This wrapper function is used on an ECG signal to estimate the threshold
% for triggering a trial. To this aim, the findpeaks() MATLAB function is
% used: pks and locs are its output.
%
% INPUT
% - ecg          ECG signal.
% - MpSys        DAQ settings.
% - pctRWave     Percentage of the average peak amplitude to set the
%                threshold to. The default is 0.6. If the average peak
%                amplitude is 100, then the threshold is set at 60.
% - hrMax        Maximum heart rate. The default is 97 BPM. This parameter
%                is used to identify the R-waves.
% - secsToPlot   The seconds of the random epoch to plot. The default is 5.
%                If set to zero, no plots are returned.
% OUTPUT
% - thresh       Numeric value corresponding to the ECG threshold.
% - pks          See the documentation of findpeaks().
% - locs         See the documentation of findpeaks().
%
% ----------
% Author : Valerio Villani
% E-mail : valerio.cn2@gmail.com
% Created: 2023-04-27, using MATLAB 9.10.0.1669831 (R2021a) Update 2
% =========================================================================

%% DETERMINE THRESHOLD
ibi = floor(60/hrMax*MpSys.fs);
minAmp = quantile(ecg, 3/4);

[pks, locs] = findpeaks(ecg, 'MinPeakProminence', minAmp, 'MinPeakDistance', ibi);
if isempty(pks)
   error('No R-waves were detected with the current parameters.') ;
end
thresh = mean(pks)*pctRWave;

%% PLOT RESULTS
if secsToPlot > 0
    x = 1:length(ecg);
    y = ecg;
    txt = sprintf('Threshold ~ %.3f', thresh);
    nDp = MpSys.fs*secsToPlot;
    dpIdx = randsample(max(x)-nDp, 1);
    epoch = dpIdx:dpIdx+nDp-1;
    
    figure(101);
    subplot(2,1,1);
    plot(x, y, x(locs), pks, 'o');
    yline(thresh,'r-', txt, 'LineWidth', 1);
    title('Detected R-waves');
    
    subplot(2,1,2);
    plot(x(epoch), y(epoch));
    yline(thresh,'r-',txt, 'LineWidth', 1);
    title('ECG - Random epoch');
    subtitle(strcat('(', num2str(secsToPlot), ' seconds)'));
end

end