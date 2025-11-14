function [lid_clust, rad_clust, cam_yolo, lid_pp, gt] = load_perception(log, use_sim_ref, use_ref, log_ref)
% LOAD_PERCEPTION  Parse perception detections and ground truth from log.
%
%   [lid_clust, rad_clust, cam_yolo, lid_pp, gt] = load_perception(log, use_sim_ref, use_ref, log_ref)
%
%   All four detection structs are guaranteed to exist. Missing sources
%   are replaced with empty structs containing NaN fields.


%  Helper empty structs


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

emptyRadarStruct = emptyDetectionStruct;
emptyRadarStruct.rho_dot = NaN;


%  LIDAR CLUSTERING DETECTIONS

if isfield(log,'perception__lidar__clustering_detections')
    d = log.perception__lidar__clustering_detections;

    lid_clust.sens_stamp = d.sensor_stamp__tot;
    lid_clust.stamp      = d.stamp__tot;

    lid_clust.x_rel   = replaceZeroWithNaN(d.detections__x_rel);
    lid_clust.y_rel   = replaceZeroWithNaN(d.detections__y_rel);
    lid_clust.z_rel   = replaceZeroWithNaN(d.detections__z_rel);
    lid_clust.yaw_rel = replaceZeroWithNaN(d.detections__yaw_rel);

    lid_clust.x_map   = replaceZeroWithNaN(d.detections__x_map);
    lid_clust.y_map   = replaceZeroWithNaN(d.detections__y_map);
    lid_clust.z_map   = replaceZeroWithNaN(d.detections__z_map);
    lid_clust.yaw_map = replaceZeroWithNaN(d.detections__yaw_map);
else
    lid_clust = emptyDetectionStruct;
end


%  RADAR CLUSTERING DETECTIONS

if isfield(log,'perception__radar__clustering_detections')
    d = log.perception__radar__clustering_detections;

    rad_clust.sens_stamp = d.sensor_stamp__tot;
    rad_clust.stamp      = d.stamp__tot;

    rad_clust.x_rel   = replaceZeroWithNaN(d.detections__x_rel);
    rad_clust.y_rel   = replaceZeroWithNaN(d.detections__y_rel);
    rad_clust.z_rel   = replaceZeroWithNaN(d.detections__z_rel);
    rad_clust.yaw_rel = replaceZeroWithNaN(d.detections__yaw_rel);
    rad_clust.rho_dot = replaceZeroWithNaN(d.detections__rho_dot);

    rad_clust.x_map   = replaceZeroWithNaN(d.detections__x_map);
    rad_clust.y_map   = replaceZeroWithNaN(d.detections__y_map);
    rad_clust.z_map   = replaceZeroWithNaN(d.detections__z_map);
    rad_clust.yaw_map = replaceZeroWithNaN(d.detections__yaw_map);
else
    rad_clust = emptyRadarStruct;
end


%  CAMERA YOLO DETECTIONS

if isfield(log,'perception__camera__yolo_detections')
    d = log.perception__camera__yolo_detections;

    cam_yolo.sens_stamp = d.sensor_stamp__tot;
    cam_yolo.stamp      = d.stamp__tot;

    cam_yolo.x_rel   = replaceZeroWithNaN(d.detections__x_rel);
    cam_yolo.y_rel   = replaceZeroWithNaN(d.detections__y_rel);
    cam_yolo.z_rel   = replaceZeroWithNaN(d.detections__z_rel);
    cam_yolo.yaw_rel = replaceZeroWithNaN(d.detections__yaw_rel);

    cam_yolo.x_map   = replaceZeroWithNaN(d.detections__x_map);
    cam_yolo.y_map   = replaceZeroWithNaN(d.detections__y_map);
    cam_yolo.z_map   = replaceZeroWithNaN(d.detections__z_map);
    cam_yolo.yaw_map = replaceZeroWithNaN(d.detections__yaw_map);
else
    cam_yolo = emptyDetectionStruct;
end


%  LIDAR POINTPILLARS DETECTIONS

if isfield(log,'perception__lidar__pointpillars_detections')
    d = log.perception__lidar__pointpillars_detections;

    lid_pp.sens_stamp = d.sensor_stamp__tot;
    lid_pp.stamp      = d.stamp__tot;

    lid_pp.x_rel   = replaceZeroWithNaN(d.detections__x_rel);
    lid_pp.y_rel   = replaceZeroWithNaN(d.detections__y_rel);
    lid_pp.z_rel   = replaceZeroWithNaN(d.detections__z_rel);
    lid_pp.yaw_rel = replaceZeroWithNaN(d.detections__yaw_rel);

    lid_pp.x_map   = replaceZeroWithNaN(d.detections__x_map);
    lid_pp.y_map   = replaceZeroWithNaN(d.detections__y_map);
    lid_pp.z_map   = replaceZeroWithNaN(d.detections__z_map);
    lid_pp.yaw_map = replaceZeroWithNaN(d.detections__yaw_map);
else
    lid_pp = emptyDetectionStruct;
end


%  GROUND TRUTH EXTRACTION

gt = struct();  % guaranteed existence

if exist("use_sim_ref",'var') && use_sim_ref
    gt.stamp   = log.sim_out.bag_stamp;
    gt.x_rel   = log.sim_out.opponents__x_rel(:,1);
    gt.y_rel   = log.sim_out.opponents__y_rel(:,1);
    gt.rho_dot = log.sim_out.opponents__rho_dot(:,1);
    gt.yaw_rel = unwrap(log.sim_out.opponents__psi_rel(:,1));

    gt.x_map   = log.sim_out.opponents__x_geom(:,1);
    gt.y_map   = log.sim_out.opponents__y_geom(:,1);
    gt.vx      = log.sim_out.opponents__vx(:,1);

    gt.yaw_map = unwrap(log.sim_out.opponents__psi(:,1));

elseif exist('use_ref','var') && use_ref
    gt.stamp   = (log_ref.timestamp - double(log.time_offset_nsec))*1e-9;
    gt.x_rel   = log_ref.x_rel;
    gt.y_rel   = log_ref.y_rel;
    gt.z_rel   = log_ref.z_rel;
    gt.rho     = log_ref.rho;
    gt.rho_dot = log_ref.rho_dot;
    gt.yaw_rel = unwrap(log_ref.yaw_rel);

    gt.x_map   = log_ref.x_map;
    gt.y_map   = log_ref.y_map;
    gt.z_map   = log_ref.z_map;
    gt.vx      = log_ref.speed;
    gt.yaw_map = log_ref.yaw_map;
end


%  NaN CHECK: Confirm at least one detection source contains data

isAllNaNStruct = @(s) all(structfun(@(x) ...
    (isnumeric(x) && all(isnan(x(:)))) || isempty(x), ...
    s, 'UniformOutput', true));

if all([
    isAllNaNStruct(lid_clust), ...
    isAllNaNStruct(rad_clust), ...
    isAllNaNStruct(cam_yolo), ...
    isAllNaNStruct(lid_pp)
])
    error('No detections found: all detection structures are empty or contain only NaN values.');
end

end % FUNCTION END


%  Helper function to replace zeros with NaN

function out = replaceZeroWithNaN(x)
    out = x;
    out(out == 0) = NaN;
end
