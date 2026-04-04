clc
clear
close all

disp("=== TEST: STATION SELECTION ===")

config = system_config();

signals = load_signals();
signals = interpolate_signal(signals, config.L);

messages = signals.messages;
Fs = signals.Fs;

fdm = build_fdm_signal(messages, Fs);

num_stations = length(messages);

for k = 1:num_stations
    
    fprintf("\nReceiving station %d\n", k)

    config.station = k;

    audio = receiver_system(fdm, Fs, config);

    audio = audio / max(abs(audio));

    Fs_audio = Fs/config.L;

    sound(audio, Fs_audio)

    pause(5)

end