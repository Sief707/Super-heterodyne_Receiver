signals = load_signals();

signal = signals.signal;
Fs = signals.Fs;

N = length(signal);

% FFT
X = fft(signal);

% Frequency axis
f = (-N/2:N/2-1)*(Fs/N);

% Shift
X_shifted = fftshift(X);

% Plot
figure;
plot(f, abs(X_shifted));
% xlim([-10000 10000]);
title('Signal Spectrum');
xlabel('Frequency (Hz)');
ylabel('Magnitude');
grid on;