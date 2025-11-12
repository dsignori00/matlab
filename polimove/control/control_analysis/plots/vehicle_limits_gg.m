h                   = figure('numbertitle', 'off');
h.Name              = "[Log" + i_log + "] Vehicle limits GG";
tcl                 = tiledlayout(1,1);
tcl.TileSpacing     = 'compact';
tcl.Padding         = 'compact';

% Compute ellipse constraint

MUX_ACC_GAIN = 0.5;
MUX_DEC_GAIN = 1.0;
MUY = 1.0;

g = 9.81;

t = log.estimation.bag_stamp;
v = log.estimation.vx;
bank = log.estimation.roll;
 
ax_meas_tire = log.estimation.ax + k_drag * v.^2;
ay_meas_tire = log.estimation.ay;

ax_ref_tire = interp1(log.control__long__command.bag_stamp, log.control__long__command.speed_ctrl_acc_ref, t) + k_drag * v.^2;
% ax_ref_tire = interp1(log.control__long__command.bag_stamp, log.control__long__command.long_acc_ref, t) + k_drag * v.^2;
ay_ref_tire = interp1(log.control__lateral__command.bag_stamp, log.control__lateral__command.yaw_rate_ref, t) .* log.estimation.vx + g * sin(bank);

[ax_meas_norm, ay_meas_norm] = compute_normalized_accelerations(v, ax_meas_tire, ay_meas_tire, bank, k_downforce);
[ax_ref_norm, ay_ref_norm] = compute_normalized_accelerations(v, ax_ref_tire, ay_ref_tire, bank, k_downforce);

mux_acc = MUX_ACC_GAIN * interp1(log.local_planner.bag_stamp, log.local_planner.mux_acc_gain_feas, t, 'previous');
mux_dec = MUX_DEC_GAIN * interp1(log.local_planner.bag_stamp, log.local_planner.mux_dec_gain_feas, t, 'previous');
muy     = MUY * interp1(log.local_planner.bag_stamp, log.local_planner.muy_gain_feas, t, 'previous');

exp_ellipse_acc = interp1(log.local_planner.bag_stamp, log.local_planner.exp_ellipse_acc, t, 'previous');
exp_ellipse_dec = interp1(log.local_planner.bag_stamp, log.local_planner.exp_ellipse_dec, t, 'previous');

% Find unique mu/ellipse setting (remove NaNs)
mu_unique = unique([mux_acc mux_dec muy exp_ellipse_acc exp_ellipse_dec], 'rows');
mu_unique(any(isnan(mu_unique), 2), :) = [];

% Plot constraint

ax_mu(end+1) = nexttile(1); hold on, legend show, grid on, box on; axis equal;

xlabel('');
ylabel('');

% Plot each ellipse config
for i = 1 : size(mu_unique, 1)
    % Plot ellipse
    mux_acc         = mu_unique(i, 1);
    mux_dec         = mu_unique(i, 2);
    muy             = mu_unique(i, 3);
    exp_ellipse_acc = mu_unique(i, 4);
    exp_ellipse_dec = mu_unique(i, 5);

    % Number of points for plotting
    N = 500;
    
    % Parametric angle range
    theta = linspace(-pi, pi, N);
    
    % Allocate space
    x = zeros(size(theta));
    y = zeros(size(theta));
    
    % Loop through angles and compute points
    for k = 1:N
        angle = theta(k);
        cos_t = cos(angle);
        sin_t = sin(angle);
    
        % Choose exponent based on y sign
        if sin_t >= 0
            e = exp_ellipse_acc;
            a = muy;         % horizontal radius
            b = mux_acc;     % vertical radius (top)
        else
            e = exp_ellipse_dec;
            a = muy;
            b = mux_dec;     % vertical radius (bottom)
        end
    
        x(k) = sign(cos_t) * a * abs(cos_t)^(2/e);
        y(k) = sign(sin_t) * b * abs(sin_t)^(2/e);
    end

    plot(x, y, 'k', 'DisplayName', 'limits', 'HandleVisibility', 'off')
end

scatter(-ay_meas_norm, ax_meas_norm, 10, t, 'filled', 'DisplayName', 'meas')
% scatter(-ay_ref_norm, ax_ref_norm, 10, 'filled', 'DisplayName', 'ref')

xlabel('Time [s]')


%% Auxiliary function

function [ax_norm, ay_norm] = compute_normalized_accelerations(v, ax_tire, ay_tire, bank, k_downforce)

g = 9.81;

% TODO check
Fz = g * cos(bank) - (ay_tire - 0 * g * sin(bank)) .* sin(bank) + k_downforce * v.^2;

ax_norm = ax_tire ./ Fz;
ay_norm = ay_tire ./ Fz;

end