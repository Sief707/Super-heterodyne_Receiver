clc
clear
close all

disp("=== TEST: SIGNAL QUALITY ===")

% -------------------------------------------------
% Load original signal
% -------------------------------------------------

signals = load_signals;

original = signals.signal;
Fs_original = signals.Fs;

% -------------------------------------------------
% Run full receiver chain
% -------------------------------------------------

signals = interpolate_signal(signals,60);

message = signals.signal;
Fs = signals.Fs;

messages = {message,message};

fdm = build_fdm_signal(messages,Fs);

rf = rf_stage_filter(fdm,Fs,100e3);

mixed = mixer_stage(rf,Fs,115e3);

if_signal = if_stage_filter(mixed,Fs);

baseband = baseband_mixer(if_signal,Fs);

audio_high = baseband_lpf(baseband,Fs);

% -------------------------------------------------
% Decimate to return to audio sampling rate
% -------------------------------------------------

temp.signal = audio_high;
temp.Fs = Fs;

signals_out = decimate_signal(temp,60);

recovered = signals_out.signal;
Fs_audio = signals_out.Fs;

% -------------------------------------------------
% Normalize signals for fair comparison
% -------------------------------------------------

original = original / max(abs(original));
recovered = recovered / max(abs(recovered));

% -------------------------------------------------
% Align signals using cross-correlation
% -------------------------------------------------

[c,lags] = xcorr(recovered, original);
[~,idx] = max(abs(c));

delay = lags(idx);

if delay > 0
    recovered = recovered(delay+1:end);
    original = original(1:length(recovered));
else
    original = original(-delay+1:end);
    recovered = recovered(1:length(original));
end


% -------------------------------------------------
% Compute SNR
% -------------------------------------------------

error_signal = original - recovered;

signal_power = sum(original.^2);
error_power  = sum(error_signal.^2);

SNR = 10*log10(signal_power/error_power);

disp("Recovered audio sampling rate:")
disp(Fs_audio)

disp("Signal-to-Noise Ratio (dB):")
disp(SNR)

% -------------------------------------------------
% Plot comparison
% -------------------------------------------------

figure

subplot(2,1,1)
plot(original)
title("Original Signal")

subplot(2,1,2)
plot(recovered)
title("Recovered Signal")