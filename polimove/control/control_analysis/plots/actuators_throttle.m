h                   = figure('numbertitle', 'off');
h.Name              = "[Log" + i_log + "] Actuators: throttle";
tcl                 = tiledlayout(3,1);
tcl.TileSpacing     = 'compact';
tcl.Padding         = 'compact';

% Throttle

ax_time(end+1) = nexttile(1); hold on, legend show, grid on, box on;

ylabel('Throttle [0-1]');
plot(log.control__long__command.bag_stamp, log.control__long__command.throttle * 100, 'DisplayName', 'cmd');
plot(log.vehicle_fbk.bag_stamp, log.vehicle_fbk.throttle_position,   'DisplayName', 'fbk');

if isfield(log.vehicle_fbk, 'push_to_pass_ack')
    patch_properties = {'FaceColor', colors.orange{2}, 'EdgeColor', colors.orange{2}, 'FaceAlpha', 0.3, 'DisplayName', 'PTP'};
    plot_patches(log.vehicle_fbk.bag_stamp, log.vehicle_fbk.push_to_pass_ack, ax_time(end), patch_properties);
elseif isfield(log.vehicle_fbk, 'ptp_status__type')
    patch_properties = {'FaceColor', colors.orange{2}, 'EdgeColor', colors.orange{2}, 'FaceAlpha', 0.3, 'DisplayName', 'PTP'};
    plot_patches(log.vehicle_fbk.bag_stamp, log.vehicle_fbk.ptp_status__type == log.vehicle_fbk.ptp_status__ACTIVE, ax_time(end), patch_properties);
end

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

% Boost

ax_time(end+1) = nexttile(3); hold on, legend show, grid on, box on;

ylabel('Pressure [psi]');
if isfield(log.vehicle_fbk, 'boost_pressure')    
    plot(log.vehicle_fbk.bag_stamp, log.vehicle_fbk.boost_pressure, 'DisplayName', 'boost pressure');
end

xlabel('Time [s]')

