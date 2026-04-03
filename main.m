clc
clear
close all

disp("=== SUPERHETERODYNE RECEIVER ===")

% -------------------------------------------------
% Load configuration
% -------------------------------------------------

config = system_config();

% compute selected carrier frequency
Fc = config.Fc0 + (config.station-1)*config.deltaF;

% compute local oscillator
f_LO = Fc + config.IF;

% -------------------------------------------------
% Load signal
% -------------------------------------------------

signals = load_signals();

% -------------------------------------------------
% Interpolation
% -------------------------------------------------

signals = interpolate_signal(signals,config.L);

message = signals.signal;
Fs = signals.Fs;

% -------------------------------------------------
% Build FDM signal
% -------------------------------------------------

messages = {message , message};

fdm = build_fdm_signal(messages,Fs);

% -------------------------------------------------
% Receiver chain
% -------------------------------------------------

rf = rf_stage_filter(fdm,Fs,Fc);

mixed = mixer_stage(rf,Fs,f_LO);

if_signal = if_stage_filter(mixed,Fs);

baseband = baseband_mixer(if_signal,Fs);

audio_high = baseband_lpf(baseband,Fs);

% -------------------------------------------------
% Decimation
% -------------------------------------------------

temp.signal = audio_high;
temp.Fs = Fs;

signals_out = decimate_signal(temp,config.L);

audio = signals_out.signal;
Fs_audio = signals_out.Fs;

% -------------------------------------------------
% Normalize audio for playback
% -------------------------------------------------

audio = audio / max(abs(audio));

% -------------------------------------------------
% Playback
% -------------------------------------------------

disp("Playing recovered station...")
sound(audio,Fs_audio)
audiowrite("results/recovered_station.wav",audio,Fs_audio)