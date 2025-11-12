h                   = figure('numbertitle', 'off');
h.Name              = "[Log" + i_log + "] Dynamics: tires longitudinal";
tcl                 = tiledlayout(3,1);
tcl.TileSpacing     = 'compact';
tcl.Padding         = 'compact';

% Speed

ax_time(end+1) = nexttile(1); hold on, legend show, grid on, box on;

ylabel('Long. speed [km/h]');

plot(log.estimation.bag_stamp, log.estimation.wheel_speeds(:,1) * 3.6, 'DisplayName', 'FL');
plot(log.estimation.bag_stamp, log.estimation.wheel_speeds(:,1) * 3.6, 'DisplayName', 'FR');
plot(log.estimation.bag_stamp, log.estimation.wheel_speeds(:,1) * 3.6, 'DisplayName', 'RL');
plot(log.estimation.bag_stamp, log.estimation.wheel_speeds(:,1) * 3.6, 'DisplayName', 'RR');
plot(log.estimation.bag_stamp, log.estimation.vx * 3.6, 'k','DisplayName','long speed');

% Longitudinal slip

ax_time(end+1) = nexttile(2); hold on, legend show, grid on, box on;

ylabel('Long. slip [$\%$]');
plot(log.estimation.bag_stamp, log.estimation.wheel_slips(:, 1) * 100, 'DisplayName', 'FL');
plot(log.estimation.bag_stamp, log.estimation.wheel_slips(:, 2) * 100, 'DisplayName', 'FR');
plot(log.estimation.bag_stamp, log.estimation.wheel_slips(:, 3) * 100, 'DisplayName', 'RL');
plot(log.estimation.bag_stamp, log.estimation.wheel_slips(:, 4) * 100, 'DisplayName', 'RR');

% Longitudinal acceleration

ax_time(end+1) = nexttile(3); hold on, legend show, grid on, box on;

ylabel('Long. acc. [g]');
plot(log.estimation.bag_stamp, log.estimation.ax / 9.81,   'DisplayName', 'long acc');
plot(log.control__long__command.bag_stamp, log.control__long__command.long_acc / 9.81, 'DisplayName', 'long acc from speed');

xlabel('Time [s]')
