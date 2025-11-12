h                   = figure('numbertitle', 'off');
h.Name              = "[Log" + i_log + "] Actuators: gears stability";
tcl                 = tiledlayout(4,1);
tcl.TileSpacing     = 'compact';
tcl.Padding         = 'compact';

% Compute gear shift patches

shifts = [0; diff(log.vehicle_fbk.current_gear)];
upshifts_patches = shifts > 0;
downshifts_patches = shifts < 0;
upshifts_patches_properties = {'FaceColor', colors.orange{2}, 'EdgeColor', colors.orange{2}, 'FaceAlpha', 0.3, 'HandleVisibility', 'off'};
downshifts_patches_properties = {'FaceColor', colors.red{2}, 'EdgeColor', colors.orange{2}, 'FaceAlpha', 0.3, 'HandleVisibility', 'off'};

% Speed

ax_time(end+1) = nexttile(1); hold on, legend show, grid on, box on;

ylabel('Speed [km/h]');
plot(log.estimation.bag_stamp, log.estimation.vx * 3.6, 'DisplayName', 'long speed');
plot_patches(log.vehicle_fbk.bag_stamp, upshifts_patches, ax_time(end), upshifts_patches_properties);
plot_patches(log.vehicle_fbk.bag_stamp, downshifts_patches, ax_time(end), downshifts_patches_properties);

% Acceleration

ax_time(end+1) = nexttile(2); hold on, legend show, grid on, box on;

ylabel('Acceleration [g]');
plot(log.estimation.bag_stamp, log.estimation.ax / 9.81, 'DisplayName', 'long');
plot(log.estimation.bag_stamp, log.estimation.ay / 9.81, 'DisplayName', 'lat');
plot_patches(log.vehicle_fbk.bag_stamp, upshifts_patches, ax_time(end), upshifts_patches_properties);
plot_patches(log.vehicle_fbk.bag_stamp, downshifts_patches, ax_time(end), downshifts_patches_properties);

% Yaw rate

ax_time(end+1) = nexttile(3); hold on, legend show, grid on, box on;

ylabel('Yaw rate [deg/s]');
plot(log.control__lateral__command.bag_stamp, 180/pi * log.control__lateral__command.yaw_rate_ref, 'DisplayName','ref');
plot(log.estimation.bag_stamp, 180/pi * log.estimation.yaw_rate, 'DisplayName','fbk');
plot(log.estimation.bag_stamp, 180/pi * log.estimation.yaw_rate_virtual, 'DisplayName', 'fbk virtual');
plot_patches(log.vehicle_fbk.bag_stamp, upshifts_patches, ax_time(end), upshifts_patches_properties);
plot_patches(log.vehicle_fbk.bag_stamp, downshifts_patches, ax_time(end), downshifts_patches_properties);

% Long. slip

ax_time(end+1) = nexttile(4); hold on, legend show, grid on, box on;

ylabel('Long. slip [$\%$]');
plot(log.estimation.bag_stamp, log.estimation.wheel_slips(:, 1)*100, 'DisplayName', 'FL');
plot(log.estimation.bag_stamp, log.estimation.wheel_slips(:, 2)*100, 'DisplayName', 'FR');
plot(log.estimation.bag_stamp, log.estimation.wheel_slips(:, 3)*100, 'DisplayName', 'RL');
plot(log.estimation.bag_stamp, log.estimation.wheel_slips(:, 4)*100, 'DisplayName', 'RR');
plot_patches(log.vehicle_fbk.bag_stamp, upshifts_patches, ax_time(end), upshifts_patches_properties);
plot_patches(log.vehicle_fbk.bag_stamp, downshifts_patches, ax_time(end), downshifts_patches_properties);

xlabel('Time [s]')