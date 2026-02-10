function errors = process_states(gt, tt, err_thr)

    % INTERPOLATION OF GT AND ERROR COMPUTATION
    interpFields = {'x_map','y_map','x_rel','y_rel','yaw_map','yaw_rel', 'vx'};
    for l = interpFields
        gt.([l{1} '_interp'])  = interp1(gt.stamp, gt.(l{1}), tt.stamp);
        errors.([l{1} '_err']) = tt.(l{1}) - gt.([l{1} '_interp']);
    end

    tt.yaw_map = unwrap_angle_smart(tt.yaw_map, gt.yaw_map_interp);
    tt.yaw_rel = unwrap_angle_smart(tt.yaw_rel, gt.yaw_rel_interp);
    errors.yaw_map_err = tt.yaw_map - gt.yaw_map_interp;



    % STATISTICS COMPUTATION
    ass = hypot(errors.x_map_err, errors.y_map_err) < err_thr;
    stats = {'x_rel','y_rel','yaw_map','vx'};
    for l = stats
        errors.([l{1} '_std'])  = std(errors.([l{1} '_err'])(ass));
        errors.([l{1} '_mean']) = mean(errors.([l{1} '_err'])(ass));
    end

    [errors.x_ellipse, errors.y_ellipse] = calculate_ellipse( ...
        errors.x_rel_std, errors.y_rel_std, errors.x_rel_mean, errors.y_rel_mean);

end
