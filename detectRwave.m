function [Ts, signal] = detectRwave(Bhapi, MpSys, thresh, Stim, trialSecs, slideWinPct)
arguments
    Bhapi(1,1) struct;
    MpSys(1,1) struct;
    thresh(1,1) {mustBeNumeric};
    Stim(1,1) struct;
    trialSecs(1,1) {mustBeNumeric, mustBePositive};
    slideWinPct(1,1) {mustBeInRange(slideWinPct, 0, 1)} = 0.05;
end
%% DESCRIPTION

%% DEFINE FIXATION CROSS
rect = Screen('Rect', Stim.windowPtr);

Cross.armLength = 40;
Cross.xCoords = [-Cross.armLength Cross.armLength 0 0];
Cross.yCoords = [0 0 -Cross.armLength Cross.armLength];
Cross.obj = [Cross.xCoords; Cross.yCoords];
Cross.xyPos = [rect(3)/2 rect(4)/2];
Cross.col = [0 0 0];
Cross.lwd = 4;

%% VALIDATE INPUT
if Stim.dur >= trialSecs
    error('The stimulus duration must be shorter than the trial.');
end

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

imgTexture = Screen('MakeTexture', Stim.windowPtr, imread(Stim.loc));
Screen('DrawTexture', Stim.windowPtr, imgTexture);
signal = nan(1, dpToStore);
% peakTracker = nan(size(dpBuffer)); % maybe you can delete this var
hasPeaked = false;
peakOnset = NaN;
imgOnset = NaN;
imgOffset = NaN;
signalOnset = GetSecs();
while(dpToStore > 0)
    [MpSys.status, dpBuffer, dpStored] = calllib(Bhapi.lib, 'receiveMPData', dpBuffer, sws, dpStored);
    if ~strcmp(MpSys.status,'MPSUCCESS')
        fprintf('FAILED to receive MP data!\n');
        calllib(Bhapi.lib, 'disconnectMPDev');
        return
    else
        signal(dpOffset:dpOffset+dpStored-1) = dpBuffer(1:dpStored);
        
        isAboveThresh = sum(dpBuffer>thresh) > floor(2/3*length(dpBuffer));
        isRising = sum(diff(dpBuffer)>=0) > floor(1/4*length(dpBuffer));
        if ~hasPeaked && (isAboveThresh && isRising)
            peakOnset = GetSecs();
            fprintf("Peak detected at sample:\t %d\n\n", sum(~isnan(signal)));
            hasPeaked = true;
            [~, imgOnset] = Screen('Flip', Stim.windowPtr, peakOnset+Stim.soa);
            [~, imgOffset] = Screen('Flip', Stim.windowPtr, imgOnset+Stim.dur);
            Screen('DrawLines', Stim.windowPtr, Cross.obj, ...
                Cross.lwd, Cross.col, Cross.xyPos, 2);
            Screen('Flip', Stim.windowPtr);
        end
        
        dpOffset = dpOffset + sws;
        dpToStore = dpToStore - sws;
    end
end
signalOffset = GetSecs();
Screen('Close', imgTexture);

%% STOP RECORDING
fprintf('\nStop acquisition...\n');
MpSys.status = calllib(Bhapi.lib, 'stopAcquisition');
if ~strcmp(MpSys.status,'MPSUCCESS')
    fprintf('FAILED to stop acquisition!\n');
    calllib(Bhapi.lib, 'disconnectMPDev');
    return
end
closeApi(Bhapi, MpSys);

%% NO PEAKS DETECTED
if isnan(peakOnset)
    fprintf('============================================================\n');
    fprintf('\t[!!] NO PEAKS DETECTED IN THE LAST %.2f SECONDS [!!]\t\n', trialSecs);
    fprintf('============================================================\n');
end

%% AGGREGATE TIMESTAMPS OF EVENTS
Ts.trialOnset = signalOnset;
Ts.trialOffset = signalOffset;
Ts.peakOnset = peakOnset;
Ts.stimOnset = imgOnset;
Ts.stimOffset = imgOffset;

end