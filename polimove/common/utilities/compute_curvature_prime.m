function rhop = compute_curvature_prime(points, d_knot_vec)

    N_points = length(d_knot_vec);

    Np_tens = generate_bspline_prime_endpoints(d_knot_vec);
    Ns_tens = generate_bspline_second_endpoints(d_knot_vec);
    Nt_tens = generate_bspline_third_endpoints(d_knot_vec);

    Padding_mat = [eye(N_points); [1 zeros(1, N_points-1)]; [0 1 zeros(1, N_points-2)]; [0 0 1 zeros(1, N_points-3)]];

    C_mat = zeros(4*N_points, N_points+3);

    for i=1:N_points
        C_mat(4*(i-1)+1, i) = 1;
        C_mat(4*(i-1)+2, i+1) = 1;
        C_mat(4*(i-1)+3, i+2) = 1;
        C_mat(4*(i-1)+4, i+3) = 1;
    end

    Np_mat = zeros(N_points, 4*N_points);
    Ns_mat = zeros(N_points, 4*N_points);
    Nt_mat = zeros(N_points, 4*N_points);

    for i=1:N_points
        Np_mat(i, (4*(i-1)+1):(4*i)) = Np_tens(:, :, i);
        Ns_mat(i, (4*(i-1)+1):(4*i)) = Ns_tens(:, :, i);
        Nt_mat(i, (4*(i-1)+1):(4*i)) = Nt_tens(:, :, i);
    end

    knots_prime = (Np_mat*C_mat*Padding_mat) * points;
    knots_second = (Ns_mat*C_mat*Padding_mat) * points;
    knots_third = (Nt_mat*C_mat*Padding_mat) * points;
    tf_val = compute_duds(points, d_knot_vec);

    xp = knots_prime(:, 1);
    yp = knots_prime(:, 2);
    xs = knots_second(:, 1);
    ys = knots_second(:, 2);
    xt = knots_third(:, 1);
    yt = knots_third(:, 2);

    rhop = 3.*tf_val.^6.*(-(xp.^2).*xs.*ys + xp.*(xs.^2).*yp - xp.*yp.*(ys.^2) + xs.*(yp.^2).*ys) + ...
           tf_val.^4.*(yt.*xp - xt.*yp);
end

