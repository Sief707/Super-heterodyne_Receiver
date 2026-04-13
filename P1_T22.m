%{
NOTE:
A complete software environment was developed for this project, following
a modular architecture as described in the report. 

For submission purposes, all components were merged into a single .m file,
which explains the large file size. However, the core system implementation
(main execution flow) is concise and consists of approximately 40 lines.

All tests exist below commented.

System Modules and Functions exist at the end of the file

Full project repository (Full Software Architecture):
https://github.com/Sief707/Super-heterodyne_Receiver
%}

%% ================== Main Code ====================
clc
clear
close all

disp("==========================================")
disp(" SUPERHETERODYNE RECEIVER SYSTEM ")
disp("==========================================")

%% Load configuration
disp("Loading system configuration...")
config = system_config();

%% Load signals
disp("Loading audio stations...")
signals = load_signals();

%% Interpolation
disp("Interpolating signals (increase sampling rate)...")
signals = interpolate_signal(signals, config.L);
Fs = signals.Fs;
messages = signals.messages;

%% Build FDM signal
disp("Building FDM multiplexed transmitter signal...")
fdm_signal = build_fdm_signal(messages, Fs);

%% Receiver
disp("Running receiver system...")
audio = receiver_system(fdm_signal, Fs, config);

%% Normalize
disp("Normalizing recovered audio...")
audio = audio / max(abs(audio));

%% Audio sampling frequency
Fs_audio = Fs / config.L;

%% Playback
disp("Playing recovered station...")
sound(audio, Fs_audio)

%% Save audio
disp("Saving recovered audio to results folder...")
audiowrite("results/recovered_station.wav", audio, Fs_audio)
disp("==========================================")
disp(" SYSTEM EXECUTION COMPLETED ")
disp("==========================================")


%% =================== FULL VERIFICATION TESTS =======================
%{
%% ===================== TEST: SIGNAL LOADING =====================
% Purpose:
% Validate that all input audio signals are properly loaded,
% correctly formatted, and consistent with system configuration.
signals = load_signals();
messages = signals.messages;
Fs = signals.Fs;
num_stations = length(messages);
 
%% ===================== BASEBAND SPECTRUM (ALL STATIONS) ===================
figure
colors = lines(num_stations);   % generate different colors
for k = 1:num_stations
    % -------- Extract signal --------
    msg = messages{k};
    % -------- Limit samples for FFT (avoid memory issues) --------
    analysis_length = min(200000, length(msg));
    msg = msg(1:analysis_length);
    N = length(msg);
    % -------- Frequency axis --------
    f = (-N/2:N/2-1)*(Fs/N);
    % -------- FFT computation --------
    X = fftshift(fft(msg));
    X = abs(X)/max(abs(X));
    % -------- Plot --------
    subplot(num_stations,1,k)
    plot(f/1000 , X ,'Color', colors(k,:), 'LineWidth',1.3)
    title(sprintf("Baseband Spectrum - Station %d",k))
    xlabel("Frequency (kHz)")
    ylabel("Magnitude")
    grid on
    xlim([-10 10])   % typical audio bandwidth
end
 
%% ===================== BANDWIDTH ESTIMATION (99% ENERGY) ==================
num_signals = length(messages);
for k = 1:num_signals
    % -------- Extract signal --------
    y = messages{k};
    N = length(y);
    % -------- Power Spectrum --------
    Y = fftshift(abs(fft(y)).^2) / N;
    f = (-N/2:N/2-1)*(Fs/N);
    % -------- Keep positive frequencies only --------
    Y_pos = Y(N/2:end);
    f_pos = f(N/2:end);
    % -------- Cumulative energy --------
    cum_energy = cumsum(Y_pos);
    total_energy = cum_energy(end);
    % -------- Find bandwidth (99% energy) --------
    idx = find(cum_energy >= 0.99*total_energy,1);
    BW = f_pos(idx);
    fprintf("Estimated Audio BW of station %d ? %.2f Hz\n",k,BW);
end
 
%% ===================== SINGLE SIGNAL SPECTRUM (STATION 3) =================
figure 
msg = messages{3};
N = length(msg);
% -------- FFT --------
X = fftshift(fft(msg));
f = (-N/2:N/2-1)*(Fs/N);
% -------- Plot --------
plot(f/1e3 , abs(X)/max(abs(X)))
xlim([0 15])
grid on
 
%% ===================== TIME DOMAIN VISUALIZATION =====================
figure
colors = lines(num_stations);   % generate different colors
for k = 1:num_stations
    % -------- Extract signal --------
    msg = messages{k};
    % -------- Limit samples for visualization --------
    analysis_length = min(20000, length(msg));
    msg = msg(1:analysis_length);
    N = length(msg);
    % -------- Time axis --------
    t = (0:N-1)/Fs;
    % -------- Plot --------
    subplot(num_stations,1,k)
    plot(t , msg , 'Color', colors(k,:), 'LineWidth',1.2)
    title(sprintf("Time Domain Signal - Station %d",k))
    xlabel("Time (s)")
    ylabel("Amplitude")
    grid on
end
%}

