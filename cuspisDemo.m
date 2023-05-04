function [D, signal] = cuspisDemo(demoNo)
arguments
    demoNo(1,1) {mustBeInteger, mustBeMember(demoNo, [1, 2])};
end
%% 
if demoNo == 1
    nPres = 1;
else
    nPres = 3;
end

Bhapi = setApi();
MpSys = setDaq();
openApi(Bhapi, MpSys);
ecg = recSignal(Bhapi, MpSys, 6, 'seconds', 0.5);
thresh = getEcgThresh(ecg, MpSys, 0.6, 97, 0);
commandwindow();

Screen('Preference', 'SkipSyncTests', 1);
PsychDefaultSetup(2);
HideCursor();
screenNo = max(Screen('Screens'));
windowPtr = Screen('OpenWindow', screenNo, [150 150 150]);
Screen('BlendFunction', windowPtr, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

%% PREPARE STIMULUS
Stim = prepStim(fullfile(pwd(), 'circle.jpg'), windowPtr, 0.100, 0.300, nPres);

%% TRIGGER TRIAL
[D, signal] = triggerTrial(Stim, thresh, 6, Bhapi, MpSys, 0.05);

%%
closeApi(Bhapi, MpSys);
WaitSecs(0.5);
ShowCursor();
sca;

end