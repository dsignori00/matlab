h                   = figure('numbertitle', 'off');
h.Name              = "[Log" + i_log + "] Vehicle limits";
tcl                 = tiledlayout(2,1);
tcl.TileSpacing     = 'compact';
tcl.Padding         = 'compact';

% Compute ellipse constraint

MUX_ACC_GAIN = 0.5;
MUX_DEC_GAIN = 1.0;
MUY = 1.0;

g = 9.81;

t = log.estimation.bag_stamp;
v = log.estimation.vx;
bank = log.estimation.roll;

ax_meas_tire = log.estimation.ax + k_drag * v.^2;
ay_meas_tire = log.estimation.ay;

ax_ref_tire = interp1(log.control__long__command.bag_stamp, log.control__long__command.speed_ctrl_acc_ref, t) + k_drag * v.^2;
% ax_ref_tire = interp1(log.control__long__command.bag_stamp, log.control__long__command.long_acc_ref, t) + k_drag * v.^2;
ay_ref_tire = interp1(log.control__lateral__command.bag_stamp, log.control__lateral__command.yaw_rate_ref, t) .* log.estimation.vx + g * sin(bank);

mux_acc = MUX_ACC_GAIN * interp1(log.local_planner.bag_stamp, log.local_planner.mux_acc_gain_feas, t, 'previous');
mux_dec = MUX_DEC_GAIN * interp1(log.local_planner.bag_stamp, log.local_planner.mux_dec_gain_feas, t, 'previous');
muy     = MUY * interp1(log.local_planner.bag_stamp, log.local_planner.muy_gain_feas, t, 'previous');

exp_ellipse_acc = interp1(log.local_planner.bag_stamp, log.local_planner.exp_ellipse_acc, t, 'previous');
exp_ellipse_dec = interp1(log.local_planner.bag_stamp, log.local_planner.exp_ellipse_dec, t, 'previous');

[ellipse_constr_ref, ellipse_angle_ref] = compute_ellispe_constraint(v, ax_ref_tire, ay_ref_tire, bank, mux_acc, mux_dec, muy, exp_ellipse_acc, exp_ellipse_dec, k_downforce);
[ellipse_constr_meas, ellipse_angle_meas] = compute_ellispe_constraint(v, ax_meas_tire, ay_meas_tire, bank, mux_acc, mux_dec, muy, exp_ellipse_acc, exp_ellipse_dec, k_downforce);

% Constraint value (reference)

ax_time(end+1) = nexttile(1); hold on, legend show, grid on, box on; cb = colorbar;

ylabel('Constraint value [-]');
ylabel(cb, 'GG plot angle [deg]')

plot(t, ones(size(t)), 'k', 'DisplayName', 'limit')
scatter(t, ellipse_constr_ref, 10, rad2deg(ellipse_angle_ref), 'filled', 'DisplayName', 'ref')

clim([-90 90])
if ~ismember(90, cb.XTick)
    cb.XTick = [cb.XTick 90];
end
if ~ismember(-90, cb.XTick)
    cb.XTick = [-90 cb.XTick];
end
cb.XTickLabel{1}   = 'Dec.';
cb.XTickLabel{end} = 'Acc.';

% Constraint value (measured)

ax_time(end+1) = nexttile(2); hold on, legend show, grid on, box on; cb = colorbar;

ylabel('Constraint value [-]');
ylabel(cb, 'GG plot angle [deg]')

plot(t, ones(size(t)), 'k', 'DisplayName', 'limit')
scatter(t, ellipse_constr_meas, 10, rad2deg(ellipse_angle_meas), 'filled', 'DisplayName', 'meas')

clim([-90 90])
if ~ismember(90, cb.XTick)
    cb.XTick = [cb.XTick 90];
end
if ~ismember(-90, cb.XTick)
    cb.XTick = [-90 cb.XTick];
end
cb.XTickLabel{1}   = 'Dec.';
cb.XTickLabel{end} = 'Acc.';


xlabel('Time [s]')


%% Auxiliary function

function [ellipse_constr, ellipse_angle] = compute_ellispe_constraint(v, ax_tire, ay_tire, bank, mux_acc, mux_dec, muy, exp_ellipse_acc, exp_ellipse_dec, k_downforce)

% Constants
g = 9.81;

Fz = g * cos(bank) - (ay_tire - g * sin(bank)) .* sin(bank) + k_downforce * v.^2;

ellipse_constr_acc = (abs(ax_tire) ./ Fz ./ mux_acc).^exp_ellipse_acc + (abs(ay_tire) ./ Fz ./ muy).^exp_ellipse_acc;
ellipse_constr_dec = (abs(ax_tire) ./ Fz ./ mux_dec).^exp_ellipse_dec + (abs(ay_tire) ./ Fz ./ muy).^exp_ellipse_dec;

ellipse_constr = zeros(size(v));

ellipse_constr(ax_tire >= 0) = ellipse_constr_acc(ax_tire >= 0);
ellipse_constr(ax_tire < 0)  = ellipse_constr_dec(ax_tire < 0);

ellipse_angle = atan2(ax_tire, ay_tire);

ellipse_angle = abs(wrapToPi(ellipse_angle + pi/2)) - pi/2;

end