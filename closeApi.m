function closeApi(Bhapi, MpSys)
arguments
    Bhapi(1,1) struct;
    MpSys(1,1) struct;
end
%% DESCRIPTION

%% SHUT DOWN
fprintf('Disconnecting...\n')
MpSys.status = calllib(Bhapi.lib, 'disconnectMPDev');

end