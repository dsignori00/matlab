%% ERROR STD

% LIDAR CLUSTERING
ass_idxs = sqrt(lid_clust.x_map_err.^2+lid_clust.y_map_err.^2)<10;
lid_clust.x_rel_std = std(lid_clust.x_rel_err(ass_idxs));
lid_clust.x_rel_mean = mean(lid_clust.x_rel_err(ass_idxs));
lid_clust.y_rel_std = std(lid_clust.y_rel_err(ass_idxs));
lid_clust.y_rel_mean = mean(lid_clust.y_rel_err(ass_idxs));
lid_clust.yaw_map_std = std(lid_clust.yaw_map_err(ass_idxs));
lid_clust.yaw_map_mean = mean(lid_clust.yaw_map_err(ass_idxs));

% RADAR CLUSTERING

ass_idxs = sqrt(rad_clust.x_map_err.^2+rad_clust.y_map_err.^2)<10;
rad_clust.x_rel_std = std(rad_clust.x_rel_err(ass_idxs));
rad_clust.x_rel_mean = mean(rad_clust.x_rel_err(ass_idxs));
rad_clust.y_rel_std = std(rad_clust.y_rel_err(ass_idxs));
rad_clust.y_rel_mean = mean(rad_clust.y_rel_err(ass_idxs));
rad_clust.yaw_map_std = std(rad_clust.yaw_map_err(ass_idxs));
rad_clust.yaw_map_mean = mean(rad_clust.yaw_map_err(ass_idxs));
rad_clust.rho_dot_std = std(rad_clust.rho_dot_err(ass_idxs));
rad_clust.rho_dot_mean = std(rad_clust.rho_dot_err(ass_idxs));

% LIDAR POINTPILLARS
ass_idxs = sqrt(lid_pp.x_map_err.^2+lid_pp.y_map_err.^2)<10;
lid_pp.x_rel_std = std(lid_pp.x_rel_err(ass_idxs));
lid_pp.x_rel_mean = mean(lid_pp.x_rel_err(ass_idxs));
lid_pp.y_rel_std = std(lid_pp.y_rel_err(ass_idxs));
lid_pp.y_rel_mean = mean(lid_pp.y_rel_err(ass_idxs));
lid_pp.yaw_map_std = std(lid_pp.yaw_map_err(ass_idxs));
lid_pp.yaw_map_mean = mean(lid_pp.yaw_map_err(ass_idxs));


% CAMERA YOLO
ass_idxs = sqrt(cam_yolo.x_map_err.^2+cam_yolo.y_map_err.^2)<10;
cam_yolo.x_rel_mean = mean(cam_yolo.x_rel_err(ass_idxs));
cam_yolo.y_rel_mean = mean(cam_yolo.y_rel_err(ass_idxs));
cam_yolo.yaw_map_mean = mean(cam_yolo.yaw_map_err(ass_idxs));
cam_yolo.x_rel_std = std(cam_yolo.x_rel_err(ass_idxs));
cam_yolo.y_rel_std = std(cam_yolo.y_rel_err(ass_idxs));
cam_yolo.yaw_map_std = std(cam_yolo.yaw_map_err(ass_idxs));

[lid_clust.x_ellipse,lid_clust.y_ellipse] = calculate_ellipse(lid_clust.x_rel_std,lid_clust.y_rel_std,lid_clust.x_rel_mean, lid_clust.y_rel_mean);
[rad_clust.x_ellipse,rad_clust.y_ellipse] = calculate_ellipse(rad_clust.x_rel_std,rad_clust.y_rel_std,rad_clust.x_rel_mean, rad_clust.y_rel_mean);
[lid_pp.x_ellipse,lid_pp.y_ellipse]       = calculate_ellipse(lid_pp.x_rel_std,lid_pp.y_rel_std,lid_pp.x_rel_mean, lid_pp.y_rel_mean);
[cam_yolo.x_ellipse,cam_yolo.y_ellipse]   = calculate_ellipse(cam_yolo.x_rel_std,cam_yolo.y_rel_std,cam_yolo.x_rel_mean, cam_yolo.y_rel_mean);