%{
%% ===================== TEST: INTERPOLATION =====================
% Purpose:
% Verify correct interpolation of signals, including sampling rate update
% and integrity of processed signals.
 
disp("TEST: INTERPOLATION ")
 
%% ===================== LOAD SIGNALS =====================
signals = load_signals();
messages = signals.messages;
original_Fs = signals.Fs;
num_signals = length(messages);
fprintf("Original Fs: %d \n",original_Fs);
fprintf("Number of signals : %d \n",num_signals);             
 
%% ===================== DEFINE INTERPOLATION FACTOR =====================
L = 60;
 
%% ===================== RUN INTERPOLATION =====================
signals_interp = interpolate_signal(signals, L);
messages_interp = signals_interp.messages;
new_Fs = signals_interp.Fs;
fprintf("New Fs: %d \n",new_Fs);
 
%% ===================== ASSERTIONS =====================
if new_Fs ~= L * original_Fs
    error("Sampling frequency not updated correctly")
end
disp("Interpolation test PASSED")
 
%% ===================== COLOR SETUP =====================
colors = lines(num_signals);   % generate different colors
 
%% ===================== TIME DOMAIN (AFTER INTERPOLATION) ==================
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
 
%% ===================== TIME DOMAIN (BEFORE INTERPOLATION) =================
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
 
%% ===================== BASEBAND SPECTRUM (AFTER INTERPOLATION) ============
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
%}

%{
%% ===================== TEST: MODULATION =====================
% Purpose:
% Verify modulation process including signal scaling, DSB-SC modulation,
% and correct FDM spectrum construction.
 
disp("=== TEST: MODULATION ===")
 
%% ===================== LOAD + INTERPOLATION =====================
signals = load_signals();
L = 20;
signals = interpolate_signal(signals, L);
messages = signals.messages;
Fs = signals.Fs;
disp("Sampling Frequency After Interpolation:")
disp(Fs)
num_stations = length(messages);
disp("Number of stations loaded:")
disp(num_stations)
 
%% ===================== COLOR SETUP =====================
colors = lines(num_stations);
 
%% ===================== RMS POWER SCALING =====================
powers = zeros(1,num_stations);
for k = 1:num_stations
    powers(k) = mean(messages{k}.^2);
end
amplitudes = sqrt(powers);
amplitudes = amplitudes / max(amplitudes);
for k = 1:num_stations
    messages{k} = amplitudes(k) * messages{k};
end
 
%% ===================== BUILD FDM SIGNAL =====================
fdm = build_fdm_signal(messages, Fs);
disp("FDM signal generated successfully")
 
%% ===================== DSB-SC PER SIGNAL =====================
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
 

%% ===================== DSB FDM (GLOBAL NORMALIZATION) =====================
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
 
%% ===================== FDM FFT ANALYSIS =====================
analysis_length = min(200000, length(fdm));
fdm_segment = fdm(1:analysis_length);
N = length(fdm_segment);
f = (-N/2:N/2-1)*(Fs/N);
X = fftshift(fft(fdm_segment));
X = abs(X);
 
%% ===================== GLOBAL NORMALIZATION FACTOR =====================
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
 
%% ===================== BASEBAND CHECK =====================
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

%% ===================== FINAL FDM SPECTRUM =====================
fdm = build_fdm_signal(messages, Fs);
N = length(fdm);
X = fftshift(fft(fdm));
f = (-N/2 : N/2-1) * (Fs/N);
figure 
plot(f/1e3 , abs(X)/max(abs(X)))
xlabel('Frequency (kHz)')
ylabel('RF Transmitted FDM signal')
grid on
%}

%{
%% ===================== TEST: RF STAGE =====================
% Purpose:
% Verify RF filtering stage by isolating each station from the FDM signal
% and observing its spectrum around the corresponding carrier.
 
disp("=== TEST: RF STAGE ===")
 
%% ===================== LOAD CONFIGURATION =====================
config = system_config();
 
%% ===================== LOAD + INTERPOLATE SIGNALS =====================
signals = load_signals();
signals = interpolate_signal(signals, config.L);
messages = signals.messages;
Fs = signals.Fs;
num_stations = length(messages);
disp("Number of stations loaded:")
disp(num_stations)
 
%% ===================== BUILD FDM SIGNAL =====================
fdm = build_fdm_signal(messages, Fs);
disp("FDM signal generated")
 
%% ===================== RF STAGE ANALYSIS =====================
figure
colors = lines(num_stations);
 
for k = 1:num_stations
 
    disp(["Testing RF filter for station ", num2str(k)])
 
    % -------- Carrier frequency --------
    Fc = config.Fc0 + (k-1)*config.deltaF;
 
    % -------- RF filtering --------
    rf_signal = rf_stage_filter(fdm, Fs, Fc);
 
    % -------- FFT --------
    N = length(rf_signal);
    f = (-N/2:N/2-1)*(Fs/N);
    X = fftshift(fft(rf_signal));
    X = abs(X)/max(abs(X));
 
    % -------- Plot --------
    subplot(num_stations,1,k)
    plot(f/1000 , X , 'Color', colors(k,:) , 'LineWidth',1.5)
    title(sprintf("RF Stage Output - Station %d",k))
    xlabel("Frequency (kHz)")
    ylabel("Normalized Magnitude")
    grid on
    xlim([-250 250])
 
end
%}

