clc
clear
close all

disp("=== TEST: MODULATION ===")

%% Load signals
signals = load_signals();

%% Interpolate signals (Phase 2)
L = 60;
signals = interpolate_signal(signals, L);

messages = signals.messages;
Fs       = signals.Fs;

disp("Sampling Frequency After Interpolation:")
disp(Fs)

num_stations = length(messages);

disp("Number of stations loaded:")
disp(num_stations)

%% Build FDM Signal (Phase 3)
fdm = build_fdm_signal(messages, Fs);
disp("FDM signal generated successfully")

%% ---------------------------------------------------------
%% FFT analysis window (prevents memory overflow)
%% ---------------------------------------------------------

analysis_length = min(200000, length(fdm));
fdm_segment = fdm(1:analysis_length);

N = length(fdm_segment);

%% Frequency axis
f = (-N/2:N/2-1)*(Fs/N);

%% FFT computation
X = fftshift(fft(fdm_segment));

%% Normalize magnitude
X = abs(X) / max(abs(X));



%% ---------------------------------------------------------
%% Plot 1 : RF Spectrum (Original multiplexed plot)
%% ---------------------------------------------------------

figure

plot(f/1000, X)

title("FDM Multiplexed Spectrum (All Stations)")
xlabel("Frequency (kHz)")
ylabel("Normalized Magnitude")
grid on

xlim([-360 360])


%% ---------------------------------------------------------
%% Plot 2 : Full Spectrum View
%% ---------------------------------------------------------

figure
plot(f/1000, X)

title("Full Spectrum View (Zoomed In)")
xlabel("Frequency (kHz)")
ylabel("Normalized Magnitude")
grid on

xlim([70 250])


%% ---------------------------------------------------------
%% Plot 3 : RF Spectrum of Individual Stations (Colored)
%% ---------------------------------------------------------

figure
colors = lines(num_stations);

hold on

analysis_length = min(200000, length(messages{1}));

for k = 1:num_stations
    
    msg = messages{k};
    
    msg_segment = msg(1:analysis_length);
    
    Fc = 100e3 + (k-1)*30e3;
    
    modulated = dsb_sc_modulate(msg_segment, Fc, Fs);
    
    Nk = length(modulated);
    
    fk = (-Nk/2:Nk/2-1)*(Fs/Nk);
    
    Xk = fftshift(fft(modulated));
    Xk = abs(Xk)/max(abs(Xk));
    
    plot(fk/1000, Xk, 'Color', colors(k,:), 'LineWidth', 1.3)

end

title("RF Spectrum of Individual Stations")
xlabel("Frequency (kHz)")
ylabel("Normalized Magnitude")
grid on

xlim([-360 360])

legend("Station 1","Station 2","Station 3","Station 4","Station 5")

%% ---------------------------------------------------------
%% Plot RF Spectrum of Each Station Separately
%% ---------------------------------------------------------

colors = lines(num_stations);

analysis_length = min(200000, length(messages{1}));

for k = 1:num_stations

    msg = messages{k};

    msg_segment = msg(1:analysis_length);

    % Carrier frequency
    Fc = 100e3 + (k-1)*30e3;

    % Modulate station
    modulated = dsb_sc_modulate(msg_segment, Fc, Fs);

    % FFT
    Nk = length(modulated);
    fk = (-Nk/2:Nk/2-1)*(Fs/Nk);

    Xk = fftshift(fft(modulated));
    Xk = abs(Xk)/max(abs(Xk));

    % Plot
    figure
    plot(fk/1000, Xk, 'Color', colors(k,:), 'LineWidth', 1.5)

    title(sprintf("RF Spectrum of Station %d",k))
    xlabel("Frequency (kHz)")
    ylabel("Normalized Magnitude")

    grid on
    xlim([-280 280])

end

disp("Modulation test completed successfully")