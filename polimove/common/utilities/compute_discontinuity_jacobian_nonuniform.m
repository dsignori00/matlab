function J =  compute_discontinuity_jacobian_nonuniform(d_knot_vec)

    N_points = length(d_knot_vec);

    Nt_mat = generate_bspline_third_endpoints(d_knot_vec);
    Nt_mat_padded = cat(3, Nt_mat, Nt_mat(:, :, 1));

    J_padded = zeros(N_points, N_points+4);

    for i=1:N_points

        J_padded(i, i) = -Nt_mat_padded(1, 1, i);
        J_padded(i, i+1) = Nt_mat_padded(1, 1, i+1) - Nt_mat_padded(1, 2, i);
        J_padded(i, i+2) = Nt_mat_padded(1, 2, i+1) - Nt_mat_padded(1, 3, i);
        J_padded(i, i+3) = Nt_mat_padded(1, 3, i+1) - Nt_mat_padded(1, 4, i);
        J_padded(i, i+4) = Nt_mat_padded(1, 4, i+1);

    end

    J = J_padded(:, 1:N_points);
    J(:, 1:4) = J(:, 1:4) + J_padded(:, (end-3):end);
    
end

