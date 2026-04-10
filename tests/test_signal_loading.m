signals = load_signals();

messages = signals.messages;
Fs = signals.Fs;

num_stations = length(messages);

figure
colors = lines(num_stations);   % generate different colors
for k = 1:num_stations

    msg = messages{k};

    % Limit samples for FFT (avoid memory issues)
    analysis_length = min(200000, length(msg));
    msg = msg(1:analysis_length);

    N = length(msg);

    % Frequency axis
    f = (-N/2:N/2-1)*(Fs/N);

    % FFT
    X = fftshift(fft(msg));
    X = abs(X)/max(abs(X));

    % Subplot
    subplot(num_stations,1,k)

    plot(f/1000 , X ,'Color', colors(k,:), 'LineWidth',1.3)

    title(sprintf("Baseband Spectrum - Station %d",k))
    xlabel("Frequency (kHz)")
    ylabel("Magnitude")

    grid on
    xlim([-10 10])   % typical audio bandwidth

end

num_signals = length(messages);
for k = 1:num_signals
    y = messages{k};
    N = length(y);
    Y = fftshift(abs(fft(y)).^2) / N;
    f = (-N/2:N/2-1)*(Fs/N);
    % keep positive frequencies only
    Y_pos = Y(N/2:end);
    f_pos = f(N/2:end);
    % cumulative energy
    cum_energy = cumsum(Y_pos);
    total_energy = cum_energy(end);
    % find frequency containing 99% of energy
    idx = find(cum_energy >= 0.99*total_energy,1);
    BW = f_pos(idx);
    fprintf("Estimated Audio BW of station %d ≈ %.2f Hz\n",k,BW);
end

figure 
msg = messages{3};

N = length(msg);

X = fftshift(fft(msg));
f = (-N/2:N/2-1)*(Fs/N);

plot(f/1e3 , abs(X)/max(abs(X)))
xlim([0 15])
grid on

%% TD plot 
figure

colors = lines(num_stations);   % generate different colors

for k = 1:num_stations

    msg = messages{k};

    % Limit samples for visualization
    analysis_length = min(20000, length(msg));
    msg = msg(1:analysis_length);

    N = length(msg);

    % Time axis
    t = (0:N-1)/Fs;

    % Subplot
    subplot(num_stations,1,k)

    plot(t , msg , 'Color', colors(k,:), 'LineWidth',1.2)

    title(sprintf("Time Domain Signal - Station %d",k))
    xlabel("Time (s)")
    ylabel("Amplitude")

    grid on

end