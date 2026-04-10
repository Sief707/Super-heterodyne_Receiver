function if_output = if_stage_filter(signal, Fs)
    % Load system configuration parameters
    config = system_config();
    % Intermediate frequency center
    F_IF = config.IF;   
    % Required bandwidth (DSB signal)
    BW = 2*config.BW;
    % Lower and upper band edges
    f1 = F_IF - BW/2;
    f2 = F_IF + BW/2;
    % FIR filter order
    N = 200;
    % Symmetric index for impulse response
    n = -N/2:N/2;
    % Convert band edges to digital radian frequencies
    wc1 = 2*pi*f1/Fs;
    wc2 = 2*pi*f2/Fs;
    % Ideal band-pass filter impulse response
    h = (sin(wc2*n) - sin(wc1*n)) ./ (pi*n);
    % Fix center sample (avoid division by zero)
    h(N/2+1) = (wc2 - wc1)/pi;
    % Apply Hamming window for practical FIR filter
    k = 0:N;
    w = 0.54 - 0.46*cos(2*pi*k/N);
    h = h .* w;
    % Filter the IF signal
    if_output = conv(signal, h, 'same');
end