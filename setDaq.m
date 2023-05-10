function MpSys = setDaq(acqCh, fs, mpType, commMethod)
arguments
    acqCh(1,1) {mustBeInteger, mustBePositive, mustBeInRange(acqCh, 1, 16)} = 1;
    fs(1,1) {mustBeInteger, mustBePositive, mustBeLessThanOrEqual(fs, 2e5)} = 1e4;
    mpType(1,1) {mustBeMember(mpType, [101, 103])} = 103;
    commMethod(1,1){mustBeInteger, mustBePositive} = 11;
end
% SETDAQ Sets the data acquisition hardware.
%   MpSys = SETDAQ() sets the hardware to record a signal from Channel 1 at
%   10000 Hz, using the MP160 System and the UDP.
%
%   MpSys = SETDAQ(3, 500, 101) sets the hardware to record a signal from
%   Channel 3 at 500 Hz, using the MP150 System and the UDP.
%
%   See also SETAPI.
%
%
%
% === DESCRIPTION =========================================================
% This function sets the data acquisition (DAQ) hardware before the
% recording. This function is used along with setApi().
%
% INPUT
% - acqCh       Acquisition channel. The default is Channel 1.
% - fs          Sampling frequency in hertz. The default is 10000 Hz.
% - mpType      Type of DAQ hardware. The default is 103, which refers to
%               the BIOPAC MP160 System - see the BHAPI Manual for more
%               information.
% - commMethod  Type of communication between the DAQ hardware and the
%               computer used for the recording. The default is 11, which
%               refers to the UDP (Ethernet cable) - see the BHAPI Manual
%               for more information.
% OUTPUT
% - MpSys       Structure array with all the settings for the DAQ hardware.
%
% ----------
% Author : Valerio Villani
% E-mail : valerio.cn2@gmail.com
% Created: 2023-04-26, using MATLAB 9.10.0.1669831 (R2021a) Update 2
% =========================================================================
% Portions Copyright 2004-2009 BIOPAC Systems, Inc.

%% SET PARAMETERS
MpSys.type = mpType;
MpSys.sn = 'auto';                % serial number
MpSys.comm = commMethod;
MpSys.status = [];                % for diagnostic purposes, if errors occur
MpSys.ch = zeros(1, 16, 'int32'); % channels
MpSys.fs = fs;
MpSys.t  = 1/fs*1e3;              % time period (ms)

MpSys.ch(acqCh) = 1;              % switch on the acquisition channel

end