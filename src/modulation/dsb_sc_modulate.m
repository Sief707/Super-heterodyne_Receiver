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