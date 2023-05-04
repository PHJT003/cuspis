function Bhapi = setApi(installDir)
arguments
    installDir(1,:) char {mustBeNonzeroLengthText, mustBeFolder} = fullfile( ...
        'C:', 'Program Files (x86)', 'BIOPAC Systems, Inc', ...
        'BIOPAC Hardware API 2.2 Research');
end
% SETAPI Sets the installation directory for the application programming
% interface.
%   Bhapi = SETAPI() sets the BHAPI directory to the default location on a 
%   64-bit Windows OS.
%
%   Bhapi = SETDAPI('C:\bhapi-folder') sets the BHAPI directory to the 
%   'bhapi-folder' location.
%
%   See also SETDAQ.
%
%
%
% === DESCRIPTION =========================================================
% This function sets the BIOPAC Hardware Application Programming Interface
% (BHAPI) before the recording. This function is used along with setDaq().
%
% INPUT
% - installDir  Installation directory. The default is:
%               'C:\Program Files (x86)\BIOPAC Systems, Inc\BIOPAC Hardware API 2.2 Research'.
% OUTPUT
% - Bhapi       Structure array with all the settings for the BHAPI.
%
% ----------
% Author : Valerio Villani
% E-mail : valerio.cn2@gmail.com
% Created: 2023-04-26, using MATLAB 9.10.0.1669831 (R2021a) Update 2
% =========================================================================

%% SET PARAMETERS
Bhapi.lib = 'mpdev';                                        % library name
Bhapi.doth = fullfile(installDir, 'mpdev.h');               % header file

is64 = strcmp(cell2mat(regexp(computer('arch'), '\d+', 'match')), '64');
if is64                                                     % DLL
    Bhapi.dll = fullfile(installDir, 'x64', 'mpdev.dll');   % 64-bit Win OS
else
    Bhapi.dll = fullfile(installDir, 'Win32', 'mpdev.dll'); % 32-bit Win OS
end

end