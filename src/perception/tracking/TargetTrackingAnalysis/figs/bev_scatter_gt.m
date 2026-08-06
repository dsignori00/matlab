%#ok<*UNRCH>
%#ok<*INUSD>

%% BEV - Ground truth vs sensor detections (time-synced + spatially linked)
% One figure per sensor (lidar pointpillars, lidar clustering, radar,
% camera).
%
%   - Each figure has its own "Refresh" button, exactly like map.m /
%     q_map.m: it reads the time window currently selected on the shared
%     linked (time) axes (ax(1) = xlim) and redraws gt + sensor scatter
%     only within that window.
%   - The 4 BEV axes are ALSO linked to each other in x AND y (linkaxes
%     'xy'), so zooming/panning on one of them zooms/pans all the others
%     too (they all share the same map frame, in meters).
%
% NOTE: as with map.m/q_map.m, press "Refresh" once after opening the
% figure to draw it the first time, then again every time you zoom/pan
% the shared TIME axis on any of the linked time plots. The spatial
% zoom/pan (x/y) is instead live-linked by MATLAB itself, no button
% needed for that.

%% Create the 4 figures + axes (created upfront so they can be linked)
bev_ax = gobjects(1,4);

bev_titles = { ...
    'BEV - GT vs Lidar PointPillars'; ...
    'BEV - GT vs Lidar Clustering'; ...
    'BEV - GT vs Radar'; ...
    'BEV - GT vs Camera' ...
};

for k = 1:4
    figure('name', bev_titles{k}, 'NumberTitle', 'off');
    % NOTE: use subplot(1,1,1) rather than axes(...) to get the axes
    % handle: "axes" is shadowed in this workspace by the shared
    % time-axes-list variable (axes = [] ...), so calling the builtin
    % axes() function here would actually read that variable instead.
    bev_ax(k) = subplot(1,1,1);
    hold(bev_ax(k), 'on'); grid(bev_ax(k), 'on'); axis(bev_ax(k), 'equal');
    xlabel(bev_ax(k), 'x [m]'); ylabel(bev_ax(k), 'y [m]');
    title(bev_ax(k), bev_titles{k}, 'Interpreter', 'none');
end

% --- link the 4 BEV axes together (spatial zoom/pan shared) ---
linkaxes(bev_ax, 'xy');

% --- add a "Refresh" button on top of each figure ---
c = c + 1;
b(c) = uicontrol('Parent', get(bev_ax(1), 'Parent'), 'Style', 'pushbutton', ...
    'String', 'Refresh', 'Units', 'normalized', ...
    'Position', [0.01 0.01 0.1 0.05], 'Callback', @refreshBevPPButtonPushed);

c = c + 1;
b(c) = uicontrol('Parent', get(bev_ax(2), 'Parent'), 'Style', 'pushbutton', ...
    'String', 'Refresh', 'Units', 'normalized', ...
    'Position', [0.01 0.01 0.1 0.05], 'Callback', @refreshBevLidarButtonPushed);

c = c + 1;
b(c) = uicontrol('Parent', get(bev_ax(3), 'Parent'), 'Style', 'pushbutton', ...
    'String', 'Refresh', 'Units', 'normalized', ...
    'Position', [0.01 0.01 0.1 0.05], 'Callback', @refreshBevRadarButtonPushed);

c = c + 1;
b(c) = uicontrol('Parent', get(bev_ax(4), 'Parent'), 'Style', 'pushbutton', ...
    'String', 'Refresh', 'Units', 'normalized', ...
    'Position', [0.01 0.01 0.1 0.05], 'Callback', @refreshBevCameraButtonPushed);

% --- make bev_ax reachable from the callbacks (they run via evalin('base', ...)) ---
assignin('base', 'bev_ax', bev_ax);

%% Callbacks (one per sensor, each targets its own slot in bev_ax)
function refreshBevPPButtonPushed(~, ~)
    refreshBevGeneric('pointpillars', 'BEV - GT vs Lidar PointPillars', 1);
end

function refreshBevLidarButtonPushed(~, ~)
    refreshBevGeneric('lidar', 'BEV - GT vs Lidar Clustering', 2);
end

function refreshBevRadarButtonPushed(~, ~)
    refreshBevGeneric('radar', 'BEV - GT vs Radar', 3);
end

