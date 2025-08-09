function best_lap = extract_best_lap(dataset, VEH_IDX, LAP_TIME_MIN, LAP_TIME_MAX)

    lap_ids = unique(dataset.laps(:, VEH_IDX));
    lap_times = nan(numel(lap_ids), 1);
    
    k = 1;
    for i = lap_ids' 
        curr_lap_time = max(dataset.laptime_prog(dataset.laps(:, VEH_IDX) == i, VEH_IDX));
        if curr_lap_time < LAP_TIME_MIN || curr_lap_time > LAP_TIME_MAX
            lap_times(k) = NaN;
        else
            lap_times(k) = curr_lap_time;
        end
        k = k+1;
    end

    [min_time, best_lap_idx] = min(lap_times, [], 'omitnan');

    if isnan(min_time)        
        best_lap = fill_with_nan();
    else
        idx_vec = dataset.laps(:, VEH_IDX) == lap_ids(best_lap_idx);

        x = dataset.x(idx_vec, VEH_IDX);
        y = dataset.y(idx_vec, VEH_IDX);
        v = dataset.vx(idx_vec, VEH_IDX)./3.6;
        yaw = dataset.yaw(idx_vec, VEH_IDX);

        best_lap.x   = x;
        best_lap.y   = y;
        best_lap.v   = v;
        best_lap.yaw = yaw;
        best_lap.s   = [0; cumsum(sqrt(diff(x).^2 + diff(y).^2))];
    end

end

