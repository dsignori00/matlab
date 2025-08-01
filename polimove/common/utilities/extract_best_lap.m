function best_lap = extract_best_lap(dataset, VEH_IDX, LAP_TIME_MIN, LAP_TIME_MAX)

    N_laps = max(dataset.laps(:, VEH_IDX));

    lap_times = nan(N_laps, 1);

    for i=1:N_laps
    
        curr_lap_time = max(dataset.laptime_prog(dataset.laps(:, VEH_IDX) == i, VEH_IDX));
    
        if curr_lap_time > LAP_TIME_MIN
            lap_times(i) = max(dataset.laptime_prog(dataset.laps(:, VEH_IDX) == i, VEH_IDX));
        else
            lap_times(i) = LAP_TIME_MAX;
        end
    end

    [~, best_lap_idx] = min(lap_times);

    idx_vec = dataset.laps(:, VEH_IDX) == best_lap_idx;

    x = dataset.x(idx_vec, VEH_IDX);
    y = dataset.y(idx_vec, VEH_IDX);
    v = dataset.vx(idx_vec, VEH_IDX)./3.6;
    yaw = dataset.yaw(idx_vec, VEH_IDX);

    best_lap.x = x;
    best_lap.y = y;
    best_lap.v = v;
    best_lap.yaw = yaw;
    best_lap.s = [0; cumsum(sqrt(diff(x).^2 + diff(y).^2))];

end

