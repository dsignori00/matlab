%% Multibag
h                   = figure('numbertitle', 'off');
h.Name              = "[All bags] Space: control";
tcl                 = tiledlayout(3,1);
tcl.TileSpacing     = 'compact';
tcl.Padding         = 'compact';

% colors_lap = reshape(color_spacer(laps), n_bags);

laps = [5;
        5];

ax_space(end+1) = nexttile(1); hold on, grid on, box on;
ylabel('Steer [deg]');
legend_vec = {'PROTO 1'; 'PROTO 2'};
for j = 1 : n_bags
    colors_lap = color_shades_brightness(colors.matlab{j}, bags{j}.traj_server.lap_count(end) - bags{j}.traj_server.lap_count(1) + 1, 0.5);
    for i = bags{j}.traj_server.lap_count(1) : bags{j}.traj_server.lap_count(end)
        idx_sel = i == bags{j}.traj_server.lap_count & any(i == laps(j,:));
        idx_sel = ~conv(~idx_sel, true(padding_idxs,1), 'same');
        plot(bags{j}.traj_server.s(idx_sel), bags{j}.control__lateral__command.steer_angle(idx_sel) * 180/pi, 'Color', colors_lap{i-bags{j}.traj_server.lap_count(1)+1}, 'DisplayName', [legend_vec{j} ', lap ' num2str(i)]);
    end
end
ax_space(end+1) = nexttile(2); hold on, grid on, box on; legend show;
ylabel('Velocity [kph]');
for j = 1 : n_bags
    colors_lap = color_shades_brightness(colors.matlab{j}, bags{j}.traj_server.lap_count(end) - bags{j}.traj_server.lap_count(1) + 1, 0.5);
    for i = bags{j}.traj_server.lap_count(1) : bags{j}.traj_server.lap_count(end)
        idx_sel = i == bags{j}.traj_server.lap_count & any(i == laps(j,:));
        idx_sel = ~conv(~idx_sel, true(padding_idxs,1), 'same');
        plot(bags{j}.traj_server.s(idx_sel), bags{j}.estimation.vx(idx_sel) * MPS2KPH, 'Color', colors_lap{i-bags{j}.traj_server.lap_count(1)+1}, 'DisplayName', [legend_vec{j}  ', lap ' num2str(i)]);
    end
end
legend('Location','eastoutside')
ax_space(end+1) = nexttile(3); hold on, grid on, box on;
ylabel('Trajectory tracking error [m]');
for j = 1 : n_bags
    colors_lap = color_shades_brightness(colors.matlab{j}, bags{j}.traj_server.lap_count(end) - bags{j}.traj_server.lap_count(1) + 1, 0.5);
    for i = bags{j}.traj_server.lap_count(1) : bags{j}.traj_server.lap_count(end)
        idx_sel = i == bags{j}.traj_server.lap_count & any(i == laps(j,:));
        idx_sel = ~conv(~idx_sel, true(padding_idxs,1), 'same');
        plot(bags{j}.traj_server.s(idx_sel),  bags{j}.control__lateral__command.lat_error(idx_sel), 'Color', colors_lap{i-bags{j}.traj_server.lap_count(1)+1}, 'DisplayName', [legend_vec{j}  ', lap ' num2str(i)]);
    end
end
xlabel('Curvilinear abscissa [m]');