clc
clear
close all

disp("=== TEST: BASEBAND MIXER ===")

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

N = length(baseband);
f = (-N/2:N/2-1)*(Fs/N);

X = abs(fftshift(fft(baseband)));
X = X/max(X);

figure
plot(f/1000,X)
xlim([0 40])
title("Baseband Mixer Output")
xlabel("Frequency (kHz)")
ylabel("Normalized Magnitude")
grid on