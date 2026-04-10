
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

colors = lines(num_stations);

%% Prepare figure
figure
colors = lines(num_stations);

%% Loop through stations
for k = 1:num_stations

    disp(["Testing mixer stage for station ", num2str(k)])

    % Carrier frequency
    Fc = config.Fc0 + (k-1)*config.deltaF;

    % RF filter (select station)
    rf = rf_stage_filter(fdm, Fs, Fc);

    % Local oscillator
    f_LO = Fc + config.IF + config.f1;

    % Mixer stage
    if_signal = mixer_stage(rf, Fs, f_LO);

    %% FFT
    N = length(if_signal);
    f = (-N/2:N/2-1)*(Fs/N);

    X = fftshift(fft(if_signal));
    X = abs(X)/max(abs(X));

    %% Subplot
    subplot(num_stations,1,k)

    plot(f/1000, X, 'Color', colors(k,:), 'LineWidth',1.5)

    title(sprintf("Mixer Output Spectrum - Station %d",k))
    xlabel("Frequency (kHz)")
    ylabel("Normalized Magnitude")

    grid on
    xlim([-500 500])

end



%% better visualization for imaging 
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

colors = lines(num_stations);

%% Pre-modulate stations
modulated = cell(num_stations,1);

for i = 1:num_stations
    Fc_i = config.Fc0 + (i-1)*config.deltaF;
    modulated{i} = dsb_sc_modulate(messages{i}, Fc_i, Fs);
end

figure

%% Receiver tuning loop
for k = 1:num_stations

    Fc = config.Fc0 + (k-1)*config.deltaF;
    f_LO = Fc + config.IF;

    subplot(num_stations,1,k)
    hold on

    for i = 1:num_stations

        % Mix each station separately
        mixed = mixer_stage(modulated{i}, Fs, f_LO);

        N = length(mixed);
        f = (-N/2:N/2-1)*(Fs/N);

        X = fftshift(fft(mixed));
        X = abs(X)/max(abs(X));

        plot(f/1000, X, 'Color', colors(i,:), 'LineWidth',1.2)

    end

    title(sprintf("Mixer Output Spectrum - Receiver tuned to Station %d",k))
    xlabel("Frequency (kHz)")
    ylabel("Normalized Magnitude")

    grid on
    xlim([-500 500])

    if k == 1
        legend("Station 1","Station 2","Station 3","Station 4","Station 5")
    end

    hold off

end

