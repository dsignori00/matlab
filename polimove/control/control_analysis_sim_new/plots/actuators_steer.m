h                   = figure('numbertitle', 'off');
h.Name              = "[Log" + i_log + "] Actuators: steer";
tcl                 = tiledlayout(1,1);
tcl.TileSpacing     = 'compact';
tcl.Padding         = 'compact';

% Steer

ax_time(end+1) = nexttile(1); hold on, legend show, grid on, box on;

ylabel('Steer [deg]');
plot(log.control__lateral__command.bag_stamp, log.control__lateral__command.steer_angle * 180/pi, 'DisplayName', 'cmd');
plot(log.vehicle_fbk.bag_stamp, log.vehicle_fbk.steering_wheel_angle  * 180/pi, 'DisplayName', 'fbk');

xlabel('Time [s]')
