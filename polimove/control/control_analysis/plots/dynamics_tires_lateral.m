h                   = figure('numbertitle', 'off');
h.Name              = "[Log" + i_log + "] Dynamics: tires lateral";
tcl                 = tiledlayout(3,1);
tcl.TileSpacing     = 'compact';
tcl.Padding         = 'compact';

% Front wheel slip angles

ax_time(end+1) = nexttile(1); hold on, legend show, grid on, box on;
ylabel(' Wheel side slip angle [deg]');
plot(log.estimation.bag_stamp, log.estimation.alpha(:,1) * 180/pi, 'DisplayName', 'FL');
plot(log.estimation.bag_stamp, log.estimation.alpha(:,2) * 180/pi, 'DisplayName', 'FR');

% Rear wheel slip angles

ax_time(end+1) = nexttile(2); hold on, legend show, grid on, box on;
ylabel('Wheel side slip angle [deg]');
plot(log.estimation.bag_stamp, log.estimation.alpha(:,3) * 180/pi, 'DisplayName', 'RL');
plot(log.estimation.bag_stamp, log.estimation.alpha(:,4) * 180/pi, 'DisplayName', 'RR');

% Lateral acceleration

ax_time(end+1) = nexttile(3); hold on, legend show, grid on, box on;
ylabel('Lat. acc. [g]');
plot(log.estimation.bag_stamp, log.estimation.ay / 9.81, 'DisplayName', 'lat acc');
plot(log.control__lateral__command.bag_stamp, log.control__lateral__command.lat_acc_min / 9.81, 'k', 'DisplayName', 'min');
plot(log.control__lateral__command.bag_stamp, log.control__lateral__command.lat_acc_max / 9.81, 'k', 'DisplayName', 'max');

xlabel('Time [s]')