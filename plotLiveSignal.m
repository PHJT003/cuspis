function [signal, hr] = plotLiveSignal(Bhapi, MpSys, isEcg, t, unit, slideWinPct)
arguments
    Bhapi(1,1) struct;
    MpSys(1,1) struct;
    isEcg {mustBeNumericOrLogical} = true;
    t(1,1) {mustBeInteger, mustBePositive} = 12;
    unit char {mustBeMember(unit, {'minutes', 'seconds'})} = 'seconds';
    slideWinPct(1,1) {mustBeInRange(slideWinPct, 0, 1)} = 0.05;
end
%% DESCRIPTION

%% SET PARAMETERS
if strcmp(unit, 'seconds')
    k = 1;
else
    k = 60;
end

recSecs = t*k;
dpStored = 0;
dpToStore = MpSys.fs*recSecs;
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
while(dpToStore > 0)
    [MpSys.status, dpBuffer, dpStored] = calllib(Bhapi.lib, 'receiveMPData', dpBuffer, sws, dpStored);
    if ~strcmp(MpSys.status,'MPSUCCESS')
        fprintf('FAILED to receive MP data!\n');
        calllib(Bhapi.lib, 'disconnectMPDev');
        return
    else
        signal(dpOffset:dpOffset+dpStored-1) = dpBuffer(1:dpStored);
        
        len = length(~isnan(signal));
        y = signal(1:len);
        x(1:len) = (1:len);
        pause(1e-3);
        figure(201);
        plot(x(1:length(y)), y);
        
        dpOffset = dpOffset + sws;
        dpToStore = dpToStore - sws;
        %         fprintf('Progress: %.2f%%\n', 100-((dpToStore/(MpSys.fs*recSecs))*100));
    end
end

%% STOP RECORDING
fprintf('\nStop acquisition...\n');
MpSys.status = calllib(Bhapi.lib, 'stopAcquisition');
if ~strcmp(MpSys.status,'MPSUCCESS')
    fprintf('FAILED to stop acquisition!\n');
    calllib(Bhapi.lib, 'disconnectMPDev');
    return
end

%% ESTIMATE HR
if isEcg && t == 12
    [~, pks, ~] = getEcgThresh(signal, MpSys, 0.6, 97, 0);
    hr = length(pks)*5;
elseif isEcg && t~= 12
    hr = NaN;
    msg = sprintf("\nThe HR was not estimated.\nTo estimate it, set the arguments t = 12 and unit = 'seconds'.");
    warning(msg);
end

end