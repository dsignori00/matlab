%#ok<*UNRCH>
%#ok<*INUSD>

%% MAP
fig3 = figure('name','MAP', 'NumberTitle', 'off');
% axMap = axes('Parent',fig3);
% Button
c = uicontrol('Style','pushbutton', ...
    'String','Refresh', ...
    'Units','normalized', ...
    'Position',[0.01 0.01 0.1 0.05], ...
    'Callback',@refreshMap);

function refreshMap(src, event)

    % --- fetch from base ---
    ax         = evalin('base', 'ax');
    bag1       = evalin('base', 'bag1');
    FOOTPRINT  = evalin('base', 'FOOTPRINT');

    L = 0.3 * FOOTPRINT.length; 

    % --- time window ---
    t_lim = xlim(ax(1));

    [ego_t1, ego_tend] = timeWindowIdx(bag1.ego.stamp, t_lim);
    [debug_t1, debug_tend] = timeWindowIdx(bag1.debug.stamp, t_lim);
    [line_t1, line_tend] = timeWindowIdx(bag1.lines.stamp, t_lim);

    x0_debug = interp1(bag1.ego.stamp(ego_t1:ego_tend), bag1.ego.x(ego_t1:ego_tend), bag1.debug.stamp(debug_t1:debug_tend));
    y0_debug = interp1(bag1.ego.stamp(ego_t1:ego_tend), bag1.ego.y(ego_t1:ego_tend), bag1.debug.stamp(debug_t1:debug_tend));

    % rotate line endpoints to world frame
    x0_line = interp1(bag1.ego.stamp(ego_t1:ego_tend), bag1.ego.x(ego_t1:ego_tend), bag1.lines.stamp(line_t1:line_tend));
    y0_line = interp1(bag1.ego.stamp(ego_t1:ego_tend), bag1.ego.y(ego_t1:ego_tend), bag1.lines.stamp(line_t1:line_tend));
    yaw_line = interp1(bag1.ego.stamp(ego_t1:ego_tend), bag1.ego.heading(ego_t1:ego_tend), bag1.lines.stamp(line_t1:line_tend));

    c = cos(yaw_line(:));
    s = sin(yaw_line(:));

    Ps = bag1.lines.start_pt(line_t1:line_tend,:,:);
    Pe = bag1.lines.end_pt(line_t1:line_tend,:,:);

    line_start_world = Ps;
    line_end_world = Pe;

    line_start_world(:,:,1) = c.*Ps(:,:,1) - s.*Ps(:,:,2) + x0_line(:);
    line_start_world(:,:,2) = s.*Ps(:,:,1) + c.*Ps(:,:,2) + y0_line(:);

    line_end_world(:,:,1) = c.*Pe(:,:,1) - s.*Pe(:,:,2) + x0_line(:);
    line_end_world(:,:,2) = s.*Pe(:,:,1) + c.*Pe(:,:,2) + y0_line(:);

    X = cat(3, ...
        line_start_world(:,:,1), ...
        line_end_world(:,:,1));      % N × M × 2

    Y = cat(3, ...
        line_start_world(:,:,2), ...
        line_end_world(:,:,2));      % N × M × 2

    % reorder so dimension 1 = start/end
    X = permute(X, [3 1 2]);   % 2 × N × M
    Y = permute(Y, [3 1 2]);

    % collapse (N,M) → segments
    xs = reshape(X, 2, []);
    ys = reshape(Y, 2, []);


    % --- reset axes ---
    subplot(1,1,1); cla reset; hold on;
    grid on;
    axis equal;
    xlabel('x [m]');
    ylabel('y [m]');

    % --- plot ---
    plot(x0_debug, y0_debug, 'k-', 'DisplayName', 'Ego');

    angle = deg2rad(bag1.debug.rows_angle.map(debug_t1:debug_tend));
    sampled = NaN(size(angle));
    sampled(1:10:end) = angle(1:10:end);
    dx = L * cos(sampled); dy = L * sin(sampled);
    quiver(x0_debug, y0_debug, dx, dy, 0, ...
        'r', 'LineWidth', 2, 'MaxHeadSize', 2, ...
        'DisplayName','Rows Direction');

    plot(xs, ys, 'b-', 'LineWidth',1.5,'HandleVisibility','off');

    legend show
end
