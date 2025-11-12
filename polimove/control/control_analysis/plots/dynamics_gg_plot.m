h                   = figure('numbertitle', 'off');
h.Name              = "[Log" + i_log + "] Dynamics: GG plot";
tcl                 = tiledlayout(1,1);
tcl.TileSpacing     = 'compact';
tcl.Padding         = 'compact';

% GG plot

ax_gg(end+1) = nexttile(1); hold on, grid on, box on; axis equal;

xlabel('Lat. acc. [g]');
ylabel('Long. acc. [g]');
xlim([-max(abs(log.estimation.ay)) max(abs(log.estimation.ay))] / 9.81);
ylim([min(log.estimation.ax) max(log.estimation.ax)] / 9.81);
legend

% Accelerations

refresh_gg_plot(0, 0, ax_time, log)

% Refresh button

c = uicontrol('Style','pushbutton');
c.String = {'Refresh'};
c.Callback = @(src,event) refresh_gg_plot(src, event, ax_time, log);


% Refresh callback

function refresh_gg_plot(src, event, ax_time, log)

    % Get time limits
    if ~isempty(ax_time)
        time_limits = xlim(ax_time(1));
    else
        time_limits = [min(log.traj_server.bag_stamp) max(log.traj_server.bag_stamp)];
    end

    % Delete previous plots
    delete(findall(gca, 'Tag', 'dynamic'));

    % Get number of laps and colors
    n_laps = double(log.traj_server.lap_count(end) - log.traj_server.lap_count(1) + 1);
    colors_lap = color_spacer(max(2,n_laps));

    % Plot accelerations
    for i = log.traj_server.lap_count(1) : log.traj_server.lap_count(end)
        lap_timespan = log.traj_server.bag_stamp(log.traj_server.lap_count == i);
        sel_idxs = log.estimation.bag_stamp >= max(lap_timespan(1), time_limits(1)) & log.estimation.bag_stamp <= min(lap_timespan(end), time_limits(2)) & ~isnan(log.estimation.x_cog) & ~isnan(log.estimation.y_cog);   
        if any(sel_idxs)
            scatter(-log.estimation.ay(sel_idxs) / 9.81, log.estimation.ax(sel_idxs) / 9.81, 5, colors_lap{i-log.traj_server.lap_count(1)+1}, 'filled', 'DisplayName', ['lap ' num2str(i)], 'Tag', 'dynamic');
        end
    end

end

