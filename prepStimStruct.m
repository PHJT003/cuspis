function Stim = prepStimStruct(stimPath, windowPtr, durSecs, soaSecs, nPres)
arguments
    stimPath(1,:) {mustBeText, mustBeFile};
    windowPtr(1,1) {mustBeNumeric, mustBeGreaterThanOrEqual(windowPtr, 0)};
    durSecs(1,1) {mustBeNumeric, mustBeGreaterThanOrEqual(durSecs, 1e-3)} = 0.200;
    soaSecs(1,1) {mustBeNumeric, mustBeGreaterThanOrEqual(soaSecs, 0)} = 0.0;
    nPres(1,1) {mustBeInteger, mustBePositive} = 1;
end

%% DESCRIPTION

%% SET PARAMETERS
Stim.loc = stimPath;
Stim.windowPtr = windowPtr;
Stim.dur = durSecs;
Stim.soa = soaSecs;
Stim.nPres = nPres;

end