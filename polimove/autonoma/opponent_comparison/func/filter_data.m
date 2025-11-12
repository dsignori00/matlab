function best_lap = filter_data(best_lap, lowpass_filt, derivative_filt, Ts)

    LOW_PASS_FREQ = lowpass_filt.Numerator{:}(2) / 2 / pi;

    d_deriv = designfilt('differentiatorfir', 'FilterOrder', 50, 'PassbandFrequency', 10, 'StopbandFrequency', 15, 'SampleRate', 1/Ts);

    N_samples = length(best_lap.x);
    N_cut = floor(1/(Ts*LOW_PASS_FREQ))*3;
    
    t_vec = 0:Ts:((N_samples-1)*Ts);
    
    x_filt = lsim(lowpass_filt, best_lap.x, t_vec);
    y_filt = lsim(lowpass_filt, best_lap.y, t_vec);
    v_filt = lsim(lowpass_filt, best_lap.v, t_vec);
    yaw_filt = lsim(lowpass_filt, best_lap.yaw, t_vec);
    ax = lsim(derivative_filt, best_lap.v, t_vec);
    ax = filter(d_deriv, best_lap.v) ./ Ts;
    
    % best_lap.t_vec_filt = t_vec(N_cut:end).';
    % best_lap.x_filt = x_filt(N_cut:end);
    % best_lap.y_filt = y_filt(N_cut:end);
    % best_lap.v_filt = v_filt(N_cut:end);
    % best_lap.yaw_filt = yaw_filt(N_cut:end);
    % best_lap.ax = ax(N_cut:end);

    best_lap.t_vec_filt = t_vec.';
    best_lap.x_filt = best_lap.x;
    best_lap.y_filt = best_lap.y;
    best_lap.v_filt = best_lap.v;
    best_lap.yaw_filt = best_lap.yaw;
    best_lap.ax = [ones(50, 1).*ax(51); ax(51:end)];

end

