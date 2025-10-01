h                   = figure('numbertitle', 'off');
h.Name              = "[Log" + i_log + "] Dynamics: stability";
tcl                 = tiledlayout(4,1);
tcl.TileSpacing     = 'compact';
tcl.Padding         = 'compact';

% Yaw rate

ax_time(end+1) = nexttile(1); hold on, legend show, grid on, box on;

ylabel('Yaw rate [deg/s]');
plot(log.estimation.bag_stamp, log.estimation.yaw_rate * 180/pi, 'DisplayName', 'yaw rate');

% Sideslip

ax_time(end+1) = nexttile(2); hold on, legend show, grid on, box on;

ylabel('Sideslip angle [deg]');
plot(log.estimation.bag_stamp, log.estimation.beta * 180/pi, 'DisplayName', 'beta');

% Longitudinal slip

ax_time(end+1) = nexttile(3); hold on, legend show, grid on, box on;

ylabel('Long. slip [$\%$]');
plot(log.estimation.bag_stamp, log.estimation.wheel_slips(:, 1)*100, 'DisplayName', 'FL');
plot(log.estimation.bag_stamp, log.estimation.wheel_slips(:, 2)*100, 'DisplayName', 'FR');
plot(log.estimation.bag_stamp, log.estimation.wheel_slips(:, 3)*100, 'DisplayName', 'RL');
plot(log.estimation.bag_stamp, log.estimation.wheel_slips(:, 4)*100, 'DisplayName', 'RR');

% Lateral slip

ax_time(end+1) = nexttile(4); hold on, legend show, grid on, box on;

ylabel('Sideslip angle [deg]');
plot(log.estimation.bag_stamp, log.estimation.alpha(:,1) * 180/pi, 'DisplayName', 'FL');
plot(log.estimation.bag_stamp, log.estimation.alpha(:,2) * 180/pi, 'DisplayName', 'FR');
plot(log.estimation.bag_stamp, log.estimation.alpha(:,3) * 180/pi, 'DisplayName', 'RL');
plot(log.estimation.bag_stamp, log.estimation.alpha(:,4) * 180/pi, 'DisplayName', 'RR');

xlabel('Time [s]')
