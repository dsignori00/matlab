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
    % ---------- persistent graphics ----------
    persistent hAx hEgo hRows hLines initialized

    % --- fetch from base ---
    ax         = evalin('base', 'ax');
    bag1       = evalin('base', 'bag1');
    FOOTPRINT  = evalin('base', 'FOOTPRINT');

    L = 0.3 * FOOTPRINT.length;

    % ---------- time window ----------
    t_lim = xlim(ax(1));

    [ego_t1, ego_tend]     = timeWindowIdx(bag1.ego.stamp, t_lim);
    [debug_t1, debug_tend] = timeWindowIdx(bag1.debug.stamp, t_lim);
    [line_t1, line_tend]   = timeWindowIdx(bag1.lines.stamp, t_lim);

    % ---------- ego interpolation ----------
    x0_debug = interp1( ...
        bag1.ego.stamp(ego_t1:ego_tend), ...
        bag1.ego.x(ego_t1:ego_tend), ...
        bag1.debug.stamp(debug_t1:debug_tend));

    y0_debug = interp1( ...
        bag1.ego.stamp(ego_t1:ego_tend), ...
        bag1.ego.y(ego_t1:ego_tend), ...
        bag1.debug.stamp(debug_t1:debug_tend));

    % ---------- line pose interpolation ----------
    x0_line = interp1(bag1.ego.stamp(ego_t1:ego_tend), ...
                      bag1.ego.x(ego_t1:ego_tend), ...
                      bag1.lines.stamp(line_t1:line_tend));

    y0_line = interp1(bag1.ego.stamp(ego_t1:ego_tend), ...
                      bag1.ego.y(ego_t1:ego_tend), ...
                      bag1.lines.stamp(line_t1:line_tend));

    yaw_line = interp1(bag1.ego.stamp(ego_t1:ego_tend), ...
                       bag1.ego.heading(ego_t1:ego_tend), ...
                       bag1.lines.stamp(line_t1:line_tend));

    % ---------- ego → world transform ----------
    c = cos(yaw_line(:));
    s = sin(yaw_line(:));

    Ps = bag1.lines.start_pt(line_t1:line_tend,:,:);
    Pe = bag1.lines.end_pt(line_t1:line_tend,:,:);

    line_start_world = Ps;
    line_end_world   = Pe;

    line_start_world(:,:,1) = c.*Ps(:,:,1) - s.*Ps(:,:,2) + x0_line(:);
    line_start_world(:,:,2) = s.*Ps(:,:,1) + c.*Ps(:,:,2) + y0_line(:);

    line_end_world(:,:,1)   = c.*Pe(:,:,1) - s.*Pe(:,:,2) + x0_line(:);
    line_end_world(:,:,2)   = s.*Pe(:,:,1) + c.*Pe(:,:,2) + y0_line(:);

    % --- build segments as NaN-separated vectors ---
    tmp = line_start_world(:,:,1);
    tmp_end = line_end_world(:,:,1);
    xs = [tmp(:), tmp_end(:), nan(numel(tmp),1)]';

    tmp = line_start_world(:,:,2);
    tmp_end = line_end_world(:,:,2);
    ys = [tmp(:), tmp_end(:), nan(numel(tmp),1)]';

    xs = xs(:);
    ys = ys(:);

    % ---------- rows direction ----------
    angle = deg2rad(bag1.debug.rows_angle.map(debug_t1:debug_tend));
    sampled = NaN(size(angle));
    sampled(1:10:end) = angle(1:10:end);

    dx = L*cos(sampled);
    dy = L*sin(sampled);

    if isempty(initialized) || ...
        ~isgraphics(hEgo) || ...
        ~isgraphics(hRows) || ...
        ~isgraphics(hLines)

        figure(gcf);
        hAx = axes;
        hold(hAx,'on');
        grid(hAx,'on');
        axis(hAx,'equal');

        xlabel(hAx,'x [m]');
        ylabel(hAx,'y [m]');

        % create ONCE
        hEgo = plot(hAx,nan,nan,'k-','DisplayName','Ego');

        hRows = quiver(hAx,nan,nan,nan,nan,0,...
            'r','LineWidth',2,'MaxHeadSize',2,...
            'DisplayName','Rows Direction');

        hLines = plot(hAx,nan,nan,'b-',...
            'LineWidth',1.5,...
            'DisplayName','Lines');

        legend(hAx,'show');

        initialized = true;
    end

    % ---------- UPDATE ONLY DATA ----------
    set(hEgo,'XData',x0_debug,'YData',y0_debug);

    set(hRows,...
        'XData',x0_debug,...
        'YData',y0_debug,...
        'UData',dx,...
        'VData',dy);

    set(hLines,'XData',xs,'YData',ys);

    drawnow limitrate nocallbacks
end