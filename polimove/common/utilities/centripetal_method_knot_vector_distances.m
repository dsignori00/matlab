function dk_vec = centripetal_method_knot_vector_distances(d_vec, EXPONENT)

    N_points = length(d_vec);
    dk_vec = [d_vec(end).^(EXPONENT); d_vec(1:(end-1)).^(EXPONENT)] ./ sum(d_vec.^(EXPONENT)) .* N_points;

end

