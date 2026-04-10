function if_signal = mixer_stage(rf_signal, Fs, f_LO)

    % Determine number of samples
    N = length(rf_signal);

    % Generate time vector based on sampling frequency
    t = (0:N-1)' / Fs;

    % Generate local oscillator signal
    lo = cos(2*pi*f_LO*t);

    % Perform mixing by multiplying RF signal with LO
    % This shifts the signal spectrum to new frequencies
    if_signal = rf_signal .* lo;

end