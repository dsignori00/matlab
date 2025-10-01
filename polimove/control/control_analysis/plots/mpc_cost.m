h                   = figure('numbertitle', 'off');
h.Name              = "[Log" + i_log + "] MPC: cost";
tcl                 = tiledlayout(2,1);
tcl.TileSpacing     = 'compact';
tcl.Padding         = 'compact';

% Compute cost function terms

[cost_n, cost_mu, cost_v, cost_r_ref_diff, cost_ax_ref_diff, cost_slack] ...
    = compute_mpc_cost(log.control__mpc__command, Qn, Qmu, Qv, W_r_ref_diff, W_ax_ref_diff, Qslack, true);
cost = cost_n + cost_mu + cost_v + cost_r_ref_diff + cost_ax_ref_diff + cost_slack;

% MPC disabled

mpc_disabled = (log.control__mpc__command.valid_solution == 0);
patch_properties = { 'FaceColor', 'r', 'FaceAlpha', 0.15, 'EdgeColor', 'none', 'HandleVisibility', 'off'};

% Cost function terms

ax_time(end+1) = nexttile(1); hold on, legend show, grid on, box on;

ylabel('Cost [\%]');
plot(log.control__mpc__command.bag_stamp, 100*cost_n./cost,           'DisplayName', 'lateral error');
plot(log.control__mpc__command.bag_stamp, 100*cost_mu./cost,          'DisplayName', 'heading error');
plot(log.control__mpc__command.bag_stamp, 100*cost_v./cost,           'DisplayName', 'speed');
plot(log.control__mpc__command.bag_stamp, 100*cost_r_ref_diff./cost,  'DisplayName', 'yaw rate ref diff');
plot(log.control__mpc__command.bag_stamp, 100*cost_ax_ref_diff./cost, 'DisplayName', 'ax rate ref diff');
plot(log.control__mpc__command.bag_stamp, 100*cost_slack./cost,       'DisplayName', 'slack');
plot_patches(log.control__mpc__command.bag_stamp, mpc_disabled, ax_time(end), patch_properties)

% Cost function terms (area plot)

ax_time(end+1) = nexttile(2); hold on, legend show, grid on, box on;

ylabel('Cost [\%]');

area(log.control__mpc__command.bag_stamp, ...
    100*[cost_n, cost_mu, cost_v, cost_r_ref_diff, cost_ax_ref_diff, cost_slack]./cost, ...
    'EdgeColor', 'none');
legend('lateral error', 'heading error', 'speed', 'yaw rate ref diff', 'ax rate ref diff', 'slack');
plot_patches(log.control__mpc__command.bag_stamp, mpc_disabled, ax_time(end), patch_properties)


xlabel('Time [s]');
