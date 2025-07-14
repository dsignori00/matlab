function new_points = resample_line(points, s_vec_interp)

    points_closed = [points; points(1, :)];

    s_vec = compute_curv_abscissa(points_closed);

    new_points(:, 1) = interp1(s_vec, points_closed(:, 1), s_vec_interp);
    new_points(:, 2) = interp1(s_vec, points_closed(:, 2), s_vec_interp);

end

