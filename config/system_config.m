function config = system_config()
% Carrier base frequency
config.Fc0 = 100e3;
% Channel spacing
config.deltaF = 30e3;
% Intermediate frequency
config.IF = 15e3;
% Band Width
config.BW = 6e3;
% Selected station index
% 1 -> 100 kHz ..... % 2 -> 130 kHz .....
config.station = 1;
% Interpolation factor
config.L = 60;
% Frequency offsets
config.f1 = 0e3;
end