function tt = load_target_tracking(log)
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
    tt.ax = log.perception__opponents.opponents__ax;
    tt.yaw_map = log.perception__opponents.opponents__psi;
    tt.count = log.perception__opponents.count;
    tt.max_opp = max(tt.count);
    tt.x_map(tt.x_map==0)=nan;
    tt.y_map(tt.y_map==0)=nan;
    tt.vx(tt.vx==0)=nan;
    tt.ax(tt.ax==0)=nan;
    tt.yaw_map(tt.yaw_map==0)=nan;
end