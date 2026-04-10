function audio_out = baseband_lpf(signal, Fs)
    % Load system configuration parameters
    config = system_config(); 
    % Audio bandwidth (baseband signal occupies BW)
    BW = config.BW;
    % FIR filter order
    N = 200;
    % Symmetric time index for impulse response
    n = -N/2:N/2;
    % Convert cutoff frequency to digital radian frequency
    wc = 2*pi*BW/Fs;
    % Ideal low-pass filter impulse response (sinc)
    h = sin(wc*n)./(pi*n);
    % Correct center sample to avoid division by zero
    h(N/2+1) = wc/pi;
    % Generate Hamming window
    k = 0:N;
    w = 0.54 - 0.46*cos(2*pi*k/N);
    % Apply window to obtain practical FIR filter
    h = h .* w;
    % Apply filter to recover baseband audio
    audio_out = conv(signal,h,'same');
end