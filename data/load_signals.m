function signals = load_signals()

    % read audio
    [raw_signal , sampling_frequency] = audioread('Short_QuranPalestine.wav');
	
    % convert to mono
    if size(raw_signal, 2) == 2
       mono_signal = mean(raw_signal, 2);
    else
       mono_signal = raw_signal;
    end
	
    % store in struct
	signals.signal = mono_signal;
	signals.Fs = sampling_frequency;

end
