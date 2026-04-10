function baseband_signal = baseband_mixer(if_signal, Fs)
%% Load configuration
config = system_config();
    % Intermediate frequency used in the receiver
    f_IF = config.IF;

    % Determine signal length
    N = length(if_signal);

    % Generate time axis
    t = (0:N-1)'/Fs;

    % Generate local oscillator at IF frequency
    lo = cos(2*pi*(f_IF + config.f1)*t);

    % Mix IF signal with local oscillator to shift it to baseband
    baseband_signal = if_signal .* lo;

end