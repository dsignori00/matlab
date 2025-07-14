function Ns_mat = generate_bspline_second_endpoints(d_knot_vec)

    N_points = length(d_knot_vec);

    d_knot_vec_padded = [d_knot_vec; d_knot_vec(1:3)];

    Ns_mat = nan(1, 4, N_points);

    for i=1:N_points

        curr_a = d_knot_vec_padded(i);
        curr_b = d_knot_vec_padded(i+1);
        curr_c = d_knot_vec_padded(i+2);
        curr_d = d_knot_vec_padded(i+3);

        curr_Ns_vec = nan(1, 4);

        curr_Ns_vec(1) = 6/((curr_b + curr_c)*(curr_a + curr_b + curr_c));
        curr_Ns_vec(3) = 6/((curr_b + curr_c)*(curr_b + curr_c + curr_d));
        curr_Ns_vec(2) = -curr_Ns_vec(3) -curr_Ns_vec(1);
        curr_Ns_vec(4) = 0;

        Ns_mat(:, :, i) = curr_Ns_vec;

    end

end

