function center_line = compute_center_line(left_line, right_line)

    N_points_r = size(right_line, 1);

    center_line = nan(N_points_r, 2);

    for i=1:N_points_r

        curr_point_r = right_line(i, :);
        diff_vec = left_line - curr_point_r;

        d_sq_vec = dot(diff_vec.', diff_vec.');
        [~, idx_min] = min(d_sq_vec);

        curr_point_l = left_line(idx_min, :);

        center_line(i, :) = (curr_point_r + curr_point_l) ./ 2;

    end

end

