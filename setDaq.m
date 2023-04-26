function MpSys = setDaq(acqCh, fs, mpType, commMethod)
arguments
    acqCh(1,1) {mustBeInteger, mustBePositive, mustBeInRange(acqCh, 1, 16)} = 1;
    fs(1,1) {mustBeInteger, mustBePositive, mustBeLessThanOrEqual(fs, 2e5)} = 1e4;
    mpType(1,1) {mustBeMember(mpType, [101, 103])} = 103;
    commMethod(1,1){mustBeInteger, mustBePositive} = 11;
end
%% DESCRIPTION

%% SET PARAMETERS
MpSys.type = mpType;
MpSys.sn = 'auto';
MpSys.comm = commMethod;
MpSys.status = [];
MpSys.ch = zeros(1, 16, 'int32');
MpSys.fs = fs;
MpSys.t  = 1/fs*1e3; % time period (ms)

MpSys.ch(acqCh) = 1; % switch on channel

end