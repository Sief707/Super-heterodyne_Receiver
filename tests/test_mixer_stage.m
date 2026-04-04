clc
clear
close all

disp("=== TEST: MIXER STAGE ===")

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
fdm = build_fdm_signal(messages, Fs);

disp("FDM signal generated")

%% Safe FFT window
analysis_length = min(200000, length(fdm));
fdm_segment = fdm(1:analysis_length);

colors = lines(num_stations);

%% Loop through stations
for k = 1:num_stations

    disp(["Testing mixer stage for station ", num2str(k)])

    % Carrier frequency
    Fc = config.Fc0 + (k-1)*config.deltaF;

    % RF filter (select station)
    rf = rf_stage_filter(fdm_segment, Fs, Fc);

    % Local oscillator
    f_LO = Fc + config.IF;

    % Mixer stage
    if_signal = mixer_stage(rf, Fs, f_LO);

    %% FFT
    N = length(if_signal);
    f = (-N/2:N/2-1)*(Fs/N);

    X = fftshift(fft(if_signal));
    X = abs(X)/max(abs(X));

    %% Plot
    figure
    plot(f/1000, X, 'Color', colors(k,:), 'LineWidth',1.5)

    title(sprintf("Mixer Output Spectrum - Station %d",k))
    xlabel("Frequency (kHz)")
    ylabel("Normalized Magnitude")

    grid on
    xlim([-500 500])

end