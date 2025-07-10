h                   = figure('numbertitle', 'off');
h.Name              = "[Log" + i_log + "] Lateral: yaw rate";
tcl                 = tiledlayout(2,1);
tcl.TileSpacing     = 'compact';
tcl.Padding         = 'compact';

matlab_colors = colororder;

% Yaw rate

ax_time(end+1) = nexttile(1); hold on, legend show, grid on, box on;

ylabel('Yaw rate [deg/s]');

plot(log.control__lateral__command.bag_stamp, 180/pi * log.control__lateral__command.yaw_rate_ref, 'DisplayName','ref');
plot(log.estimation.bag_stamp,                180/pi * log.estimation.yaw_rate,                    'DisplayName','fbk');
yawrate_min_plot = plot(log.control__lateral__command.bag_stamp, log.control__lateral__command.yaw_rate_min * 180/pi, 'Color', 'k', 'DisplayName','min');
yawrate_max_plot = plot(log.control__lateral__command.bag_stamp, log.control__lateral__command.yaw_rate_max * 180/pi, 'Color', 'k', 'DisplayName','max');
uistack(yawrate_min_plot, 'bottom');
uistack(yawrate_max_plot, 'bottom');

% Steer

ax_time(end+1) = nexttile(2); hold on, legend show, grid on, box on;

ylabel('Steer angle [deg]');

plot(log.control__lateral__command.bag_stamp, 180/pi * log.control__lateral__command.steer_angle_manual,   'Color', matlab_colors(3,:), 'DisplayName','cmd manual');
plot(log.control__lateral__command.bag_stamp, 180/pi * log.control__lateral__command.steer_angle_lead_lag, 'Color', matlab_colors(4,:), 'DisplayName','cmd lead lag');
plot(log.control__lateral__command.bag_stamp, 180/pi * log.control__lateral__command.steer_angle_fb,       'Color', matlab_colors(5,:), 'DisplayName','cmd fb');
plot(log.control__lateral__command.bag_stamp, 180/pi * log.control__lateral__command.steer_angle_ff,       'Color', matlab_colors(6,:), 'DisplayName','cmd ff');
plot(log.control__lateral__command.bag_stamp, 180/pi * log.control__lateral__command.steer_angle,          'Color', matlab_colors(1,:), 'DisplayName','cmd');
plot(log.vehicle_fbk.bag_stamp, 180/pi * log.vehicle_fbk.steering_wheel_angle,                             'Color', matlab_colors(2,:), 'DisplayName','fbk');
steer_min_plot = plot(log.control__lateral__command.bag_stamp, 180/pi * log.control__lateral__command.steer_angle_min, 'Color', 'k', 'DisplayName','min');
steer_max_plot = plot(log.control__lateral__command.bag_stamp, 180/pi * log.control__lateral__command.steer_angle_max, 'Color', 'k', 'DisplayName','max');
uistack(steer_min_plot, 'bottom');
uistack(steer_max_plot, 'bottom');

xlabel('Time [s]')