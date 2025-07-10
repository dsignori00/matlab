h                   = figure('numbertitle', 'off');
h.Name              = "[Log" + i_log + "] Track map";
tcl                 = tiledlayout(1,1);
tcl.TileSpacing     = 'compact';
tcl.Padding         = 'compact';

% Track boundaries

ax_xy(end+1) = nexttile(1); hold on, grid on, box on; axis equal;

xlabel('X [m]');
ylabel('Y [m]');
plot(traj_DB(22 + 1).X, traj_DB(22 + 1).Y, 'k', 'HandleVisibility', 'off')
plot(traj_DB(23 + 1).X, traj_DB(23 + 1).Y, 'k', 'HandleVisibility', 'off')
plot(traj_DB(11).X, traj_DB(11).Y, '--k', 'HandleVisibility', 'off')
legend

% Positions

refresh_xy_plot(0, 0, log, traj_DB);

% Refresh button

c = uicontrol('Style','pushbutton');
c.String = {'Refresh'};
c.Callback = @(src,event) refresh_xy_plot(src, event, log, traj_DB);

% Refresh callback

function refresh_xy_plot(src, event, log, traj_DB)
    
    % Get vector of axes from base workspace
    ax_time = evalin('base', 'ax_time');
    ax_space = evalin('base', 'ax_space');

    % Delete previous plots
    delete(findall(gca, 'Tag', 'dynamic'));

    % Get time limits
    if ~isempty(ax_time)
        time_limits = xlim(ax_time(1));
    else
        time_limits = [min(log.traj_server.bag_stamp) max(log.traj_server.bag_stamp)];
    end

    % Get space limits
    if ~isempty(ax_space)
        s_limits = xlim(ax_space(1));
        s_start = s_limits(1);
        s_end = s_limits(2);
    else
        s_start = -inf;
        s_end = inf;
    end
    
    % Draw patch on selected track region
    if s_start > traj_DB(24 + 1).S(1) || s_end < traj_DB(24 + 1).S(end)
        % Find start and and idx
        [~, s_idx_start] = min(abs(s_start - traj_DB(24 + 1).S));
        [~, s_idx_end] = min(abs(s_end - traj_DB(24 + 1).S));
        
        % Ensure vectors are column vectors for consistency
        line1_x = traj_DB(22 + 1).X(s_idx_start:s_idx_end);
        line1_y = traj_DB(22 + 1).Y(s_idx_start:s_idx_end);
        line2_x = traj_DB(23 + 1).X(s_idx_start:s_idx_end);
        line2_y = traj_DB(23 + 1).Y(s_idx_start:s_idx_end);
        
        % Create the coordinates for the patch by combining both lines
        patch_x = [line1_x; flipud(line2_x)];
        patch_y = [line1_y; flipud(line2_y)];
        
        % Draw the patch
        uistack(patch(patch_x, patch_y, 'yellow', 'EdgeColor', 'none', 'FaceAlpha', 0.6, 'Tag', 'dynamic', 'HandleVisibility', 'off'), 'bottom');
    end

    % Get number of laps and colors
    n_laps = double(log.traj_server.lap_count(end) - log.traj_server.lap_count(1) + 1);
    colors_lap = color_spacer(max(2,n_laps));

    % Plot positions
    for i = log.traj_server.lap_count(1) : log.traj_server.lap_count(end)
        lap_timespan = log.traj_server.bag_stamp(log.traj_server.lap_count == i);
        sel_idxs = log.estimation.bag_stamp >= max(lap_timespan(1), time_limits(1)) & log.estimation.bag_stamp <= min(lap_timespan(end), time_limits(2)) & ~isnan(log.estimation.x_cog) & ~isnan(log.estimation.y_cog);   
        if any(sel_idxs)
            x_cog = log.estimation.x_cog(sel_idxs);
            y_cog = log.estimation.y_cog(sel_idxs);
            scatter(x_cog, y_cog, 5, colors_lap{i-log.traj_server.lap_count(1)+1}, 'filled', 'DisplayName', ['lap ' num2str(i)], 'Tag', 'dynamic');
        end
    end

end
