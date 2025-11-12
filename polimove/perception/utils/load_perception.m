% Helper function to create an empty detection struct
emptyDetectionStruct = struct( ...
    'sens_stamp', NaN, ...
    'stamp', NaN, ...
    'x_rel', NaN, ...
    'y_rel', NaN, ...
    'z_rel', NaN, ...
    'yaw_rel', NaN, ...
    'x_map', NaN, ...
    'y_map', NaN, ...
    'z_map', NaN, ...
    'yaw_map', NaN ...
);

% Add optional radar-specific field
emptyRadarStruct = emptyDetectionStruct;
emptyRadarStruct.rho_dot = NaN;

% LIDAR CLUSTERING DETECTIONS
if exist("log.perception__lidar__clustering_detections",'var')
    lid_clust.sens_stamp = log.perception__lidar__clustering_detections.sensor_stamp__tot;
    lid_clust.stamp      = log.perception__lidar__clustering_detections.stamp__tot;
    % relative
    lid_clust.x_rel  = log.perception__lidar__clustering_detections.detections__x_rel;
    lid_clust.y_rel  = log.perception__lidar__clustering_detections.detections__y_rel;
    lid_clust.z_rel  = log.perception__lidar__clustering_detections.detections__z_rel;
    lid_clust.yaw_rel= log.perception__lidar__clustering_detections.detections__yaw_rel;
    lid_clust.x_rel(lid_clust.x_rel==0)=nan;
    lid_clust.y_rel(lid_clust.y_rel==0)=nan;
    lid_clust.z_rel(lid_clust.z_rel==0)=nan;
    lid_clust.yaw_rel(lid_clust.yaw_rel==0)=nan;
    % map
    lid_clust.x_map  = log.perception__lidar__clustering_detections.detections__x_map;
    lid_clust.y_map  = log.perception__lidar__clustering_detections.detections__y_map;
    lid_clust.z_map  = log.perception__lidar__clustering_detections.detections__z_map;
    lid_clust.yaw_map= log.perception__lidar__clustering_detections.detections__yaw_map;
    lid_clust.x_map(lid_clust.x_map==0)=nan;
    lid_clust.y_map(lid_clust.y_map==0)=nan;
    lid_clust.z_map(lid_clust.z_map==0)=nan;
    lid_clust.yaw_map(lid_clust.yaw_map==0)=nan;
else
    lid_clust = emptyDetectionStruct;
end

% RADAR CLUSTERING DETECTIONS
if exist("log.perception__radar__clustering_detections",'var')
    rad_clust.sens_stamp = log.perception__radar__clustering_detections.sensor_stamp__tot;
    rad_clust.stamp      = log.perception__radar__clustering_detections.stamp__tot;
    % relative
    rad_clust.x_rel  = log.perception__radar__clustering_detections.detections__x_rel;
    rad_clust.y_rel  = log.perception__radar__clustering_detections.detections__y_rel;
    rad_clust.z_rel  = log.perception__radar__clustering_detections.detections__z_rel;
    rad_clust.yaw_rel= log.perception__radar__clustering_detections.detections__yaw_rel;
    rad_clust.rho_dot= log.perception__radar__clustering_detections.detections__rho_dot;
    rad_clust.x_rel(rad_clust.x_rel==0)=nan;
    rad_clust.y_rel(rad_clust.y_rel==0)=nan;
    rad_clust.z_rel(rad_clust.z_rel==0)=nan;
    rad_clust.yaw_rel(rad_clust.yaw_rel==0)=nan;
    rad_clust.rho_dot(rad_clust.rho_dot==0)=nan;
    % map
    rad_clust.x_map  = log.perception__radar__clustering_detections.detections__x_map;
    rad_clust.y_map  = log.perception__radar__clustering_detections.detections__y_map;
    rad_clust.z_map  = log.perception__radar__clustering_detections.detections__z_map;
    rad_clust.yaw_map= log.perception__radar__clustering_detections.detections__yaw_map;
    rad_clust.x_map(rad_clust.x_map==0)=nan;
    rad_clust.y_map(rad_clust.y_map==0)=nan;
    rad_clust.z_map(rad_clust.z_map==0)=nan;
    rad_clust.yaw_map(rad_clust.yaw_map==0)=nan;
else
    rad_clust = emptyRadarStruct;
end

