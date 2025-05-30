%% Lateral signals in time

% Lateral controller
h                   = figure('numbertitle', 'off');
h.Name              = "LAT Bag " + i + ": " + "Lateral";
tcl                 = tiledlayout(2,1);
tcl.TileSpacing     = 'compact';
tcl.Padding         = 'compact';
ax_time(end+1) = nexttile(1); hold on, legend show, grid on, box on,
ylabel('Lat. error [m]');
plot(data.time, data.lat_error,       'DisplayName','lateral error');
plot(data.time, -data.lat_error_filt, 'DisplayName','lateral error filt');
ax_time(end+1) = nexttile(2); hold on, legend show, grid on, box on,
ylabel('Yaw rate [deg/s]');
plot(data.time, RAD2DEG * data.yaw_rate_ref, 'DisplayName','yaw rate ref');
plot(data.time, RAD2DEG * data.yaw_rate, 'DisplayName','yaw rate');
xlabel('data.time [s]')

% Yaw rate controller
h                   = figure('numbertitle', 'off');
h.Name              = "LAT Bag " + i + ": " + "Yaw rate";
tcl                 = tiledlayout(2,1);
tcl.TileSpacing     = 'compact';
tcl.Padding         = 'compact';
ax_time(end+1) = nexttile(1); hold on, legend show, grid on, box on,
ylabel('Yaw rate [deg/s]');
plot(data.time, data.yaw_rate_ref * RAD2DEG,'DisplayName','yaw rate ref');
plot(data.time, data.yaw_rate * RAD2DEG, 'DisplayName','yaw rate meas');
plot(data.time, data.yaw_rate_ref_ecog * RAD2DEG,'DisplayName','yaw rate ref - ecog');
plot(data.time, data.yaw_rate_ref_prev * RAD2DEG,'DisplayName','yaw rate ref - preview');
plot(data.time, data.yaw_rate_min * RAD2DEG, 'Color', 'k', 'DisplayName','yaw rate min');
plot(data.time, data.yaw_rate_max * RAD2DEG, 'Color', 'k', 'DisplayName','yaw rate max');
ax_time(end+1) = nexttile(2); hold on, legend show, grid on, box on,
ylabel('Steer angle [deg]');
plot(data.time, RAD2DEG * data.steer_angle_cmd, 'DisplayName','steer cmd');
plot(data.time, RAD2DEG * data.steer_angle_manual, 'DisplayName','steer cmd manual');
plot(data.time, RAD2DEG * data.steer_angle_lead_lag, 'DisplayName','steer lead lag');
% plot(data.time, RAD2DEG * data.steer_angle_fb_cmd, 'DisplayName','steer cmd fb');
% plot(data.time, RAD2DEG * data.steer_angle_ff_cmd, 'DisplayName','steer cmd ff');
plot(data.time, RAD2DEG * data.steering_wheel_angle_fbk, 'DisplayName','steer fbk');
plot(data.time, RAD2DEG * data.steer_angle_min, 'Color', 'k', 'DisplayName','steer min');
plot(data.time, RAD2DEG * data.steer_angle_max, 'Color', 'k', 'DisplayName','steer max');
ylim(1.1 * RAD2DEG * [min(data.steer_angle_min) max(data.steer_angle_max)])
xlabel('data.time [s]')

% speed - yaw rate - steer

h                   = figure('numbertitle', 'off');
h.Name              = "LAT Bag " + i + ": " + "vx/r/delta";
tcl                 = tiledlayout(3,1);
tcl.TileSpacing     = 'compact';
tcl.Padding         = 'compact';
ax_time(end+1)=nexttile(1);

hold on
ylabel('vx [kph]')
plot(data.time, MPS2KPH*data.long_vel_ref, 'LineWidth',1.5, 'DisplayName','v ref')
plot(data.time, MPS2KPH*data.vx_hat, 'LineWidth',1.5, 'DisplayName','v hat')
legend show
ax_time(end+1)=nexttile(2);
hold on
ylabel('yaw rate [deg/s]')
plot(data.time, rad2deg(data.yaw_rate_ref), 'LineWidth',1.5, 'DisplayName','yaw rate ref')
plot(data.time, rad2deg(data.omega_z_hat), 'LineWidth',1.5, 'DisplayName','yaw rate hat')
legend show
ax_time(end+1)=nexttile(3);
hold on
ylabel('steer at the wheel [deg]')
xlabel('time [s]')
plot(data.time, RAD2DEG * data.steer_angle_cmd, 'DisplayName','steer cmd');
plot(data.time, RAD2DEG * data.steer_angle_manual, 'DisplayName','steer cmd manual');
plot(data.time, RAD2DEG * data.steer_angle_lead_lag, 'DisplayName','steer lead lag');
plot(data.time, RAD2DEG * data.steer_angle_fb_cmd, 'DisplayName','steer cmd fb');
plot(data.time, RAD2DEG * data.steer_angle_ff_cmd, 'DisplayName','steer cmd ff');
plot(data.time, RAD2DEG * data.steering_wheel_angle_fbk, 'DisplayName','steer fbk');
plot(data.time, RAD2DEG * data.steer_angle_min, 'Color', 'k', 'DisplayName','steer min');
plot(data.time, RAD2DEG * data.steer_angle_max, 'Color', 'k', 'DisplayName','steer max');
ylim(1.1 * RAD2DEG * [min(data.steer_angle_min) max(data.steer_angle_max)])
legend show

