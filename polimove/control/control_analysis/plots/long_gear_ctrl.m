h                   = figure('numbertitle', 'off');
h.Name              = "[Log" + i_log + "] Longitudinal: gears";
tcl                 = tiledlayout(3,1);
tcl.TileSpacing     = 'compact';
tcl.Padding         = 'compact';

% Gear

ax_time(end+1) = nexttile(1); hold on, legend show, grid on, box on;

ylabel('Gear [-]'); 
stairs(log.control__long__command.bag_stamp, log.control__long__command.gear,     '-o', 'DisplayName','cmd');
stairs(log.control__long__command.bag_stamp, log.control__long__command.gear_ref, '-o', 'DisplayName','ref');
stairs(log.control__long__command.bag_stamp, log.control__long__command.gear_min, '-o', 'DisplayName','min');
stairs(log.control__long__command.bag_stamp, log.control__long__command.gear_max, '-o', 'DisplayName','max');
stairs(log.vehicle_fbk.bag_stamp, log.vehicle_fbk.current_gear,                   '-o', 'DisplayName','fbk');

% Engine speed

ax_time(end+1) = nexttile(2); hold on, legend show, grid on, box on;

ylabel('Engine speed [RPM]');
plot(log.vehicle_fbk.bag_stamp, log.vehicle_fbk.engine_rpm, 'DisplayName', 'engine speed');

% Speed

ax_time(end+1) = nexttile(3); hold on, legend show, grid on, box on;

ylabel('Long. speed [km/h]');
plot(log.estimation.bag_stamp, log.estimation.vx * 3.6, 'DisplayName','fbk');

xlabel('Time [s]')