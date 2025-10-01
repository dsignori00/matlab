function smooth_points = smoothing_discontinuities_nonuniform(d_knot_vec, points, DELTA_MAX)

    N_points = size(points, 1);

    lb = -DELTA_MAX.*ones(N_points, 1);
    ub = DELTA_MAX.*ones(N_points, 1);
    
    opts = optimoptions('quadprog');
    opts.OptimalityTolerance = 1e-15;
    opts.StepTolerance = 1e-15;
    opts.MaxIterations = 100*N_points;
    
    disc_vec = compute_discontinuities_nonuniform(d_knot_vec, points);
    disc_vec_x = disc_vec(:, 1);
    disc_vec_y = disc_vec(:, 2);
    disc_jac = compute_discontinuity_jacobian_nonuniform(d_knot_vec);
    H_quadprog = (disc_jac.') * disc_jac;
    f_quadprog_x = ((disc_vec_x.') * disc_jac).';
    f_quadprog_y = ((disc_vec_y.') * disc_jac).';
    
    dx_opt = quadprog(H_quadprog, f_quadprog_x, [], [], [], [], lb, ub, [], opts);
    dy_opt = quadprog(H_quadprog, f_quadprog_y, [], [], [], [], lb, ub, [], opts);
    smooth_points = points + [dx_opt zeros(N_points, 1)] + [zeros(N_points, 1) dy_opt];

end

