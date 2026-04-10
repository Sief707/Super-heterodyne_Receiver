clc
clear
close all

disp("==========================================")
disp(" SUPERHETERODYNE RECEIVER SYSTEM ")
disp("==========================================")

%% Load configuration

disp("Loading system configuration...")
config = system_config();

%% Load signals

disp("Loading audio stations...")
signals = load_signals();

%% Interpolation

disp("Interpolating signals (increase sampling rate)...")
signals = interpolate_signal(signals, config.L);

Fs = signals.Fs;
messages = signals.messages;

%% Build FDM signal

disp("Building FDM multiplexed transmitter signal...")
fdm_signal = build_fdm_signal(messages, Fs);

%% Receiver

disp("Running receiver system...")
audio = receiver_system(fdm_signal, Fs, config);

%% Normalize

disp("Normalizing recovered audio...")
audio = audio / max(abs(audio));

%% Audio sampling frequency

Fs_audio = Fs / config.L;

%% Playback

disp("Playing recovered station...")
sound(audio, Fs_audio)

%% Save audio

disp("Saving recovered audio to results folder...")
audiowrite("results/recovered_station.wav", audio, Fs_audio)

disp("==========================================")
disp(" SYSTEM EXECUTION COMPLETED ")
disp("==========================================")