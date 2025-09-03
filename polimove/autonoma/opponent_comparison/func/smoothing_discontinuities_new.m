function smooth_points = smoothing_discontinuities_new(d_knot_vec, points, left_limit, right_limit)

    N_points = size(points, 1);

    N_tens = generate_bspline_endpoints(d_knot_vec);

    Padding_mat = [eye(N_points); [1 zeros(1, N_points-1)]; [0 1 zeros(1, N_points-2)]; [0 0 1 zeros(1, N_points-3)]];

    C_mat = zeros(4*N_points, N_points+3);

    for i=1:N_points
        C_mat(4*(i-1)+1, i) = 1;
        C_mat(4*(i-1)+2, i+1) = 1;
        C_mat(4*(i-1)+3, i+2) = 1;
        C_mat(4*(i-1)+4, i+3) = 1;
    end

    N_mat = zeros(N_points, 4*N_points);

    for i=1:N_points
        N_mat(i, (4*(i-1)+1):(4*i)) = N_tens(:, :, i);
    end

    knot_points = compute_knot_points(points, d_knot_vec);
    knot_points_padded = [knot_points; knot_points(1, :)];

    ds_knot_points = sqrt(diff(knot_points_padded(:, 1)).^2 + diff(knot_points_padded(:, 2)).^2);
    ds_knot_points_shifted = [ds_knot_points(end); ds_knot_points(1:(end-1))];
    
    opts = optimoptions('quadprog');
    opts.OptimalityTolerance = 1e-13;
    opts.MaxIterations = N_points/5;
    opts.Display = 'iter';

    t_vec = compute_tangents(points, d_knot_vec);
    n_vec = compute_normals(points, d_knot_vec);
    
    disc_vec = compute_discontinuities_nonuniform(d_knot_vec, points);
    disc_vec_x = disc_vec(:, 1);
    disc_vec_y = disc_vec(:, 2);

    J = compute_discontinuity_jacobian(d_knot_vec);
    g = [disc_vec_x; disc_vec_y];

    H_quadprog = ((J.') * J) ./ N_points.^2;
    f_quadprog = (((g.') * J).') ./ N_points.^2;

    A = nan(4*N_points, 2*N_points);
    b = nan(4*N_points, 1);

    A(1:(N_points), :) = [N_mat*C_mat*Padding_mat*diag(n_vec(:, 1)) N_mat*C_mat*Padding_mat*diag(n_vec(:, 2))];
    A((N_points+1):(2*N_points), :) = -[N_mat*C_mat*Padding_mat*diag(n_vec(:, 1)) N_mat*C_mat*Padding_mat*diag(n_vec(:, 2))];
    A((2*N_points+1):(3*N_points), :) = [N_mat*C_mat*Padding_mat*diag(t_vec(:, 1)) N_mat*C_mat*Padding_mat*diag(t_vec(:, 2))];
    A((3*N_points+1):(4*N_points), :) = -[N_mat*C_mat*Padding_mat*diag(t_vec(:, 1)) N_mat*C_mat*Padding_mat*diag(t_vec(:, 2))];

    b(1:N_points) = left_limit ./ 2;
    b((N_points+1):(2*N_points)) = -right_limit ./ 2;
    b((2*N_points+1):(3*N_points)) = ds_knot_points ./ 10;
    b((3*N_points+1):(4*N_points)) = ds_knot_points_shifted ./ 10;
    
    dxy_opt = quadprog(H_quadprog, f_quadprog, A, b, [], [], [], [], [], opts);

    smooth_points = points + [dxy_opt(1:N_points) dxy_opt((N_points+1):(2*N_points))];

 end

