function signal = recSignal(Bhapi, MpSys, t, unit, slideWinPct)
arguments
    Bhapi(1,1) struct;
    MpSys(1,1) struct;
    t(1,1) {mustBeInteger, mustBePositive} = 30;
    unit char {mustBeMember(unit, {'minutes', 'seconds'})} = 'seconds';
    slideWinPct(1,1) {mustBeInRange(slideWinPct, 0, 1)} = 0.05;
end
% RECSIGNAL Records a signal for a specific duration.
%   signal = RECSIGNAL(Bhapi, MpSys) records a signal (e.g., ECG) for 30
%   seconds, using a sliding window whose size is 5% of the sampling
%   frequency.
%
%   signal = RECSIGNAL(Bhapi, MpSys, 5, 'minutes', 0.20) records a signal
%   (e.g., ECG) for 5 minutes, using a sliding window whose size is 20% of
%   the sampling frequency.
%
%   See also OPENAPI, CLOSEAPI.
%
%
%
% === DESCRIPTION =========================================================
% This function is used to record a signal. For example, it can be used to
% record a baseline ECG. Use openApi() and closeApi() respectively before
% and after calling recSignal().
%
% INPUT
% - Bhapi        API settings.
% - MpSys        DAQ settings.
% - t            Time to record for. The default is 30.
% - unit         Unit of time. The default is 'seconds'.
% - slideWinPct  The size of the sliding window, expressed as a percentage
%                of the sampling frequency. If MpSys.fs is 100 Hz and
%                slideWinPct is set to 0.05, then the signal will be
%                acquired in chunks of 5 data-points.
% OUTPUT
% - signal       Numeric vector with the recorded signal.
%
% ----------
% Author : Valerio Villani
% E-mail : valerio.cn2@gmail.com
% Created: 2023-04-27, using MATLAB 9.10.0.1669831 (R2021a) Update 2
% =========================================================================

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
        
        dpOffset = dpOffset + sws;
        dpToStore = dpToStore - sws;
        fprintf('Progress: %.2f%%\n', 100-((dpToStore/(MpSys.fs*recSecs))*100));
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

end