function openApi(Bhapi, MpSys)
arguments
    Bhapi(1,1) struct;
    MpSys(1,1) struct;
end
%% DESCRIPTION

%% CALL DLL
if libisloaded(Bhapi.lib) % restart
    calllib(Bhapi.lib, 'disconnectMPDev');
    unloadlibrary(Bhapi.lib);
end

loadlibrary(Bhapi.dll, Bhapi.doth); % load functions
fprintf('\nmpdev.dll loaded.\n');
libfunctions(Bhapi.lib, '-full');

%% CONNECT TO THE MP SYSTEM
fprintf('Connecting...');
[MpSys.status, MpSys.sn] = calllib(Bhapi.lib,'connectMPDev', MpSys.type, MpSys.comm, MpSys.sn);
if ~strcmp(MpSys.status, 'MPSUCCESS')
    fprintf('FAILED to connect!\n');
    calllib(Bhapi.lib, 'disconnectMPDev');
    return
end
fprintf('\nConnected.\n\n');

%% SET DAQ PARAMETERS
fprintf('Setting sampling rate to %d Hz', MpSys.fs); % sampling rate
MpSys.status = calllib(Bhapi.lib, 'setSampleRate', MpSys.t);
if ~strcmp(MpSys.status,'MPSUCCESS')
    fprintf('FAILED to set sampling rate!\n');
    calllib(Bhapi.lib, 'disconnectMPDev');
    return
end
fprintf('\nSampling rate set.\n\n');

fprintf('Setting to acquire from Channel %d', find(MpSys.ch == 1)); % acquisition channel
[MpSys.status, MpSys.ch] = calllib(Bhapi.lib, 'setAcqChannels', MpSys.ch);
if ~strcmp(MpSys.status,'MPSUCCESS')
    fprintf('FAILED to set acquisition channels!\n');
    calllib(Bhapi.lib, 'disconnectMPDev');
    return
end
fprintf('\nChannel %d set.\n\n', find(MpSys.ch == 1));

end