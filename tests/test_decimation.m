clc
clear
close all

disp("=== TEST: DECIMATION ===")

%% Load configuration
config = system_config();

%% Load signals
signals = load_signals();

%% Interpolate signals
signals = interpolate_signal(signals, config.L);

messages = signals.messages;
Fs       = signals.Fs;

num_stations = length(messages);

disp("Number of stations loaded:")
disp(num_stations)

%% Build multiplexed FDM signal
fdm = build_fdm_signal(messages,Fs);

disp("FDM signal generated")

%% Loop through stations
for k = 1:num_stations

    disp(["Testing decimation for station ", num2str(k)])

    % Carrier frequency
    Fc = config.Fc0 + (k-1)*config.deltaF;

    % RF filter
    rf = rf_stage_filter(fdm,Fs,Fc);

    % RF → IF mixer
    f_LO = Fc + config.IF;
    mixed = mixer_stage(rf,Fs,f_LO);

    % IF filter
    if_signal = if_stage_filter(mixed,Fs);

    % IF → baseband mixer
    baseband = baseband_mixer(if_signal,Fs);

    % Baseband LPF
    audio_high = baseband_lpf(baseband,Fs);

    %% Prepare struct for decimator
    temp.signal = audio_high;
    temp.Fs     = Fs;

    signals_out = decimate_signal(temp,config.L);

    audio = signals_out.signal;
    Fs_audio = signals_out.Fs;

    disp("Recovered sampling frequency:")
    disp(Fs_audio)

    %% Play audio
    sound(audio, Fs_audio)

    pause(5)   % allow audio playback before next station

end