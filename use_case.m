%%
clear, clc, close all;

%% STEP 0
% Turn on the MP160 System and connect it to a computer with the Ethernet
% cable. Then, get things ready for recording an ECG from Channel 1 at 10
% kHz.

Bhapi = setApi('C:\Program Files (x86)\BIOPAC Systems, Inc\BIOPAC Hardware API 2.2 Research');
MpSys = setDaq(1, 1e4, 103, 11);

openApi(Bhapi, MpSys);

%% STEP 1
% Prepare the subject's skin and attach the electrodes. For recordings in
% the MRI scanner, see BIOPAC's application note #283 (https://shorturl.at/aeqD9).
% Then, check the ECG signal with plotLiveSignal().

[~, hr] = plotLiveSignal(Bhapi, MpSys, true, 12, 'seconds', 0.05);
fprintf('The estimated HR is %.2f BPM.\n', hr);

%% STEP 2
% Record a baseline ECG with recSignal(). Then, compute a threshold with
% getEcgThresh(). The threshold can be also set (or adjusted) after the
% inspecting the signal visually or by using another peak detection
% algorithm.

close all;

ecg = recSignal(Bhapi, MpSys, 12, 'seconds', 0.5);
thresh = getEcgThresh(ecg, MpSys, 0.75, round(1.5*hr), 6);

%% STEP 3
% Prepare the stimulus with prepStim(). Then, run the task with Psychtoolbox.
% In the script for the task, embed the triggerTrial() function.
%
% For convenience, here use a short demo.
% Input 1 for the single stimulus presentation demo and 2 for the for the 
% cardio-visual stimulation demo.

close all;

demoNo = input('Input a number (1 or 2): ');
[demoData, demoEcg] = cuspisDemo(demoNo);

%% STEP 4
% At the end of the task, turn off the BHAPI and plot a trial.

closeApi(Bhapi, MpSys);
plotTrial(demoData, demoEcg, MpSys, 'Demo Trial');