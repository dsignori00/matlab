h                   = figure('numbertitle', 'off');
h.Name              = "[Log" + i_log + "] Actuators: gears";
tcl                 = tiledlayout(3,1);
tcl.TileSpacing     = 'compact';
tcl.Padding         = 'compact';

% Gear

ax_time(end+1) = nexttile(1); hold on, legend show, grid on, box on;

ylabel('gear [-]');
stairs(log.control__long__command.bag_stamp, log.control__long__command.gear,'DisplayName','cmd');
stairs(log.vehicle_fbk.bag_stamp, log.vehicle_fbk.current_gear,'DisplayName','fbk');

% Engine speed

ax_time(end+1) = nexttile(2); hold on, legend show, grid on, box on;

ylabel('Engine speed [RPM]');
plot(log.vehicle_fbk.bag_stamp, log.vehicle_fbk.engine_rpm, 'DisplayName', 'engine speed');
if isfield(log.vehicle_fbk, 'push_to_pass_ack')
    patch_properties = {'FaceColor', colors.orange{2}, 'EdgeColor', colors.orange{2}, 'FaceAlpha', 0.3, 'DisplayName', 'PTP'};
    plot_patches(log.vehicle_fbk.bag_stamp, log.vehicle_fbk.push_to_pass_ack, ax_time(end), patch_properties);
elseif isfield(log.vehicle_fbk, 'ptp_status__type')
    patch_properties = {'FaceColor', colors.orange{2}, 'EdgeColor', colors.orange{2}, 'FaceAlpha', 0.3, 'DisplayName', 'PTP'};
    plot_patches(log.vehicle_fbk.bag_stamp, log.vehicle_fbk.ptp_status__type == log.vehicle_fbk.ptp_status__ACTIVE, ax_time(end), patch_properties);
end

% Speed

ax_time(end+1) = nexttile(3); hold on, legend show, grid on, box on;

ylabel('Speed [km/h]');
plot(log.estimation.bag_stamp, log.estimation.vx * 3.6, 'DisplayName', 'long speed');

xlabel('Time [s]')