function best_lap = fit_trajectory(best_lap, CURVATURE_RESAMPLE_PARAMS, SMOOTHING_TOL)

    center_line_resampled = curvature_resample([best_lap.x_filt best_lap.y_filt], CURVATURE_RESAMPLE_PARAMS);
    
    left_border = [best_lap.x_filt - SMOOTHING_TOL.*sin(best_lap.yaw_filt), best_lap.y_filt + SMOOTHING_TOL.*cos(best_lap.yaw_filt)];
    right_border = [best_lap.x_filt + SMOOTHING_TOL.*sin(best_lap.yaw_filt), best_lap.y_filt - SMOOTHING_TOL.*cos(best_lap.yaw_filt)];
    
    [smooth_center_line, d_knot_vec] = smoothing_discontinuities(center_line_resampled, left_border, right_border);
    
    N_points = size(smooth_center_line, 1);
    
    v_smooth = nan(N_points, 1);
    ax_smooth = nan(N_points, 1);
    
    for i=1:N_points
    
        [~, curr_idx] = min((best_lap.x_filt-smooth_center_line(i, 1)).^2 + (best_lap.y_filt-smooth_center_line(i, 2)).^2);
    
        v_smooth(i) = best_lap.v_filt(curr_idx);
        ax_smooth(i) = best_lap.ax(curr_idx);
    
    end
    
    rho_smooth = compute_curvature(smooth_center_line, d_knot_vec);
    s_smooth = compute_curv_abscissa(smooth_center_line);
    
    ay_smooth = v_smooth.^2 .* rho_smooth;

    best_lap.x_smooth = center_line_resampled(:, 1);
    best_lap.y_smooth = center_line_resampled(:, 2);
    best_lap.rho_smooth = rho_smooth;
    best_lap.s_smooth = s_smooth;
    best_lap.v_smooth = v_smooth;
    best_lap.ax_smooth = ax_smooth;
    best_lap.ay_smooth = ay_smooth;

end

