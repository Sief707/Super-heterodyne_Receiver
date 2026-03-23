clc
clear
close all

disp("=== TEST: MODULATION ===")

%% Load signal
signals = load_signals();

%% Interpolate signal (Phase 2)
L = 60;
signals = interpolate_signal(signals, L);

message = signals.signal;
Fs      = signals.Fs;

disp("Sampling Frequency After Interpolation:")
disp(Fs)

%% Create multiple messages for FDM

% Here we duplicate the same signal to simulate multiple stations
messages = {message , message};

%% Build FDM Signal (Phase 3)
fdm = build_fdm_signal(messages, Fs);
disp("FDM signal generated successfully")

%% Compute FFT of multiplexed signal
N = length(fdm);

% Frequency axis
f = (-N/2:N/2-1)*(Fs/N);

% FFT computation
X = fftshift(fft(fdm));

% Normalize magnitude for better visualization
X = abs(X) / max(abs(X));

%% ---------------------------------------------------------
%% Plot 1 : RF Spectrum (Original multiplexed plot)
%% ---------------------------------------------------------

figure
plot(f, X)

title("FDM Spectrum")
xlabel("Frequency (Hz)")
ylabel("Normalized Magnitude")
grid on

% Focus on RF band
xlim([80000 150000])

%% ---------------------------------------------------------
%% Plot 2 : RF Spectrum in kHz (cleaner visualization)
%% ---------------------------------------------------------

figure
plot(f/1000, X)

title("FDM Spectrum (RF Region)")
xlabel("Frequency (kHz)")
ylabel("Normalized Magnitude")
grid on

xlim([80 150])

%% ---------------------------------------------------------
%% Plot 3 : Full Spectrum View
%% ---------------------------------------------------------

figure
plot(f/1000, X)

title("Full Spectrum View")
xlabel("Frequency (kHz)")
ylabel("Normalized Magnitude")
grid on

%% ---------------------------------------------------------
%% Plot 4 : Zoom into first station (around 100 kHz)
%% ---------------------------------------------------------

figure
plot(f/1000, X)

title("Station Around 100 kHz")
xlabel("Frequency (kHz)")
ylabel("Normalized Magnitude")
grid on

xlim([90 110])

disp("Modulation test completed successfully")