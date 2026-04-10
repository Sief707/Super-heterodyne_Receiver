disp("TEST: INTERPOLATION ")

%% Load signals

signals = load_signals();

messages = signals.messages;
original_Fs = signals.Fs;

num_signals = length(messages);

fprintf("Original Fs: %d \n",original_Fs);
fprintf("Number of signals : %d \n",num_signals);             


%% Define interpolation factor
L = 60;

%% Run interpolation

signals_interp = interpolate_signal(signals, L);

messages_interp = signals_interp.messages;
new_Fs = signals_interp.Fs;

fprintf("New Fs: %d \n",new_Fs);

%% Assertions

if new_Fs ~= L * original_Fs
    error("Sampling frequency not updated correctly")
end

disp("Interpolation test PASSED")


colors = lines(num_signals);   % generate different colors
%% =====================================================
%% Plot 1 : Time Domain Signals AFTER Interpolation
%% =====================================================

figure('Name','Interpolated Signals (Time Domain)')

for k = 1:num_signals

    signal = messages_interp{k};

    subplot(num_signals,1,k)

    plot(signal,'Color', colors(k,:))

    title(sprintf("Interpolated Signal - Station %d",k))
    xlabel("Samples")
    ylabel("Amplitude")

    grid on

end

%% =====================================================
%% Plot 2 : Time Domain Signals BEFORE Interpolation
%% =====================================================

figure('Name','NON INTERPOLATED Signals (Time Domain)')

for k = 1:num_signals

    signal = messages{k};

    subplot(num_signals,1,k)

    plot(signal,'Color', colors(k,:))

    title(sprintf("NON INTERPOLATED Signal - Station %d",k))
    xlabel("Samples")
    ylabel("Amplitude")

    grid on

end


%% =====================================================
%% Plot 2 : Baseband Spectrum AFTER Interpolation
%% =====================================================

figure('Name','Baseband Spectrum After Interpolation')

for k = 1:num_signals

    msg = messages_interp{k};

    % limit analysis length (avoid huge FFT)
    analysis_length = min(200000 , length(msg));
    msg = msg(1:analysis_length);

    N = length(msg);

    % Frequency axis
    f = (-N/2:N/2-1)*(new_Fs/N);

    % FFT
     X = fftshift(fft(msg));

     X = abs(X);

     % normalize for visualization
     X = X / max(X);

    subplot(num_signals,1,k)

    plot(f/1000 , X , 'LineWidth',1.3)

    title(sprintf("Baseband Spectrum After Interpolation - Station %d",k))
    xlabel("Frequency (kHz)")
    ylabel("Magnitude")

    grid on
    xlim([-10 10])

end