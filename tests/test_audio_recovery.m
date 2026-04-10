
disp("=== TEST: AUDIO RECOVERY ===")

%% Load configuration
config = system_config();

%% Load signals
signals = load_signals();

original_messages = signals.messages;
Fs_original       = signals.Fs;

num_stations = length(original_messages);

disp("Number of stations loaded:")
disp(num_stations)

%% Interpolate signals
signals = interpolate_signal(signals, config.L);

messages = signals.messages;
Fs       = signals.Fs;

%% Build multiplexed FDM signal
fdm = build_fdm_signal(messages,Fs);

colors = lines(num_stations);

%% Loop through stations
for k = 1:num_stations

    disp(["Recovering audio for station ", num2str(k)])

    original_signal = original_messages{k};

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
    recovered_audio = baseband_lpf(baseband,Fs);

    % Normalize recovered audio
    recovered_audio = recovered_audio / max(abs(recovered_audio));

    %% Downsample audio using project decimation module

    temp.signal = recovered_audio;
    temp.Fs     = Fs;

    signals_out = decimate_signal(temp,config.L);

    audio_play = signals_out.signal;
    Fs_audio   = signals_out.Fs;

    %% Play recovered audio
    disp("Playing recovered audio...")
    sound(audio_play, Fs_audio)

    pause(length(audio_play)/Fs_audio)

    %% Visual comparison
    figure

    subplot(2,1,1)
    plot(original_signal,'Color',colors(k,:))
    title(sprintf("Original Audio Signal - Station %d",k))

    subplot(2,1,2)
    plot(recovered_audio,'Color',colors(k,:))
    title(sprintf("Recovered Audio Signal - Station %d",k))
    % saveas(gcf,"../results/test_audio_recovery/station_"+k+"_comparison.png")

end