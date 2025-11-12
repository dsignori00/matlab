function trajectory = gen_speed_profile(trajectory, mu_vec)

    mux_acc_lap = mu_vec(:, 1);
    mux_dec_lap = mu_vec(:, 2);
    muy_lap = mu_vec(:, 3);

    % GLOBAL CONSTANTS
    global kLongSpeedMin; kLongSpeedMin = 5.0;
    global kLongSpeedMax; kLongSpeedMax = 100.0;
    global kDrag; kDrag = 0.000990566; %F175
    global kDownForce; kDownForce = 0.002333; %F175
    global g; g = 9.81;
    
    [~, max_idx] = max(abs(trajectory.k));

    x_lap = [trajectory.x(max_idx:end); trajectory.x(1:(max_idx-1))];
    y_lap = [trajectory.y(max_idx:end); trajectory.y(1:(max_idx-1))];
    rho_lap = [trajectory.k(max_idx:end); trajectory.k(1:(max_idx-1))];
    mux_acc_lap = [mux_acc_lap(max_idx:end); mux_acc_lap(1:(max_idx-1))];
    mux_dec_lap = [mux_dec_lap(max_idx:end); mux_dec_lap(1:(max_idx-1))];
    muy_lap = [muy_lap(max_idx:end); muy_lap(1:(max_idx-1))];
    n_lap = 2.0 * ones(size(rho_lap));
    vx_max = 100.0 * ones(size(rho_lap));

    [vx_ref] = Compute_vx_lap(rho_lap, mux_acc_lap, mux_dec_lap, muy_lap, vx_max, x_lap, y_lap, n_lap);

    s_padded = [0; cumsum(sqrt(diff([trajectory.x; trajectory.x(1)]).^2+diff([trajectory.y; trajectory.y(1)]).^2))];

    if isfield(trajectory, 's')
        trajectory.s = s_padded(1:end-1);
    end
    
    trajectory.vx_ref = [vx_ref((end-max_idx+2):end), vx_ref(1:(end-max_idx+1))]';

    v_padded = [trajectory.vx_ref; trajectory.vx_ref(1)];

    trajectory.ax = (v_padded(2:end).^2 - v_padded(1:end-1).^2) ./ 2 ./ diff(s_padded);

end