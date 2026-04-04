clc
clear
close all

disp("=== TEST: BASEBAND LPF ===")

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

%% Safe FFT window
analysis_length = min(200000, length(fdm));
fdm_segment = fdm(1:analysis_length);

colors = lines(num_stations);

%% Loop through stations
for k = 1:num_stations

    disp(["Testing baseband LPF for station ", num2str(k)])

    % Carrier frequency
    Fc = config.Fc0 + (k-1)*config.deltaF;

    % RF filter
    rf = rf_stage_filter(fdm_segment,Fs,Fc);

    % RF → IF mixer
    f_LO = Fc + config.IF;
    mixed = mixer_stage(rf,Fs,f_LO);

    % IF filter
    if_signal = if_stage_filter(mixed,Fs);

    % IF → baseband mixer
    baseband = baseband_mixer(if_signal,Fs);

    % Baseband LPF
    audio = baseband_lpf(baseband,Fs);

    %% FFT
    N = length(audio);
    f = (-N/2:N/2-1)*(Fs/N);

    X = fftshift(fft(audio));
    X = abs(X)/max(abs(X));

    %% Plot
    figure
    plot(f/1000,X,'Color',colors(k,:),'LineWidth',1.5)

    title(sprintf("Recovered Audio Spectrum - Station %d",k))
    xlabel("Frequency (kHz)")
    ylabel("Normalized Magnitude")

    grid on
    xlim([-20 20])

end