h                   = figure('numbertitle', 'off');
h.Name              = "[Log" + i_log + "] Space: MPC cost";
tcl                 = tiledlayout(5,1);
tcl.TileSpacing     = 'compact';
tcl.Padding         = 'compact';

% Compute cost function terms

[cost_n, cost_mu, cost_v, cost_r_ref_diff, cost_ax_ref_diff, cost_slack] ...
    = compute_mpc_cost(log.control__mpc__command, Qn, Qmu, Qv, W_r_ref_diff, W_ax_ref_diff, Qslack, true);
cost = cost_n + cost_mu + cost_v + cost_r_ref_diff + cost_ax_ref_diff + cost_slack;

% Get lap indexes interval

lap_idxs = get_lap_indexes(log.traj_server);

% Get lap colors

colors_lap = color_spacer(max(2, length(lap_idxs)));

% Lateral error cost

ax_space(end+1) = nexttile(1); hold on, grid on, box on;

ylabel('Cost $n$ [\%]');
for i = 1 : length(lap_idxs)
    data_interp = interp1(log.control__mpc__command.bag_stamp, ...
                          100*cost_n./cost, ...
                          log.traj_server.bag_stamp(lap_idxs{i}));
    plot(log.traj_server.s(lap_idxs{i}), data_interp, 'Color', colors_lap{i}, 'DisplayName', ['lap ' num2str(log.traj_server.lap_count(lap_idxs{i}(1)))]);
end

% Heading error cost

ax_space(end+1) = nexttile(2); hold on, grid on, box on;

ylabel('Cost $\mu$ [\%]');
for i = 1 : length(lap_idxs)
    data_interp = interp1(log.control__mpc__command.bag_stamp, ...
                          100*cost_mu./cost, ...
                          log.traj_server.bag_stamp(lap_idxs{i}));
    plot(log.traj_server.s(lap_idxs{i}), data_interp, 'Color', colors_lap{i}, 'DisplayName', ['lap ' num2str(log.traj_server.lap_count(lap_idxs{i}(1)))]);
end

% Speed cost

ax_space(end+1) = nexttile(3); hold on, grid on, box on;

ylabel('Cost $v_x$ [\%]');
for i = 1 : length(lap_idxs)
    data_interp = interp1(log.control__mpc__command.bag_stamp, ...
                          100*cost_v./cost, ...
                          log.traj_server.bag_stamp(lap_idxs{i}));
    plot(log.traj_server.s(lap_idxs{i}), data_interp, 'Color', colors_lap{i}, 'DisplayName', ['lap ' num2str(log.traj_server.lap_count(lap_idxs{i}(1)))]);
end

% Yaw rate reference differences cost

ax_space(end+1) = nexttile(4); hold on, grid on, box on;

ylabel('Cost $\Delta r_{ref}$ [\%]');
for i = 1 : length(lap_idxs)
    data_interp = interp1(log.control__mpc__command.bag_stamp, ...
                          100*cost_r_ref_diff./cost, ...
                          log.traj_server.bag_stamp(lap_idxs{i}));
    plot(log.traj_server.s(lap_idxs{i}), data_interp, 'Color', colors_lap{i}, 'DisplayName', ['lap ' num2str(log.traj_server.lap_count(lap_idxs{i}(1)))]);
end

% Long. acc. reference differences cost

ax_space(end+1) = nexttile(5); hold on, grid on, box on;

ylabel('Cost $\Delta a_{x,ref}$ [\%]');
for i = 1 : length(lap_idxs)
    data_interp = interp1(log.control__mpc__command.bag_stamp, ...
                          100*cost_ax_ref_diff./cost, ...
                          log.traj_server.bag_stamp(lap_idxs{i}));
    plot(log.traj_server.s(lap_idxs{i}), data_interp, 'Color', colors_lap{i}, 'DisplayName', ['lap ' num2str(log.traj_server.lap_count(lap_idxs{i}(1)))]);
end

legend('Location', 'southeast');

xlabel('Curvilinear abscissa [m]');