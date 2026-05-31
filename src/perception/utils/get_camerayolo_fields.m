function out = get_camerayolo_fields(log, t_source_type)
% CAMERA CLUSTERING DETECTIONS
% Inputs: log (struct), t_source_type (3,4)
% Output: out (struct or [])
    out = struct();

    source_type = log.perception__camera__yolo_detections.source__type;
    mask = source_type == t_source_type;
    if sum(mask) == 0, return; end

    out.sens_stamp = log.perception__camera__yolo_detections.sensor_stamp__tot(mask,:);
    out.stamp      = log.perception__camera__yolo_detections.stamp__tot(mask,:);
    out.id         = log.perception__camera__yolo_detections.detections__id(mask,:);
    out.count      = log.perception__camera__yolo_detections.count(mask,:);
    out.source_type = log.perception__camera__yolo_detections.source__type(mask,:);

    % relative
    out.x_rel   = log.perception__camera__yolo_detections.detections__x_rel(mask,:);
    out.y_rel   = log.perception__camera__yolo_detections.detections__y_rel(mask,:);
    out.z_rel   = log.perception__camera__yolo_detections.detections__z_rel(mask,:);
    out.yaw_rel = log.perception__camera__yolo_detections.detections__yaw_rel(mask,:);
    
    % map
    out.x_map   = log.perception__camera__yolo_detections.detections__x_map(mask,:);
    out.y_map   = log.perception__camera__yolo_detections.detections__y_map(mask,:);
    out.z_map   = log.perception__camera__yolo_detections.detections__z_map(mask,:);
    out.yaw_map = log.perception__camera__yolo_detections.detections__yaw_map(mask,:);
    no_meas = (out.x_map==0);


    out.x_rel(no_meas)     = nan;
    out.y_rel(no_meas)     = nan;
    out.z_rel(no_meas)     = nan;
    out.yaw_rel(no_meas)  = nan;

    out.x_map(no_meas)     = nan;
    out.y_map(no_meas)     = nan;
    out.z_map(no_meas)     = nan;
    out.yaw_map(no_meas) = nan;
    out.max_det = max(out.count);

end