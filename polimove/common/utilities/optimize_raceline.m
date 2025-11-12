function raceline_bspline = optimize_raceline(track_bspline, AX_MAX, AY_MAX)

    d_knot_vec = track_bspline.d_knots;
    points = track_bspline.points;
    nl_vec = track_bspline.nl_vec;
    nr_vec = track_bspline.nr_vec;

    N_points = length(d_knot_vec);

    du_vec = [d_knot_vec(3:end); d_knot_vec(1:2)];

    normals = compute_normals(points, d_knot_vec);
    tangents = compute_tangents(points, d_knot_vec);

    N_tens = generate_bspline_endpoints(d_knot_vec);
    Nf_tens = generate_bspline_prime_endpoints(d_knot_vec);
    Ns_tens = generate_bspline_second_endpoints(d_knot_vec);
    Nt_tens = generate_bspline_third_endpoints(d_knot_vec);

    Padding_curr_mat = zeros(N_points+3, N_points);
    Padding_next_mat = zeros(N_points+3, N_points);

    for i=1:N_points
        Padding_curr_mat(i, i) = 1;
    end

    Padding_curr_mat(N_points+1, 1) = 1;
    Padding_curr_mat(N_points+2, 2) = 1;
    Padding_curr_mat(N_points+3, 3) = 1;

    for i=1:(N_points-1)
        Padding_next_mat(i, i+1) = 1;
    end

    Padding_next_mat(N_points, 1) = 1;
    Padding_next_mat(N_points+1, 2) = 1;
    Padding_next_mat(N_points+2, 3) = 1;
    Padding_next_mat(N_points+3, 4) = 1;

    C_mat = zeros(4*N_points, N_points+3);

    for i=1:N_points
        C_mat(4*(i-1)+1, i) = 1;
        C_mat(4*(i-1)+2, i+1) = 1;
        C_mat(4*(i-1)+3, i+2) = 1;
        C_mat(4*(i-1)+4, i+3) = 1;
    end

    N_mat = zeros(N_points, 4*N_points);
    Nf_mat = zeros(N_points, 4*N_points);
    Ns_mat = zeros(N_points, 4*N_points);
    Nt_curr_mat = zeros(N_points, 4*N_points);
    Nt_next_mat = zeros(N_points, 4*N_points);

    for i=1:N_points

        N_mat(i, (4*(i-1)+1):(4*i)) = N_tens(:, :, i);
        Nf_mat(i, (4*(i-1)+1):(4*i)) = Nf_tens(:, :, i);
        Ns_mat(i, (4*(i-1)+1):(4*i)) = Ns_tens(:, :, i);

        Nt_curr_mat(i, (4*(i-1)+1):(4*i)) = Nt_tens(:, :, i);

        if i==N_points
            Nt_next_mat(i, (4*(i-1)+1):(4*i)) = Nt_tens(:, :, 1);
        else
            Nt_next_mat(i, (4*(i-1)+1):(4*i)) = Nt_tens(:, :, i+1);
        end

    end

    disc_vec_0 = (Nt_next_mat*C_mat*Padding_next_mat - Nt_curr_mat*C_mat*Padding_curr_mat) * points;

    import casadi.*

    v_vec = MX.sym('v_vec', 4*N_points + 1, 1);

    vel_vec = v_vec(1:(N_points+1));
    ax_vec = v_vec((N_points+2):(2*N_points+1));

    n_cp_vec = v_vec((2*N_points+2):(3*N_points+1));
    t_cp_vec = v_vec((3*N_points+2):(4*N_points+1));

    dir_mat = N_mat*C_mat*Padding_curr_mat;
    dirf_mat = Nf_mat * C_mat * Padding_curr_mat;
    dirs_mat = Ns_mat * C_mat * Padding_curr_mat;
    dirt_mat = Nt_curr_mat * C_mat * Padding_curr_mat;
    dirdisc_mat = Nt_next_mat*C_mat*Padding_next_mat - Nt_curr_mat*C_mat*Padding_curr_mat;

    dir_mat_MX = sparsify_matrix_casadi(dir_mat, 1e-10);
    dirf_mat_MX = sparsify_matrix_casadi(dirf_mat, 1e-10);
    dirs_mat_MX = sparsify_matrix_casadi(dirs_mat, 1e-10);
    dirt_mat_MX = sparsify_matrix_casadi(dirt_mat, 1e-10);
    dirdisc_mat_MX = sparsify_matrix_casadi(dirdisc_mat, 1e-10);

    dxy_vec = dir_mat_MX*([n_cp_vec t_cp_vec]);
    modified_points = points + [n_cp_vec t_cp_vec];

    n_vec = dxy_vec(:, 1).*normals(:, 1) + dxy_vec(:, 2).*normals(:, 2);
    t_vec = dxy_vec(:, 1).*tangents(:, 1) + dxy_vec(:, 2).*tangents(:, 2);

    first_der_vec = dirf_mat_MX * modified_points;
    second_der_vec = dirs_mat_MX * modified_points;
    third_der_vec = dirt_mat_MX * modified_points;
    disc_vec = dirdisc_mat_MX * modified_points;

    dsdu_sq_vec = first_der_vec(:, 1).^2 + first_der_vec(:, 2).^2;
    rho_sq_vec = ((first_der_vec(:, 1).*second_der_vec(:, 2) - first_der_vec(:, 2).*second_der_vec(:, 1)).^2) ./ ...
                 (dsdu_sq_vec.^3);

    g_vec = MX(4*N_points+1, 1);

    g_vec(1:N_points) = vel_vec(2:end) - vel_vec(1:(end-1)) - ax_vec ./ vel_vec(1:(end-1)) .* sqrt(dsdu_sq_vec) .* du_vec;
    g_vec(N_points+1) = vel_vec(N_points) - vel_vec(1);
    g_vec((N_points+2):(2*N_points+1)) = (vel_vec(1:N_points).^4) .* rho_sq_vec + ax_vec.^2;
    g_vec((2*N_points+2):(3*N_points+1)) = n_vec;
    g_vec((3*N_points+2):(4*N_points+1)) = t_vec;

    w_reg = MX(1, 1);
    w_reg(1) = 1e-1;

    cost = sum(sqrt(dsdu_sq_vec) ./ vel_vec(1:N_points) .* du_vec);
    cost = cost + w_reg .* sum(disc_vec(:, 1).^2 + disc_vec(:, 2).^2) ./ sum(disc_vec_0(:, 1).^2 + disc_vec_0(:, 2).^2);

    first_der_fun = Function('first_der_fun', {v_vec}, {first_der_vec});
    second_der_fun = Function('second_der_fun', {v_vec}, {second_der_vec});
    third_der_fun = Function('third_der_fun', {v_vec}, {third_der_vec});
    n_fun = Function('n_fun', {v_vec}, {n_vec});

    lbg = nan(3*N_points+1, 1);
    ubg = nan(3*N_points+1, 1);

    lbg(1:(N_points+1)) = 0;
    lbg((N_points+2):(2*N_points+1)) = 0;
    lbg((2*N_points+2):(3*N_points+1)) = nr_vec;
    lbg((3*N_points+2):(4*N_points+1)) = 0;

    ubg(1:(N_points+1)) = 0;
    ubg((N_points+2):(2*N_points+1)) = AY_MAX.^2;
    ubg((2*N_points+2):(3*N_points+1)) = nl_vec;
    ubg((3*N_points+2):(4*N_points+1)) = 0;

    lbx = nan(4*N_points + 1, 1);
    ubx = nan(4*N_points + 1, 1);

    lbx(1:(N_points+1)) = 5;
    lbx((N_points+2):(2*N_points+1)) = -AX_MAX;
    lbx((2*N_points+2):(3*N_points+1)) = -20;
    lbx((3*N_points+2):(4*N_points+1)) = -20;

    ubx(1:(N_points+1)) = 200;
    ubx((N_points+2):(2*N_points+1)) = AX_MAX;
    ubx((2*N_points+2):(3*N_points+1)) = 20;
    ubx((3*N_points+2):(4*N_points+1)) = 20;

    x_guess = nan(4*N_points+1, 1);

    x_guess(1:(N_points+1)) = 5;
    x_guess((N_points+2):(2*N_points+1)) = 0;
    x_guess((2*N_points+2):(3*N_points+1)) = 0;
    x_guess((3*N_points+2):(4*N_points+1)) = 0;

    nlp = struct('x', v_vec, 'f', cost, 'g', g_vec);

    solver = nlpsol('solver', 'ipopt', nlp);

    sol = solver('x0', x_guess, 'lbx', lbx, 'ubx', ubx, 'lbg', lbg, 'ubg', ubg);

    val_vec_sol = full(sol.x);

    v_vec_sol = val_vec_sol(1:(N_points+1));
    ax_vec_sol = val_vec_sol((N_points+2):(2*N_points+1));
    n_cp_vec_sol = val_vec_sol((2*N_points+2):(3*N_points+1));
    t_cp_vec_sol = val_vec_sol((3*N_points+2):(4*N_points+1));

    first_der_guess = full(first_der_fun(x_guess));
    second_der_guess = full(second_der_fun(x_guess));
    third_der_guess = full(third_der_fun(x_guess));

    first_der_sol = full(first_der_fun(val_vec_sol));
    second_der_sol = full(second_der_fun(val_vec_sol));
    third_der_sol = full(third_der_fun(val_vec_sol));
    n_sol = full(n_fun(val_vec_sol));

    raceline_bspline.d_knot_vec = d_knot_vec;
    raceline_bspline.points = points + [n_cp_vec_sol t_cp_vec_sol];
    raceline_bspline.n = n_sol;
    raceline_bspline.v = v_vec_sol;
    raceline_bspline.ax = ax_vec_sol;
    raceline_bspline.first_der_sol = first_der_sol;
    raceline_bspline.second_der_sol = second_der_sol;
    raceline_bspline.third_der_sol = third_der_sol;
    raceline_bspline.first_der_guess = first_der_guess;
    raceline_bspline.second_der_guess = second_der_guess;
    raceline_bspline.third_der_guess = third_der_guess;

end
