function signals = load_signals()

% Locate project root directory (parent of source folder)
this_file = mfilename('fullpath');
[src_folder,~,~] = fileparts(this_file);
project_root = fileparts(src_folder);

% Define path to audio signals directory
audio_folder = fullfile(project_root,"data","audio_files");

% Retrieve all WAV files from the directory
files = dir(fullfile(audio_folder,"*.wav"));

% Stop execution if no audio files are found
if isempty(files)
    error("No .wav files found in %s",audio_folder)
end

% Determine number of input signals
num_signals = length(files);

% Preallocate cell array to store audio messages
messages = cell(1,num_signals);

% Read each audio file and process it
for k = 1:num_signals

    % Construct full file path
    filepath = fullfile(files(k).folder,files(k).name);

    % Read audio signal and sampling frequency
    [audio,Fs] = audioread(filepath);

    % Convert stereo signals to mono by averaging channels
    if size(audio,2) == 2
        audio = mean(audio,2);
    end

    % Store processed signal
    messages{k} = audio;

end

% Store outputs in structured format
signals.messages = messages;
signals.Fs = Fs;

end