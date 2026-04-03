function fdm_signal = build_fdm_signal(messages, Fs)

% -------------------------------------------------
% BUILD FDM SIGNAL
%
% Combines multiple modulated stations into a
% single multiplexed RF signal.
%
% Inputs
% -------
% messages{k} : baseband audio signals
% Fs          : sampling frequency
%
% Output
% -------
% fdm_signal  : multiplexed RF signal
% -------------------------------------------------

% Number of stations
num_signals = length(messages);

% Carrier parameters
base_carrier = 100e3;
deltaF       = 30e3;

% -------------------------------------------------
% Determine common signal length
% -------------------------------------------------

lengths = zeros(num_signals,1);

for k = 1:num_signals
    lengths(k) = length(messages{k});
end

N = min(lengths);   % shortest signal

% -------------------------------------------------
% Initialize multiplexed signal
% -------------------------------------------------

fdm_signal = zeros(N,1);

% -------------------------------------------------
% Modulate and combine each station
% -------------------------------------------------

for n = 1:num_signals
    
    % Carrier frequency of station
    Fc = base_carrier + (n-1)*deltaF;
    
    % Truncate signal to common length
    signal = messages{n}(1:N);
    
    % DSB-SC modulation
    modulated = dsb_sc_modulate(signal, Fc, Fs);
    
    % Add to multiplexed signal
    fdm_signal = fdm_signal + modulated;
    
end

end