%{
%% ===================== TEST: MIXER STAGE =====================
% Purpose:
% Verify frequency translation using mixer stage and observe IF spectrum.
 
disp("=== TEST: MIXER STAGE ===")
 
%% ===================== LOAD CONFIGURATION =====================
config = system_config();
 
%% ===================== LOAD + INTERPOLATE SIGNALS =====================
signals = load_signals();
signals = interpolate_signal(signals, config.L);
messages = signals.messages;
Fs = signals.Fs;
num_stations = length(messages);
disp("Number of stations loaded:")
disp(num_stations)
 
%% ===================== BUILD FDM SIGNAL =====================
fdm = build_fdm_signal(messages, Fs);
disp("FDM signal generated")
 
%% ===================== COLOR SETUP =====================
colors = lines(num_stations);
 
%% ===================== MIXER OUTPUT (PER STATION) =====================
figure
for k = 1:num_stations
    disp(["Testing mixer stage for station ", num2str(k)])
    % -------- Carrier frequency --------
    Fc = config.Fc0 + (k-1)*config.deltaF;
    % -------- RF filter --------
    rf = rf_stage_filter(fdm, Fs, Fc);
    % -------- Local oscillator --------
    f_LO = Fc + config.IF + config.f1;
    % -------- Mixer --------
    if_signal = mixer_stage(rf, Fs, f_LO);
    % -------- FFT --------
    N = length(if_signal);
    f = (-N/2:N/2-1)*(Fs/N);
    X = fftshift(fft(if_signal));
    X = abs(X)/max(abs(X));
    % -------- Plot --------
    subplot(num_stations,1,k)
    plot(f/1000, X, 'Color', colors(k,:), 'LineWidth',1.5)
    title(sprintf("Mixer Output Spectrum - Station %d",k))
    xlabel("Frequency (kHz)")
    ylabel("Normalized Magnitude")
    grid on
    xlim([-500 500])
end

%% ===================== MIXER IMAGING VISUALIZATION =====================
% Purpose:
% Show how all stations appear after mixing (image + desired IF)
 
disp("=== TEST: MIXER STAGE ===")
 
%% ===================== RELOAD + INTERPOLATE =====================
config = system_config();
signals = load_signals();
signals = interpolate_signal(signals, config.L);
messages = signals.messages;
Fs = signals.Fs;
num_stations = length(messages);
disp("Number of stations loaded:")
disp(num_stations)
 
%% ===================== COLOR SETUP =====================
colors = lines(num_stations);
 
%% ===================== PRE-MODULATION =====================
modulated = cell(num_stations,1);
for i = 1:num_stations
    Fc_i = config.Fc0 + (i-1)*config.deltaF;
    modulated{i} = dsb_sc_modulate(messages{i}, Fc_i, Fs);
end
 
%% ===================== RECEIVER TUNING LOOP =====================
figure
for k = 1:num_stations
    Fc = config.Fc0 + (k-1)*config.deltaF;
    f_LO = Fc + config.IF;
    subplot(num_stations,1,k)
    hold on
    for i = 1:num_stations
        % -------- Mix each station --------
        mixed = mixer_stage(modulated{i}, Fs, f_LO);
        N = length(mixed);
        f = (-N/2:N/2-1)*(Fs/N);
        X = fftshift(fft(mixed));
        X = abs(X)/max(abs(X));
        plot(f/1000, X, 'Color', colors(i,:), 'LineWidth',1.2)
    end
    title(sprintf("Mixer Output Spectrum - Receiver tuned to Station %d",k))
    xlabel("Frequency (kHz)")
    ylabel("Normalized Magnitude")
    grid on
    xlim([-500 500])
    if k == 1
        legend("Station 1","Station 2","Station 3","Station 4","Station 5")
    end
    hold off
end
%}

%{
%% ===================== TEST: IF STAGE =====================
% Purpose:
% Verify IF stage by translating RF to IF and applying IF filter,
% ensuring correct frequency selection and filtering.
 
disp("=== TEST: IF STAGE ===")
 
%% ===================== LOAD CONFIGURATION =====================
config = system_config();
 
%% ===================== LOAD + INTERPOLATE SIGNALS =====================
signals = load_signals();
signals = interpolate_signal(signals, config.L);
messages = signals.messages;
Fs = signals.Fs;
num_stations = length(messages);
disp("Number of stations loaded:")
disp(num_stations)
 
%% ===================== BUILD FDM SIGNAL =====================
fdm = build_fdm_signal(messages,Fs);
disp("FDM signal generated")
 
%% ===================== COLOR SETUP =====================
colors = lines(num_stations);
 
%% ===================== IF STAGE ANALYSIS =====================
figure
colors = lines(num_stations);
 
for k = 1:num_stations
 
    disp(["Testing IF stage for station ", num2str(k)])
 
    % -------- Carrier frequency --------
    Fc = config.Fc0 + (k-1)*config.deltaF;
 
    % -------- RF filter --------
    rf = rf_stage_filter(fdm, Fs, Fc);
 
    % -------- Mixer (RF ? IF) --------
    f_LO = Fc + config.IF;
    mixed = mixer_stage(rf, Fs, f_LO);
 
    % -------- IF filter --------
    if_signal = if_stage_filter(mixed, Fs);
 
    % -------- FFT --------
    N = length(if_signal);
    f = (-N/2:N/2-1)*(Fs/N);
    X = fftshift(fft(if_signal));
    X = abs(X)/max(abs(X));
 
    % -------- Plot --------
    subplot(num_stations,1,k)
    plot(f/1000, X, 'Color', colors(k,:), 'LineWidth',1.5)
    title(sprintf("IF Stage Output - Station %d",k))
    xlabel("Frequency (kHz)")
    ylabel("Normalized Magnitude")
    grid on
    xlim([-500 500])
 
end
 
sgtitle("IF Stage Verification - Filtered IF Spectra")
%}

