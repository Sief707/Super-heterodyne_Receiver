function signals = load_signals()

% -------------------------------------------------
% LOAD SIGNALS
%
% Automatically loads all audio stations located in
% data/audio_files/
% -------------------------------------------------

files = dir("data/audio_files/*.wav");

num_signals = length(files);

messages = cell(1,num_signals);

for k = 1:num_signals
    
    filepath = fullfile(files(k).folder, files(k).name);

    [audio, Fs] = audioread(filepath);

    % convert stereo → mono
    if size(audio,2) == 2
        audio = mean(audio,2);
    end

    messages{k} = audio;

end

signals.messages = messages;
signals.Fs = Fs;

end