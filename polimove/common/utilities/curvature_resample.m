function points_resampled = curvature_resample(points, CURVATURE_RESAMPLE_PARAMS)

    RHO_WINDOWSIDELEN = CURVATURE_RESAMPLE_PARAMS.rho_windowsidelen;
    RHO_N_FILTERS = CURVATURE_RESAMPLE_PARAMS.rho_n_filters;
    S_WINDOWSIDELEN = CURVATURE_RESAMPLE_PARAMS.s_windowsidelen;
    S_N_FILTERS = CURVATURE_RESAMPLE_PARAMS.s_n_filters;
    RHO_MIN_THRESHOLD = CURVATURE_RESAMPLE_PARAMS.rho_min_threshold;
    N_new_points = CURVATURE_RESAMPLE_PARAMS.N_new_points;

    N_points = size(points, 1);

    points_padded = [points; points(1, :)];
    points_s = compute_curv_abscissa(points_padded);
    s_end = points_s(end);

    rho_vec = compute_3points_curvatures(points);
    rho_vec_smooth = movmean_smoothing(rho_vec, RHO_WINDOWSIDELEN, RHO_N_FILTERS);

    radius_vec = 1 ./ (max(abs(rho_vec_smooth), RHO_MIN_THRESHOLD));

    ds_vec = radius_vec ./ sum(radius_vec) .* s_end;
    ds_vec_smooth = movmean_smoothing(ds_vec, S_WINDOWSIDELEN, S_N_FILTERS);
    ds_vec_smooth = ds_vec_smooth ./ sum(ds_vec_smooth) .* s_end;

    s_vec = [0; cumsum(ds_vec_smooth)];
    s_vec_resampled = interp1((0:N_points).', s_vec, ((0:N_new_points).*(N_points/N_new_points)).');
    s_vec_resampled(end) = [];

    points_resampled = resample_line(points, s_vec_resampled);

end

