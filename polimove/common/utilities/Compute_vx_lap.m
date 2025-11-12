function [vx_lap_ref] = compute_vx_lap(rho_lap, mux_acc_lap, mux_dec_lap, muy_lap, vx_max_lap, x_lap, y_lap, n_lap)

lap_len = length(x_lap);

rho_1 = rho_lap(1);
mux_acc = mux_acc_lap(1);
muy = muy_lap(1);

vx_lap_ref(1) = VehicleLimitsLongSpeedMax(rho_1, mux_acc, muy);

%% ADD ACCELERATION LIMITS (FORWARD PASS)
for i=1:1:(lap_len - 1)
    x_prev = x_lap(i);
    y_prev = y_lap(i);
    rho_prev = rho_lap(i);
    mux_acc_prev = mux_acc_lap(i);
    muy_prev = muy_lap(i);
    vx_prev_ref = vx_lap_ref(i);
    n_prev = n_lap(i);

    x_curr = x_lap(i+1);
    y_curr = y_lap(i+1);
    rho_curr = rho_lap(i+1);
    mux_acc_curr = mux_acc_lap(i+1);
    muy_curr = muy_lap(i+1);
    vx_max = vx_max_lap(i+1);

    s_step = sqrt((x_curr - x_prev)^2 + (y_curr - y_prev)^2);

    % vx_ref
    vx_guess = VehicleLimitsLongSpeedMax(rho_curr, mux_acc_curr, muy_curr);
    vx_guess = min(vx_guess, vx_max);

    vx_dot_f = VehicleLimitsLongAccMax(rho_prev, vx_lap_ref(i), mux_acc_prev, muy_prev, n_prev);
    vx_curr_squared = vx_prev_ref * vx_prev_ref + 2.0 * vx_dot_f * s_step;
    vx_curr_squared = max(0.0, vx_curr_squared);
    vx_curr = sqrt(vx_curr_squared);
    vx_lap_ref(i+1) = min(vx_guess, vx_curr);
end

%% ADD DECELERATION LIMITS (BACKWARD PASS)
for i=lap_len:-1:2
    x_curr = x_lap(i);
    y_curr = y_lap(i);
    rho_curr = rho_lap(i);
    mux_dec_curr = mux_dec_lap(i);
    muy_curr = muy_lap(i);
    vx_curr_ref = vx_lap_ref(i);
    n_curr = n_lap(i);

    x_prev = x_lap(i-1);
    y_prev = y_lap(i-1);

    s_step = sqrt((x_curr - x_prev)^2 + (y_curr - y_prev)^2);

    % vx_ref 
    vx_dot_b = VehicleLimitsLongAccMin(rho_curr, vx_curr_ref, mux_dec_curr, muy_curr, n_curr);
    vx_prev_squared = vx_curr_ref * vx_curr_ref - 2.0 * vx_dot_b * s_step;
    vx_prev_squared = max(0.0, vx_prev_squared);
    vx_prev = sqrt(vx_prev_squared);
    vx_lap_ref(i-1) = min(vx_lap_ref(i-1), vx_prev);
end

end

