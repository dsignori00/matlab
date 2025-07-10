h                   = figure('numbertitle', 'off');
h.Name              = "[Log" + i_log + "] Lateral: lat. error";
tcl                 = tiledlayout(2,1);
tcl.TileSpacing     = 'compact';
tcl.Padding         = 'compact';

matlab_colors = colororder;

% Lateral error

ax_time(end+1) = nexttile(1); hold on, legend show, grid on, box on;

ylabel('Lat. error [m]');
plot(log.control__lateral__command.bag_stamp, log.control__lateral__command.lat_error,      'DisplayName','lateral error');
plot(log.control__lateral__command.bag_stamp, log.control__lateral__command.lat_error_filt, 'DisplayName','lateral error filt');

% Yaw rate

ax_time(end+1) = nexttile(2); hold on, legend show, grid on, box on;

ylabel('Yaw rate [deg/s]');
plot(log.control__lateral__command.bag_stamp, 180/pi * log.control__lateral__command.yaw_rate_ref_prev, '--', 'Color', matlab_colors(3,:), 'DisplayName','prev internal');
plot(log.control__lateral__command.bag_stamp, 180/pi * log.control__lateral__command.yaw_rate_ref,            'Color', matlab_colors(1,:), 'DisplayName','ref');
plot(log.estimation.bag_stamp,                180/pi * log.estimation.yaw_rate,                               'Color', matlab_colors(2,:), 'DisplayName','fbk');
yawrate_min_plot = plot(log.control__lateral__command.bag_stamp, log.control__lateral__command.yaw_rate_min * 180/pi, 'Color', 'k', 'DisplayName','min');
yawrate_max_plot = plot(log.control__lateral__command.bag_stamp, log.control__lateral__command.yaw_rate_max * 180/pi, 'Color', 'k', 'DisplayName','max');
uistack(yawrate_min_plot, 'bottom');
uistack(yawrate_max_plot, 'bottom');

xlabel('Time [s]')