% sideslip

h                   = figure('numbertitle', 'off');
h.Name              = "LAT Bag " + i + ": " + "beta";
tcl                 = tiledlayout(1,1);
tcl.TileSpacing     = 'compact';
tcl.Padding         = 'compact';
ax_time(end+1)=nexttile(1);
hold on
ylabel('beta [deg]')
xlabel('time [s]')
plot(data.time, RAD2DEG * data.beta, 'DisplayName','beta');
legend show

% speed - e lat - steer

h                   = figure('numbertitle', 'off');
h.Name              = "LAT Bag " + i + ": " + "vx/elat/delta";
tcl                 = tiledlayout(3,1);
tcl.TileSpacing     = 'compact';
tcl.Padding         = 'compact';
ax_time(end+1)=nexttile(1);

hold on
ylabel('vx [kph]')
plot(data.time, MPS2KPH*data.long_vel_ref, 'LineWidth',1.5, 'DisplayName','v ref')
plot(data.time, MPS2KPH*data.vx_hat, 'LineWidth',1.5, 'DisplayName','v hat')
legend show
ax_time(end+1)=nexttile(2);
hold on
ylabel('lateral error [m]')
plot(data.time, data.lat_error,       'DisplayName','lateral error');
plot(data.time, -data.lat_error_filt, 'DisplayName','lateral error filt');
legend show
ax_time(end+1)=nexttile(3);
hold on
ylabel('steer at the wheel [deg]')
xlabel('time [s]')
plot(data.time, RAD2DEG * data.steer_angle_cmd, 'DisplayName','steer cmd');
plot(data.time, RAD2DEG * data.steer_angle_manual, 'DisplayName','steer cmd manual');
plot(data.time, RAD2DEG * data.steer_angle_lead_lag, 'DisplayName','steer lead lag');
plot(data.time, RAD2DEG * data.steer_angle_fb_cmd, 'DisplayName','steer cmd fb');
plot(data.time, RAD2DEG * data.steer_angle_ff_cmd, 'DisplayName','steer cmd ff');
plot(data.time, RAD2DEG * data.steering_wheel_angle_fbk, 'DisplayName','steer fbk');
plot(data.time, RAD2DEG * data.steer_angle_min, 'Color', 'k', 'DisplayName','steer min');
plot(data.time, RAD2DEG * data.steer_angle_max, 'Color', 'k', 'DisplayName','steer max');
ylim(1.1 * RAD2DEG * [min(data.steer_angle_min) max(data.steer_angle_max)])
legend show


% e lat - yaw-rate - steer
h                   = figure('numbertitle', 'off');
h.Name              = "LAT Bag " + i + ": " + "elat/r/steer";
tcl                 = tiledlayout(3,1);
tcl.TileSpacing     = 'compact';
tcl.Padding         = 'compact';
ax_time(end+1)=nexttile(1);

hold on
ylabel('lateral error [m]')
plot(data.time, data.lat_error,       'DisplayName','lateral error');
plot(data.time, -data.lat_error_filt, 'DisplayName','lateral error filt');legend show

ax_time(end+1)=nexttile(2);

hold on
ylabel('yaw rate [deg/s]')
plot(data.time, rad2deg(data.omega_z_hat), 'LineWidth',1.5,'DisplayName','yaw rate hat')
plot(data.time, rad2deg(data.yaw_rate_ref), 'LineWidth',1.5,'DisplayName','yaw rate ref')
legend show

ax_time(end+1)=nexttile(3);

hold on
ylabel('steer [deg]')
xlabel('time [s]')
plot(data.time, rad2deg(data.steer_angle_cmd), 'LineWidth',1.5, 'DisplayName','steer ctrl cmd')
legend show

% e lat - yaw-rate - beta

h                   = figure('numbertitle', 'off');
h.Name              = "LAT Bag " + i + ": " + "elat/r/beta";
tcl                 = tiledlayout(3,1);
tcl.TileSpacing     = 'compact';
tcl.Padding         = 'compact';
ax_time(end+1)=nexttile(1);

