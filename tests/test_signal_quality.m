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

%% Storage for aligned signals
recovered_all = cell(num_stations,1);
original_all  = cell(num_stations,1);

%% Loop through stations
figure
sgtitle("Original vs Recovered Signals")

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

    %% Align signals using cross-correlation
    [c,lags] = xcorr(recovered, original);
    [~,idx] = max(abs(c));
    delay = lags(idx);

    if delay > 0
        recovered = recovered(delay+1:end);
    else
        original = original(-delay+1:end);
    end

    %% Force equal lengths
    min_len = min(length(original), length(recovered));
    original  = original(1:min_len);
    recovered = recovered(1:min_len);

    %% Optimal amplitude scaling (better than normalization)
    alpha = (original'*recovered)/(recovered'*recovered);
    recovered = alpha * recovered;

    %% Store aligned signals
    original_all{k}  = original;
    recovered_all{k} = recovered;

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
    subplot(num_stations,1,k)

    h1 = plot(original,'k','LineWidth',1.2);
    hold on
    h2 = plot(recovered,'r','LineWidth',1.2);

    grid on
    title(sprintf("Station %d",k))
    xlabel("Samples")
    ylabel("Amplitude")

    if k == 1
        legend([h1 h2],["Original","Recovered"])
    end

end

%% =====================================================
%% Spectrum Comparison (Original vs Recovered)
%% =====================================================

figure
sgtitle("Original vs Recovered Spectrum")

for k = 1:num_stations

    original  = original_all{k};
    recovered = recovered_all{k};

    N = length(original);

    %% FFT
    Y_orig = fftshift(abs(fft(original)));
    Y_rec  = fftshift(abs(fft(recovered)));

    %% Normalize spectra with common scale
    scale = max([Y_orig; Y_rec]);
    Y_orig = Y_orig / scale;
    Y_rec  = Y_rec / scale;

    %% Frequency axis
    f = (-N/2:N/2-1)*(Fs_audio/N);

    subplot(num_stations,1,k)

    h1 = plot(f/1000, Y_orig, 'k','LineWidth',1.2);
    hold on
    h2 = plot(f/1000, Y_rec, 'r','LineWidth',1.2);

    grid on
    title(sprintf("Station %d Spectrum",k))
    xlabel("Frequency (kHz)")
    ylabel("Normalized Magnitude")

    xlim([-10 10])

    if k == 1
        legend([h1 h2],["Original","Recovered"])
    end

end