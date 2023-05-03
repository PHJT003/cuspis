function [D, signal] = detectRwave(Bhapi, MpSys, thresh, Stim, trialSecs, slideWinPct)
arguments
    Bhapi(1,1) struct;
    MpSys(1,1) struct;
    thresh(1,1) {mustBeNumeric};
    Stim(1,1) struct;
    trialSecs(1,1) {mustBeNumeric, mustBePositive};
    slideWinPct(1,1) {mustBeInRange(slideWinPct, 0, 1)} = 0.05;
end
%% DESCRIPTION

%% VALIDATE INPUT
if Stim.dur >= trialSecs
    error('The stimulus duration must be shorter than the trial.');
end

%% DEFINE FIXATION CROSS
rect = Screen('Rect', Stim.windowPtr);

Cross.armLength = 40;
Cross.xCoords = [-Cross.armLength Cross.armLength 0 0];
Cross.yCoords = [0 0 -Cross.armLength Cross.armLength];
Cross.obj = [Cross.xCoords; Cross.yCoords];
Cross.xyPos = [rect(3)/2 rect(4)/2];
Cross.col = [0 0 0];
Cross.lwd = 4;

%% DEFINE STIMULUS
imgOnset = nan(1, Stim.nPres);
imgOffset = nan(1, Stim.nPres);
imgTexture = Screen('MakeTexture', Stim.windowPtr, imread(Stim.loc));

%% SET RECORDING PARAMETERS
dpStored = 0;
dpToStore = MpSys.fs*trialSecs;
sws = MpSys.fs*slideWinPct; % sliding window size
dpBuffer = zeros(1, sws);   % temporary buffer
dpOffset = 1;

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
peakOnset = nan(1, Stim.nPres);
nPres = 1;
signalOnset = GetSecs();
while(dpToStore > 0)
    [MpSys.status, dpBuffer, dpStored] = calllib(Bhapi.lib, 'receiveMPData', dpBuffer, sws, dpStored);
    if ~strcmp(MpSys.status,'MPSUCCESS')
        fprintf('FAILED to receive MP data!\n');
        calllib(Bhapi.lib, 'disconnectMPDev');
        return
    else
        signal(dpOffset:dpOffset+dpStored-1) = dpBuffer(1:dpStored);
        
        hasPeaked = nPres > Stim.nPres;
        isAboveThresh = sum(dpBuffer>thresh) > floor(2/3*length(dpBuffer));
        isRising = sum(diff(dpBuffer)>=0) > floor(1/4*length(dpBuffer));
        if  ~hasPeaked && isAboveThresh && isRising
            peakOnset(nPres) = GetSecs();
            Screen('DrawTexture', Stim.windowPtr, imgTexture);
            [~, imgOnset(nPres)] = Screen('Flip', Stim.windowPtr, peakOnset(nPres)+Stim.soa);
            [~, imgOffset(nPres)] = Screen('Flip', Stim.windowPtr, imgOnset(nPres)+Stim.dur);
            
            Screen('DrawLines', Stim.windowPtr, Cross.obj, Cross.lwd, Cross.col, Cross.xyPos, 2);
            Screen('Flip', Stim.windowPtr);
            
            fprintf("Peak detected at sample:\t %d\n\n", sum(~isnan(signal)));
            nPres = nPres + 1;
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

%% NO PEAKS DETECTED
if isnan(peakOnset)
    fprintf('============================================================\n');
    fprintf('\t[!!] NO PEAKS DETECTED IN THE LAST %.2f SECONDS [!!]\t\n', trialSecs);
    fprintf('============================================================\n');
end

%% AGGREGATE TRIAL DATA
D.trialOnset = signalOnset;    % timestamps
D.trialOffset = signalOffset;
D.peakOnset = peakOnset;
D.stimOnset = imgOnset;
D.stimOffset = imgOffset;
D.soa = Stim.soa;              % parameters used to trigger the stimulus'
D.thresh = thresh;             % presentation

end