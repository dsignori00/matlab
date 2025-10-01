function [t_vec, points_idx, M_vec, Mf_vec, Ms_vec, Mt_vec] = transform_u_vec_t_vec(d_knot_vec, u_vec)

    N_samples = length(u_vec);
    N_points = length(d_knot_vec);

    t_vec = nan(N_samples, 1);
    points_idx = nan(N_samples, 1);
    M_vec = nan(N_samples, 4, 4);
    Mf_vec = nan(N_samples, 3, 4);
    Ms_vec = nan(N_samples, 2, 4);
    Mt_vec = nan(N_samples, 1, 4);

    d_knot_vec_padded = [d_knot_vec; d_knot_vec(1:4)];
    u_vec_breakpoints = [0; cumsum(d_knot_vec_padded(3:(end-2)))];

    u_vec(end) = u_vec_breakpoints(end);

    for i=1:N_points

        curr_idx_vec = u_vec >= u_vec_breakpoints(i) & u_vec < u_vec_breakpoints(i+1);
        
        points_idx(curr_idx_vec) = i;
        t_vec(curr_idx_vec) = (u_vec(curr_idx_vec) - u_vec_breakpoints(i)) ./ ...
                              (u_vec_breakpoints(i+1) - u_vec_breakpoints(i));

        [curr_M, curr_Mf, curr_Ms, curr_Mt] = compute_bspline_matrices(d_knot_vec_padded(i:(i+4)));

        M_vec(curr_idx_vec, :, :) = repmat(reshape(curr_M, [1, 4, 4]), [sum(curr_idx_vec), 1, 1]);
        Mf_vec(curr_idx_vec, :, :) = repmat(reshape(curr_Mf, [1, 3, 4]), [sum(curr_idx_vec), 1, 1]);
        Ms_vec(curr_idx_vec, :, :) = repmat(reshape(curr_Ms, [1, 2, 4]), [sum(curr_idx_vec), 1, 1]);
        Mt_vec(curr_idx_vec, :, :) = repmat(reshape(curr_Mt, [1, 1, 4]), [sum(curr_idx_vec), 1, 1]);

    end

    curr_idx_vec = u_vec >= u_vec_breakpoints(end);

    [curr_M, curr_Mf, curr_Ms, curr_Mt] = compute_bspline_matrices(d_knot_vec_padded(N_points:(N_points+4)));
        
    points_idx(curr_idx_vec) = N_points;
    t_vec(curr_idx_vec) = (u_vec(curr_idx_vec) - u_vec_breakpoints(end-1)) ./ ...
                          (u_vec_breakpoints(end) - u_vec_breakpoints(end-1));

    M_vec(curr_idx_vec, :, :) = repmat(reshape(curr_M, [1, 4, 4]), [sum(curr_idx_vec), 1, 1]);
    Mf_vec(curr_idx_vec, :, :) = repmat(reshape(curr_Mf, [1, 3, 4]), [sum(curr_idx_vec), 1, 1]);
    Ms_vec(curr_idx_vec, :, :) = repmat(reshape(curr_Ms, [1, 2, 4]), [sum(curr_idx_vec), 1, 1]);
    Mt_vec(curr_idx_vec, :, :) = repmat(reshape(curr_Mt, [1, 1, 4]), [sum(curr_idx_vec), 1, 1]);

end

