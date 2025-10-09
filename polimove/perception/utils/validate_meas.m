% LIDAR CLUSTERING
valid_idxs = ~isnan(lid_clust.x_map);
valid_idxs = valid_idxs(:,1);
lid_clust.sens_stamp = lid_clust.sens_stamp(valid_idxs);
lid_clust.x_map = lid_clust.x_map(valid_idxs);
lid_clust.y_map = lid_clust.y_map(valid_idxs);
lid_clust.z_map = lid_clust.z_map(valid_idxs);
lid_clust.yaw_map = lid_clust.yaw_map(valid_idxs);
lid_clust.x_rel = lid_clust.x_rel(valid_idxs);
lid_clust.y_rel = lid_clust.y_rel(valid_idxs);
lid_clust.z_rel = lid_clust.z_rel(valid_idxs);
lid_clust.yaw_rel = lid_clust.yaw_rel(valid_idxs);
lid_clust.yaw_rel = unwrap(rad2deg(lid_clust.yaw_rel));


% RADAR CLUSTERING
valid_idxs = ~isnan(rad_clust.x_map);
valid_idxs = valid_idxs(:,1);
rad_clust.sens_stamp = rad_clust.sens_stamp(valid_idxs);
rad_clust.x_map = rad_clust.x_map(valid_idxs);
rad_clust.y_map = rad_clust.y_map(valid_idxs);
rad_clust.z_map = rad_clust.z_map(valid_idxs);
rad_clust.yaw_map = rad_clust.yaw_map(valid_idxs);
rad_clust.x_rel = rad_clust.x_rel(valid_idxs);
rad_clust.y_rel = rad_clust.y_rel(valid_idxs);
rad_clust.z_rel = rad_clust.z_rel(valid_idxs);
rad_clust.rho_dot = rad_clust.rho_dot(valid_idxs);
rad_clust.yaw_rel = rad_clust.yaw_rel(valid_idxs);
rad_clust.yaw_rel = unwrap(rad2deg(rad_clust.yaw_rel));


% LIDAR POINTPILLARS    
valid_idxs = ~isnan(lid_pp.x_map);
valid_idxs = valid_idxs(:,1);
lid_pp.sens_stamp = lid_pp.sens_stamp(valid_idxs);
lid_pp.x_map = lid_pp.x_map(valid_idxs);
lid_pp.y_map = lid_pp.y_map(valid_idxs);
lid_pp.z_map = lid_pp.z_map(valid_idxs);
lid_pp.yaw_map = lid_pp.yaw_map(valid_idxs);
lid_pp.x_rel = lid_pp.x_rel(valid_idxs);
lid_pp.y_rel = lid_pp.y_rel(valid_idxs);
lid_pp.z_rel = lid_pp.z_rel(valid_idxs);
lid_pp.yaw_rel = lid_pp.yaw_rel(valid_idxs);
lid_pp.yaw_rel = unwrap(rad2deg(lid_pp.yaw_rel));

% CAM YOLO   
valid_idxs = ~isnan(cam_yolo.x_map);
valid_idxs = valid_idxs(:,1);
cam_yolo.sens_stamp = cam_yolo.sens_stamp(valid_idxs);
cam_yolo.x_map = cam_yolo.x_map(valid_idxs);
cam_yolo.y_map = cam_yolo.y_map(valid_idxs);
cam_yolo.z_map = cam_yolo.z_map(valid_idxs);
cam_yolo.yaw_map = cam_yolo.yaw_map(valid_idxs);
cam_yolo.x_rel = cam_yolo.x_rel(valid_idxs);
cam_yolo.y_rel = cam_yolo.y_rel(valid_idxs);
cam_yolo.z_rel = cam_yolo.z_rel(valid_idxs);
cam_yolo.yaw_rel = cam_yolo.yaw_rel(valid_idxs);
cam_yolo.yaw_rel = unwrap(rad2deg(cam_yolo.yaw_rel));