hold on
ylabel('lateral error [m]')
plot(data.time, data.lat_error,       'DisplayName','lateral error');
plot(data.time, -data.lat_error_filt, 'DisplayName','lateral error filt');legend show

ax_time(end+1)=nexttile(2);

hold on
ylabel('yaw rate [deg/s]')
plot(data.time, rad2deg(data.omega_z_hat), 'LineWidth',1.5,'DisplayName','yaw rate hat')
plot(data.time, rad2deg(data.yaw_rate_ref), 'LineWidth',1.5,'DisplayName','yaw rate ref')
legend show

ax_time(end+1)=nexttile(3);

hold on
ylabel('beta [deg]')
xlabel('time [s]')
plot(data.time, rad2deg(data.beta), 'LineWidth',1.5, 'DisplayName','sideslip angle')
legend show

% 
beta_dot = [0; diff(data.beta)] / Ts;
r_beta_dot = data.ay_hat ./data.vx_hat;

h                   = figure('numbertitle', 'off');
h.Name              = "LAT Bag " + i + ": " + "elat/r + betadot";
tcl                 = tiledlayout(3,1);
tcl.TileSpacing     = 'compact';
tcl.Padding         = 'compact';
ax_time(end+1)=nexttile(1);

hold on
ylabel('lateral error [m]')
plot(data.time, data.lat_error,       'DisplayName','lateral error');
plot(data.time, -data.lat_error_filt, 'DisplayName','lateral error filt');legend show

ax_time(end+1)=nexttile(2);

hold on
ylabel('yaw rate [deg/s]')
plot(data.time, rad2deg(data.omega_z_hat + beta_dot), 'Color', clr_matlab{3}, 'LineWidth',1.5,'DisplayName','r + beta dot')
plot(data.time, rad2deg(r_beta_dot), 'Color', clr_matlab{4}, 'LineWidth',1.5,'DisplayName','ay / v')
plot(data.time, rad2deg(data.curvature_curr .* data.vx_hat), 'Color', clr_matlab{5}, 'LineWidth',1.5,'DisplayName','rho * v')

plot(data.time, rad2deg(data.omega_z_hat), 'Color', clr_matlab{1}, 'LineWidth',1.5,'DisplayName','yaw rate hat')
plot(data.time, rad2deg(data.yaw_rate_ref), 'Color', clr_matlab{2}, 'LineWidth',1.5,'DisplayName','yaw rate ref')
legend show
ax_time(end+1)=nexttile(3);

hold on
ylabel('speed [kph]')
xlabel('time [s]')
plot(data.time, data.vx_hat * 3.6, 'LineWidth',1.5, 'DisplayName','speed')
legend show


%% Space

% speed -steer - elat
h                   = figure('numbertitle', 'off');
h.Name              = "LAT Bag " + i + ": " + "speed/steer";
tcl                 = tiledlayout(3,1);
tcl.TileSpacing     = 'compact';
tcl.Padding         = 'compact';
ax_space(end+1)=nexttile(1);
hold on
ylabel('vx [kph]')
scatter3(data.closest_idx_ref*0.5,MPS2KPH*data.vx_hat,data.time,[],data.lap_count,'.')
ax_space(end+1)=nexttile(2);
hold on
ylabel('steer [deg]'), xlabel('s [m]'),
scatter3(data.closest_idx_ref*0.5,rad2deg(data.steer_angle_cmd),data.time,[],data.lap_count,'.')
ax_space(end+1)=nexttile(3);
hold on
ylabel('elat [m]'), xlabel('s [m]'),
scatter3(data.closest_idx_ref*0.5, -data.lat_error_filt, data.time,[],data.lap_count,'.')

% speed -steer - throttle
h                   = figure('numbertitle', 'off');
h.Name              = "LAT Bag " + i + ": " + "speed/steer/throttle";
tcl                 = tiledlayout(3,1);
tcl.TileSpacing     = 'compact';
tcl.Padding         = 'compact';
ax_space(end+1)=nexttile(1);
hold on
ylabel('vx [kph]')
scatter3(data.closest_idx_ref*0.5,MPS2KPH*data.vx_hat,data.time,[],data.lap_count,'.')
ax_space(end+1)=nexttile(2);
hold on
ylabel('steer [deg]'), xlabel('s [m]'),
scatter3(data.closest_idx_ref*0.5,rad2deg(data.steer_angle_cmd),data.time,[],data.lap_count,'.')
ax_space(end+1)=nexttile(3);
hold on
ylabel('elat [m]'), xlabel('s [m]'),
scatter3(data.closest_idx_ref*0.5, data.throttle_long_cmd, data.time,[],data.lap_count,'.')

