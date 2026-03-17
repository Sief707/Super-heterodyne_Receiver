signals = load_signals();

figure;
plot(signals.signal , 'b');
title('Time Domain Signal');
xlabel('Samples');
ylabel('Amplitude');
grid on;