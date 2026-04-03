clc
clear
close all

signals = load_signals;
signals = interpolate_signal(signals,60);

message = signals.signal;
Fs = signals.Fs;

messages = {message,message};

fdm = build_fdm_signal(messages,Fs);

rf = rf_stage_filter(fdm,Fs,100e3);

mixed = mixer_stage(rf,Fs,115e3);

if_signal = if_stage_filter(mixed,Fs);

N = length(if_signal);
f = (-N/2:N/2-1)*(Fs/N);

X = abs(fftshift(fft(if_signal)));
X = X/max(X);

figure
plot(f/1000,X)
xlim([0 50])
title("IF Stage Output")
xlabel("Frequency (kHz)")
grid on