function update_speed_laps
    shared = getappdata(0, 'sharedData');
    fig = findobj('Name', 'Speed Profile');
    if isempty(fig), return; end

    lapE = shared.lap_ego;
    lapO = shared.lap_opp;
    laptime = shared.ego.laptime.fulltime(lapE);

    ax_speed = getappdata(fig, 'ax');
    ax_lapdiff = getappdata(fig, 'ax_lapdiff');

    cla(ax_speed); cla(ax_lapdiff);
    hold(ax_speed, 'on'); hold(ax_lapdiff, 'on');

    title(ax_speed, sprintf('Speed Profile - Opp Lap %d vs Ego Lap %d', lapO, lapE));
    title(ax_lapdiff, sprintf('Lap-relative Time Difference - Opp Lap %d vs Ego Lap %d', lapO, lapE));

    % Plot Ego Speed
    idxE = shared.ego.laps == lapE;
    plot(ax_speed, shared.ego.index(idxE), shared.ego.vx(idxE), ...
        'Color', shared.colors(1,:), ...
         'DisplayName',sprintf('0 - POLIMOVE - Laptime: %s', laptime));

    % Lap time interpolation setup
    ego.index = shared.ego.index(idxE);
    ego.laptime_prog = shared.ego.laptime_prog(idxE);
    [uI, ia] = unique(double(ego.index), 'stable');  % ensure double type
    egoLT = ego.laptime_prog;

    yline(ax_lapdiff, 0, 'Color', 'k', 'LineStyle', '--', 'HandleVisibility', 'off');

    % Plot Opponents
    selected_opps = get_selected_opponents(fig);
    for kk = selected_opps(:)'
        idxO = shared.v2v.laps(:, kk) == lapO;
        if ~any(idxO), continue; end

        opp_index = double(shared.v2v.index(idxO, kk));  % ensure double
        opp_speed = shared.v2v.vx(idxO, kk);
        opp_lap_time = shared.v2v.laptime_prog(idxO, kk);
        opp_name = shared.name_map(kk);
        laptime = shared.v2v.laptime(kk).fulltime(lapO);

        plot(ax_speed, opp_index, opp_speed, ...
             'Color', shared.colors(kk+1, :), ...
             'DisplayName', sprintf('%d - %s - Laptime: %s', kk, opp_name, laptime))

        if ~isempty(uI)
            egoInterp = interp1(uI, egoLT(ia), opp_index, 'linear', 'extrap');
            lap_time_diff = opp_lap_time - egoInterp;
            plot(ax_lapdiff, opp_index, lap_time_diff, ...
                 'Color', shared.colors(kk+1,:), ...
                 'DisplayName', sprintf('%d - %s - Laptime: %s', kk, opp_name, laptime));
        end
    end

    ylabel(ax_speed, 'Speed (km/h)');
    legend(ax_speed, 'Location', 'northeast');
    grid(ax_speed, 'on'); box(ax_speed, 'on');

    xlabel(ax_lapdiff, 'Closest Index');
    ylabel(ax_lapdiff, 'Δ Lap Time (s)');
    legend(ax_lapdiff, 'Location', 'northeast');
    grid(ax_lapdiff, 'on'); box(ax_lapdiff, 'on');
end