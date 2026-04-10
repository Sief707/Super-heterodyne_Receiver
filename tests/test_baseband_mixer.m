
disp("=== TEST: BASEBAND MIXER ===")

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


colors = lines(num_stations);

%% Prepare figure
figure
colors = lines(num_stations);

%% Loop through stations
for k = 1:num_stations

    disp(["Testing baseband mixer for station ", num2str(k)])

    % Carrier frequency
    Fc = config.Fc0 + (k-1)*config.deltaF ;

    % RF filter
    rf = rf_stage_filter(fdm,Fs,Fc);

    % RF → IF mixer
    f_LO = Fc + config.IF + config.f1 ; %% test frequency offset
    mixed = mixer_stage(rf,Fs,f_LO);

    % IF filter
    if_signal = if_stage_filter(mixed,Fs);

    % IF → baseband mixer
    baseband = baseband_mixer(if_signal,Fs);

    %% FFT
    N = length(baseband);
    f = (-N/2:N/2-1)*(Fs/N);

    X = fftshift(fft(baseband));
    X = abs(X)/max(abs(X));

    %% Subplot
    subplot(num_stations,1,k)

    plot(f/1000,X,'Color',colors(k,:),'LineWidth',1.5)

    title(sprintf("Baseband Mixer Output - Station %d",k))
    xlabel("Frequency (kHz)")
    ylabel("Normalized Magnitude")

    grid on
    xlim([-70 70])

end

sgtitle("Baseband Mixer Verification - Spectra")