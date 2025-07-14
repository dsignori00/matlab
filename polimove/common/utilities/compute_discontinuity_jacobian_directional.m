function [Jx, Jy] =  compute_discontinuity_jacobian_directional(d_knot_vec, t_vec)

    N_points = length(d_knot_vec);

    N_tens = generate_bspline_endpoints(d_knot_vec);
    Nt_tens = generate_bspline_third_endpoints(d_knot_vec);

    Padding_curr_mat = [eye(N_points); [1 zeros(1, N_points-1)]; [0 1 zeros(1, N_points-2)]; [0 0 1 zeros(1, N_points-3)]];
    Padding_next_mat = [[zeros(N_points-1, 1) eye(N_points-1)]; [1 zeros(1, N_points-1)]; [0 1 zeros(1, N_points-2)]; [0 0 1 zeros(1, N_points-3)]; [0 0 0 1 zeros(1, N_points-4)]];

    C_mat = zeros(4*N_points, N_points+3);

    for i=1:N_points
        C_mat(4*(i-1)+1, i) = 1;
        C_mat(4*(i-1)+2, i+1) = 1;
        C_mat(4*(i-1)+3, i+2) = 1;
        C_mat(4*(i-1)+4, i+3) = 1;
    end

    N_mat = zeros(N_points, 4*N_points);
    Nt_curr_mat = zeros(N_points, 4*N_points);
    Nt_next_mat = zeros(N_points, 4*N_points);

    for i=1:N_points

        N_mat(i, (4*(i-1)+1):(4*i)) = N_tens(:, :, i);
        Nt_curr_mat(i, (4*(i-1)+1):(4*i)) = Nt_tens(:, :, i);

        if i==N_points
            Nt_next_mat(i, (4*(i-1)+1):(4*i)) = Nt_tens(:, :, 1);
        else
            Nt_next_mat(i, (4*(i-1)+1):(4*i)) = Nt_tens(:, :, i+1);
        end

    end

    Jx = ((Nt_next_mat*C_mat*Padding_next_mat - Nt_curr_mat*C_mat*Padding_curr_mat) / (N_mat*C_mat*Padding_curr_mat)) * diag(t_vec(:, 1));
    Jy = ((Nt_next_mat*C_mat*Padding_next_mat - Nt_curr_mat*C_mat*Padding_curr_mat) / (N_mat*C_mat*Padding_curr_mat)) * diag(t_vec(:, 2));
    
end

