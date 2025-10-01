function Nt_mat = generate_bspline_third_endpoints(d_knot_vec)

    N_points = length(d_knot_vec);

    d_knot_vec_padded = [d_knot_vec; d_knot_vec(1:4)];

    Nt_mat = nan(1, 4, N_points);

    for i=1:N_points

        curr_a = d_knot_vec_padded(i);
        curr_b = d_knot_vec_padded(i+1);
        curr_c = d_knot_vec_padded(i+2);
        curr_d = d_knot_vec_padded(i+3);
        curr_e = d_knot_vec_padded(i+4);

        curr_Nt_vec = nan(1, 4);

        curr_Nt_vec(1) = -6/(curr_c*(curr_b + curr_c)*(curr_a + curr_b + curr_c));
        curr_Nt_vec(2) = (6*(curr_b + 2*curr_c + curr_d))/(curr_c*(curr_b + curr_c)*(curr_c + curr_d)*(curr_b + curr_c + curr_d)) - curr_Nt_vec(1);
        curr_Nt_vec(4) = 6/(curr_c*(curr_c + curr_d)*(curr_c + curr_d + curr_e));
        curr_Nt_vec(3) = -(6*(curr_b + 2*curr_c + curr_d))/(curr_c*(curr_b + curr_c)*(curr_c + curr_d)*(curr_b + curr_c + curr_d)) - curr_Nt_vec(4);

        Nt_mat(:, :, i) = curr_Nt_vec;

    end

end

