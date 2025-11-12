function Np_mat = generate_bspline_prime_endpoints(d_knot_vec)

    N_points = length(d_knot_vec);

    d_knot_vec_padded = [d_knot_vec; d_knot_vec(1:3)];

    Np_mat = nan(1, 4, N_points);

    for i=1:N_points

        curr_a = d_knot_vec_padded(i);
        curr_b = d_knot_vec_padded(i+1);
        curr_c = d_knot_vec_padded(i+2);
        curr_d = d_knot_vec_padded(i+3);

        curr_Np_vec = nan(1, 4);

        curr_Np_vec(1) = -3*curr_c/((curr_b + curr_c)*(curr_a + curr_b + curr_c));
        curr_Np_vec(3) = 3*curr_b/((curr_b + curr_c)*(curr_b + curr_c + curr_d));
        curr_Np_vec(2) = -curr_Np_vec(3) -curr_Np_vec(1);
        curr_Np_vec(4) = 0;

        Np_mat(:, :, i) = curr_Np_vec;

    end

end