%{
%% ===================== TEST: BASEBAND MIXER =====================
% Purpose:
% Verify final downconversion from IF to baseband and observe recovered spectrum.
 
disp("=== TEST: BASEBAND MIXER ===")
 
%% ===================== LOAD CONFIGURATION =====================
config = system_config();
 
%% ===================== LOAD + INTERPOLATE SIGNALS =====================
signals = load_signals();
signals = interpolate_signal(signals, config.L);
messages = signals.messages;
Fs = signals.Fs;
num_stations = length(messages);
disp("Number of stations loaded:")
disp(num_stations)
 
%% ===================== BUILD FDM SIGNAL =====================
fdm = build_fdm_signal(messages,Fs);
disp("FDM signal generated")
 
%% ===================== COLOR SETUP =====================
colors = lines(num_stations);
 
%% ===================== BASEBAND MIXER ANALYSIS =====================
figure
colors = lines(num_stations);
 
for k = 1:num_stations
 
    disp(["Testing baseband mixer for station ", num2str(k)])
 
    % -------- Carrier frequency --------
    Fc = config.Fc0 + (k-1)*config.deltaF;
 
    % -------- RF filter --------
    rf = rf_stage_filter(fdm,Fs,Fc);
 
    % -------- RF ? IF mixer --------
    f_LO = Fc + config.IF + config.f1; % test frequency offset
    mixed = mixer_stage(rf,Fs,f_LO);
 
    % -------- IF filter --------
    if_signal = if_stage_filter(mixed,Fs);
 
    % -------- IF ? Baseband mixer --------
    baseband = baseband_mixer(if_signal,Fs);
 
    % -------- FFT --------
    N = length(baseband);
    f = (-N/2:N/2-1)*(Fs/N);
    X = fftshift(fft(baseband));
    X = abs(X)/max(abs(X));
 
    % -------- Plot --------
    subplot(num_stations,1,k)
    plot(f/1000,X,'Color',colors(k,:),'LineWidth',1.5)
    title(sprintf("Baseband Mixer Output - Station %d",k))
    xlabel("Frequency (kHz)")
    ylabel("Normalized Magnitude")
    grid on
    xlim([-70 70])
 
end
 
sgtitle("Baseband Mixer Verification - Spectra")
%}

%{
%% ===================== TEST: BASEBAND LPF =====================
% Purpose:
% Verify final low-pass filtering stage and ensure recovery of audio spectrum.
 
disp("=== TEST: BASEBAND LPF ===")
 
%% ===================== LOAD CONFIGURATION =====================
config = system_config();
 
%% ===================== LOAD + INTERPOLATE SIGNALS =====================
signals = load_signals();
signals = interpolate_signal(signals, config.L);
messages = signals.messages;
Fs = signals.Fs;
num_stations = length(messages);
disp("Number of stations loaded:")
disp(num_stations)
 
%% ===================== BUILD FDM SIGNAL =====================
fdm = build_fdm_signal(messages,Fs);
disp("FDM signal generated")
 
%% ===================== COLOR SETUP =====================
figure
colors = lines(num_stations);
 
%% ===================== BASEBAND LPF ANALYSIS =====================
for k = 1:num_stations
 
    disp(["Testing baseband LPF for station ", num2str(k)])
 
    % -------- Carrier frequency --------
    Fc = config.Fc0 + (k-1)*config.deltaF;
 
    % -------- RF filter --------
    rf = rf_stage_filter(fdm,Fs,Fc);
 
    % -------- RF ? IF mixer --------
    f_LO = Fc + config.IF;
    mixed = mixer_stage(rf,Fs,f_LO);
 
    % -------- IF filter --------
    if_signal = if_stage_filter(mixed,Fs);
 
    % -------- IF ? Baseband mixer --------
    baseband = baseband_mixer(if_signal,Fs);
 
    % -------- Baseband LPF --------
    audio = baseband_lpf(baseband,Fs);
 
    % -------- FFT --------
    N = length(audio);
    f = (-N/2:N/2-1)*(Fs/N);
    X = fftshift(fft(audio));
    X = abs(X)/max(abs(X));
 
    % -------- Plot --------
    subplot(num_stations,1,k)
    plot(f/1000,X,'Color',colors(k,:),'LineWidth',1.5)
    title(sprintf("Recovered Audio Spectrum - Station %d",k))
    xlabel("Frequency (kHz)")
    ylabel("Normalized Magnitude")
    grid on
    xlim([-20 20])
 
end
 
sgtitle("Baseband LPF Verification - Recovered Audio Spectra")
%}

