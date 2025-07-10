h                   = figure('numbertitle', 'off');
h.Name              = "[Log" + i_log + "] Dynamics: tires combined";
tcl                 = tiledlayout(3,1);
tcl.TileSpacing     = 'compact';
tcl.Padding         = 'compact';

% Longitudinal slip

ax_time(end+1) = nexttile(1); hold on, legend show, grid on, box on;

ylabel('Long. slip [$\%$]');
plot(log.estimation.bag_stamp, log.estimation.wheel_slips(:, 1)*100, 'DisplayName', 'FL');
plot(log.estimation.bag_stamp, log.estimation.wheel_slips(:, 2)*100, 'DisplayName', 'FR');
plot(log.estimation.bag_stamp, log.estimation.wheel_slips(:, 3)*100, 'DisplayName', 'RL');
plot(log.estimation.bag_stamp, log.estimation.wheel_slips(:, 4)*100, 'DisplayName', 'RR');

% Front wheel slip angle

ax_time(end+1) = nexttile(2); hold on, legend show, grid on, box on;

ylabel('Wheel side slip angle [deg]');
plot(log.estimation.bag_stamp, log.estimation.alpha(:,1) * 180/pi, 'DisplayName', 'FL');
plot(log.estimation.bag_stamp, log.estimation.alpha(:,2) * 180/pi, 'DisplayName', 'FR');

% Rear wheel slip angle

ax_time(end+1) = nexttile(3); hold on, legend show, grid on, box on;

ylabel('Wheel side slip angle [deg]');
plot(log.estimation.bag_stamp, log.estimation.alpha(:,3) * 180/pi, 'DisplayName', 'RL');
plot(log.estimation.bag_stamp, log.estimation.alpha(:,4) * 180/pi, 'DisplayName', 'RR');

xlabel('Time [s]')