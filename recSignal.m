function signal = recSignal(Bhapi, MpSys, t, unit, slideWinPct)
arguments
    Bhapi(1,1) struct;
    MpSys(1,1) struct;
    t(1,1) {mustBeInteger, mustBePositive} = 5;
    unit char {mustBeMember(unit, ['minutes', 'seconds'])} = 'minutes';
    slideWinPct(1,1) {mustBeInRange(slideWinPct, 0, 1)} = 0.05;
end
%% DESCRIPTION

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