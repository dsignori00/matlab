function [R_x,P_x,R_y,P_y,corr_val,stamp,xe,ye] = corr_with_ref(sensor, corr_stamp, corr_value)

    valid = ~isnan(sensor.x_map_err);

    stamp = sensor.sens_stamp(valid);
    xe    = sensor.x_map_err(valid);
    ye    = sensor.y_map_err(valid);

    corr_val = interp1(corr_stamp, corr_value, stamp, 'linear', 'extrap');

    [R_x,P_x] = corrcoef(corr_val, abs(xe));
    [R_y,P_y] = corrcoef(corr_val, abs(ye));
end
