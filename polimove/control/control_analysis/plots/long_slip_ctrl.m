h                   = figure('numbertitle', 'off');
h.Name              = "[Log" + i_log + "] Longitudinal: slip";
tcl                 = tiledlayout(3,1);
tcl.TileSpacing     = 'compact';
tcl.Padding         = 'compact';

% Compute gear shift patches

shifts = [0; diff(log.vehicle_fbk.current_gear)];
upshifts_patches = shifts > 0;
downshifts_patches = shifts < 0;
upshifts_patches_properties = {'FaceColor', colors.orange{2}, 'EdgeColor', colors.orange{2}, 'FaceAlpha', 0.3, 'HandleVisibility', 'off'};
downshifts_patches_properties = {'FaceColor', colors.red{2}, 'EdgeColor', colors.orange{2}, 'FaceAlpha', 0.3, 'HandleVisibility', 'off'};

% Throttle and brake

ax_time(end+1) = nexttile(1); hold on, legend show, grid on, box on;

ylabel('Throttle - Brake [\%-bar]');

plot(log.control__long__command.bag_stamp, log.control__long__command.throttle * 100, 'DisplayName', 'throttle');
plot(log.control__long__command.bag_stamp, log.control__long__command.brake * 1e-5,   'DisplayName', 'brake');

plot_patches(log.vehicle_fbk.bag_stamp, upshifts_patches, ax_time(end), upshifts_patches_properties);
plot_patches(log.vehicle_fbk.bag_stamp, downshifts_patches, ax_time(end), downshifts_patches_properties);

% Longitudinal slip

ax_time(end+1) = nexttile(2); hold on, legend show, grid on, box on;

ylabel('Long. slip [$\%$]');
plot(log.estimation.bag_stamp, log.estimation.wheel_slips(:, 1) * 100, 'DisplayName', 'FL');
plot(log.estimation.bag_stamp, log.estimation.wheel_slips(:, 2) * 100, 'DisplayName', 'FR');
plot(log.estimation.bag_stamp, log.estimation.wheel_slips(:, 3) * 100, 'DisplayName', 'RL');
plot(log.estimation.bag_stamp, log.estimation.wheel_slips(:, 4) * 100, 'DisplayName', 'RR');

plot_patches(log.vehicle_fbk.bag_stamp, upshifts_patches, ax_time(end), upshifts_patches_properties);
plot_patches(log.vehicle_fbk.bag_stamp, downshifts_patches, ax_time(end), downshifts_patches_properties);

% Speed

ax_time(end+1) = nexttile(3); hold on, legend show, grid on, box on;

ylabel('Long. speed [km/h]');
plot(log.estimation.bag_stamp, log.estimation.vx * 3.6, 'DisplayName','fbk');

xlabel('Time [s]')