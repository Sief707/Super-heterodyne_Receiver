clc
clear
close all

addpath(genpath(pwd))

disp("=======================================")
disp(" RUNNING SUPERHETERODYNE TEST SUITE ")
disp("=======================================")

tests = {
    "test_interpolation"
    "test_modulation"
    "test_rf_stage"
    "test_mixer_stage"
    "test_if_stage"
    "test_baseband_mixer"
    "test_baseband_lpf"
    "test_decimation"
    "test_audio_recovery"
    "test_signal_quality"
    "test_station_selection"
};

for k = 1:length(tests)

    test_name = tests{k};

    disp("---------------------------------------")
    disp("Running " + test_name)
    disp("---------------------------------------")

    close all

    run("tests/" + test_name + ".m")

end

disp("=======================================")
disp(" ALL TESTS COMPLETED SUCCESSFULLY ")
disp("=======================================")