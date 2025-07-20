function update_trajectory_laps()
    shared = getappdata(0,'sharedData');
    fig = findobj('Name','Trajectory'); if isempty(fig), return; end
    ax = getappdata(fig,'ax'); cla(ax); hold(ax,'on');
    laptime = shared.ego.laptime.fulltime(shared.lap_ego);
    idxE = shared.ego.laps == shared.lap_ego;
    plot(ax, shared.ego.x(idxE), shared.ego.y(idxE), '.', 'Color',shared.colors(1,:), ...
        'DisplayName',sprintf('0 - POLIMOVE - Laptime: %s', laptime));
    opps = get_selected_opponents(fig);

    for kk = opps(:)'
        lapO = shared.lap_opp;
        opp_name = shared.name_map(kk);
        laptime = shared.v2v.laptime(kk).fulltime(lapO);
        idxO = shared.v2v.laps(:,kk) == lapO;
        plot(ax, shared.v2v.x(idxO,kk), shared.v2v.y(idxO,kk), ...
             '.', 'Color',shared.colors(kk+1,:), ...
             'DisplayName', sprintf('%d - %s - Laptime: %s', kk, opp_name, laptime))
    end
    legend(ax,'Location','northeast'); axis(ax,'equal'); grid(ax,'on'); box(ax,'on');
    id_left = length(shared.trajDatabase) - 2;
    id_right = length(shared.trajDatabase) - 1;
    plot(ax, shared.trajDatabase(id_left).X, shared.trajDatabase(id_left).Y, 'k', 'LineWidth', 1, 'HandleVisibility','off');
    plot(ax, shared.trajDatabase(id_right).X, shared.trajDatabase(id_right).Y, 'k', 'LineWidth', 1, 'HandleVisibility','off');
    title(ax, sprintf('Trajectory - Opp Lap %d vs Ego Lap %d', shared.lap_opp, shared.lap_ego));
end