function fdm_signal = build_fdm_signal(messages, Fs)

% Load configuration
config = system_config();

% Determine number of stations
num_signals = length(messages);

% Define carrier parameters
base_carrier = config.Fc0;   % Carrier frequency of first station (100 kHz)
deltaF       = config.deltaF;    % Frequency spacing between stations

% Determine lengths of all message signals
lengths = zeros(num_signals,1);

for k = 1:num_signals
    lengths(k) = length(messages{k});
end

% Use the shortest signal length to ensure equal size
N = min(lengths);

% Initialize multiplexed FDM signal
fdm_signal = zeros(N,1);

% Loop through all stations
for n = 1:num_signals
    
    % Compute carrier frequency for the current station
    Fc = base_carrier + (n-1)*deltaF;
    
    % Truncate message to the common signal length
    signal = messages{n}(1:N);
    
    % Perform DSB-SC modulation
    modulated = dsb_sc_modulate(signal, Fc, Fs);
    
    % Add modulated signal to the multiplexed FDM signal
    fdm_signal = fdm_signal + modulated;
    
end

end