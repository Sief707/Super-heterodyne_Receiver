function signals_out = decimate_signal(signals_in, L)

% -------------------------------------------------
% PURPOSE
% Reduce sampling rate after receiver processing
% Reverses the interpolation performed earlier
% -------------------------------------------------

% Extract signal and sampling frequency
signal = signals_in.signal;
Fs     = signals_in.Fs;

% Downsample signal
signal_decimated = signal(1:L:end);

% Update sampling frequency
Fs_new = Fs / L;

% Store results
signals_out.signal = signal_decimated;
signals_out.Fs = Fs_new;

end