%{
%% ===================== TEST: DECIMATION =====================
% Purpose:
% Verify downsampling stage and recovery of audio at correct sampling rate.
 
disp("=== TEST: DECIMATION ===")
 
%% ===================== LOAD CONFIGURATION =====================
config = system_config();
 
%% ===================== LOAD + INTERPOLATE SIGNALS =====================
signals = load_signals();
signals = interpolate_signal(signals, config.L);
messages = signals.messages;
Fs = signals.Fs;
num_stations = length(messages);
fprintf("Number of stations loaded: %d\n",num_stations)
 
%% ===================== BUILD FDM SIGNAL =====================
fdm = build_fdm_signal(messages,Fs);
disp("FDM signal generated")
 
%% ===================== DECIMATION TEST PER STATION =====================
for k = 1:num_stations
 
    disp(["Testing decimation for station ", num2str(k)])
 
    % -------- Carrier frequency --------
    Fc = config.Fc0 + (k-1)*config.deltaF;
 
    % -------- RF filter --------
    rf = rf_stage_filter(fdm,Fs,Fc);
 
    % -------- RF ? IF mixer --------
    f_LO = Fc + config.IF;
    mixed = mixer_stage(rf,Fs,f_LO);
 
    % -------- IF filter --------
    if_signal = if_stage_filter(mixed,Fs);
 
    % -------- IF ? Baseband mixer --------
    baseband = baseband_mixer(if_signal,Fs);
 
    % -------- Baseband LPF --------
    audio_high = baseband_lpf(baseband,Fs);
 
    % -------- Prepare struct for decimation --------
    temp.signal = audio_high;
    temp.Fs = Fs;
 
    % -------- Decimation --------
    signals_out = decimate_signal(temp,config.L);
    audio = signals_out.signal;
    Fs_audio = signals_out.Fs;
 
    disp("Recovered sampling frequency: %d\n",Fs_audio)
 
    % -------- Audio playback --------
    sound(audio, Fs_audio)
    pause(5)   % allow audio playback before next station
 
    %saveas(gcf,"../results/test_decimation/station_"+k+"_decimated_audio.png")
end
%}

%{
%% ===================== TEST: SIGNAL QUALITY =====================
% Purpose:
% Quantitatively evaluate system performance by comparing original and
% recovered signals using alignment, scaling, and SNR computation.
 
clc
clear
close all
 
disp("=== TEST: SIGNAL QUALITY ===")
 
%% ===================== LOAD CONFIGURATION =====================
config = system_config();
 
%% ===================== LOAD ORIGINAL SIGNALS =====================
signals = load_signals();
original_messages = signals.messages;
Fs_original = signals.Fs;
num_stations = length(original_messages);
disp("Number of stations loaded:")
disp(num_stations)
 
%% ===================== INTERPOLATION =====================
signals = interpolate_signal(signals, config.L);
messages = signals.messages;
Fs = signals.Fs;
 
%% ===================== BUILD FDM SIGNAL =====================
fdm = build_fdm_signal(messages,Fs);
 
%% ===================== COLOR SETUP =====================
colors = lines(num_stations);
 
%% ===================== STORAGE =====================
recovered_all = cell(num_stations,1);
original_all  = cell(num_stations,1);
 
%% ===================== TIME DOMAIN COMPARISON =====================
figure
sgtitle("Original vs Recovered Signals")
 
for k = 1:num_stations
 
    disp(["Computing signal quality for station ", num2str(k)])
 
    original = original_messages{k};
 
    % -------- Carrier frequency --------
    Fc = config.Fc0 + (k-1)*config.deltaF;
 
    % -------- RF filter --------
    rf = rf_stage_filter(fdm,Fs,Fc);
 
    % -------- RF ? IF mixer --------
    f_LO = Fc + config.IF;
    mixed = mixer_stage(rf,Fs,f_LO);
 
    % -------- IF filter --------
    if_signal = if_stage_filter(mixed,Fs);
 
    % -------- IF ? Baseband mixer --------
    baseband = baseband_mixer(if_signal,Fs);
 
    % -------- Baseband LPF --------
    audio_high = baseband_lpf(baseband,Fs);
 
    % -------- Decimation --------
    temp.signal = audio_high;
    temp.Fs = Fs;
    signals_out = decimate_signal(temp,config.L);
    recovered = signals_out.signal;
    Fs_audio = signals_out.Fs;
 
    %% -------- ALIGNMENT (CROSS-CORRELATION) --------
    [c,lags] = xcorr(recovered, original);
    [~,idx] = max(abs(c));
    delay = lags(idx);
 
    if delay > 0
        recovered = recovered(delay+1:end);
    else
        original = original(-delay+1:end);
    end
 
    %% -------- FORCE SAME LENGTH --------
    min_len = min(length(original), length(recovered));
    original = original(1:min_len);
    recovered = recovered(1:min_len);
 
    %% -------- AMPLITUDE SCALING --------
    alpha = (original'*recovered)/(recovered'*recovered);
    recovered = alpha * recovered;
 
    %% -------- STORE --------
    original_all{k} = original;
    recovered_all{k} = recovered;
 
    %% -------- SNR COMPUTATION --------
    error_signal = original - recovered;
    signal_power = sum(original.^2);
    error_power = sum(error_signal.^2);
    SNR = 10*log10(signal_power/error_power);
 
    disp("Recovered audio sampling rate:")
    disp(Fs_audio)
    disp("Signal-to-Noise Ratio (dB):")
    disp(SNR)
 
    %% -------- PLOT --------
    subplot(num_stations,1,k)
    h1 = plot(original,'k','LineWidth',1.2);
    hold on
    h2 = plot(recovered,'r','LineWidth',1.2);
    grid on
    title(sprintf("Station %d",k))
    xlabel("Samples")
    ylabel("Amplitude")
    if k == 1
        legend([h1 h2],["Original","Recovered"])
    end
 
end
 
%% ===================== SPECTRUM COMPARISON =====================
figure
sgtitle("Original vs Recovered Spectrum")
 
for k = 1:num_stations
 
    original = original_all{k};
    recovered = recovered_all{k};
    N = length(original);
 
    %% -------- FFT --------
    Y_orig = fftshift(abs(fft(original)));
    Y_rec = fftshift(abs(fft(recovered)));
 
    %% -------- NORMALIZATION --------
    scale = max([Y_orig; Y_rec]);
    Y_orig = Y_orig / scale;
    Y_rec = Y_rec / scale;
 
    %% -------- FREQUENCY AXIS --------
    f = (-N/2:N/2-1)*(Fs_audio/N);
 
    %% -------- PLOT --------
    subplot(num_stations,1,k)
    h1 = plot(f/1000, Y_orig, 'k','LineWidth',1.2);
    hold on
    h2 = plot(f/1000, Y_rec, 'r','LineWidth',1.2);
    grid on
    title(sprintf("Station %d Spectrum",k))
    xlabel("Frequency (kHz)")
    ylabel("Normalized Magnitude")
    xlim([-10 10])
    if k == 1
        legend([h1 h2],["Original","Recovered"])
    end
 
end
%}

