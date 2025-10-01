function lap_struct = exclude_repetitions(lap_struct)

    x = lap_struct.x;
    y = lap_struct.y;

    ds = sqrt(diff(x).^2 + diff(y).^2);

    valid_idx = [true; ds > 0];

    ds_valid = ds(valid_idx(2:end));
    s_valid = [0; cumsum(ds_valid)];

    lap_struct.x_no_rep = x(valid_idx);
    lap_struct.y_no_rep = y(valid_idx);
    lap_struct.v_no_rep = lap_struct.v(valid_idx);
    lap_struct.yaw_no_rep = lap_struct.yaw(valid_idx);
    lap_struct.s_no_rep = s_valid;

end

