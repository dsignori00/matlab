function out = get_pointpillars_fields(log)
% LIDAR POINTPILLARS DETECTIONS
% Inputs: log (struct)
% Output: out (struct or [])
    out = struct();
    out.sens_stamp = log.perception__lidar__pointpillars_detections.sensor_stamp__tot;
    out.stamp      = log.perception__lidar__pointpillars_detections.stamp__tot;

    % relative
    out.x_rel   = log.perception__lidar__pointpillars_detections.detections__x_rel;
    out.y_rel   = log.perception__lidar__pointpillars_detections.detections__y_rel;
    out.z_rel   = log.perception__lidar__pointpillars_detections.detections__z_rel;
    out.yaw_rel = log.perception__lidar__pointpillars_detections.detections__yaw_rel;
    out.valid_yaw = log.perception__lidar__pointpillars_detections.detections__valid_yaw;
    out.score = log.perception__lidar__pointpillars_detections.detections__confidence;
    


    % map
    out.x_map   = log.perception__lidar__pointpillars_detections.detections__x_map;
    out.y_map   = log.perception__lidar__pointpillars_detections.detections__y_map;
    out.z_map   = log.perception__lidar__pointpillars_detections.detections__z_map;
    out.yaw_map = log.perception__lidar__pointpillars_detections.detections__yaw_map;
    no_meas = (out.x_map==0);

    out.score(no_meas)     = nan;
    out.x_rel(no_meas)     = nan;
    out.y_rel(no_meas)     = nan;
    out.z_rel(no_meas)     = nan;
    out.yaw_rel(no_meas) = nan;
    out.x_map(no_meas)     = nan;
    out.y_map(no_meas)     = nan;
    out.z_map(no_meas)     = nan;
    out.yaw_map(no_meas) = nan;
    out.count = size(out.x_map,2) - sum(no_meas,2);
    out.max_det = max(out.count);

end