%{
%% ===================== TEST: AUDIO RECOVERY =====================
% Purpose:
% Verify full receiver chain by recovering and playing audio signals,
% and visually comparing original vs recovered waveforms.
 
disp("=== TEST: AUDIO RECOVERY ===")
 
%% ===================== LOAD CONFIGURATION =====================
config = system_config();
 
%% ===================== LOAD ORIGINAL SIGNALS =====================
signals = load_signals();
original_messages = signals.messages;
Fs_original = signals.Fs;
num_stations = length(original_messages);
disp("Number of stations loaded:")
disp(num_stations)
 
%% ===================== INTERPOLATION =====================
signals = interpolate_signal(signals, config.L);
messages = signals.messages;
Fs = signals.Fs;
 
%% ===================== BUILD FDM SIGNAL =====================
fdm = build_fdm_signal(messages,Fs);
 
%% ===================== COLOR SETUP =====================
colors = lines(num_stations);
 
%% ===================== AUDIO RECOVERY LOOP =====================
for k = 1:num_stations
 
    disp(["Recovering audio for station ", num2str(k)])
 
    original_signal = original_messages{k};
 
    % -------- Carrier frequency --------
    Fc = config.Fc0 + (k-1)*config.deltaF;
 
    % -------- RF filter --------
    rf = rf_stage_filter(fdm,Fs,Fc);
 
    % -------- RF ? IF mixer --------
    f_LO = Fc + config.IF;
    mixed = mixer_stage(rf,Fs,f_LO);
 
    % -------- IF filter --------
    if_signal = if_stage_filter(mixed,Fs);
 
    % -------- IF ? Baseband mixer --------
    baseband = baseband_mixer(if_signal,Fs);
 
    % -------- Baseband LPF --------
    recovered_audio = baseband_lpf(baseband,Fs);
 
    % -------- Normalize --------
    recovered_audio = recovered_audio / max(abs(recovered_audio));
 
    %% -------- Decimation --------
    temp.signal = recovered_audio;
    temp.Fs = Fs;
    signals_out = decimate_signal(temp,config.L);
    audio_play = signals_out.signal;
    Fs_audio = signals_out.Fs;
 
    %% -------- Playback --------
    disp("Playing recovered audio...")
    sound(audio_play, Fs_audio)
    pause(length(audio_play)/Fs_audio)
 
    %% -------- Visual Comparison --------
    figure
    subplot(2,1,1)
    plot(original_signal,'Color',colors(k,:))
    title(sprintf("Original Audio Signal - Station %d",k))
    subplot(2,1,2)
    plot(recovered_audio,'Color',colors(k,:))
    title(sprintf("Recovered Audio Signal - Station %d",k))
    % saveas(gcf,"../results/test_audio_recovery/station_"+k+"_comparison.png")
 
end
%}

