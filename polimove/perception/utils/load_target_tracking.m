function tt = load_target_tracking(log)
    if isfield(log, "perception__opponents")
        tt.stamp = log.perception__opponents.stamp__tot;
        % relative
        tt.x_rel = log.perception__opponents.opponents__x_rel;
        tt.y_rel = log.perception__opponents.opponents__y_rel;
        tt.rho_dot = log.perception__opponents.opponents__rho_dot;
        tt.yaw_rel = log.perception__opponents.opponents__psi_rel;
        tt.x_rel(tt.x_rel==0)=nan;
        tt.y_rel(tt.y_rel==0)=nan;
        tt.rho_dot(tt.rho_dot==0)=nan;
        tt.yaw_rel(tt.yaw_rel==0)=nan;
        % map
        tt.x_map = log.perception__opponents.opponents__x_geom;
        tt.y_map = log.perception__opponents.opponents__y_geom;
        tt.vx = log.perception__opponents.opponents__vx;
        tt.yaw_map = log.perception__opponents.opponents__psi;
        tt.ax = log.perception__opponents.opponents__ax;
        tt.covariance = valid_covariance(log.perception__opponents.opponents__ekf_p);
        tt.count = log.perception__opponents.count;
        tt.max_opp = max(tt.count);
        tt.x_map(tt.x_map==0)=nan;
        tt.y_map(tt.y_map==0)=nan;
        tt.vx(tt.vx==0)=nan;
        tt.yaw_map(tt.yaw_map==0)=nan;
        tt.ax(tt.ax==0)=nan;
        if isfield(log.perception__opponents,"opponents__yaw_rate")
            tt.yaw_rate = log.perception__opponents.opponents__yaw_rate;
            tt.yaw_rate(tt.yaw_rate==0)=nan;
        end
        % associated measures
        if isfield(log.perception__opponents,"opponents__meas_count")
            tt.measures.count = log.perception__opponents.opponents__meas_count;
            tt.measures.source = log.perception__opponents.opponents__meas_source_type;
            tt.measures.stamp = log.perception__opponents.opponents__meas_stamp;
            tt.measures.x_map = log.perception__opponents.opponents__meas_x_map;
            tt.measures.y_map = log.perception__opponents.opponents__meas_y_map;
            tt.measures.stamp(tt.measures.stamp==0)=nan;
            tt.measures.x_map(tt.measures.x_map==0)=nan;
            tt.measures.y_map(tt.measures.y_map==0)=nan;
            tt.measures.stamp = tt.measures.stamp - log.time_offset_nsec*10^-9;
        end
    else
        error('No target tracking data found in the log.');
    end
end