function [R_x,P_x,R_y,P_y] = corr_with_ref(sensor, idx, corr_stamp, corr_value)
    
    stamp = repmat(sensor.sens_stamp, 1, size(sensor.x_map_err,2));
    stamp = stamp(idx);

    xe = sensor.x_map_err(idx);
    ye = sensor.y_map_err(idx);

    % Interpola corr_value ai timestamp corrispondenti
    corr_val = interp1(corr_stamp, corr_value, stamp, 'linear', 'extrap');

    % Correlazione
    [R_x,P_x] = corrcoef(corr_val, abs(xe));
    [R_y,P_y] = corrcoef(corr_val, abs(ye));

end
