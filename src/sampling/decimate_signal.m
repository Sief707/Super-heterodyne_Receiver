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