function closeApi(Bhapi, MpSys)
arguments
    Bhapi(1,1) struct;
    MpSys(1,1) struct;
end
% CLOSEAPI Ends the application programming interface.
%   CLOSEAPI(Bhapi, MpSys) ends the BHAPI with the settings specified in
%   the Bhapi and MpSys structure arrays.
%
%   See also OPENAPI, SETAPI, SETDAQ.
%
%
%
% === DESCRIPTION =========================================================
% This function switches off the BIOPAC Hardware Application Programming
% Interface (BHAPI). Before recording, openApi() is used.
%
% INPUT
% - Bhapi       API settings.
% - MpSys       DAQ settings.
%
% ----------
% Author : Valerio Villani
% E-mail : valerio.cn2@gmail.com
% Created: 2023-04-26, using MATLAB 9.10.0.1669831 (R2021a) Update 2
% =========================================================================

%% SHUT DOWN
fprintf('\nDisconnecting...\n')
MpSys.status = calllib(Bhapi.lib, 'disconnectMPDev');
fprintf('Disconnected.\n\n');

end