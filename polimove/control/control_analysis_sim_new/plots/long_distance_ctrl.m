h                   = figure('numbertitle', 'off');
h.Name              = "[Log" + i_log + "] Longitudinal: distance";
tcl                 = tiledlayout(3,1);
tcl.TileSpacing     = 'compact';
tcl.Padding         = 'compact';

% Distance

ax_time(end+1) = nexttile(1); hold on, legend show, grid on, box on;

ylabel('Distance [m]');
plot(log.local_planner.bag_stamp, log.local_planner.dist_control_ref,  'DisplayName','dist ref');
plot(log.local_planner.bag_stamp, log.local_planner.dist_control_meas, 'DisplayName','dist meas');

% Speed

ax_time(end+1) = nexttile(2); hold on, legend show, grid on, box on;

ylabel('Long. speed [km/h]');
plot(log.estimation.bag_stamp, zeros(size(log.estimation.bag_stamp)),'DisplayName','TODO CHECK');
plot(log.control__long__command.bag_stamp, log.control__long__command.long_vel_ref_dist_ctrl*3.6,'DisplayName','ref dist ctrl');
plot(log.control__long__command.bag_stamp, log.control__long__command.long_vel_ref*3.6,'DisplayName','ref local planner');
plot(log.local_planner.bag_stamp, log.local_planner.dist_control_vel*3.6,'DisplayName','vx opp');
plot(log.local_planner.bag_stamp, (log.local_planner.dist_control_vel-1*(log.local_planner.dist_control_ref(:, 1)-log.local_planner.dist_control_meas))*3.6,'DisplayName','vx ref proportional');
plot(log.estimation.bag_stamp, log.estimation.vx*3.6,'DisplayName','vx');

% Acceleration

ax_time(end+1) = nexttile(3); hold on, legend show, grid on, box on;

ylabel('Long. acc. [g]');
plot(log.control__long__command.bag_stamp, log.control__long__command.long_acc/9.81,                    'DisplayName', 'fbk');
plot(log.control__long__command.bag_stamp, log.control__long__command.speed_ctrl_acc_ref/9.81,          'DisplayName', 'ref');
plot(log.control__long__command.bag_stamp, log.control__long__command.speed_ctrl_acc_ref_internal/9.81, 'DisplayName', 'ref internal');
plot(log.control__long__command.bag_stamp, log.control__long__command.speed_ctrl_acc_ref_mpc/9.81,      'DisplayName', 'ref mpc');
plot(log.control__long__command.bag_stamp, log.control__long__command.long_acc_max/9.81, 'k',           'DisplayName', 'max');
plot(log.control__long__command.bag_stamp, log.control__long__command.long_acc_min/9.81, 'k',           'DisplayName', 'min');

xlabel('Time [s]')
