h                   = figure('numbertitle', 'off');
h.Name              = "[Log" + i_log + "] Dynamics: lateral";
tcl                 = tiledlayout(3,1);
tcl.TileSpacing     = 'compact';
tcl.Padding         = 'compact';

% Yaw rate

ax_time(end+1) = nexttile(1); hold on, legend show, grid on, box on;

ylabel('Yaw rate [deg/s]');
plot(log.estimation.bag_stamp, log.estimation.yaw_rate * 180/pi, 'DisplayName', 'yaw rate');

% Sideslip

ax_time(end+1) = nexttile(2); hold on, legend show, grid on, box on;

ylabel('Sideslip [deg]');
plot(log.estimation.bag_stamp, log.estimation.beta * 180/pi, 'DisplayName', 'beta');

% Lateral acceleration

ax_time(end+1) = nexttile(3); hold on, legend show, grid on, box on;

ylabel('Lat. acc. [g]');
plot(log.estimation.bag_stamp, log.estimation.ay / 9.81, 'DisplayName', 'lat acc');
plot(log.control__lateral__command.bag_stamp, log.control__lateral__command.lat_acc_min / 9.81, 'k', 'DisplayName', 'min');
plot(log.control__lateral__command.bag_stamp, log.control__lateral__command.lat_acc_max / 9.81, 'k', 'DisplayName', 'max');

xlabel('Time [s]')