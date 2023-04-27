function thresh = getEcgThresh(ecg, MpSys, pctRWave, hr, secsToPlot)
arguments
    ecg(1,:) {mustBeVector, mustBeNumeric};
    MpSys(1,1) struct;
    pctRWave(1,1) {mustBeInRange(pctRWave, 0, 1)} = 0.6;
    hr(1,1) {mustBeInteger, mustBePositive} = 68; % doi.org/10/b6kkjh
    secsToPlot(1,1) {mustBeInteger, mustBePositive, mustBeGreaterThanOrEqual(secsToPlot, 1)} = 5;
end
%% DESCRIPTION

%% DETERMINE THRESHOLD
ibi = floor(60/hr*MpSys.fs);
minAmp = quantile(ecg, 3/4);

[pks, locs] = findpeaks(ecg, 'MinPeakProminence', minAmp, 'MinPeakDistance', ibi);
if isempty(pks)
   error('No R-waves were detected with the current parameters.') ;
end
thresh = mean(pks)*pctRWave;

%% PLOT RESULTS
x = 1:length(ecg);
y = ecg;
txt = sprintf('Threshold = %.2f', thresh);
nDp = MpSys.fs*secsToPlot;
dpIdx = randsample(max(x)-nDp, 1);
epoch = dpIdx:dpIdx+nDp-1;

figure(1);
plot(x, y, x(locs), pks, 'o');
yline(thresh,'r-', txt, 'LineWidth', 1);
title('Detected R-Waves');
                                      
figure(2)
plot(x(epoch), y(epoch));
yline(thresh,'r-',txt, 'LineWidth', 1);
title('ECG - Random epoch');
subtitle(strcat('(', num2str(secsToPlot), ' seconds)'));

end