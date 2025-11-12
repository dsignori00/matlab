h                   = figure('numbertitle', 'off');
h.Name              = "[Log" + i_log + "] Pacejka lateral";
tcl                 = tiledlayout(1,2);
tcl.TileSpacing     = 'compact';
tcl.Padding         = 'compact';

omega_z_dot = [0; diff(log.control__lateral__command.yaw_rate)];
omega_z_dot_th = 0.03;

COND = abs(omega_z_dot)<omega_z_dot_th & log.estimation.vx *3.6 > 50;

vx_FL = log.estimation.vx - car_params.vehicle.Tf/2 * log.estimation.yaw_rate;
vx_FR = log.estimation.vx + car_params.vehicle.Tf/2 * log.estimation.yaw_rate;
vx_RL = log.estimation.vx - car_params.vehicle.Tr/2  * log.estimation.yaw_rate;
vx_RR = log.estimation.vx + car_params.vehicle.Tr/2  * log.estimation.yaw_rate;

vy_FL = log.estimation.vy + car_params.vehicle.Lf * log.estimation.yaw_rate;
vy_FR = log.estimation.vy + car_params.vehicle.Lf * log.estimation.yaw_rate;
vy_RL = log.estimation.vy - car_params.vehicle.Lr * log.estimation.yaw_rate;
vy_RR = log.estimation.vy - car_params.vehicle.Lr * log.estimation.yaw_rate;

alpha_FL = atan2(vy_FL, vx_FL) - log.vehicle_fbk.steering_wheel_angle;
alpha_FR = atan2(vy_FR, vx_FR) - log.vehicle_fbk.steering_wheel_angle;
alpha_RL = atan2(vy_RL, vx_RL);
alpha_RR = atan2(vy_RR, vx_RR);

alpha_FL = alpha_FL(COND); 
alpha_FR = alpha_FR(COND);
alpha_RL = alpha_RL(COND);
alpha_RR = alpha_RR(COND);

Fy_F = (log.estimation.ay(COND)*car_params.vehicle.Lr*car_params.vehicle.M)./...
            (cos(log.vehicle_fbk.steering_wheel_angle(COND))*(car_params.vehicle.L));

Fy_R = (Fy_F .* cos(log.vehicle_fbk.steering_wheel_angle(COND)) * (car_params.vehicle.Lf)) / (car_params.vehicle.Lr);


colors_lap = color_spacer(max(log.traj_server.lap_count) + 1);

ax_time(end+1) = nexttile(1); hold on, legend show, grid on, box on; ylabel(' Lateral Force[N]');xlabel('Slip angle [deg]');title('Front')

for i = 6 %flip(0 : max(log.traj_server.lap_count))
    sel_idxs = log.traj_server.lap_count(COND) == i;
    if sum(sel_idxs) > 0
%         scatter(-log.estimation.ay(sel_idxs) / 9.81, log.estimation.ax(sel_idxs) / 9.81, [], colors_lap{i+1}, 'filled', 'DisplayName', ['lap ' num2str(i)]);
        scatter((alpha_FL(sel_idxs)+alpha_FR(sel_idxs))/2 * 180/pi, Fy_F(sel_idxs),  8, colors_lap{i+1}, 'filled', 'DisplayName', ['lap ' num2str(i)]);
    end
end
xlim([-5 5])
ylim([-13000 13000])
ax_time(end+1) = nexttile(2); hold on, legend show, grid on, box on; ylabel(' Lateral Force[N]');xlabel('Slip angle [deg]');title('Rear')
for i = 6 %flip(0 : max(log.traj_server.lap_count))
    sel_idxs = log.traj_server.lap_count(COND) == i;
    if sum(sel_idxs) > 0
%         scatter(-log.estimation.ay(sel_idxs) / 9.81, log.estimation.ax(sel_idxs) / 9.81, [], colors_lap{i+1}, 'filled', 'DisplayName', ['lap ' num2str(i)]);
        scatter((alpha_RL(sel_idxs)+alpha_RR(sel_idxs))/2 * 180/pi, Fy_R(sel_idxs),  8, colors_lap{i+1}, 'filled', 'DisplayName', ['lap ' num2str(i)]);
    end
end
xlim([-5 5])
ylim([-13000 13000])
