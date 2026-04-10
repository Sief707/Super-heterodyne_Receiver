
disp("=== TEST: RF STAGE ===")

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


%% Prepare figure
figure

colors = lines(num_stations);

for k = 1:num_stations

    disp(["Testing RF filter for station ", num2str(k)])

    % Carrier frequency
    Fc = config.Fc0 + (k-1)*config.deltaF;

    % RF filter
    rf_signal = rf_stage_filter(fdm, Fs, Fc);

    %% FFT
    N = length(rf_signal);
    f = (-N/2:N/2-1)*(Fs/N);

    X = fftshift(fft(rf_signal));
    X = abs(X)/max(abs(X));

    %% Subplot
    subplot(num_stations,1,k)

    plot(f/1000 , X , 'Color', colors(k,:) , 'LineWidth',1.5)

    title(sprintf("RF Stage Output - Station %d",k))
    xlabel("Frequency (kHz)")
    ylabel("Normalized Magnitude")

    grid on
    xlim([-250 250])

end