function tt = compute_speed_std(tt)

    buff_dim = 1.0;  % trailing window length in seconds
    n = length(tt.stamp);
    nOpp = tt.max_opp;

    tt.vx_std = NaN(n, nOpp);  % preallocate output

    for it = 1:n
        % Define trailing time window
        t_start = tt.stamp(it) - buff_dim;
        t_end   = tt.stamp(it);

        % Find all indices in that time window
        idx = (tt.stamp >= t_start) & (tt.stamp <= t_end);

        % Compute std for each opponent separately
        if any(idx)
            tt.vx_std(it, :) = std(tt.vx(idx, 1:nOpp), 0, 1);
        end
    end
end

