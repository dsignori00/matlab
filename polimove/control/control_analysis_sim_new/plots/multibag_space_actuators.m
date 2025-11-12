h                   = figure('numbertitle', 'off');
h.Name              = "[All bags] Space: actuators";
tcl                 = tiledlayout(4,1);
tcl.TileSpacing     = 'compact';
tcl.Padding         = 'compact';

ax_space(end+1) = nexttile(1); hold on, grid on, box on;
ylabel('Throttle [-]');
for j = 1 : n_bags
    colors_lap = color_shades_brightness(colors.matlab{j}, bags{j}.traj_server.lap_count(end) - bags{j}.traj_server.lap_count(1) + 1, 0.5);
    for i = bags{j}.traj_server.lap_count(1) : bags{j}.traj_server.lap_count(end)
        if (isempty(laps) || ismember(i, laps))
            idx_sel = i == bags{j}.traj_server.lap_count;
            idx_sel = ~conv(~idx_sel, true(padding_idxs,1), 'same');
            plot(bags{j}.traj_server.s(idx_sel), bags{j}.vehicle_fbk.throttle_position(idx_sel), 'Color', colors_lap{i-bags{j}.traj_server.lap_count(1)+1}, 'DisplayName', ['Bag ' num2str(j) ', lap ' num2str(i)]);
        end
    end
end

ax_space(end+1) = nexttile(2); hold on, grid on, box on;
ylabel('Gear [-]');
for j = 1 : n_bags
    colors_lap = color_shades_brightness(colors.matlab{j}, bags{j}.traj_server.lap_count(end) - bags{j}.traj_server.lap_count(1) + 1, 0.5);
    for i = bags{j}.traj_server.lap_count(1) : bags{j}.traj_server.lap_count(end)
        if (isempty(laps) || ismember(i, laps))
            idx_sel = i == bags{j}.traj_server.lap_count;
            idx_sel = ~conv(~idx_sel, true(padding_idxs,1), 'same');
            plot(bags{j}.traj_server.s(idx_sel), bags{j}.vehicle_fbk.current_gear(idx_sel), 'Color', colors_lap{i-bags{j}.traj_server.lap_count(1)+1}, 'DisplayName', ['Bag ' num2str(j) ', lap ' num2str(i)]);
        end
    end
end

ax_space(end+1) = nexttile(3); hold on, grid on, box on;
ylabel('Brake [bar]');
for j = 1 : n_bags
    colors_lap = color_shades_brightness(colors.matlab{j}, bags{j}.traj_server.lap_count(end) - bags{j}.traj_server.lap_count(1) + 1, 0.5);
    for i = bags{j}.traj_server.lap_count(1) : bags{j}.traj_server.lap_count(end)
        if (isempty(laps) || ismember(i, laps))
            idx_sel = i == bags{j}.traj_server.lap_count;
            idx_sel = ~conv(~idx_sel, true(padding_idxs,1), 'same');
            plot(bags{j}.traj_server.s(idx_sel), PA2BAR * bags{j}.control__long__command.brake(idx_sel), 'Color', colors_lap{i-bags{j}.traj_server.lap_count(1)+1}, 'DisplayName', ['Bag ' num2str(j) ', lap ' num2str(i)]);
        end
    end
end

ax_space(end+1) = nexttile(4); hold on, grid on, box on; legend show;
ylabel('Steer [deg]');
for j = 1 : n_bags
    colors_lap = color_shades_brightness(colors.matlab{j}, bags{j}.traj_server.lap_count(end) - bags{j}.traj_server.lap_count(1) + 1, 0.5);
    for i = bags{j}.traj_server.lap_count(1) : bags{j}.traj_server.lap_count(end)
        if (isempty(laps) || ismember(i, laps))
            idx_sel = i == bags{j}.traj_server.lap_count;
            idx_sel = ~conv(~idx_sel, true(padding_idxs,1), 'same');
            plot(bags{j}.traj_server.s(idx_sel), 180/pi * bags{j}.control__lateral__command.steer_angle(idx_sel), 'Color', colors_lap{i-bags{j}.traj_server.lap_count(1)+1}, 'DisplayName', ['Bag ' num2str(j) ', lap ' num2str(i)]);
        end
    end
end


xlabel('Curvilinear abscissa [m]');