%% =================== SYSTEM FUNCTIONS AND MODULES ===================

%% ================= CONFIGURATIONS FUNCTION =================
function config = system_config()
% Carrier base frequency
config.Fc0 = 100e3;
% Channel spacing
config.deltaF = 30e3;
% Intermediate frequency
config.IF = 15e3;
% Band Width
config.BW = 6e3;
% Selected station index
% 1 -> 100 kHz ..... % 2 -> 130 kHz .....
config.station = 1;
% Interpolation factor
config.L = 60;
% Frequency offsets
config.f1 = 0e3;
end

%% ================= LOADING THE SIGNALS =================
function signals = load_signals()

% Locate project root directory
this_file = mfilename('fullpath');
[src_folder,~,~] = fileparts(this_file);
project_root = src_folder;

% Define path
audio_folder = fullfile(project_root,"data","audio_files");

% Mapping:
% 1 -> Quran
% 2 -> Sky News
% 3 -> Russian Voice
% 4 -> FM9090
% 5 -> BBC Arabic

file_names = {
    "Short_QuranPalestine.wav"
    "Short_SkyNewsArabia.wav"
    "Short_RussianVoice.wav"
    "Short_FM9090.wav"
    "Short_BBCArabic2.wav"
};

num_signals = length(file_names);

messages = cell(1,num_signals);

for k = 1:num_signals

    filepath = fullfile(audio_folder, file_names{k});

    if ~isfile(filepath)
        error("File not found: %s", filepath)
    end

    [audio,Fs] = audioread(filepath);

    if size(audio,2) == 2
        audio = mean(audio,2);
    end

    messages{k} = audio;

end

signals.messages = messages;
signals.Fs = Fs;

end

%% ================= INTERPOLATION FUNCTION =================
function signals_out = interpolate_signal(signals_in, L)
% Extract input signals and original sampling frequency
messages = signals_in.messages;
Fs = signals_in.Fs;
% Determine number of signals
num_signals = length(messages);
% Preallocate cell array for interpolated signals
messages_interp = cell(1,num_signals);
% Process each signal individually
for k = 1:num_signals
    % Retrieve current signal
    signal = messages{k};
    % Define original discrete-time index
    old_time = (0:length(signal)-1)';
    % Define new time index with higher resolution
    new_time = (0:1/L:length(signal)-1)';
    % Perform linear interpolation
    signal_interp = interp1(old_time,signal,new_time,'linear');
    % Store interpolated signal
    messages_interp{k} = signal_interp;
end
% Store outputs in structured format
signals_out.messages = messages_interp;
% Update sampling frequency after interpolation
signals_out.Fs = L * Fs;
end

%% ================= MODULATION FUNCTION =================
function modulated_signal = dsb_sc_modulate(message, Fc, Fs)
    % Determine number of samples
    N = length(message);
    % Time axis
    t = (0:N-1)' / Fs;
    % Generate carrier
    carrier = cos(2*pi*Fc*t);
    % Perform DSB-SC modulation
    modulated_signal = message .* carrier;
end

%% ================= FDM FUNCTION =================
function fdm_signal = build_fdm_signal(messages, Fs)

% Load configuration
config = system_config();

% Determine number of stations
num_signals = length(messages);

% Define carrier parameters
base_carrier = config.Fc0;   % Carrier frequency of first station (100 kHz)
deltaF       = config.deltaF;    % Frequency spacing between stations

% Determine lengths of all message signals
lengths = zeros(num_signals,1);

for k = 1:num_signals
    lengths(k) = length(messages{k});
end

% Use the shortest signal length to ensure equal size
N = min(lengths);

% Initialize multiplexed FDM signal
fdm_signal = zeros(N,1);

% Loop through all stations
for n = 1:num_signals
    
    % Compute carrier frequency for the current station
    Fc = base_carrier + (n-1)*deltaF;
    
    % Truncate message to the common signal length
    signal = messages{n}(1:N);
    
    % Perform DSB-SC modulation
    modulated = dsb_sc_modulate(signal, Fc, Fs);
    
    % Add modulated signal to the multiplexed FDM signal
    fdm_signal = fdm_signal + modulated;
    
end

end


%% ================= RF FILTER FUNCTION =================
function rf_output = rf_stage_filter(signal, Fs, Fc)
   % Load system configuration parameters
   config = system_config();  
   % Required RF bandwidth (DSB signal occupies twice the message BW)
   BW = 2*config.BW;
   % Lower and upper band edges of the RF filter
   f1 = Fc - BW/2;
   f2 = Fc + BW/2;
   % FIR filter length
   N = 200;
   % Symmetric time index for impulse response
   n = -N/2:N/2;
   % Convert band edges to digital radian frequencies
   wc1 = 2*pi*f1/Fs;
   wc2 = 2*pi*f2/Fs;
   % Ideal band-pass filter impulse response
   h = (sin(wc2*n) - sin(wc1*n)) ./ (pi*n);
   % Correct the center sample to avoid division by zero
   h(N/2 + 1) = (wc2 - wc1)/pi;
   % Apply Hamming window to obtain a practical FIR filter
   k = 0:N;
   w = 0.54 - 0.46*cos(2*pi*k/N);
   h = h .* w;
   % Filter the RF signal
   rf_output = conv(signal, h, 'same');