function refreshBevCameraButtonPushed(~, ~)
    refreshBevGeneric('camera', 'BEV - GT vs Camera', 4);
end

%% Shared drawing routine (used by all 4 callbacks above)
function refreshBevGeneric(sensor_name, fig_title, ax_slot)

    % --- fetch from base ---
    ax          = evalin('base', 'axes');    % shared TIME axes (for t_lim)
    bev_ax      = evalin('base', 'bev_ax');  % the 4 linked BEV axes
    sensors     = evalin('base', 'sensors');
    col         = evalin('base', 'col');
    use_ref     = evalin('base', 'use_ref');
    use_sim_ref = evalin('base', 'use_sim_ref');
    if use_ref || use_sim_ref
        gt = evalin('base', 'gt');
    end

    ax_bev = bev_ax(ax_slot);

    % --- find the sensor inside "sensors" ---
    idx = [];
    for i = 1:numel(sensors)
        if strcmpi(sensors{i}.name, sensor_name)
            idx = i;
            break;
        end
    end
    if isempty(idx)
        cla(ax_bev, 'reset');
        title(ax_bev, sprintf('Sensore "%s" non trovato in "sensors"', sensor_name), 'Interpreter', 'none');
        return
    end
    s = sensors{idx}.s;

    % --- time window from the shared linked (time) axes ---
    % NOTE: this "ax" list/link ('x' only) is a completely separate
    % group from "bev_ax" (linked 'xy' among the 4 BEV only, see the
    % top of this file). ax(1) is just used to read back whatever time
    % window the user currently has selected on the OTHER time plots
    % (range, speed_acc, ...). If that window is not valid/sensible
    % (e.g. no time plot has been zoomed/drawn yet, or ax is empty),
    % fall back to the full extent so the BEV is never left empty.
    if isempty(ax) || ~any(isgraphics(ax))
        t_lim = [-inf inf];
    else
        t_lim = xlim(ax(1));
        if any(isnan(t_lim)) || diff(t_lim) <= 0
            t_lim = [-inf inf];
        end
    end

    % --- reset the BEV axes (keeping it linked: cla, not full reset) ---
    cla(ax_bev);
    % NOTE: linkaxes() sets XLimMode/YLimMode to 'manual' on all linked
    % axes to keep them in sync. That means once they're linked, adding
    % new data does NOT auto-fit the view anymore: the axes stays stuck
    % on whatever range it had when the link was created (here: the
    % default [0 1], since the axes were empty at creation time).
    % Force auto mode back on before plotting so the view fits the data,
    % then re-apply 'equal' (which may nudge one of the two ranges to
    % preserve a 1:1 aspect, that's expected).
    ax_bev.XLimMode = 'auto';
    ax_bev.YLimMode = 'auto';
    hold(ax_bev, 'on'); grid(ax_bev, 'on');
    xlabel(ax_bev, 'x [m]'); ylabel(ax_bev, 'y [m]');
    title(ax_bev, fig_title, 'Interpreter', 'none');

    % --- ground truth, cropped to the time window ---
    if use_ref || use_sim_ref
        [t1_gt, tend_gt] = timeWindowIdx(gt.stamp, t_lim);
        if ~isempty(t1_gt) && ~isempty(tend_gt)
            plot(ax_bev, gt.x_map(t1_gt:tend_gt), gt.y_map(t1_gt:tend_gt), ...
                'Color', col.ref, 'LineWidth', 1.5, 'DisplayName', 'gt');
        end
    end

    % --- sensor detections, cropped to the time window ---
    [i1, i2] = timeWindowIdx(s.sens_stamp, t_lim);
    if ~isempty(i1) && ~isempty(i2)
        x_meas = s.x_map(i1:i2, :); x_meas = x_meas(:);
        y_meas = s.y_map(i1:i2, :); y_meas = y_meas(:);
        valid  = ~isnan(x_meas) & ~isnan(y_meas);
        x_meas = x_meas(valid);
        y_meas = y_meas(valid);

        scatter(ax_bev, x_meas, y_meas, 25, sensors{idx}.col, 'filled', ...
            'MarkerFaceAlpha', 0.6, 'DisplayName', sensors{idx}.name);
    end

    axis(ax_bev, 'equal');
    legend(ax_bev, 'show', 'Interpreter', 'none');
end