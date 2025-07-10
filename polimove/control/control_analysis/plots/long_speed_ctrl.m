h                   = figure('numbertitle', 'off');
h.Name              = "[Log" + i_log + "] Longitudinal: speed ctrl";
tcl                 = tiledlayout(5,4);
tcl.TileSpacing     = 'compact';
tcl.Padding         = 'compact';

% Speed

ax_time(end+1) = nexttile([2 4]); hold on, legend show, grid on, box on;

ylabel('Long. speed [km/h]');
plot(log.estimation.bag_stamp, log.estimation.vx * 3.6, 'DisplayName','fbk');
plot(log.control__long__command.bag_stamp, log.control__long__command.long_vel_ref * 3.6, 'DisplayName', 'ref');
plot(log.control__long__command.bag_stamp, log.control__long__command.long_vel_chunk_ref * 3.6, 'DisplayName', 'ref chunk');

% Acceleration

ax_time(end+1) = nexttile([2 4]); hold on, legend show, grid on, box on;

ylabel('Long. acc. [g]');
plot(log.control__long__command.bag_stamp, log.control__long__command.long_acc/9.81,           'DisplayName', 'fbk');
plot(log.control__long__command.bag_stamp, log.control__long__command.long_acc_ref/9.81,          'DisplayName', 'ref');
plot(log.control__long__command.bag_stamp, log.control__long__command.long_acc_max/9.81, 'k',           'DisplayName', 'max');
plot(log.control__long__command.bag_stamp, log.control__long__command.long_acc_min/9.81, 'k',           'DisplayName', 'min');

% Vehicle limits (mu and ellipse)

ax_time(end+1) = nexttile([1 1]); hold on, legend show, grid on, box on;

plot(log.local_planner.bag_stamp, log.local_planner.mux_acc_gain_ref, 'DisplayName', 'mux acc');
y_lim = ylim();
ylim([0 y_lim(2)]);

ax_time(end+1) = nexttile([1 1]); hold on, legend show, grid on, box on;

plot(log.local_planner.bag_stamp, log.local_planner.mux_dec_gain_ref, 'DisplayName', 'mux dec');
y_lim = ylim();
ylim([0 y_lim(2)]);
ax_time(end+1) = nexttile([1 1]); hold on, legend show, grid on, box on;

plot(log.local_planner.bag_stamp, log.local_planner.muy_gain_ref, 'DisplayName', 'muy');
y_lim = ylim();
ylim([0 y_lim(2)]);
ax_time(end+1) = nexttile([1 1]); hold on, legend show, grid on, box on;

plot(log.local_planner.bag_stamp, log.local_planner.exp_ellipse_acc, 'DisplayName', 'ell. acc');
plot(log.local_planner.bag_stamp, log.local_planner.exp_ellipse_dec, 'DisplayName', 'ell. dec');
y_lim = ylim();
ylim([0 y_lim(2)]);

xlabel('Time [s]')