end

%% ================= MIXER FUNCTION =================
function if_signal = mixer_stage(rf_signal, Fs, f_LO)
    % Load configuration
    config = system_config();

    % Determine number of samples
    N = length(rf_signal);

    % Generate time vector based on sampling frequency
    t = (0:N-1)' / Fs;

    % Generate local oscillator signal
    lo = cos(2*pi*(f_LO+config.f1)*t);

    % Perform mixing by multiplying RF signal with LO
    % This shifts the signal spectrum to new frequencies
    if_signal = rf_signal .* lo;

end

%% ================= IF STAGE FUNCTION =================
function if_output = if_stage_filter(signal, Fs)
    % Load system configuration parameters
    config = system_config();
    % Intermediate frequency center
    F_IF = config.IF;   
    % Required bandwidth (DSB signal)
    BW = 2*config.BW;
    % Lower and upper band edges
    f1 = F_IF - BW/2;
    f2 = F_IF + BW/2;
    % FIR filter order
    N = 200;
    % Symmetric index for impulse response
    n = -N/2:N/2;
    % Convert band edges to digital radian frequencies
    wc1 = 2*pi*f1/Fs;
    wc2 = 2*pi*f2/Fs;
    % Ideal band-pass filter impulse response
    h = (sin(wc2*n) - sin(wc1*n)) ./ (pi*n);
    % Fix center sample (avoid division by zero)
    h(N/2+1) = (wc2 - wc1)/pi;
    % Apply Hamming window for practical FIR filter
    k = 0:N;
    w = 0.54 - 0.46*cos(2*pi*k/N);
    h = h .* w;
    % Filter the IF signal
    if_output = conv(signal, h, 'same');
end


%% ================= BASEBAND MIXER FUNCTION =================
function baseband_signal = baseband_mixer(if_signal, Fs)
    % Load configuration
    config = system_config();
    % Intermediate frequency used in the receiver
    f_IF = config.IF;

    % Determine signal length
    N = length(if_signal);

    % Generate time axis
    t = (0:N-1)'/Fs;

    % Generate local oscillator at IF frequency
    lo = cos(2*pi*(f_IF + config.f1)*t);

    % Mix IF signal with local oscillator to shift it to baseband
    baseband_signal = if_signal .* lo;

end

%% ================= BP LPF FUNCTION =================
function audio_out = baseband_lpf(signal, Fs)
    % Load system configuration parameters
    config = system_config(); 
    % Audio bandwidth (baseband signal occupies BW)
    BW = config.BW;
    % FIR filter order
    N = 200;
    % Symmetric time index for impulse response
    n = -N/2:N/2;
    % Convert cutoff frequency to digital radian frequency
    wc = 2*pi*BW/Fs;
    % Ideal low-pass filter impulse response (sinc)
    h = sin(wc*n)./(pi*n);
    % Correct center sample to avoid division by zero
    h(N/2+1) = wc/pi;
    % Generate Hamming window
    k = 0:N;
    w = 0.54 - 0.46*cos(2*pi*k/N);
    % Apply window to obtain practical FIR filter
    h = h .* w;
    % Apply filter to recover baseband audio
    audio_out = conv(signal,h,'same');
end

%% ================= RECEIVER FULL SYSTEM FUNCTION =================
function audio = receiver_system(fdm_signal, Fs, config)
% Compute selected carrier frequency
Fc = config.Fc0 + (config.station-1)*config.deltaF;
% Compute local oscillator frequency
f_LO = Fc + config.IF;
% RF Stage
% Select desired station using band-pass filter
rf_signal = rf_stage_filter(fdm_signal, Fs, Fc);
% Mixer: convert RF → IF
mixed_signal = mixer_stage(rf_signal, Fs, f_LO);
% IF Stage Filter
if_signal = if_stage_filter(mixed_signal, Fs);
% Mixer: convert IF → baseband
baseband_signal = baseband_mixer(if_signal, Fs);
% Baseband Low-Pass Filter
% Recover audio band (0–5 kHz)
audio_high_rate = baseband_lpf(baseband_signal, Fs);
% Decimation
% Reduce sampling rate back to audio rate
temp.signal = audio_high_rate;
temp.Fs = Fs;
signals_out = decimate_signal(temp, config.L);
audio = signals_out.signal;
end

%% ================= DECIMATION FUNCTION =================
function signals_out = decimate_signal(signals_in, L)
% Extract signal and current sampling frequency
signal = signals_in.signal;
Fs     = signals_in.Fs;
% Downsample the signal by factor L
signal_decimated = signal(1:L:end);
% Update the sampling frequency
Fs_new = Fs / L;
% Store outputs in a structure
signals_out.signal = signal_decimated;
signals_out.Fs = Fs_new;
end

