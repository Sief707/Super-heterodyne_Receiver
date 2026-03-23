clc
clear
close all

disp("=== TEST: RF STAGE ===")

% Load signal
signals = load_signals;

% Interpolate
signals = interpolate_signal(signals,60);

message = signals.signal;
Fs      = signals.Fs;

% Build two-station FDM
messages = {message , message};
fdm = build_fdm_signal(messages, Fs);

% Apply RF filter (select 100 kHz station)
rf_signal = rf_stage_filter(fdm, Fs, 100e3);

% Spectrum analysis
N = length(rf_signal);
f = (-N/2:N/2-1)*(Fs/N);

X = abs(fftshift(fft(rf_signal)));
X = X / max(X);

figure
plot(f/1000, X)

title("RF Stage Output")
xlabel("Frequency (kHz)")
ylabel("Normalized Magnitude")
grid on

xlim([80 150])