% CAMERA YOLO DETECTIONS
if exist("log.perception__camera__yolo_detections",'var')
    cam_yolo.sens_stamp = log.perception__camera__yolo_detections.sensor_stamp__tot;
    cam_yolo.stamp      = log.perception__camera__yolo_detections.stamp__tot;
    % relative
    cam_yolo.x_rel  = log.perception__camera__yolo_detections.detections__x_rel;
    cam_yolo.y_rel  = log.perception__camera__yolo_detections.detections__y_rel;
    cam_yolo.z_rel  = log.perception__camera__yolo_detections.detections__z_rel;
    cam_yolo.yaw_rel= log.perception__camera__yolo_detections.detections__yaw_rel;
    cam_yolo.x_rel(cam_yolo.x_rel==0)=nan;
    cam_yolo.y_rel(cam_yolo.y_rel==0)=nan;
    cam_yolo.z_rel(cam_yolo.z_rel==0)=nan;
    cam_yolo.yaw_rel(cam_yolo.yaw_rel==0)=nan;
    % map
    cam_yolo.x_map  = log.perception__camera__yolo_detections.detections__x_map;
    cam_yolo.y_map  = log.perception__camera__yolo_detections.detections__y_map;
    cam_yolo.z_map  = log.perception__camera__yolo_detections.detections__z_map;
    cam_yolo.yaw_map= log.perception__camera__yolo_detections.detections__yaw_map;
    cam_yolo.x_map(cam_yolo.x_map==0)=nan;
    cam_yolo.y_map(cam_yolo.y_map==0)=nan;
    cam_yolo.z_map(cam_yolo.z_map==0)=nan;
    cam_yolo.yaw_map(cam_yolo.yaw_map==0)=nan;
else
    cam_yolo = emptyDetectionStruct;
end

% LIDAR POINTPILLARS DETECTIONS
if exist("log.perception__lidar__pointpillars_detections",'var')
    lid_pp.sens_stamp = log.perception__lidar__pointpillars_detections.sensor_stamp__tot;
    lid_pp.stamp      = log.perception__lidar__pointpillars_detections.stamp__tot;
    % relative
    lid_pp.x_rel  = log.perception__lidar__pointpillars_detections.detections__x_rel;
    lid_pp.y_rel  = log.perception__lidar__pointpillars_detections.detections__y_rel;
    lid_pp.z_rel  = log.perception__lidar__pointpillars_detections.detections__z_rel;
    lid_pp.yaw_rel= log.perception__lidar__pointpillars_detections.detections__yaw_rel;
    lid_pp.x_rel(lid_pp.x_rel==0)=nan;
    lid_pp.y_rel(lid_pp.y_rel==0)=nan;
    lid_pp.z_rel(lid_pp.z_rel==0)=nan;
    lid_pp.yaw_rel(lid_pp.yaw_rel==0)=nan;
    % map
    lid_pp.x_map  = log.perception__lidar__pointpillars_detections.detections__x_map;
    lid_pp.y_map  = log.perception__lidar__pointpillars_detections.detections__y_map;
    lid_pp.z_map  = log.perception__lidar__pointpillars_detections.detections__z_map;
    lid_pp.yaw_map= log.perception__lidar__pointpillars_detections.detections__yaw_map;
    lid_pp.x_map(lid_pp.x_map==0)=nan;
    lid_pp.y_map(lid_pp.y_map==0)=nan;
    lid_pp.z_map(lid_pp.z_map==0)=nan;
    lid_pp.yaw_map(lid_pp.yaw_map==0)=nan;
else
    lid_pp = emptyDetectionStruct;
end



% GROUND TRUTH
if(use_sim_ref)
    gt.stamp = log.sim_out.bag_stamp;
    % relative
    gt.x_rel = log.sim_out.opponents__x_rel(:,1);
    gt.y_rel = log.sim_out.opponents__y_rel(:,1);
    gt.rho_dot = log.sim_out.opponents__rho_dot(:,1);
    gt.yaw_rel = unwrap(log.sim_out.opponents__psi_rel(:,1));
    % map
    gt.x_map = log.sim_out.opponents__x_geom(:,1);
    gt.y_map = log.sim_out.opponents__y_geom(:,1);
    gt.vx = log.sim_out.opponents__vx(:,1);
    gt.yaw_map = log.sim_out.opponents__psi(:,1);
    gt.yaw_map = unwrap(gt.yaw_map);
elseif(use_ref)
    gt.stamp = (log_ref.timestamp - double(log.time_offset_nsec))*1e-9;
    % relative
    gt.x_rel = log_ref.x_rel;
    gt.y_rel = log_ref.y_rel;
    gt.z_rel = log_ref.z_rel;    
    gt.rho = log_ref.rho;
    gt.rho_dot = log_ref.rho_dot;
    gt.yaw_rel = unwrap(log_ref.yaw_rel);
    % map
    gt.x_map = log_ref.x_map;
    gt.y_map = log_ref.y_map;
    gt.z_map = log_ref.z_map;
    gt.vx = log_ref.speed;
    gt.yaw_map = log_ref.yaw_map;
end


if all( [
    all(structfun(@(x) all(isnan(x)), lid_clust)), ...
    all(structfun(@(x) all(isnan(x)), rad_clust)), ...
    all(structfun(@(x) all(isnan(x)), cam_yolo)), ...
    all(structfun(@(x) all(isnan(x)), lid_pp)) ] )
    
    error('No detections found: all detection structures are empty or contain only NaN values.');
end
