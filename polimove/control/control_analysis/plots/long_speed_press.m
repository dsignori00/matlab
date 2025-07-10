h                   = figure('numbertitle', 'off');
h.Name              = "[Log" + i_log + "] Longitudinal: speed ctrl";
tcl                 = tiledlayout(1,1);
tcl.TileSpacing     = 'compact';
tcl.Padding         = 'compact';

idx_record = log.traj_server.lap_count == 10 & log.estimation.vx * 3.6 > 70; 

ax_time(end+1) = nexttile(tcl); hold all, grid on, box on;
% ylabel('Velocit\`a [km/h]'), xlabel('Spazio [m]');
ylabel('Speed [km$/$h]'), xlabel('Space [m]');

% xline(1602.92, '--k')
% yline(285, '--k')
scatter(1604, 285, 60, 'r', 'filled', 'DisplayName','Top Speed');
plot(log.s(idx_record), log.estimation.vx(idx_record) * 3.64, 'Color', colors.matlab{1});
set(gca,'DefaultTextInterpreter', 'latex')
zoom_plot


h                   = figure('numbertitle', 'off');
h.Name              = "[Log" + i_log + "] Longitudinal: speed ctrl";
tcl                 = tiledlayout(1,1);
tcl.TileSpacing     = 'compact';
tcl.Padding         = 'compact';

idx_record = log.traj_server.lap_count == 10 & log.estimation.vx * 3.6 > 70; 

ax_time(end+1) = nexttile(tcl); hold on, grid on, box on,ylabel('Speed [km$/$h]'), xlabel('Space [m]');
plot(log.s(idx_record), log.estimation.vx(idx_record) * 3.64,'DisplayName', 'Estimation speed');
plot(log.s(idx_record), log.vehicle_fbk.v_fl(idx_record) * 3.6,'DisplayName', 'Wheel speed');

