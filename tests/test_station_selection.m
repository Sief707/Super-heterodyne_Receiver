
disp("=== TEST: STATION SELECTION ===")

config = system_config();

signals = load_signals();
signals = interpolate_signal(signals, config.L);

messages = signals.messages;
Fs = signals.Fs;

fdm = build_fdm_signal(messages, Fs);

num_stations = length(messages);

disp("Number of stations loaded:")
disp(num_stations)

for k = 1:num_stations
    
    fprintf("\nReceiving station %d\n", k)

    % Tune receiver
    config.station = k;

    % Run receiver
    audio = receiver_system(fdm, Fs, config);

    % Normalize audio
    audio = audio / max(abs(audio));

    Fs_audio = Fs/config.L;

    % Play recovered audio
    sound(audio, Fs_audio)

    pause(length(audio)/Fs_audio)

end

disp("Station selection test completed successfully")