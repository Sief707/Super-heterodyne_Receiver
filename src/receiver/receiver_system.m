function audio = receiver_system(fdm_signal, Fs, config)
% Compute selected carrier frequency
Fc = config.Fc0 + (config.station-1)*config.deltaF;
% Compute local oscillator frequency
f_LO = Fc + config.IF;
% RF Stage
% Select desired station using band-pass filter
rf_signal = rf_stage_filter(fdm_signal, Fs, Fc);
% Mixer: convert RF → IF
mixed_signal = mixer_stage(rf_signal, Fs, f_LO);
% IF Stage Filter
if_signal = if_stage_filter(mixed_signal, Fs);
% Mixer: convert IF → baseband
baseband_signal = baseband_mixer(if_signal, Fs);
% Baseband Low-Pass Filter
% Recover audio band (0–5 kHz)
audio_high_rate = baseband_lpf(baseband_signal, Fs);
% Decimation
% Reduce sampling rate back to audio rate
temp.signal = audio_high_rate;
temp.Fs = Fs;
signals_out = decimate_signal(temp, config.L);
audio = signals_out.signal;
end