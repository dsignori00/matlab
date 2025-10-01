function update_lap_selection(src,~,whichLap)
    shared = getappdata(0,'sharedData');
    shared.(['lap_' whichLap]) = src.Value;
    setappdata(0,'sharedData',shared);

    % Update all dropdowns to stay synced
    tags = {'traj','speed','acc','gg'};
    for t = tags
        fig = findobj('Name', figure_name(t{1}));
        if isempty(fig), continue; end
        popup = getappdata(fig, ['popup_' whichLap]);
        if ~isempty(popup) && isvalid(popup) && popup.Value ~= src.Value
            popup.Value = src.Value;
        end
    end

    % Refresh all plots
    update_trajectory_laps;
    update_speed_laps;
    update_acc_fig;
    update_gg_plot;
end