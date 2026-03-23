function fdm_signal = build_fdm_signal(messages, Fs)

    % Number of signals
    num_signals = length(messages);

    % Carrier parameters
    base_carrier = 100e3;
    deltaF       = 30e3;

    % Signal length
    N = length(messages{1});

    % Initialize FDM signal
    fdm_signal = zeros(N,1);

    for n = 1:num_signals
        
        Fc = base_carrier + (n-1)*deltaF;
        
        modulated = dsb_sc_modulate(messages{n}, Fc, Fs);
        
        fdm_signal = fdm_signal + modulated;
        
    end

end