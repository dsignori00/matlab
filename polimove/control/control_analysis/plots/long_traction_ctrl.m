h                   = figure('numbertitle', 'off');
h.Name              = "[Log" + i_log + "] Longitudinal: TC";
tcl                 = tiledlayout(5,1);
tcl.TileSpacing     = 'compact';
tcl.Padding         = 'compact';

% Activation

activation = logical(log.control__long__command.traction_control_flag);
patch_properties = {'FaceColor', colors.orange{2}, 'EdgeColor', colors.orange{2}, 'FaceAlpha', 0.3, 'DisplayName', 'TC active', 'HandleVisibility', 'off'};

% Yaw rate error

ax_time(end+1) = nexttile(1); hold on, legend show, grid on, box on;

ylabel('Yaw rate [deg/s]');
plot(log.control__lateral__command.bag_stamp, abs(log.control__lateral__command.yaw_rate-log.control__lateral__command.yaw_rate_ref) * 180/pi, 'DisplayName', 'yaw rate error');
plot_patches(log.control__long__command.bag_stamp, activation, ax_time(end), patch_properties);

% Sideslip

ax_time(end+1) = nexttile(2); hold on, legend show, grid on, box on;

ylabel('Slip angle [deg]');
plot(log.estimation.bag_stamp, log.estimation.beta * 180/pi, 'DisplayName', 'beta');
plot_patches(log.control__long__command.bag_stamp, activation, ax_time(end), patch_properties);

% Front wheel slip angles

ax_time(end+1) = nexttile(3); hold on, legend show, grid on, box on;
ylabel('Slip angle [deg]');
plot(log.estimation.bag_stamp, log.estimation.alpha(:,1) * 180/pi, 'DisplayName', 'FL');
plot(log.estimation.bag_stamp, log.estimation.alpha(:,2) * 180/pi, 'DisplayName', 'FR');
plot(log.estimation.bag_stamp, log.estimation.alpha(:,3) * 180/pi, 'DisplayName', 'RL');
plot(log.estimation.bag_stamp, log.estimation.alpha(:,4) * 180/pi, 'DisplayName', 'RR');
plot_patches(log.control__long__command.bag_stamp, activation, ax_time(end), patch_properties);

% Longitudinal slip

ax_time(end+1) = nexttile(4); hold on, legend show, grid on, box on;

ylabel('Long. slip [$\%$]');
plot(log.estimation.bag_stamp, log.estimation.wheel_slips(:, 1) * 100, 'DisplayName', 'FL');
plot(log.estimation.bag_stamp, log.estimation.wheel_slips(:, 2) * 100, 'DisplayName', 'FR');
plot(log.estimation.bag_stamp, log.estimation.wheel_slips(:, 3) * 100, 'DisplayName', 'RL');
plot(log.estimation.bag_stamp, log.estimation.wheel_slips(:, 4) * 100, 'DisplayName', 'RR');
plot_patches(log.control__long__command.bag_stamp, activation, ax_time(end), patch_properties);

% Throttle

ax_time(end+1) = nexttile(5); hold on, legend show, grid on, box on;

ylabel('Throttle [-]');
plot(log.control__long__command.bag_stamp, log.control__long__command.throttle, 'DisplayName', 'throttle');
plot_patches(log.control__long__command.bag_stamp, activation, ax_time(end:end), patch_properties);

xlabel('Time [s]')
