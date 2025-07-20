LOW_PASS_FREQ = 10; % [Hz]
LAP_TIME_MIN = 100; % [s]
LAP_TIME_MAX = 150; % [s]
s = tf('s');
lowpass_filt = 1 / (s/(2*pi*LOW_PASS_FREQ) + 1);
derivative_filt = s / (s/(2*pi*LOW_PASS_FREQ) + 1);