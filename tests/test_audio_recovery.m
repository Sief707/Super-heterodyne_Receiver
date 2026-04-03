clc
clear
close all

disp("=== TEST: AUDIO RECOVERY ===")

% -------------------------------------------------
% Load original signal
% -------------------------------------------------

signals = load_signals;

original_signal = signals.signal;
Fs = signals.Fs;

% -------------------------------------------------
% Run transmitter + receiver chain
% -------------------------------------------------

signals = interpolate_signal(signals,60);

message = signals.signal;
Fs = signals.Fs;

messages = {message , message};

fdm = build_fdm_signal(messages,Fs);

rf = rf_stage_filter(fdm,Fs,100e3);

mixed = mixer_stage(rf,Fs,115e3);

if_signal = if_stage_filter(mixed,Fs);

baseband = baseband_mixer(if_signal,Fs);

recovered_audio = baseband_lpf(baseband,Fs);

% -------------------------------------------------
% Normalize recovered audio
% -------------------------------------------------

recovered_audio = recovered_audio / max(abs(recovered_audio));

% -------------------------------------------------
% Downsample audio using project decimation module
% -------------------------------------------------

% Prepare structure input for decimator
temp.signal = recovered_audio;
temp.Fs     = Fs;

% Decimate by the interpolation factor
signals_out = decimate_signal(temp,60);

audio_play = signals_out.signal;
Fs_audio   = signals_out.Fs;

% -------------------------------------------------
% Play recovered audio
% -------------------------------------------------

disp("Playing recovered audio...")
sound(audio_play, Fs_audio)

% -------------------------------------------------
% Compare signals (visual)
% -------------------------------------------------

figure

subplot(2,1,1)
plot(original_signal)
title("Original Audio Signal")

subplot(2,1,2)
plot(recovered_audio)
title("Recovered Audio Signal")