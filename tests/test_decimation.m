clc
clear
close all

disp("=== TEST: DECIMATION ===")

signals = load_signals;

signals = interpolate_signal(signals,60);

% run full receiver chain
message = signals.signal;
Fs = signals.Fs;

messages = {message,message};

fdm = build_fdm_signal(messages,Fs);

rf = rf_stage_filter(fdm,Fs,100e3);

mixed = mixer_stage(rf,Fs,115e3);

if_signal = if_stage_filter(mixed,Fs);

baseband = baseband_mixer(if_signal,Fs);

audio_high = baseband_lpf(baseband,Fs);

% prepare struct for decimator
temp.signal = audio_high;
temp.Fs = Fs;

signals_out = decimate_signal(temp,60);

audio = signals_out.signal;
Fs_audio = signals_out.Fs;

disp("New sampling frequency:")
disp(Fs_audio)

sound(audio, Fs_audio)