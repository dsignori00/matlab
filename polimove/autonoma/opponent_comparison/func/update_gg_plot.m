function update_gg_plot()
    shared = getappdata(0,'sharedData');
    fig = findobj('Name','GG Plot'); if isempty(fig), return; end
    axB = getappdata(fig,'ax_gg'); 
    cla(axB); hold(axB,'on'); 
    if(shared.ego_vs_ego)
        lapE = shared.lap_ego;
        lapO = shared.lap_opp;
        laptime = shared.ego.laptime.fulltime(lapE);
        laptimeO = shared.v2v.laptime.fulltime(lapO);
        idxE = shared.ego.laps == lapE;
        idxO = shared.v2v.laps == lapO;
        scatter(axB, shared.ego.ay(idxE), shared.ego.ax(idxE), ...
            'Color', shared.colors(1,:), ...
            'DisplayName',sprintf('0 - POLIMOVE - Laptime: %s', laptime));
        scatter(axB,shared.v2v.ay(idxO), shared.v2v.ax(idxO), ...
            'Color', shared.colors(2,:), ...
            'DisplayName', sprintf('%d - %s - Laptime: %s', 1, shared.name_map(1), laptimeO));  
        title(axB, sprintf('GG Plot'));    
    else
        scatter(axB, shared.best_laps{1,1}.ay_smooth, shared.best_laps{1,1}.ax_smooth, 'DisplayName','Ego','Color',shared.colors(1,:));
        for kk = get_selected_opponents(fig)'+1
            scatter(axB, shared.best_laps{kk,1}.ay_smooth, shared.best_laps{kk,1}.ax_smooth, 'DisplayName', shared.name_map(kk-1), 'Color',shared.colors(kk+1,:));
        end
        title(axB, sprintf('Best Lap GG Plot'));
    end
    xlabel(axB,'Lateral Acceleration (m/s²)'); ylabel(axB,'Longitudinal Acceleration (m/s²)'); legend(axB,'Location','northeast');
    grid(axB,'on'); box(axB); 
    axis(axB, 'equal');
end