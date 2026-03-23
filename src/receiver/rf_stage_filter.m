function rf_output = rf_stage_filter(signal, Fs, Fc)

    % Desired bandwidth
    BW = 10e3;

    % Band edges
    f1 = Fc - BW/2;
    f2 = Fc + BW/2;

    % Filter length
    N = 200;

    % Time index
    n = -N/2:N/2;

    % Convert to digital radian frequencies
    wc1 = 2*pi*f1/Fs;
    wc2 = 2*pi*f2/Fs;

    % Ideal band-pass impulse response
    h = (sin(wc2*n) - sin(wc1*n)) ./ (pi*n);

    % Fix center sample
    h(N/2 + 1) = (wc2 - wc1)/pi;

    % ----- Manual Hamming Window -----
    k = 0:N;
    w = 0.54 - 0.46*cos(2*pi*k/N);

    h = h .* w;

    % Apply filter
    rf_output = conv(signal, h, 'same');

end