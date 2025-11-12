function dxy = convert_nt_to_xy_displacements(d_knot_vec, dtn, t_vec, n_vec)

    N_points = length(d_knot_vec);

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

    dxy = (N_mat*C_mat*Padding_mat) \ (dtn(:, 1).*t_vec + dtn(:, 2).*n_vec);

end

