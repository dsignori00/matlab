function errors = process_states(gt, tt, err_thr, fields)

    % PREPROCESSING
    if ~any(strcmp(fields, 'x_map'))
        fields{end+1} = 'x_map';
    end
    if ~any(strcmp(fields, 'y_map'))
        fields{end+1} = 'y_map';
    end
    if ~any(strcmp(fields, 'x_rel'))
        fields{end+1} = 'x_rel';
    end
    if ~any(strcmp(fields, 'y_rel'))
        fields{end+1} = 'y_rel';
    end

    % INTERPOLATION OF GT AND ERROR COMPUTATION
    for l = fields
        gt.([l{1} '_interp'])  = interp1(gt.stamp, gt.(l{1}), tt.stamp);
        errors.([l{1} '_err']) = tt.(l{1}) - gt.([l{1} '_interp']);

        if(strcmp(l{1}, 'yaw_map'))
            tt.yaw_map = unwrap_angle_smart(tt.yaw_map, gt.yaw_map_interp);
            errors.yaw_map_err = tt.yaw_map - gt.yaw_map_interp;
        end

        if(strcmp(l{1}, 'yaw_rel'))
            tt.yaw_rel = unwrap_angle_smart(tt.yaw_rel, gt.yaw_rel_interp);
        end
    end


    % STATISTICS COMPUTATION
    ass = hypot(errors.x_map_err, errors.y_map_err) < err_thr;
    for l = fields
        errors.([l{1} '_std'])  = std(errors.([l{1} '_err'])(ass));
        errors.([l{1} '_mean']) = mean(errors.([l{1} '_err'])(ass));
    end

    [errors.x_ellipse, errors.y_ellipse] = calculate_ellipse( ...
        errors.x_rel_std, errors.y_rel_std, errors.x_rel_mean, errors.y_rel_mean);

end
