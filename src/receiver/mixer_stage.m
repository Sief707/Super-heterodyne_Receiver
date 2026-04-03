function if_signal = mixer_stage(rf_signal, Fs, f_LO)

    % Number of samples
    N = length(rf_signal);

    % Time vector
    t = (0:N-1)' / Fs;

    % Local oscillator
    lo = cos(2*pi*f_LO*t);

    % Mixing (multiplication)
    if_signal = rf_signal .* lo;

end