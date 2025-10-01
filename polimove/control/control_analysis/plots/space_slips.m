h                   = figure('numbertitle', 'off');
h.Name              = "[Log" + i_log + "] Space: slips";
tcl                 = tiledlayout(5,1);
tcl.TileSpacing     = 'compact';
tcl.Padding         = 'compact';

% Get lap indexes interval

lap_idxs = get_lap_indexes(log.traj_server);

% Get lap colors

colors_lap = color_spacer(max(2, length(lap_idxs)));

% Front longitudinal slip

ax_space(end+1) = nexttile(1); hold on, grid on, box on;

ylabel('Front long. [\%]');
for i = 1 : length(lap_idxs)
    data_interp = interp1(log.estimation.bag_stamp, ...
                          (log.estimation.wheel_slips(:, 1) + log.estimation.wheel_slips(:, 2)) * 50, ...
                          log.traj_server.bag_stamp(lap_idxs{i}));
    plot(log.traj_server.s(lap_idxs{i}), data_interp, 'Color', colors_lap{i}, 'DisplayName', ['lap ' num2str(log.traj_server.lap_count(lap_idxs{i}(1)))]);
end

% Rear longitudinal slip

ax_space(end+1) = nexttile(2); hold on, grid on, box on;

ylabel('Rear long. [\%]');
for i = 1 : length(lap_idxs)
    data_interp = interp1(log.estimation.bag_stamp, ...
                          (log.estimation.wheel_slips(:, 3) + log.estimation.wheel_slips(:, 4)) * 50, ...
                          log.traj_server.bag_stamp(lap_idxs{i}));
    plot(log.traj_server.s(lap_idxs{i}), data_interp, 'Color', colors_lap{i}, 'DisplayName', ['lap ' num2str(log.traj_server.lap_count(lap_idxs{i}(1)))]);
end


% Front lateral slip

ax_space(end+1) = nexttile(3); hold on, grid on, box on;

ylabel('Front angle [deg]');
for i = 1 : length(lap_idxs)
    data_interp = interp1(log.estimation.bag_stamp, ...
                          180/pi * (log.estimation.alpha(:,1) + log.estimation.alpha(:,2))/2, ...
                          log.traj_server.bag_stamp(lap_idxs{i}));
    plot(log.traj_server.s(lap_idxs{i}), data_interp, 'Color', colors_lap{i}, 'DisplayName', ['lap ' num2str(log.traj_server.lap_count(lap_idxs{i}(1)))]);
end

% Rear lateral slip

ax_space(end+1) = nexttile(4); hold on, grid on, box on;

ylabel('Rear angle [deg]');
for i = 1 : length(lap_idxs)
    data_interp = interp1(log.estimation.bag_stamp, ...
                          180/pi * (log.estimation.alpha(:,3) + log.estimation.alpha(:,4))/2, ...
                          log.traj_server.bag_stamp(lap_idxs{i}));
    plot(log.traj_server.s(lap_idxs{i}), data_interp, 'Color', colors_lap{i}, 'DisplayName', ['lap ' num2str(log.traj_server.lap_count(lap_idxs{i}(1)))]);
end

% Sideslip

ax_space(end+1) = nexttile(5); hold on, grid on, box on;

ylabel('Vehicle angle [deg]');
for i = 1 : length(lap_idxs)
    data_interp = interp1(log.estimation.bag_stamp, ...
                          180/pi * log.estimation.beta, ...
                          log.traj_server.bag_stamp(lap_idxs{i}));
    plot(log.traj_server.s(lap_idxs{i}), data_interp, 'Color', colors_lap{i}, 'DisplayName', ['lap ' num2str(log.traj_server.lap_count(lap_idxs{i}(1)))]);
end

legend('Location', 'southeast');

xlabel('Curvilinear abscissa [m]');