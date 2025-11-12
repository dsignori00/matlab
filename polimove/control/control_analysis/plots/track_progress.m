h                   = figure('numbertitle', 'off');
h.Name              = "[Log" + i_log + "] Track progress";
tcl                 = tiledlayout(3,1);
tcl.TileSpacing     = 'compact';
tcl.Padding         = 'compact';

ax_time(end+1) = nexttile(1); hold on, grid on, box on;

ylabel('Lap count [-]');
plot(log.traj_server.bag_stamp, log.traj_server.lap_count);

ax_time(end+1) = nexttile(2); hold on, grid on, box on;

ylabel('Track idx [m]');
plot(log.traj_server.bag_stamp, log.traj_server.closest_idx);

ax_time(end+1) = nexttile(3); hold on, grid on, box on;

ylabel('Speed [km/h]');
plot(log.estimation.bag_stamp, log.estimation.vx * 3.6);

xlabel('Time [s]')
