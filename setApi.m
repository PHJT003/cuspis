function Bhapi = setApi(installDir)
arguments
    installDir(1,:) char {mustBeNonzeroLengthText, mustBeFolder} = fullfile( ...
        'C:', 'Program Files (x86)', 'BIOPAC Systems, Inc', ...
        'BIOPAC Hardware API 2.2 Research');
end
%% DESCRIPTION

%% SET PARAMETERS
Bhapi.tmp = [];
Bhapi.lib = 'mpdev';
Bhapi.doth = fullfile(installDir, 'mpdev.h');

is64 = strcmp(cell2mat(regexp(computer('arch'), '\d+', 'match')), '64');
if is64
    Bhapi.dll = fullfile(installDir, 'x64', 'mpdev.dll');    % 64-bit system
else
    Bhapi.dll = fullfile(installDir, 'Win32', 'mpdev.dll');  % 32-bit system
end

end