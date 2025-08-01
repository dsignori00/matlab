function update_acc_fig()
    shared = getappdata(0,'sharedData');
    fig = findobj('Name','Acceleration Profile'); if isempty(fig), return; end
    axB = getappdata(fig,'ax_a'); axC = getappdata(fig,'ax_ax'); axA = getappdata(fig,'ax_ay');
    linkaxes([axB, axC, axA], 'off');
    cla(axB); cla(axC); cla(axA); hold(axB,'on'); hold(axC,'on'); hold(axA,'on');
    if(shared.ego_vs_ego)
        atot2 = shared.ego.ax.^2 + shared.ego.ay.^2;
        atot2opp = shared.v2v.ax.^2 + shared.v2v.ay.^2;
        lapE = shared.lap_ego;
        lapO = shared.lap_opp;
        laptime = shared.ego.laptime.fulltime(lapE);
        laptimeO = shared.v2v.laptime.fulltime(lapO);
        idxE = shared.ego.laps == lapE;
        idxO = shared.v2v.laps == lapO;
        plot(axB, shared.ego.index(idxE), shared.ego.ax(idxE), ...
            'Color', shared.colors(1,:), ...
            'DisplayName',sprintf('0 - POLIMOVE - Laptime: %s', laptime));
        plot(axB,shared.v2v.index(idxO), shared.v2v.ax(idxO), ...
            'Color', shared.colors(2,:), ...
            'DisplayName', sprintf('%d - %s - Laptime: %s', 1, shared.name_map(1), laptimeO));
        plot(axC, shared.ego.index(idxE), shared.ego.ay(idxE), ...
            'Color', shared.colors(1,:), ...
            'DisplayName',sprintf('0 - POLIMOVE - Laptime: %s', laptime));
        plot(axC,shared.v2v.index(idxO), shared.v2v.ay(idxO), ...
            'Color', shared.colors(2,:), ...
            'DisplayName', sprintf('%d - %s - Laptime: %s', 1, shared.name_map(1), laptimeO));
        plot(axA, shared.ego.index(idxE), sqrt(atot2(idxE)), ...
            'Color', shared.colors(1,:), ...
            'DisplayName',sprintf('0 - POLIMOVE - Laptime: %s', laptime));
        plot(axA,shared.v2v.index(idxO), sqrt(atot2opp(idxO)), ...
            'Color', shared.colors(2,:), ...
            'DisplayName', sprintf('%d - %s - Laptime: %s', 1, shared.name_map(1), laptimeO)); 
        title(axB, sprintf('Acceletation Profile'));      
    else
        atot2 = shared.best_laps{1,1}.ax_smooth.^2 + shared.best_laps{1,1}.ay_smooth.^2;
        plot(axB, shared.best_laps{1,1}.s_smooth, sqrt(atot2), 'DisplayName','Ego','Color',shared.colors(1,:));
        plot(axC, shared.best_laps{1,1}.s_smooth, shared.best_laps{1,1}.ax_smooth, 'DisplayName','Ego','Color',shared.colors(1,:));
        plot(axA, shared.best_laps{1,1}.s_smooth, shared.best_laps{1,1}.ay_smooth, 'DisplayName','Ego','Color',shared.colors(1,:));
        for kk = get_selected_opponents(fig)'+1
            atot2 = shared.best_laps{kk,1}.ax_smooth.^2 + shared.best_laps{kk,1}.ay_smooth.^2;
            plot(axB, shared.best_laps{kk,1}.s_smooth, sqrt(atot2), 'DisplayName', shared.name_map(kk-1), 'Color',shared.colors(kk+1,:));
            plot(axC, shared.best_laps{kk,1}.s_smooth, shared.best_laps{kk,1}.ax_smooth, 'DisplayName', shared.name_map(kk-1), 'Color',shared.colors(kk,:));
            plot(axA, shared.best_laps{kk,1}.s_smooth, shared.best_laps{kk,1}.ay_smooth, 'DisplayName', shared.name_map(kk-1), 'Color',shared.colors(kk,:));
        end
        title(axB, sprintf('Best Lap Acceletation Profile'));
    end
    xlabel(axB,'Index'); ylabel(axB,'Total (m/s²)'); legend(axB,'Location','northeast');
    xlabel(axC,'Index'); ylabel(axC,'Longitudinal (m/s²)'); legend(axC,'Location','northeast');
    xlabel(axA,'Index'); ylabel(axA,'Lateral (m/s²)'); legend(axA,'Location','northeast');
    grid(axB,'on'); grid(axC,'on'); grid(axA,'on'); box(axB); box(axC,'on'); box(axA,'on');
    axis(axB, 'tight');
    axis(axC, 'tight');
    axis(axA, 'tight');
    linkaxes([axB, axC, axA], 'x');
end