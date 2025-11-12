function normals = compute_normals(points, d_knots)

    N_points = size(points, 1);
    points_padded = [points; points(1:3, :)];

    Np_tens = generate_bspline_prime_endpoints(d_knots);

    normals = nan(N_points, 2);

    for i=1:N_points

        curr_tan = squeeze(Np_tens(:, :, i)) * points_padded(i:(i+3), :);
        normals(i, :) = [-curr_tan(2) curr_tan(1)] ./ norm(curr_tan);

    end

end

