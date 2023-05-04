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

commandwindow();

Screen('Preference', 'SkipSyncTests', 1);
PsychDefaultSetup(2);

screenNo = max(Screen('Screens'));
[windowPtr, windowRect] = Screen('OpenWindow', screenNo, [150 150 150]);

Screen('BlendFunction', windowPtr, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

%% PREPARE STIMULUS

Stim = prepStim(fullfile(pwd(), 'circle.jpg'), windowPtr, 0.100, 0.300, nPres);

%% TRIGGER TRIAL
[D, signal] = triggerTrial(Stim, thresh, 6, Bhapi, MpSys, 0.05);

%% 
WaitSecs(2);
ShowCursor();
sca;

end