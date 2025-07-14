function dataset_polimove = reinterp_ego_data(dataset_raw, Ts)

    laps = dataset_raw.traj_server.lap_count;
    lap_times = dataset_raw.traj_server.curr_lap_time;
    x = dataset_raw.estimation.ekf_x_cog;
    y = dataset_raw.estimation.ekf_y_cog;
    yaw = dataset_raw.estimation.ekf_heading;
    v = dataset_raw.estimation.ekf_vx.*3.6;
    t_est = dataset_raw.estimation.bag_stamp;
    t_traj_server = dataset_raw.traj_server.bag_stamp;

    T_end = min(max(dataset_raw.estimation.bag_stamp), max(dataset_raw.traj_server.bag_stamp));
    T_start = max(min(dataset_raw.estimation.bag_stamp), min(dataset_raw.traj_server.bag_stamp));

    t_vec = (T_start:Ts:T_end).';

    dataset_polimove.x = interp1(t_est, x, t_vec);
    dataset_polimove.y = interp1(t_est, y, t_vec);
    dataset_polimove.vx = interp1(t_est, v, t_vec);
    dataset_polimove.yaw = interp1(t_est, yaw, t_vec);
    dataset_polimove.laps = interp1(t_traj_server, double(laps), t_vec, "nearest");
    dataset_polimove.lap_time = interp1(t_traj_server, lap_times, t_vec);

end

