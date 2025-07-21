function update_acc_fig()
    shared = getappdata(0,'sharedData');
    fig = findobj('Name','Acceleration Profile'); if isempty(fig), return; end
    axB = getappdata(fig,'ax_a'); axC = getappdata(fig,'ax_ax'); axA = getappdata(fig,'ax_ay');
    cla(axB); cla(axC); cla(axA); hold(axB,'on'); hold(axC,'on'); hold(axA,'on');
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
    xlabel(axB,'Index'); ylabel(axB,'Total (m/s²)'); legend(axB,'Location','northeast');
    xlabel(axC,'Index'); ylabel(axC,'Longitudinal (m/s²)'); legend(axC,'Location','northeast');
    xlabel(axA,'Index'); ylabel(axA,'Lateral (m/s²)'); legend(axA,'Location','northeast');
    grid(axB,'on'); grid(axC,'on'); grid(axA,'on'); box(axB); box(axC,'on'); box(axA,'on');
    title(axB, sprintf('Best Lap Acceletation Profile'));
end