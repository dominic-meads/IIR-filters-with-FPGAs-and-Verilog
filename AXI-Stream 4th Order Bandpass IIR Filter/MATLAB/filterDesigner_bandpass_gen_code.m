function Hd = filterDesigner_bandpass_gen_code
%FILTERDESIGNER_BANDPASS_GEN_CODE Returns a discrete-time filter object.

% MATLAB Code
% Generated by MATLAB(R) 23.2 and DSP System Toolbox 23.2.
% Generated on: 20-Nov-2024 15:09:05

% Butterworth Bandpass filter designed using FDESIGN.BANDPASS.

% All frequency values are in Hz.
Fs = 500;  % Sampling Frequency

N   = 8;   % Order
Fc1 = 5;   % First Cutoff Frequency
Fc2 = 15;  % Second Cutoff Frequency

% Construct an FDESIGN object and call its BUTTER method.
h  = fdesign.bandpass('N,F3dB1,F3dB2', N, Fc1, Fc2, Fs);
Hd = design(h, 'butter', 'FilterStructure', 'df1sos');

% [EOF]