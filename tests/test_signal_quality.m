clc
clear
close all

disp("=== TEST: SIGNAL QUALITY ===")

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

    disp(["Computing signal quality for station ", num2str(k)])

    original = original_messages{k};

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

    %% Decimate
    temp.signal = audio_high;
    temp.Fs     = Fs;

    signals_out = decimate_signal(temp,config.L);

    recovered = signals_out.signal;
    Fs_audio  = signals_out.Fs;

    %% Normalize signals
    original  = original / max(abs(original));
    recovered = recovered / max(abs(recovered));

   %% -------------------------------------------------
   %% Align signals using cross-correlation
   %% -------------------------------------------------

   [c,lags] = xcorr(recovered, original);

   [~,idx] = max(abs(c));

   delay = lags(idx);

   if delay > 0
      recovered = recovered(delay+1:end);
   else
     original = original(-delay+1:end);
   end

   % Force equal lengths safely
   min_len = min(length(original), length(recovered));

   original  = original(1:min_len);
   recovered = recovered(1:min_len);

    %% Compute SNR
    error_signal = original - recovered;

    signal_power = sum(original.^2);
    error_power  = sum(error_signal.^2);

    SNR = 10*log10(signal_power/error_power);

    disp("Recovered audio sampling rate:")
    disp(Fs_audio)

    disp("Signal-to-Noise Ratio (dB):")
    disp(SNR)

    %% Plot comparison
    figure

    subplot(2,1,1)
    plot(original,'Color',colors(k,:))
    title(sprintf("Original Signal - Station %d",k))

    subplot(2,1,2)
    plot(recovered,'Color',colors(k,:))
    title(sprintf("Recovered Signal - Station %d",k))

end