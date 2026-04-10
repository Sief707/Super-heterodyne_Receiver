function signals_out = interpolate_signal(signals_in, L)
% Extract input signals and original sampling frequency
messages = signals_in.messages;
Fs = signals_in.Fs;
% Determine number of signals
num_signals = length(messages);
% Preallocate cell array for interpolated signals
messages_interp = cell(1,num_signals);
% Process each signal individually
for k = 1:num_signals
    % Retrieve current signal
    signal = messages{k};
    % Define original discrete-time index
    old_time = (0:length(signal)-1)';
    % Define new time index with higher resolution
    new_time = (0:1/L:length(signal)-1)';
    % Perform linear interpolation
    signal_interp = interp1(old_time,signal,new_time,'linear');
    % Store interpolated signal
    messages_interp{k} = signal_interp;
end
% Store outputs in structured format
signals_out.messages = messages_interp;
% Update sampling frequency after interpolation
signals_out.Fs = L * Fs;
end