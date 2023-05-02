function Img = prepImgStruct(imagePath, soaSecs, durSecs, windowPtr)
arguments
    imagePath(1,:) {mustBeText, mustBeFile};
    soaSecs(1,1) {mustBeNumeric, mustBeGreaterThanOrEqual(soaSecs, 0)} = 0.0;
    durSecs(1,1) {mustBeNumeric, mustBeGreaterThanOrEqual(durSecs, 1e-3)} = 0.200;
    windowPtr(1,1) {mustBeNumeric, mustBeGreaterThanOrEqual(windowPtr, 0)} = max(Screen('Screens'));
end

%% DESCRIPTION

%% SET PARAMETERS
Img.loc = imagePath;
Img.soa = soaSecs;
Img.dur = durSecs;
Img.windowPtr = windowPtr;

end