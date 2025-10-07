function out = get_radar_fields(in)
    
    out.sens_stamp = in.perception__radar__clustering_detections.sensor_stamp__tot;
    out.stamp = in.perception__radar__clustering_detections.stamp__tot;
    
    % map
    out.x_map = in.perception__radar__clustering_detections.detections__x_map;
    out.y_map = in.perception__radar__clustering_detections.detections__y_map;
    out.yaw_map = in.perception__radar__clustering_detections.detections__yaw_map;
    no_meas = (out.x_map==0);
    out.x_map(no_meas)=nan;
    out.y_map(no_meas)=nan;
    out.yaw_map(no_meas)=nan;

    % relative
    out.x_rel = in.perception__radar__clustering_detections.detections__x_rel;
    out.y_rel = in.perception__radar__clustering_detections.detections__y_rel;
    out.x_rel(no_meas)=nan;
    out.y_rel(no_meas)=nan;
    out.rho_dot = in.perception__radar__clustering_detections.detections__rho_dot;
    out.rho_dot(no_meas)=nan;

    % count
    out.count = size(out.x_map,2) - sum(no_meas,2);
    out.max_det = max(out.count);
end