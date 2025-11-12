function lap_idxs = get_lap_indexes(traj_server_struct)
    % GET_LAP_INDEXES This function identifies the lap intervals based on the lap count and 
    % the changes in 's' (which is assumed to be a distance or a similar measure).
    %
    % Input:
    %   traj_server_struct - A struct containing the trajectory server data. It should include:
    %       traj_server_struct.bag_stamp - Timestamp or another metric related to the bag data.
    %       traj_server_struct.s         - Vector representing the distance or related measure.
    %       traj_server_struct.lap_count - Vector of lap counts.
    %
    % Output:
    %   lap_idxs - A cell array where each cell contains a vector with the indices for each lap.
    
    % Find new lap indexes
    NEW_LAP_S_THRESHOLD = 500;
    new_lap_idxs = find(diff(traj_server_struct.s) < -NEW_LAP_S_THRESHOLD) + 1;
    
    % Compute lap intervals
    % new_lap_idxs = unique(new_lap_idxs);
    if isempty(new_lap_idxs)
        lap_idxs = {1 : length(traj_server_struct.bag_stamp)};
    else
        lap_idxs = cell(length(new_lap_idxs) + 1, 1);
        lap_idxs{1} = 1:new_lap_idxs(1) - 1;
        for i = 2 : length(new_lap_idxs)
            lap_idxs{i} = new_lap_idxs(i-1):new_lap_idxs(i) - 1;
        end
        lap_idxs{end} = new_lap_idxs(end) : length(traj_server_struct.bag_stamp);
    end

end

