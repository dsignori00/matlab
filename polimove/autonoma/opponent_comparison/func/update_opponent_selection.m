function update_opponent_selection(~,~,sourceTag)
    % Determine source figure
    switch sourceTag
        case 'traj'
            fig_source = findobj('Name', 'Trajectory');
        case 'speed'
            fig_source = findobj('Name', 'Speed Profile');
        case 'curv'
            fig_source = findobj('Name', 'Acceleration Profile');
        otherwise
            return;
    end

    % Get selected opponents from the source figure
    selected_opps = get_selected_opponents(fig_source);

    % Sync checkboxes across all figures
    fig_traj = findobj('Name', 'Trajectory');
    fig_speed = findobj('Name', 'Speed Profile');
    fig_curv = findobj('Name', 'Acceleration Profile');

    sync_checkbox_group(fig_traj, selected_opps);
    sync_checkbox_group(fig_speed, selected_opps);
    sync_checkbox_group(fig_curv, selected_opps);

    % Update all plots using stored sharedData.lap_ego and lap_opp
    update_trajectory_laps();
    update_speed_laps();
    %update_acc_fig();
end