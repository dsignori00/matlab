%% Multibag
h                   = figure('numbertitle', 'off');
h.Name              = "[All bags] Space: actuators";
tcl                 = tiledlayout(3,1);
tcl.TileSpacing     = 'compact';
tcl.Padding         = 'compact';

% colors_lap = reshape(color_spacer(laps), n_bags);

ax_space(end+1) = nexttile(1); hold on, grid on, box on;
ylabel('Rear Slip [$\%$]');
for j = 1 : n_bags
    colors_lap = color_shades_brightness(colors.matlab{j}, bags{j}.traj_server.lap_count(end) - bags{j}.traj_server.lap_count(1) + 1, 0.5);
    for i = bags{j}.traj_server.lap_count(1) : bags{j}.traj_server.lap_count(end)
        idx_sel = i == bags{j}.traj_server.lap_count;
        idx_sel = ~conv(~idx_sel, true(padding_idxs,1), 'same');
        plot(bags{j}.traj_server.s(idx_sel), (bags{j}.estimation.wheel_slips(idx_sel, 3) + bags{j}.estimation.wheel_slips(idx_sel, 4)) * 50, 'Color', colors_lap{i-bags{j}.traj_server.lap_count(1)+1}, 'DisplayName', ['Bag ' num2str(j) ', lap ' num2str(i)]);
    end
end
ax_space(end+1) = nexttile(2); hold on, grid on, box on; legend show;
ylabel('Gear [-]');
for j = 1 : n_bags
    colors_lap = color_shades_brightness(colors.matlab{j}, bags{j}.traj_server.lap_count(end) - bags{j}.traj_server.lap_count(1) + 1, 0.5);
    for i = bags{j}.traj_server.lap_count(1) : bags{j}.traj_server.lap_count(end)
        idx_sel = i == bags{j}.traj_server.lap_count;
        idx_sel = ~conv(~idx_sel, true(padding_idxs,1), 'same');
        plot(bags{j}.traj_server.s(idx_sel), bags{j}.vehicle_fbk.current_gear(idx_sel), 'Color', colors_lap{i-bags{j}.traj_server.lap_count(1)+1}, 'DisplayName', ['Bag ' num2str(j) ', lap ' num2str(i)]);
    end
end
legend('Location','eastoutside')
ax_space(end+1) = nexttile(3); hold on, grid on, box on;
ylabel('Yaw rate [deg/s]');
for j = 1 : n_bags
    colors_lap = color_shades_brightness(colors.matlab{j}, bags{j}.traj_server.lap_count(end) - bags{j}.traj_server.lap_count(1) + 1, 0.5);
    for i = bags{j}.traj_server.lap_count(1) : bags{j}.traj_server.lap_count(end)
        idx_sel = i == bags{j}.traj_server.lap_count;
        idx_sel = ~conv(~idx_sel, true(padding_idxs,1), 'same');
        plot(bags{j}.traj_server.s(idx_sel),  180/pi * bags{j}.estimation.yaw_rate(idx_sel), 'Color', colors_lap{i-bags{j}.traj_server.lap_count(1)+1}, 'DisplayName', ['Bag ' num2str(j) ', lap ' num2str(i)]);
    end
end
xlabel('Curvilinear abscissa [m]');