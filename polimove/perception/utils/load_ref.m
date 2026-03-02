function gt = load_ref(log, use_sim_ref, use_ref, log_ref)
    %  GROUND TRUTH EXTRACTION
    gt = struct();  % guaranteed existence

    if exist("use_sim_ref",'var') && use_sim_ref
        gt.stamp   = log.sim_out.bag_stamp;
        gt.x_rel   = log.sim_out.opponents__x_rel(:,1);
        gt.y_rel   = log.sim_out.opponents__y_rel(:,1);
        gt.rho_dot = log.sim_out.opponents__rho_dot(:,1);
        gt.yaw_rel = rad2deg(wrapToPi(log.sim_out.opponents__psi_rel(:,1)));

        gt.x_map   = log.sim_out.opponents__x_geom(:,1);
        gt.y_map   = log.sim_out.opponents__y_geom(:,1);
        gt.vx      = log.sim_out.opponents__vx(:,1);
        gt.ax      = log.sim_out.opponents__ax(:,1);

        gt.yaw_map = rad2deg(wrapToPi(log.sim_out.opponents__psi(:,1)));

    elseif exist('use_ref','var') && use_ref
        gt.stamp   = (log_ref.timestamp - double(log.time_offset_nsec))*1e-9;
        gt.x_rel   = log_ref.x_rel;
        gt.y_rel   = log_ref.y_rel;
        gt.z_rel   = log_ref.z_rel;
        gt.rho     = log_ref.rho;
        gt.rho_dot = log_ref.rho_dot;
        gt.yaw_rel = rad2deg(wrapToPi(log_ref.yaw_rel));

        gt.x_map   = log_ref.x_map;
        gt.y_map   = log_ref.y_map;
        gt.z_map   = log_ref.z_map;
        gt.vx      = log_ref.speed;
        gt.ax      = log_ref.ax;
        gt.yaw_map = rad2deg(wrapToPi(log_ref.yaw_map));
        gt.yaw_rate= rad2deg(log_ref.yaw_rate);
    end
end 
