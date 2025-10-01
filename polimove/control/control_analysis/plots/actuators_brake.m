h                   = figure('numbertitle', 'off');
h.Name              = "[Log" + i_log + "] Actuators: brake";
tcl                 = tiledlayout(2,1);
tcl.TileSpacing     = 'compact';
tcl.Padding         = 'compact';

PA2BAR = 1e-5;

% Brake pressure

ax_time(end+1) = nexttile(1); hold on, legend show, grid on, box on;

ylabel('Brake [bar]');

if isfield(log.vehicle_fbk, 'fl_brake_pressure')
    plot(log.vehicle_fbk.bag_stamp, log.vehicle_fbk.fl_brake_pressure * PA2BAR, 'DisplayName','FL fbk');
    plot(log.vehicle_fbk.bag_stamp, log.vehicle_fbk.fr_brake_pressure * PA2BAR, 'DisplayName','FR fbk');
    plot(log.vehicle_fbk.bag_stamp, log.vehicle_fbk.rl_brake_pressure * PA2BAR, 'DisplayName','RL fbk');
    plot(log.vehicle_fbk.bag_stamp, log.vehicle_fbk.rr_brake_pressure * PA2BAR, 'DisplayName','RR fbk');
end
plot(log.control__long__command.bag_stamp, log.control__long__command.brake * PA2BAR, 'k--', 'DisplayName', 'cmd');

% Temperature

ax_time(end+1) = nexttile(2); hold on, legend show, grid on, box on;

ylabel('Temp. [$^{\circ}$C]');
if isfield(log.vehicle_fbk, 'brake_temp_fl')
    plot(log.vehicle_fbk.bag_stamp, log.vehicle_fbk.brake_temp_fl, 'DisplayName', 'FL');
    plot(log.vehicle_fbk.bag_stamp, log.vehicle_fbk.brake_temp_fr, 'DisplayName', 'FR');
    plot(log.vehicle_fbk.bag_stamp, log.vehicle_fbk.brake_temp_rl, 'DisplayName', 'RL');
    plot(log.vehicle_fbk.bag_stamp, log.vehicle_fbk.brake_temp_rr, 'DisplayName', 'RR');
end

xlabel('Time [s]')