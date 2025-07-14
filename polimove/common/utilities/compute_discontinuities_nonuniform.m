function disc_vec = compute_discontinuities_nonuniform(d_knot_vec, points)

    N_points = size(points, 1);

    Nt_mat = generate_bspline_third_endpoints(d_knot_vec);
    Nt_mat_padded = cat(3, Nt_mat, Nt_mat(:, :, 1));

    disc_vec = nan(N_points, 2);

    points_padded = [points; points(1:4, :)];

    for i=1:N_points

        curr_Nt_vec = Nt_mat_padded(:, :, i);
        next_Nt_vec = Nt_mat_padded(:, :, i+1);
        curr_points_vec = points_padded(i:(i+4), :);

        curr_dNt_vec = nan(1, 5);

        curr_dNt_vec(1) = -curr_Nt_vec(1);
        curr_dNt_vec(2) = next_Nt_vec(1) - curr_Nt_vec(2);
        curr_dNt_vec(3) = next_Nt_vec(2) - curr_Nt_vec(3);
        curr_dNt_vec(4) = next_Nt_vec(3) - curr_Nt_vec(4);
        curr_dNt_vec(5) = next_Nt_vec(4);

        disc_vec(i, :) = curr_dNt_vec * curr_points_vec;

    end

end

