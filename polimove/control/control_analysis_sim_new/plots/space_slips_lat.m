h                   = figure('numbertitle', 'off');
h.Name              = "[Log" + i_log + "] Space: slips lat";
tcl                 = tiledlayout(4,1);
tcl.TileSpacing     = 'compact';
tcl.Padding         = 'compact';

% Get lap indexes interval

lap_idxs = get_lap_indexes(log.traj_server);

% Get lap colors

colors_lap = color_spacer(max(2, length(lap_idxs)));

% Slip FL

ax_space(end+1) = nexttile(1); hold on, grid on, box on;

ylabel('Slip FL [deg]');
for i = 1 : length(lap_idxs)
    data_interp = interp1(log.estimation.bag_stamp, ...
                          log.estimation.alpha(:, 1) * 180/pi, ...
                          log.traj_server.bag_stamp(lap_idxs{i}));
    plot(log.traj_server.s(lap_idxs{i}), data_interp, 'Color', colors_lap{i}, 'DisplayName', ['lap ' num2str(log.traj_server.lap_count(lap_idxs{i}(1)))]);
end

% Slip FR

ax_space(end+1) = nexttile(2); hold on, grid on, box on;

ylabel('Slip FR [deg]');
for i = 1 : length(lap_idxs)
    data_interp = interp1(log.estimation.bag_stamp, ...
                          log.estimation.alpha(:, 2) * 180/pi, ...
                          log.traj_server.bag_stamp(lap_idxs{i}));
    plot(log.traj_server.s(lap_idxs{i}), data_interp, 'Color', colors_lap{i}, 'DisplayName', ['lap ' num2str(log.traj_server.lap_count(lap_idxs{i}(1)))]);
end


% Slip RL

ax_space(end+1) = nexttile(3); hold on, grid on, box on;

ylabel('Slip RL [deg]');
for i = 1 : length(lap_idxs)
    data_interp = interp1(log.estimation.bag_stamp, ...
                          log.estimation.alpha(:, 3) * 180/pi, ...
                          log.traj_server.bag_stamp(lap_idxs{i}));
    plot(log.traj_server.s(lap_idxs{i}), data_interp, 'Color', colors_lap{i}, 'DisplayName', ['lap ' num2str(log.traj_server.lap_count(lap_idxs{i}(1)))]);
end

% Slip RR

ax_space(end+1) = nexttile(4); hold on, grid on, box on;

ylabel('Slip RR [deg]');
for i = 1 : length(lap_idxs)
    data_interp = interp1(log.estimation.bag_stamp, ...
                          log.estimation.alpha(:, 4) * 180/pi, ...
                          log.traj_server.bag_stamp(lap_idxs{i}));
    plot(log.traj_server.s(lap_idxs{i}), data_interp, 'Color', colors_lap{i}, 'DisplayName', ['lap ' num2str(log.traj_server.lap_count(lap_idxs{i}(1)))]);
end

legend('Location', 'southeast');

xlabel('Curvilinear abscissa [m]');