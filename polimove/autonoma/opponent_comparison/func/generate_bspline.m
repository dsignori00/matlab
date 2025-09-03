function bspline_mat = generate_bspline(d_knot_vec)

    N_points = length(d_knot_vec);

    N_mat = generate_bspline_endpoints(d_knot_vec);
    Np_mat = generate_bspline_prime_endpoints(d_knot_vec);
    Ns_mat = generate_bspline_second_endpoints(d_knot_vec);
    Nt_mat = generate_bspline_third_endpoints(d_knot_vec);

    bspline_mat = nan(4, 4, N_points);

    d_knot_vec_padded = [d_knot_vec; d_knot_vec(1:2)];

    for i=1:N_points

        curr_N_vec = N_mat(:, :, i);
        curr_Np_vec = Np_mat(:, :, i);
        curr_Ns_vec = Ns_mat(:, :, i);
        curr_Nt_vec = Nt_mat(:, :, i);

        curr_d = d_knot_vec_padded(i+2);

        curr_bspline_mat = [curr_N_vec; 
                            curr_d.*curr_Np_vec; 
                            ((curr_d.^2)./2).*curr_Ns_vec; 
                            ((curr_d.^3)./6).*curr_Nt_vec];

        bspline_mat(:, :, i) = curr_bspline_mat;

    end

end

