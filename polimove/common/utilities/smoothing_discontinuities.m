function [smooth_points, d_knot_vec] = smoothing_discontinuities(points, left_border, right_border)

    points_padded = [points; points(1, :)];
    ds_vec = sqrt(diff(points_padded(:, 1)).^2 + diff(points_padded(:, 2)).^2);

    % d_knot_vec = centripetal_method_knot_vector_distances(ds_vec, 1);
    % control_points = points;
    d_knot_vec = [ds_vec(end-1); ds_vec(end); ds_vec(1:(end-2))];
    control_points = compute_control_points(points, d_knot_vec);

    [left_limit, right_limit] = compute_lateral_limits(control_points, d_knot_vec, left_border, right_border);

    smooth_points = smoothing_discontinuities_new(d_knot_vec, control_points, left_limit, right_limit);

end

