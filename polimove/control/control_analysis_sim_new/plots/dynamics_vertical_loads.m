h                   = figure('numbertitle', 'off');
h.Name              = "[Log" + i_log + "] Dynamics: vertical loads";
tcl                 = tiledlayout(3,1);
tcl.TileSpacing     = 'compact';
tcl.Padding         = 'compact';

% Vertical load (4 corners)

ax_time(end+1) = nexttile(1); hold on, legend show, grid on, box on;

ylabel('Vertical load [kg]');
plot(log.vehicle_fbk.bag_stamp, log.vehicle_fbk.fl_load_wheel, 'DisplayName', 'FL');
plot(log.vehicle_fbk.bag_stamp, log.vehicle_fbk.fr_load_wheel, 'DisplayName', 'FR');
plot(log.vehicle_fbk.bag_stamp, log.vehicle_fbk.rl_load_wheel, 'DisplayName', 'RL');
plot(log.vehicle_fbk.bag_stamp, log.vehicle_fbk.rr_load_wheel, 'DisplayName', 'RR');

% Vertical load (front/rear)

ax_time(end+1) = nexttile(2); hold on, legend show, grid on, box on;

ylabel('Vertical load [kg]');
plot(log.vehicle_fbk.bag_stamp, log.vehicle_fbk.fl_load_wheel + log.vehicle_fbk.fr_load_wheel, 'DisplayName', 'total front');
plot(log.vehicle_fbk.bag_stamp, log.vehicle_fbk.rl_load_wheel + log.vehicle_fbk.rr_load_wheel, 'DisplayName', 'total rear');

% Speed

ax_time(end+1) = nexttile(3); hold on, legend show, grid on, box on;

ylabel('Speed [km/h]');
plot(log.control__long__command.bag_stamp, log.control__long__command.long_vel * 3.6, 'DisplayName', 'long speed');

xlabel('Time [s]')