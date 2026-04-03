function if_output = if_stage_filter(signal, Fs)

    % IF center frequency
    Fc = 15e3;

    % Bandwidth
    BW = 5e3;

    % Band edges
    f1 = Fc - BW/2;
    f2 = Fc + BW/2;

    % Filter order
    N = 200;

    % Time index
    n = -N/2:N/2;

    % Digital frequencies
    wc1 = 2*pi*f1/Fs;
    wc2 = 2*pi*f2/Fs;

    % Ideal bandpass response
    h = (sin(wc2*n) - sin(wc1*n)) ./ (pi*n);
    h(N/2+1) = (wc2 - wc1)/pi;

    % Manual Hamming window
    k = 0:N;
    w = 0.54 - 0.46*cos(2*pi*k/N);

    h = h .* w;

    % Apply filter
    if_output = conv(signal, h, 'same');

end