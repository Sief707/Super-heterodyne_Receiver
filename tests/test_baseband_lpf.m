clc
clear
close all

disp("=== TEST: BASEBAND LPF ===")

signals = load_signals;
signals = interpolate_signal(signals,60);

message = signals.signal;
Fs = signals.Fs;

messages = {message,message};

fdm = build_fdm_signal(messages,Fs);

rf = rf_stage_filter(fdm,Fs,100e3);

mixed = mixer_stage(rf,Fs,115e3);

if_signal = if_stage_filter(mixed,Fs);

baseband = baseband_mixer(if_signal,Fs);

audio = baseband_lpf(baseband,Fs);

% spectrum check
N = length(audio);
f = (-N/2:N/2-1)*(Fs/N);

X = abs(fftshift(fft(audio)));
X = X/max(X);

figure
plot(f/1000,X)
xlim([0 20])
title("Recovered Audio Spectrum")
xlabel("Frequency (kHz)")
grid on