figure('Name','Dataset overview', 'NumberTitle', 'off');

% Button
c = c + 1;
b(c) = uicontrol('Style','pushbutton', ...
    'String','Refresh', ...
    'Units','normalized', ...
    'Position',[0.01 0.01 0.1 0.05], ...
    'Callback',@refreshTimeButtonPushed);

function refreshTimeButtonPushed(~, ~)

    % --- fetch from base ---
    ax           = evalin('base','axes');
    log          = evalin('base','log');
    tt           = evalin('base','tt');
    sensors      = evalin('base','sensors');
    use_ref      = evalin('base','use_ref');
    use_sim_ref  = evalin('base','use_sim_ref');

    if use_ref || use_sim_ref
        gt = evalin('base','gt');
    end

    alpha = 0.5;

    % --- time window ---
    t_lim = xlim(ax(1));

    [t1_log, tend_log] = timeWindowIdx(tt.stamp, t_lim);
    if use_ref || use_sim_ref
        [t1_gt, tend_gt] = timeWindowIdx(gt.stamp, t_lim);
    end

    % --- range ---
    lgd_str = {"ground truth"};
    ydata  = gt.rho(t1_gt:tend_gt);
    clabel = repmat("ground truth", numel(ydata), 1);

    for i = 1:numel(sensors)
        s = sensors{i}.s;
        [i1, i2] = timeWindowIdx(s.sens_stamp, t_lim);
        r = sqrt(s.x_rel(i1:i2).^2 + s.y_rel(i1:i2).^2);
        r = r(:);
        ydata  = [ydata; r];
        clabel = [clabel; repmat(string(sensors{i}.name), numel(r), 1)];
        lgd_str{end+1} = string(sensors{i}.name);
    end

    tiledlayout(2,2, 'TileSpacing','compact', 'Padding','compact');
    nexttile; cla reset; hold on; grid on;

    xgroup = categorical(repmat("Range", numel(ydata), 1));
    order = ["ground truth", string(cellfun(@(z) z.name, sensors, 'UniformOutput', false))];
    cgroup = categorical(clabel, order);


    violinplot(xgroup, ydata, GroupByColor=cgroup, FaceAlpha=alpha);
    ylabel('range [m]'); set(gca,'XTickLabel',[]); 
    legend(lgd_str, 'Orientation','horizontal', 'Location','southoutside');

    % --- detection rate ---
    nexttile; cla reset; hold on; grid on;
    camera_rate = log.perception__opponents.opponents__cam_yolo_meas(t1_log:tend_log,1);
    lidar_rate  = log.perception__opponents.opponents__lid_clust_meas(t1_log:tend_log,1) - camera_rate;
    pp_rate     = log.perception__opponents.opponents__lid_pp_meas(t1_log:tend_log,1) - lidar_rate - camera_rate;
    radar_rate  = log.perception__opponents.opponents__rad_clust_meas(t1_log:tend_log,1) - pp_rate - lidar_rate - camera_rate;
    
    ydata = [lidar_rate; pp_rate; radar_rate];
    xgroup = categorical(repmat("All Rates", length(ydata), 1));

    co = get(gca,'ColorOrder');
    set(gca,'ColorOrder', co([2:end 1],:));

    cgroup = categorical([ ...
        repmat("Lidar",  length(lidar_rate),  1);
        repmat("PP",     length(pp_rate),     1)
        repmat("Radar",  length(radar_rate),  1);
    ]);
    violinplot(xgroup, ydata, GroupByColor=cgroup, FaceAlpha=alpha);
    ylabel('detection rate [Hz]'); set(gca,'xticklabel',[]);

    % --- velocity ---
    nexttile; cla reset; hold on; grid on;
    violinplot(gt.vx(t1_gt:tend_gt), FaceAlpha=alpha);
    ylabel('vx [m/s]'); set(gca,'xticklabel',[]);

    % --- acceleration ---
    nexttile; cla reset; hold on; grid on;
    violinplot(gt.ax(t1_gt:tend_gt), FaceAlpha=alpha);
    ylabel('ax [m/s]'); set(gca,'xticklabel',[]);

end
