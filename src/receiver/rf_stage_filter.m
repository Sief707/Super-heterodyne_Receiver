function rf_output = rf_stage_filter(signal, Fs, Fc)
   % Load system configuration parameters
   config = system_config();  
   % Required RF bandwidth (DSB signal occupies twice the message BW)
   BW = 2*config.BW;
   % Lower and upper band edges of the RF filter
   f1 = Fc - BW/2;
   f2 = Fc + BW/2;
   % FIR filter length
   N = 200;
   % Symmetric time index for impulse response
   n = -N/2:N/2;
   % Convert band edges to digital radian frequencies
   wc1 = 2*pi*f1/Fs;
   wc2 = 2*pi*f2/Fs;
   % Ideal band-pass filter impulse response
   h = (sin(wc2*n) - sin(wc1*n)) ./ (pi*n);
   % Correct the center sample to avoid division by zero
   h(N/2 + 1) = (wc2 - wc1)/pi;
   % Apply Hamming window to obtain a practical FIR filter
   k = 0:N;
   w = 0.54 - 0.46*cos(2*pi*k/N);
   h = h .* w;
   % Filter the RF signal
   rf_output = conv(signal, h, 'same');
end