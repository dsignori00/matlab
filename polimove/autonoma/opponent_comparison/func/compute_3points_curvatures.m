function curvatures = compute_3points_curvatures(points)

    N_points = size(points, 1);
    curvatures = nan(N_points, 1);

    for i=1:N_points

        prev_idx = i - 1;
        curr_idx = i;
        next_idx = i + 1;

        if prev_idx < 1
            prev_idx = N_points;
        end

        if next_idx > N_points
            next_idx = 1;
        end

        a = sqrt((points(prev_idx, 1) - points(curr_idx, 1))^ 2 + (points(prev_idx, 2) - points(curr_idx, 2))^ 2);                               % triangle first side
        b = sqrt((points(curr_idx, 1) - points(next_idx, 1))^ 2 + (points(curr_idx, 2) - points(next_idx, 2))^ 2);                               % triangle second side
        c = sqrt((points(prev_idx, 1) - points(next_idx, 1))^2 + (points(prev_idx, 2) - points(next_idx, 2))^ 2);                                % triangle third side
        A = (-(points(curr_idx, 1) - points(next_idx, 1)) * (points(prev_idx, 2) - points(next_idx, 2)) + ...
             (points(curr_idx, 2) - points(next_idx, 2)) * (points(prev_idx, 1) - points(next_idx, 1))) / 2.0;   % triangle signed area depending on the orientation of the three points (clockwise or anti-clockwise)
        curvatures(i) = 4.0 * A / (a * b * c); 

    end

end

