h                   = figure('numbertitle', 'off');
h.Name              = "[Log" + i_log + "] MPC: solver";
tcl                 = tiledlayout(4,1);
tcl.TileSpacing     = 'compact';
tcl.Padding         = 'compact';

% MPC disabled

mpc_disabled = ~log.control__mpc__command.valid_solution;
patch_properties = { 'FaceColor', 'r', 'FaceAlpha', 0.15, 'EdgeColor', 'none', 'HandleVisibility', 'off'};

% Exit flag

ax_time(end+1) = nexttile(1); hold on, legend show, grid on, box on;

ylabel('Flag [-]');
plot(log.control__mpc__command.bag_stamp, log.control__mpc__command.solver_exit_flag, 'DisplayName', 'exit flag');
plot_patches(log.control__mpc__command.bag_stamp, mpc_disabled, ax_time(end), patch_properties);

% Solver status

ax_time(end+1) = nexttile(2); hold on, legend show, grid on, box on;

ylabel('Status [-]');
plot(log.control__mpc__command.bag_stamp, log.control__mpc__command.solver_status, 'DisplayName', 'solver status');
plot_patches(log.control__mpc__command.bag_stamp, mpc_disabled, ax_time(end), patch_properties);

% Execution time

ax_time(end+1) = nexttile(3); hold on, legend show, grid on, box on;

ylabel('Time [ms]');
stem(log.control__mpc__command.bag_stamp, log.control__mpc__command.codegen_execution_time * 1000, 'DisplayName', 'codegen exec time');
plot_patches(log.control__mpc__command.bag_stamp, mpc_disabled, ax_time(end), patch_properties);
ylim([min(log.control__mpc__command.codegen_execution_time) max(log.control__mpc__command.codegen_execution_time(~mpc_disabled))] * 1000)

% Iterations

ax_time(end+1) = nexttile(4); hold on, legend show, grid on, box on;

ylabel('Iterations [-]');
stem(log.control__mpc__command.bag_stamp, log.control__mpc__command.solver_iterations, 'DisplayName', 'iterations');
plot_patches(log.control__mpc__command.bag_stamp, mpc_disabled, ax_time(end), patch_properties);
ylim([min(log.control__mpc__command.solver_iterations) max(log.control__mpc__command.solver_iterations(~mpc_disabled))])



xlabel('Time [s]');
