close all
clear
clc

%% Generate test stimulus samples
% generate 1000 samples coming from a 16-bit unipolar (positive) ADC with a
% sampling frequency of 10 MHz

fs = 10e+06; % sampling frequency is clock frequency 
Ts = 1/fs;   
n = 0:999;   % 1000 samples
t = n*Ts;
x = 1.65 + 1*sin(2*pi*50000*t) + 0.1*sin(2*pi*2000000*t);  

figure('Color',[1 1 1]);
h = plot(t,x);
title('x(t) Sampled at fs = 10 MHz');
ylabel('Signal');
xlabel('Time (s)');

Vref = 3.3;                      % simulated ADC reference voltage
bits = 16;                       % precision of ADC
xq = (x./Vref)*((2^(bits-1))-1); % quantize
xq_int = cast(xq,"int16");       % cast to integer data type

fid = fopen('simple_IIR_biquad_test_stimulus.txt','w');
fprintf(fid,"%d\n",xq_int);
fclose(fid);

%% generate filter coefficents
% LP elliptical filter cutoff @ 60 kHz 
% should elimate 200 kHz noise and pass 50 kHz component

fc = 60e+3;
Wc = fc/(fs/2);
[B,A] = ellip(2,0.5,40,Wc);

figure('Color',[1 1 1]);
freqz(B,A,2^10,fs);
figure('Color',[1 1 1]);
zplane(B,A);

%% Show the SOS matrix and gain

[sos,g] = tf2sos(B,A)

%% multiply coefficients to get fixed point
% 16-bit signed multiplier width, need one bit for sign, one bit for the
% "ones" place, which leaves 14 bits for the fractional part. 

scale_factor = 14;

Afixed = fix(A*(2^scale_factor))
Bfixed = fix(B*(2^scale_factor))

%% check stability of fixed point coefficients

figure('Color',[1 1 1]);
zplane(Bfixed, Afixed);
hold on;
title("Pole-Zero Plot After Fixed Point Conversion");