%% GG plot
h                   = figure('numbertitle', 'off');
h.Name              = "LAT Bag " + i + ": " + "gg plot";
tcl                 = tiledlayout(1,1);
tcl.TileSpacing     = 'compact';
tcl.Padding         = 'compact';
scatter(data.ay_hat / 9.81, data.ax_hat / 9.81,[],data.lap_count ,'filled')
axis equal,ylabel('ax [g]'), xlabel('ay [g]'),title('Lap');
cd = colorbar;

%% Lateral error projected on trajectory
clear num_laps 
num_laps = max(data.lap_count);
data.lap_count = fillmissing(data.lap_count, 'nearest');

ax_lap = [];
for i = 0:num_laps
    lap_sel_vec = data.lap_count == i;
    h                   = figure('numbertitle', 'off');
    h.Name              = "LAT Bag " + (i + 1) + ": " + "path/lateral error";
    tcl                 = tiledlayout(1,2);
    tcl.TileSpacing     = 'compact';
    tcl.Padding         = 'compact';
    ax_lap(end+1) = nexttile(1);
    scatter(data.x_hat(lap_sel_vec), data.y_hat(lap_sel_vec),[], data.lat_error(lap_sel_vec),'filled')
    axis equal,xlabel('x [m]'), ylabel('y [m]'),title('Lateral error');
    cd = colorbar;
    ax_lap(end+1) = nexttile(2);
    scatter(data.x_hat(lap_sel_vec), data.y_hat(lap_sel_vec),[], data.vx_hat(lap_sel_vec) * 3.6,'filled')
    axis equal,xlabel('x [m]'), ylabel('y [m]'),title('Speed');
    cd = colorbar;
end



%% Reference path
data.best_traj = fillmissing(data.best_traj, 'nearest');

for i = 0:num_laps
    lap_sel_vec = data.lap_count == i;

    h                   = figure('numbertitle', 'off');
    h.Name              = "LAT Bag " + (i + 1) + ": " + "path/lateral error";
    tcl                 = tiledlayout(1,1);
    tcl.TileSpacing     = 'compact';
    tcl.Padding         = 'compact';
    ax_lap(end+1) = nexttile(1); hold on;
    scatter(data.x_hat(lap_sel_vec), data.y_hat(lap_sel_vec),[], data.lat_error(lap_sel_vec),'.', 'DisplayName', 'Lateral Error')
    axis equal,xlabel('x [m]'), ylabel('y [m]');
    cd = colorbar;    
    traj_sel_vec = [10];
    for j = 1:length(traj_sel_vec)
        plot(traj_DB(traj_sel_vec(j) + 1).X, traj_DB(traj_sel_vec(j) + 1).Y, 'DisplayName', "Traj ref " + num2str(traj_sel_vec(j)))
    end    
    plot(traj_DB(22 + 1).X, traj_DB(22 + 1).Y, 'k','HandleVisibility','off')
    plot(traj_DB(23 + 1).X, traj_DB(23 + 1).Y, 'k','HandleVisibility','off')

    axis equal,xlabel('x [m]'), ylabel('y [m]'), legend show

end


linkaxes(ax_lap, 'xy')

% % understeer curve
% 
% idx_vec = data.vx_hat * 3.6 > 80;
% curv_real = calcCurvature(data.x_hat(idx_vec)',data.y_hat(idx_vec)',100,1);
% figure, hold on
% plot(data.curvature_curr(idx_vec))
% plot(curv_real)
% 
% h                   = figure('numbertitle', 'off');
% h.Name              = "LAT Bag " + i + ": " + "Understeer curve";
% tcl                 = tiledlayout(1,1);
% tcl.TileSpacing     = 'compact';
% tcl.Padding         = 'compact';
% scatter(data.ay_hat(idx_vec) / 9.81, rad2deg(data.steer_angle_cmd(idx_vec)- curv_real' * 3.115),[],data.lap_count(idx_vec),'filled')
% ylabel('$\delta - L \cdot \rho$ [deg]'), xlabel('ay [g]'),title('Lap'), colorbar
% 
% h                   = figure('numbertitle', 'off');
% h.Name              = "LAT Bag " + i + ": " + "Understeer curve";
% tcl                 = tiledlayout(1,1);
% tcl.TileSpacing     = 'compact';
% tcl.Padding         = 'compact';
% scatter(data.ay_hat(idx_vec) / 9.81, rad2deg(data.steer_angle_cmd(idx_vec) - curv_real' * 3.115),[],data.vx_hat(idx_vec) * 3.6,'filled')
% ylabel('$\delta - L \cdot \rho$ [deg]'), xlabel('ay [g]'),title('speed'), colorbar



