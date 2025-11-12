h                   = figure('numbertitle', 'off');
h.Name              = "[Log" + i_log + "] Space: actuators";
tcl                 = tiledlayout(4,1);
tcl.TileSpacing     = 'compact';
tcl.Padding         = 'compact';

% Get lap indexes interval

lap_idxs = get_lap_indexes(log.traj_server);

% Get lap colors

colors_lap = color_spacer(max(2, length(lap_idxs)));

% Throttle

ax_space(end+1) = nexttile(1); hold on, grid on, box on;

ylabel('Throttle [\%]');
for i = 1 : length(lap_idxs)
    data_interp = interp1(log.vehicle_fbk.bag_stamp, ...
                          log.vehicle_fbk.throttle_position, ...
                          log.traj_server.bag_stamp(lap_idxs{i}));
    plot(log.traj_server.s(lap_idxs{i}), data_interp, 'Color', colors_lap{i}, 'DisplayName', ['lap ' num2str(log.traj_server.lap_count(lap_idxs{i}(1)))]);
end

% Brake

ax_space(end+1) = nexttile(2); hold on, grid on, box on;

ylabel('Brake [bar]');
for i = 1 : length(lap_idxs)
    data_interp = interp1(log.vehicle_fbk.bag_stamp, ...
                          (log.vehicle_fbk.fl_brake+log.vehicle_fbk.fr_brake)/2, ...
                          log.traj_server.bag_stamp(lap_idxs{i}));
    plot(log.traj_server.s(lap_idxs{i}), data_interp, 'Color', colors_lap{i}, 'DisplayName', ['lap ' num2str(log.traj_server.lap_count(lap_idxs{i}(1)))]);
end
% for i = 1 : length(lap_idxs)
%     data_interp = interp1(log.vehicle_fbk.bag_stamp, ...
%                           log.vehicle_fbk.front_brake_pressure / 100, ...
%                           log.traj_server.bag_stamp(lap_idxs{i}));
%     plot(log.traj_server.s(lap_idxs{i}), data_interp, 'Color', colors_lap{i}, 'DisplayName', ['lap ' num2str(log.traj_server.lap_count(lap_idxs{i}(1)))]);
% end

% Gear

ax_space(end+1) = nexttile(3); hold on, grid on, box on;

ylabel('Gear [-]');
for i = 1 : length(lap_idxs)
    data_interp = interp1(log.vehicle_fbk.bag_stamp, ...
                          double(log.vehicle_fbk.current_gear), ...
                          log.traj_server.bag_stamp(lap_idxs{i}));
    plot(log.traj_server.s(lap_idxs{i}), data_interp, 'Color', colors_lap{i}, 'DisplayName', ['lap ' num2str(log.traj_server.lap_count(lap_idxs{i}(1)))]);
end

% Steer

ax_space(end+1) = nexttile(4); hold on, grid on, box on;

ylabel('Steer [deg]');
for i = 1 : length(lap_idxs)
    data_interp = interp1(log.vehicle_fbk.bag_stamp, ...
                           log.vehicle_fbk.steering_wheel_angle * 180/pi, ...
                          log.traj_server.bag_stamp(lap_idxs{i}));
    plot(log.traj_server.s(lap_idxs{i}), data_interp, 'Color', colors_lap{i}, 'DisplayName', ['lap ' num2str(log.traj_server.lap_count(lap_idxs{i}(1)))]);
end

legend('Location', 'southeast');

xlabel('Curvilinear abscissa [m]');