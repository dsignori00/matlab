h                   = figure('numbertitle', 'off');
h.Name              = "[Log" + i_log + "] Dynamics: tires xy map";
tcl                 = tiledlayout(2,2);
tcl.TileSpacing     = 'tight';
tcl.Padding         = 'compact';

% Track boundaries

for i = 1 : 4

    ax_xy(end+1) = nexttile(i); hold on, grid on, box on; axis equal;

    plot(traj_DB(22 + 1).X, traj_DB(22 + 1).Y, 'k', 'HandleVisibility', 'off')
    plot(traj_DB(23 + 1).X, traj_DB(23 + 1).Y, 'k', 'HandleVisibility', 'off')
    plot(traj_DB(11).X, traj_DB(11).Y, '--k', 'HandleVisibility', 'off')

end

refresh_xy_plot(0, 0, ax_time, log, traj_DB)

% Refresh button
c = uicontrol('Style','pushbutton');
c.String = {'Refresh'};
c.Callback = @(src,event) refresh_xy_plot(src, event, ax_time, log, traj_DB);

% Refresh callback

function refresh_xy_plot(src, event, ax_time, log, traj_DB)

    % Get time limits
    if ~isempty(ax_time)
        time_limits = xlim(ax_time(1));
    else
        time_limits = [min(log.time) max(log.time)];
    end

    % Get all 4 axes
    ax_wheels = findobj(gcf, 'Type', 'axes');

    % Delete previous plots
    delete(findall(ax_wheels, 'Tag', 'dynamic'));

    % Get selected indexes and positions
    sel_idxs = log.estimation.bag_stamp >= time_limits(1) & log.estimation.bag_stamp <= time_limits(2) & ~isnan(log.estimation.x_cog) & ~isnan(log.estimation.y_cog);   
    x_cog = log.estimation.x_cog(sel_idxs);
    y_cog = log.estimation.y_cog(sel_idxs);

    % Plot slips
    if any(sel_idxs)
        
        ax_wheels(tilenum(ax_wheels)) = ax_wheels;

        title(ax_wheels(1), 'Front wheels long. slip [\%]')
        scatter(ax_wheels(1), x_cog, y_cog, 5, (log.estimation.wheel_slips(sel_idxs,1)+log.estimation.wheel_slips(sel_idxs,2))*50, 'filled', 'Tag', 'dynamic');
        colorbar(ax_wheels(1));
        clim(ax_wheels(1), [-20 20])

        title(ax_wheels(2), 'Front wheels slip angle [deg]')
        scatter(ax_wheels(2), x_cog, y_cog, 5, 180/pi*(log.estimation.alpha(sel_idxs,1)+log.estimation.alpha(sel_idxs,2))/2, 'filled', 'Tag', 'dynamic');
        colorbar(ax_wheels(2));
        clim(ax_wheels(2), [0 5])

        title(ax_wheels(3), 'Rear wheels long. slip [\%]')
        scatter(ax_wheels(3), x_cog, y_cog, 5, (log.estimation.wheel_slips(sel_idxs,3)+log.estimation.wheel_slips(sel_idxs,4))*50, 'filled', 'Tag', 'dynamic');
        colorbar(ax_wheels(3));
        clim(ax_wheels(3), [-20 20])      

        title(ax_wheels(4), 'Rear wheels slip angle [deg]')
        scatter(ax_wheels(4), x_cog, y_cog, 5, 180/pi*(log.estimation.alpha(sel_idxs,3)+log.estimation.alpha(sel_idxs,4))/2, 'filled', 'Tag', 'dynamic');
        colorbar(ax_wheels(4));
        clim(ax_wheels(4), [0 5])

    end

end
