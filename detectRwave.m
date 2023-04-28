function signal = detectRwave(Bhapi, MpSys, thresh, windowPtr, trialSecs, slideWinPct)
arguments
    Bhapi(1,1) struct;
    MpSys(1,1) struct;
    thresh(1,1) {mustBeNumeric};
    trialSecs(1,1) {mustBeNumeric, mustBePositive};
    slideWinPct(1,1) {mustBeInRange(slideWinPct, 0, 1)} = 0.05;
end
%% DESCRIPTION

%% SET PARAMETERS
dpStored = 0;
dpToStore = MpSys.fs*trialSecs;
sws = MpSys.fs*slideWinPct; % sliding window size
dpBuffer = zeros(1, sws);   % temporary buffer
dpOffset = 1;

%% START DAEMON
openApi(Bhapi, MpSys);
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
signalOnset = GetSecs();
while(dpToStore > 0)
    [MpSys.status, dpBuffer, dpStored] = calllib(Bhapi.lib, 'receiveMPData', dpBuffer, sws, dpStored);
    if ~strcmp(MpSys.status,'MPSUCCESS')
        fprintf('FAILED to receive MP data!\n');
        calllib(Bhapi.lib, 'disconnectMPDev');
        return
    else
        signal(dpOffset:dpOffset+dpStored-1) = dpBuffer(1:dpStored);
        
        isGoingUp = sum(diff(dpBuffer)>=0) > floor(1/4*length(dpBuffer));
        isAboveThresh = sum(dpBuffer>thresh) > floor(2/3*length(dpBuffer));
        if isGoingUp && isAboveThresh
            peakOnset = GetSecs();
            fprintf("Peak detected at sample:\t %d\n\n", sum(~isnan(signal)));          
        end      
        
        dpOffset = dpOffset + sws;
        dpToStore = dpToStore - sws;
    end
end
signalOffset = GetSecs();

%% STOP RECORDING
fprintf('\nStop acquisition...\n');
MpSys.status = calllib(Bhapi.lib, 'stopAcquisition');
if ~strcmp(MpSys.status,'MPSUCCESS')
    fprintf('FAILED to stop acquisition!\n');
    calllib(Bhapi.lib, 'disconnectMPDev');
    return
end
closeApi(Bhapi, MpSys);

end