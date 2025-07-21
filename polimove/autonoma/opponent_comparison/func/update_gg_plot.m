function update_gg_plot()
    shared = getappdata(0,'sharedData');
    fig = findobj('Name','GG Plot'); if isempty(fig), return; end
    axB = getappdata(fig,'ax_gg'); 
    cla(axB); hold(axB,'on'); 
    scatter(axB, shared.best_laps{1,1}.ay_smooth, shared.best_laps{1,1}.ax_smooth, 'DisplayName','Ego','Color',shared.colors(1,:));
    for kk = get_selected_opponents(fig)'+1
        scatter(axB, shared.best_laps{kk,1}.ay_smooth, shared.best_laps{kk,1}.ax_smooth, 'DisplayName', shared.name_map(kk-1), 'Color',shared.colors(kk+1,:));
    end
    xlabel(axB,'Lateral Acceleration (m/s²)'); ylabel(axB,'Longitudinal Acceleration (m/s²)'); legend(axB,'Location','northeast');
    grid(axB,'on'); box(axB); 
    axis equal;
    title(axB, sprintf('Best Lap GG Plot'));
end