function Stim = prepStim(stimPath, windowPtr, durSecs, soaSecs, nPres)
arguments
    stimPath(1,:) {mustBeText, mustBeFile};
    windowPtr(1,1) {mustBeNumeric, mustBeGreaterThanOrEqual(windowPtr, 0)};
    durSecs(1,1) {mustBeNumeric, mustBeGreaterThanOrEqual(durSecs, 1e-3)} = 0.200;
    soaSecs(1,1) {mustBeNumeric, mustBeGreaterThanOrEqual(soaSecs, 0)} = 0.0;
    nPres(1,1) {mustBeInteger, mustBePositive} = 1;
end
% PREPSTIM Prepares the visual stimulus for a trial.
%   Stim = PREPSTIM('C:\stim.jpg', 10) prepares stim.jpg to be presented to
%   the onscreen window 10. The stimulus is shown once, for 0.200 seconds, 
%   as soon as a peak is detected.
%
%   Stim = PREPSTIM('C:\stim.jpg', 10, 0.100, 0.500, 3) prepares stim.jpg
%   to be presented to the onscreen window 10. The stimulus is shown 3
%   times, for 0.100 seconds, with a SOA of 0.500 seconds from the detected
%   peaks.
%
%   See also TRIGGERTRIAL.
%
%
%
% === DESCRIPTION =========================================================
% This function is used to gather all the parameters required for the
% triggerTrial() function.
%
% INPUT
% - stimPath    Full path of the stimulus.
% - windowPtr   ID of the onscreen window where the stimulus will be
%               presented. For more information, see the Psychtoolbox
%               documentation.
% - durSecs     Stimulus duration, in seconds. The default is 0.200
%               seconds.
% - soaSecs     Stimulus Onset Asynchrony (SOA) from the signal's peak, in
%               seconds. The default is 0 seconds.
% - nPres       Number of presentations in a trial, namely how many times
%               the stimulus will be "flashed" on the screen. The default
%               is 1. Set nPres > 1 to implement the cardio-visual 
%               stimulation (e.g., 10.1016/j.cortex.2021.10.004).
% OUTPUT
% - Stim        Structure array with all the settings for presenting a
%               stimulus.
%
% ----------
% Author : Valerio Villani
% E-mail : valerio.cn2@gmail.com
% Created: 2023-05-02, using MATLAB 9.10.0.1669831 (R2021a) Update 2
% =========================================================================

%% SET PARAMETERS
Stim.loc = stimPath;
Stim.windowPtr = windowPtr;
Stim.dur = durSecs;
Stim.soa = soaSecs;
Stim.nPres = nPres;

end