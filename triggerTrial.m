function [D, signal] = triggerTrial(Stim, thresh, trialSecs, Bhapi, MpSys, slideWinPct)
arguments
    Stim(1,1) struct;
    thresh(1,1) {mustBeNumeric};
    trialSecs(1,1) {mustBeNumeric, mustBePositive};
    Bhapi(1,1) struct;
    MpSys(1,1) struct;
    slideWinPct(1,1) {mustBeInRange(slideWinPct, 0, 1)} = 0.05;
end
% TRIGGERTRIAL Triggers the stimulus presentation with Psychtoolbox.
%   [D, signal] = TRIGGERTRIAL(Stim, 0.7, 6, Bhapi, MpSys, 0.05) triggers
%   Stim when the signal exceeds a threshold of 0.7 in a 6-second
%   time-window. The signal is recorded using the settings of Bhapi and 
%   MpSys, as well as a sliding window whose size is 5% of the sampling 
%   frequency. The trial data and signal are returned.
%
%   See also PREPSTIM, GETECGTHRESH, RECSIGNAL.
%
%
%
% === DESCRIPTION =========================================================
% This function simultaneously:
% (1) records a signal;
% (2) detects one or more peaks in the signal, once a threshold is
%     exceeded;
% (3) presents a stimulus contingent to the detected peak(s) with
%     Psychtoolbox.
% N.B.: When "flashing" the stimulus more than once, make sure to record
% enough signal: set an appropriate value for trialSecs.
%
% INPUT
% - Stim         Stimulus settings.
% - thresh       Threshold used for stimulus presentation.
% - trialSecs    The trial duration, in seconds. This also corresponds to
%                the duration of the recorded signal.
% - Bhapi        API settings.
% - MpSys        DAQ settings.
% - slideWinPct  The size of the sliding window, expressed as a percentage
%                of the sampling frequency. If MpSys.fs is 100 Hz and
%                slideWinPct is set to 0.05, then the signal will be
%                acquired in chunks of 5 data-points.
% OUTPUT
% - D            Structure array with the trial's data.
% - signal       Numeric vector with the recorded signal.
%
% ----------
% Author : Valerio Villani
% E-mail : valerio.cn2@gmail.com
% Created: 2023-05-03, using MATLAB 9.10.0.1669831 (R2021a) Update 2
% =========================================================================

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
peakOnset = nan(1, Stim.nPres);
nPres = 1;
signalOnset = GetSecs(); % trial starts
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
        
        hasPeaked = nPres > Stim.nPres;      % all peaks have been detected
        isAboveThresh = sum(dpBuffer>thresh) > floor(2/3*length(dpBuffer));
        isRising = sum(diff(dpBuffer)>=0) > floor(1/4*length(dpBuffer));
        if  ~hasPeaked && isAboveThresh && isRising
            peakOnset(nPres) = GetSecs();
            Screen('DrawTexture', Stim.windowPtr, imgTexture);
            [~, imgOnset(nPres)] = Screen('Flip', Stim.windowPtr, ...
                peakOnset(nPres)+Stim.soa);              % present stimulus
            [~, imgOffset(nPres)] = Screen('Flip', Stim.windowPtr, ...
                imgOnset(nPres)+Stim.dur);
            
            Screen('DrawLines', Stim.windowPtr, Cross.obj, ...
                Cross.lwd, Cross.col, Cross.xyPos, 2);   % present fixation
            Screen('Flip', Stim.windowPtr);              % cross
            
%             fprintf("Peak detected at sample:\t %d\n\n", sum(~isnan(signal)));
            nPres = nPres + 1;
        end
        
        dpOffset = dpOffset + sws;
        dpToStore = dpToStore - sws;
    end
end
signalOffset = GetSecs(); % trial ends
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
% if Stim.nPres > 1, then peakOnset, imgOnset, and imgOffset are vectors of
% length equals to Stim.nPres.
D.trialOnset = signalOnset;    % timestamps
D.trialOffset = signalOffset;
D.peakOnset = peakOnset;
D.stimOnset = imgOnset;
D.stimOffset = imgOffset;
D.soa = Stim.soa;              % parameters used to trigger the stimulus
D.thresh = thresh;             % presentation

end