h                   = figure('numbertitle', 'off');
h.Name              = "[Log" + i_log + "] Space: tire temp";
tcl                 = tiledlayout(4,1);
tcl.TileSpacing     = 'compact';
tcl.Padding         = 'compact';

% Get lap indexes interval

lap_idxs = get_lap_indexes(log.traj_server);

% Get lap colors

colors_lap = color_spacer(max(2, length(lap_idxs)));

% Temp FL

ax_space(end+1) = nexttile(1); hold on, grid on, box on;

ylabel('Temp FL [deg]');
for i = 1 : length(lap_idxs)
    data_interp = interp1(log.vehicle_fbk.bag_stamp, ...
                          log.vehicle_fbk.tyre_ext_temp_center_fl, ...
                          log.traj_server.bag_stamp(lap_idxs{i}));
    plot(log.traj_server.s(lap_idxs{i}), data_interp, 'Color', colors_lap{i}, 'DisplayName', ['lap ' num2str(log.traj_server.lap_count(lap_idxs{i}(1)))]);
end

% Temp FR

ax_space(end+1) = nexttile(2); hold on, grid on, box on;

ylabel('Temp FR [deg]');
for i = 1 : length(lap_idxs)
    data_interp = interp1(log.vehicle_fbk.bag_stamp, ...
                          log.vehicle_fbk.tyre_ext_temp_center_fr, ...
                          log.traj_server.bag_stamp(lap_idxs{i}));
    plot(log.traj_server.s(lap_idxs{i}), data_interp, 'Color', colors_lap{i}, 'DisplayName', ['lap ' num2str(log.traj_server.lap_count(lap_idxs{i}(1)))]);
end


% Temp RL

ax_space(end+1) = nexttile(3); hold on, grid on, box on;

ylabel('Temp RL [deg]');
for i = 1 : length(lap_idxs)
    data_interp = interp1(log.vehicle_fbk.bag_stamp, ...
                          log.vehicle_fbk.tyre_ext_temp_center_rl, ...
                          log.traj_server.bag_stamp(lap_idxs{i}));
    plot(log.traj_server.s(lap_idxs{i}), data_interp, 'Color', colors_lap{i}, 'DisplayName', ['lap ' num2str(log.traj_server.lap_count(lap_idxs{i}(1)))]);
end

% Temp RR

ax_space(end+1) = nexttile(4); hold on, grid on, box on;

ylabel('Temp RR [deg]');
for i = 1 : length(lap_idxs)
    data_interp = interp1(log.vehicle_fbk.bag_stamp, ...
                          log.vehicle_fbk.tyre_ext_temp_center_rr, ...
                          log.traj_server.bag_stamp(lap_idxs{i}));
    plot(log.traj_server.s(lap_idxs{i}), data_interp, 'Color', colors_lap{i}, 'DisplayName', ['lap ' num2str(log.traj_server.lap_count(lap_idxs{i}(1)))]);
end

legend('Location', 'southeast');

xlabel('Curvilinear abscissa [m]');