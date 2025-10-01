h                   = figure('numbertitle', 'off');
h.Name              = "[Log" + i_log + "] Longitudinal: acc ctrl";
tcl                 = tiledlayout(3,1);
tcl.TileSpacing     = 'compact';
tcl.Padding         = 'compact';

% Compute gear shift patches

shifts = [0; diff(log.vehicle_fbk.current_gear)];
upshifts_patches = shifts > 0;
downshifts_patches = shifts < 0;
upshifts_patches_properties = {'FaceColor', colors.orange{2}, 'EdgeColor', colors.orange{2}, 'FaceAlpha', 0.3, 'HandleVisibility', 'off'};
downshifts_patches_properties = {'FaceColor', colors.red{2}, 'EdgeColor', colors.orange{2}, 'FaceAlpha', 0.3, 'HandleVisibility', 'off'};

% Acceleration

ax_time(end+1) = nexttile(1); hold on, legend show, grid on, box on;

ylabel('Long. acc. [g]');
plot(log.control__long__command.bag_stamp, log.control__long__command.long_acc/9.81,                    'DisplayName', 'fbk');
plot(log.control__long__command.bag_stamp, log.control__long__command.long_acc_ref/9.81,          'DisplayName', 'ref');
plot(log.control__long__command.bag_stamp, log.control__long__command.long_acc_max/9.81, 'k',           'DisplayName', 'max');
plot(log.control__long__command.bag_stamp, log.control__long__command.long_acc_min/9.81, 'k',           'DisplayName', 'min');

% Control acceleration

ax_time(end+1) = nexttile(2); hold on, legend show, grid on, box on;

ylabel('Control acc. [g]');

plot(log.control__long__command.bag_stamp, log.control__long__command.long_acc_ctrl/9.81,    'DisplayName', 'ctrl');
plot(log.control__long__command.bag_stamp, log.control__long__command.long_acc_ctrl_fb/9.81, 'DisplayName', 'ctrl fb');
plot(log.control__long__command.bag_stamp, log.control__long__command.long_acc_ctrl_ff/9.81, 'DisplayName', 'ctrl ff');

plot(log.control__long__command.bag_stamp, log.control__long__command.long_acc_ctrl_sat_max/9.81, 'Color',  [0.5 0.5 0.5], 'DisplayName', 'sat max');
plot(log.control__long__command.bag_stamp, log.control__long__command.long_acc_ctrl_sat_min/9.81, 'Color',  [0.5 0.5 0.5], 'DisplayName', 'sat min');

if isfield(log.vehicle_fbk, 'push_to_pass_ack')
    patch_properties = {'FaceColor', colors.orange{2}, 'EdgeColor', colors.orange{2}, 'FaceAlpha', 0.3, 'DisplayName', 'PTP', 'HandleVisibility', 'off'};
    plot_patches(log.vehicle_fbk.bag_stamp, log.vehicle_fbk.push_to_pass_ack, ax_time(end), patch_properties);
end

% Throttle and brake

ax_time(end+1) = nexttile(3); hold on, legend show, grid on, box on;

ylabel('Throttle - Brake [\%-bar]');

plot(log.control__long__command.bag_stamp, log.control__long__command.throttle * 100, 'DisplayName', 'throttle');
plot(log.control__long__command.bag_stamp, log.control__long__command.brake * 1e-5,   'DisplayName', 'brake');

plot_patches(log.vehicle_fbk.bag_stamp, upshifts_patches, ax_time(end), upshifts_patches_properties);
plot_patches(log.vehicle_fbk.bag_stamp, downshifts_patches, ax_time(end), downshifts_patches_properties);

xlabel('Time [s]')