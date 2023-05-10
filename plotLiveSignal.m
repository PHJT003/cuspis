function [signal, hr] = plotLiveSignal(Bhapi, MpSys, isEcg, t, unit, slideWinPct)
arguments
    Bhapi(1,1) struct;
    MpSys(1,1) struct;
    isEcg {mustBeNumericOrLogical} = true;
    t(1,1) {mustBeInteger, mustBePositive} = 12;
    unit char {mustBeMember(unit, {'minutes', 'seconds'})} = 'seconds';
    slideWinPct(1,1) {mustBeInRange(slideWinPct, 0, 1)} = 0.05;
end
% PLOTLIVESIGNAL Records and plots the signal in real-time.
%   [signal, hr] = PLOTLIVESIGNAL(Bhapi, MpSys) records an ECG for 12
%   seconds, using a sliding window whose size is 5% of the sampling
%   frequency. The heart rate is estimated too.
%
%   signal = PLOTLIVESIGNAL(Bhapi, MpSys, 0, 5, 'minutes', 0.20) records a
%   signal for 5 minutes, using a sliding window whose size is 20% of the
%   sampling frequency.
%
%   See also RECSIGNAL, GETECGTHRESH.
%
%
%
% === DESCRIPTION =========================================================
% This function is used to record and plot a signal in real-time.
% If the signal is an ECG, you can estimate the heart rate by setting:
% isEcg = true, t = 12, and unit = 'seconds'. The heart rate is estimated
% with the getEcgThresh() function (default argument values).
%
% INPUT
% - Bhapi        API settings.
% - MpSys        DAQ settings.
% - isEcg        If the signal is an ECG.
% - t            Time to record for. The default is 12.
% - unit         Unit of time. The default is 'seconds'.
% - slideWinPct  The size of the sliding window, expressed as a percentage
%                of the sampling frequency. If MpSys.fs is 100 Hz and
%                slideWinPct is set to 0.05, then the signal will be
%                acquired in chunks of 5 data-points.
% OUTPUT
% - signal       Numeric vector with the recorded signal.
% - hr           Numeric value expressing the heart rate in BPM.
%
% ----------
% Author : Valerio Villani
% E-mail : valerio.cn2@gmail.com
% Created: 2023-04-28, using MATLAB 9.10.0.1669831 (R2021a) Update 2
% =========================================================================
% Portions Copyright 2004-2009 BIOPAC Systems, Inc.

%% SET PARAMETERS
if strcmp(unit, 'seconds')
    k = 1;
else
    k = 60;
end

recSecs = t*k;                  % recording time
dpToStore = MpSys.fs*recSecs;   % data-points to record
dpStored = 0;
sws = MpSys.fs*slideWinPct;     % sliding window size (data-points)
dpBuffer = zeros(1, sws);       % temporary buffer
dpOffset = 1;                   % pointer

%% START DAEMON
fprintf('Start acquisition daemon...\n');
MpSys.status = calllib(Bhapi.lib, 'startMPAcqDaemon');
if ~strcmp(MpSys.status,'MPSUCCESS')
    fprintf('FAILED to start acquisition daemon!\n');
    calllib(Bhapi.lib, 'disconnectMPDev');
    return
end

%% START RECORDING
fprintf('Start data acquisition...\n\n');
MpSys.status = calllib(Bhapi.lib, 'startAcquisition');
if ~strcmp(MpSys.status,'MPSUCCESS')
    fprintf('FAILED to start data acquisition!\n');
    calllib(Bhapi.lib, 'disconnectMPDev');
    return
end

signal = nan(1, dpToStore);
while(dpToStore > 0)
    % record signal
    [MpSys.status, dpBuffer, dpStored] = calllib(Bhapi.lib, 'receiveMPData', dpBuffer, sws, dpStored);
    if ~strcmp(MpSys.status,'MPSUCCESS')
        fprintf('FAILED to receive MP data!\n');
        calllib(Bhapi.lib, 'disconnectMPDev');
        return
    else
        % save signal
        signal(dpOffset:dpOffset+dpStored-1) = dpBuffer(1:dpStored);
        
        % plot signal in real-time
        len = length(~isnan(signal));
        y = signal(1:len);
        x(1:len) = (1:len);
        pause(1e-3);
        figure(201);
        plot(x(1:length(y)), y);
        
        dpOffset = dpOffset + sws;
        dpToStore = dpToStore - sws;
    end
end

%% STOP RECORDING
fprintf('\nStop acquisition...\n');
MpSys.status = calllib(Bhapi.lib, 'stopAcquisition');
if ~strcmp(MpSys.status,'MPSUCCESS')
    fprintf('FAILED to stop acquisition!\n');
    calllib(Bhapi.lib, 'disconnectMPDev');
    return
end

%% ESTIMATE HR
if isEcg && t == 12
    [~, pks, ~] = getEcgThresh(signal, MpSys, 0.6, 97, 0);
    hr = length(pks)*5;
elseif isEcg && t~= 12
    hr = NaN;
    msg = sprintf("\nThe HR was not estimated.\nTo estimate it, set the arguments t = 12 and unit = 'seconds'.");
    warning(msg);
end

end