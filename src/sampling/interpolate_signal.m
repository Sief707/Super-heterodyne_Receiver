function signals_out = interpolate_signal(signals_in, L)

    % Extract input data
    signal = signals_in.signal;
    Fs     = signals_in.Fs;
    
    % Creating old time coordinates
    old_time_axis = (0:length(signal)-1)';
    
    % Creating new time coordinates
    new_time_axis = (0 : 1/L : length(signal)-1)';

    % Applying interpolation
    interpolated_signal = interp1(old_time_axis, signal, new_time_axis, 'linear');

    % Store outputs
    signals_out.signal = interpolated_signal;
    signals_out.Fs     = L * Fs;

end