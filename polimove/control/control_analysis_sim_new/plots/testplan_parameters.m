h                   = figure('numbertitle', 'off');
h.Name              = "[Log" + i_log + "] Testplan: parameters";
tcl                 = tiledlayout(2,1);
tcl.TileSpacing     = 'compact';
tcl.Padding         = 'compact';

ax_time(end+1) = nexttile(1); hold on, legend show, grid on, box on;

ylabel('mu gain ref');
plot(log.local_planner.bag_stamp, log.local_planner.mux_acc_gain_ref, 'DisplayName', 'mux acc');
plot(log.local_planner.bag_stamp, log.local_planner.mux_dec_gain_ref, 'DisplayName', 'mux dec');
plot(log.local_planner.bag_stamp, log.local_planner.muy_gain_ref,     'DisplayName', 'muy');

ax_time(end+1) = nexttile(2); hold on, legend show, grid on, box on;

ylabel('Ellipse exp.');
plot(log.local_planner.bag_stamp, log.local_planner.exp_ellipse_acc, 'DisplayName', 'acc');
plot(log.local_planner.bag_stamp, log.local_planner.exp_ellipse_dec, 'DisplayName', 'dec');

xlabel('Time [s]')