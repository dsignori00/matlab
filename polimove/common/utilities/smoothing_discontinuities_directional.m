function smooth_points = smoothing_discontinuities_directional(d_knot_vec, points, DELTA_N_MAX, DELTA_T_FRACTION)

    N_points = size(points, 1);

    knot_points = compute_knot_points(points, d_knot_vec);
    knot_points_padded = [knot_points; knot_points(1, :)];

    ds_knot_points = sqrt(diff(knot_points_padded(:, 1)).^2 + diff(knot_points_padded(:, 2)).^2);
    ds_knot_points_shifted = [ds_knot_points(end); ds_knot_points(1:(end-1))];

    lb = [-DELTA_T_FRACTION.*ds_knot_points_shifted; -DELTA_N_MAX.*ones(N_points, 1)];
    ub = [DELTA_T_FRACTION.*ds_knot_points; DELTA_N_MAX.*ones(N_points, 1)];
    
    opts = optimoptions('quadprog');
    opts.OptimalityTolerance = 1e-10;
    opts.StepTolerance = 1e-10;
    opts.MaxIterations = 100*N_points;

    t_vec = compute_tangents(points, d_knot_vec);
    n_vec = compute_normals(points, d_knot_vec);
    
    disc_vec = compute_discontinuities_nonuniform(d_knot_vec, points);
    disc_vec_x = disc_vec(:, 1);
    disc_vec_y = disc_vec(:, 2);
    [disc_jac_xt, disc_jac_yt] = compute_discontinuity_jacobian_directional(d_knot_vec, t_vec);
    [disc_jac_xn, disc_jac_yn] = compute_discontinuity_jacobian_directional(d_knot_vec, n_vec);

    A = [disc_jac_xt disc_jac_xn; disc_jac_yt disc_jac_yn];
    b = [disc_vec_x; disc_vec_y];

    H_quadprog = (A.') * A;
    f_quadprog = ((b.') * A).';
    
    dtn_opt = quadprog(H_quadprog, f_quadprog, [], [], [], [], lb, ub, [], opts);

    dtn = [dtn_opt(1:N_points) dtn_opt((N_points+1):(2*N_points))];

    dxy = convert_nt_to_xy_displacements(d_knot_vec, dtn, t_vec, n_vec);

    smooth_points = points + dxy;

end

