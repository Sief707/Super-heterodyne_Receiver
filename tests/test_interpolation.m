clc;
clear;
close all;

disp("=== TEST: INTERPOLATION ===")

%% Load signal

signals = load_signals();

original_signal = signals.signal;
original_Fs     = signals.Fs;

disp("Original Fs:")
disp(original_Fs)

disp("Original length:")
disp(length(original_signal))

%% Define interpolation factor

L = 60;

%% Run interpolation

signals_interp = interpolate_signal(signals, L);

new_signal = signals_interp.signal;
new_Fs     = signals_interp.Fs;

disp("New Fs:")
disp(new_Fs)

disp("New length:")
disp(length(new_signal))

%% Assertions (Professional Validation)

if new_Fs ~= L * original_Fs
    error("Sampling frequency not updated correctly")
end

if length(new_signal) <= length(original_signal)
    error("Signal length did not increase")
end

disp("Interpolation test PASSED")

%% Optional Visualization

figure;

subplot(2,1,1);
plot(original_signal);
title("Original Signal");

subplot(2,1,2);
plot(new_signal);
title("Interpolated Signal");