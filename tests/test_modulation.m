disp("=== TEST: MODULATION ===")

%% Load signals
signals = load_signals();

%% Interpolate signals (Phase 2)
L = 20;
signals = interpolate_signal(signals, L);

messages = signals.messages;
Fs       = signals.Fs;

disp("Sampling Frequency After Interpolation:")
disp(Fs)

num_stations = length(messages);

disp("Number of stations loaded:")
disp(num_stations)

colors = lines(num_stations);   % generate different colors
% ---------------------------------------------------------
% Compute RMS-based scaling factors (sqrt(power))
% ---------------------------------------------------------

powers = zeros(1,num_stations);

for k = 1:num_stations
    powers(k) = mean(messages{k}.^2);
end

amplitudes = sqrt(powers);

% Normalize relative to strongest station
amplitudes = amplitudes / max(amplitudes);

% Apply scaling to signals
for k = 1:num_stations
    messages{k} = amplitudes(k) * messages{k};
end

%% Build FDM Signal (Phase 3)
fdm = build_fdm_signal(messages, Fs);
disp("FDM signal generated successfully")

%% DSB
figure; 
for i = 1:5 
    FCC = 100e3 + (i-1)*30e3 ;
    x = dsb_sc_modulate(messages{i}, FCC, Fs); 
    N = length(x); 
     
    X = fftshift(fft(x)); 
    f = (-N/2:N/2-1)*(Fs/N);
    subplot(5,1,i) 
    plot(f/1e3, abs(X)/max(abs(X)),'Color', colors(i,:)) 
     
    title(['Modulated Spectrum - Signal ', num2str(i)]) 
    xlabel('Frequency (kHz)') 
    ylabel('Mag') 
    grid on 
     
end

%% DSB - FDM Spectrum (Global Normalization)
spectra = cell(1,5);
lengths = zeros(1,5);
max_val = 0;

for i = 1:5
    
    FCC = 100e3 + (i-1)*30e3;
    
    x = dsb_sc_modulate(messages{i}, FCC, Fs);
    N = length(x);
    
    X = fftshift(fft(x));
    
    spectra{i} = X;
    lengths(i) = N;

    max_val = max(max_val, max(abs(X)));

end


figure
hold on

for i = 1:5
    
    X = spectra{i};
    N = lengths(i);

    f = (-N/2:N/2-1)*(Fs/N);

    plot(f/1e3 , abs(X)/max_val , 'Color', colors(i,:), 'LineWidth',1.2)

end

title('FDM Modulated Spectrum')
xlabel('Frequency (kHz)')
ylabel('Normalized Magnitude')
grid on
legend('Signal 1','Signal 2','Signal 3','Signal 4','Signal 5')
%% FFT analysis window (prevents memory overflow)
analysis_length = min(200000, length(fdm));
fdm_segment = fdm(1:analysis_length);

N = length(fdm_segment);

%% Frequency axis
f = (-N/2:N/2-1)*(Fs/N);

%% FFT computation
X = fftshift(fft(fdm_segment));


%% Normalize magnitude
X = abs(X);

% Compute global normalization factor from all stations
global_norm = 0;

analysis_length = min(200000, length(messages{1}));

for k = 1:num_stations

    msg = messages{k};

    msg_segment = msg(1:analysis_length);

    Fc = 100e3 + (k-1)*30e3;

    modulated = dsb_sc_modulate(msg_segment, Fc, Fs);

    Nk = length(modulated);

    Xtemp = fftshift(fft(modulated));
    Xtemp = abs(Xtemp)/Nk;

    global_norm = max(global_norm, max(Xtemp));

end




%%=============
figure
for k = 1:num_stations

    msg = messages{k};

    N = length(msg);

    X = fftshift(fft(msg));

    f = (-N/2:N/2-1)*(Fs/N);

    subplot(num_stations,1,k)

    plot(f/1e3 , abs(X)/max(abs(X)),'Color', colors(k,:))

    title(sprintf("Baseband Spectrum - Station %d",k))
    xlabel("Frequency (kHz)")
    ylabel("Mag")

    xlim([-20 20])
    grid on

end

%% FDM totally plot
fdm = build_fdm_signal(messages, Fs);

N = length(fdm);              % signal length

X = fftshift(fft(fdm));

f = (-N/2 : N/2-1) * (Fs/N);  % frequency axis
figure 
plot(f/1e3 , abs(X)/max(abs(X)))
xlabel('Frequency (kHz)')
ylabel('RF Transmitted FDM signal')
grid on
