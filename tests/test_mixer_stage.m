clc
clear
close all

disp("=== TEST: MIXER STAGE ===")

% Load signal
signals = load_signals;

% Interpolation
signals = interpolate_signal(signals,60);

message = signals.signal;
Fs      = signals.Fs;

% Build FDM
messages = {message , message};
fdm = build_fdm_signal(messages, Fs);

% RF filter (select 100 kHz)
rf = rf_stage_filter(fdm, Fs, 100e3);

% Mixer
f_LO = 115e3;
if_signal = mixer_stage(rf, Fs, f_LO);

% Spectrum analysis
N = length(if_signal);
f = (-N/2:N/2-1)*(Fs/N);

X = abs(fftshift(fft(if_signal)));
X = X / max(X);

figure
plot(f/1000, X)

title("Mixer Output Spectrum")
xlabel("Frequency (kHz)")
ylabel("Normalized Magnitude")
grid on

xlim([0 250])