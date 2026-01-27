figure("Name","Error - Summary")

% Button
b = b + 1;
c(b) = uicontrol('Style','pushbutton', ...
    'String','Refresh', ...
    'Units','normalized', ...
    'Position',[0.01 0.01 0.1 0.05], ...
    'Callback',@refreshErrorSummaryButtonPushed);

function refreshErrorSummaryButtonPushed(~,~)

    % --- fetch from base ---
    sensors  = evalin('base','sensors');
    ax       = evalin('base','ax');
    err_thr  = evalin('base','err_thr');

    % --- compute stats ---
    for k = 1:numel(sensors)
        s = sensors{k}.s;

        % time window
        t_lim = xlim(ax(1));                        
        [t1, tend] = timeWindowIdx(s.sens_stamp, t_lim);
        time = zeros(size(s.sens_stamp));
        time(t1:tend) = 1;

        ass = hypot(s.x_map_err, s.y_map_err) < err_thr;
        time_mat = repmat(time, 1, size(s.x_map_err,2));
        idx = ass & time_mat;

        stats = {'x_rel','y_rel','yaw_map'};
        for l = stats
            s.([l{1} '_std'])  = std(s.([l{1} '_err'])(idx));
            s.([l{1} '_mean']) = mean(s.([l{1} '_err'])(idx));
        end

        if sensors{k}.has_rho_dot
            s.rho_dot_std  = std(s.rho_dot_err(idx));
            s.rho_dot_mean = mean(s.rho_dot_err(idx));
        end

        [s.x_ellipse, s.y_ellipse] = calculate_ellipse( ...
            s.x_rel_std, s.y_rel_std, s.x_rel_mean, s.y_rel_mean);

        sensors{k}.s = s;  
    end

    % --- Positional errors (ellipse) ---
    subplot(2,2,[1 3]); cla reset; hold on; grid on; axis equal;
    for i = 1:numel(sensors)
        plot(sensors{i}.s.y_ellipse, sensors{i}.s.x_ellipse, ...
            'Color',sensors{i}.col,'LineWidth',2,'DisplayName',sensors{i}.name)
        scatter(sensors{i}.s.y_rel_mean, sensors{i}.s.x_rel_mean, ...
            'o','MarkerFaceColor',sensors{i}.col,'MarkerEdgeColor',sensors{i}.col,...
            'HandleVisibility','off')
    end

    xline(0,'--','LineWidth',0.3,'HandleVisibility','off')
    yline(0,'--','LineWidth',0.3,'HandleVisibility','off')
    title('Positional Errors')
    xlabel('y rel [m]'); ylabel('x rel [m]'); legend show;

    % --- Range-rate error (Radar only) ---
    rho_dot_idx = find(cellfun(@(s) s.has_rho_dot, sensors));
    subplot(2,2,2); hold on; grid on; 
    boxplot(sensors{rho_dot_idx(1)}.s.rho_dot_err(:), 'Symbol', '')
    xline(0, '--', 'LineWidth', 0.3, 'HandleVisibility', 'off')
    title('Range Rate Error'); ylabel('range rate [m/s]'); xlabel(sensors{rho_dot_idx(1)}.name); 
    ylim([-sensors{rho_dot_idx(1)}.s.rho_dot_std, sensors{rho_dot_idx(1)}.s.rho_dot_std]), xlim([0.8 1.2]); xticklabels([])


    % --- Heading error ---
    subplot(2,2,4); hold on; grid on; 

    yaw_err = [];
    group   = {};
    YawMaxStd = 0;

    for i = 1:numel(sensors)
        e = rad2deg(sensors{i}.s.yaw_map_err(:));
        yaw_err = [yaw_err; e];
        group   = [group; repmat({sensors{i}.name}, numel(e), 1)];
        YawMaxStd = max(YawMaxStd, rad2deg(sensors{i}.s.yaw_map_std));
    end

    boxplot(yaw_err, group, 'Symbol','')
    yline(0,'--','LineWidth',0.3,'HandleVisibility','off')
    title('Heading Error')
    ylabel('[deg]')
    ylim([-2*YawMaxStd 2*YawMaxStd])

end