%% Interpolation
% interpolate opp ground truth on our measures

% LIDAR CLUSTERING

lid_clust.x_map_gt = interp1(gt.stamp,gt.x_map,lid_clust.sens_stamp); 
lid_clust.y_map_gt = interp1(gt.stamp,gt.y_map,lid_clust.sens_stamp); 
lid_clust.x_rel_gt = interp1(gt.stamp,gt.x_rel,lid_clust.sens_stamp); 
lid_clust.y_rel_gt = interp1(gt.stamp,gt.y_rel,lid_clust.sens_stamp); 
lid_clust.yaw_map_gt = interp1(gt.stamp,gt.yaw_map,lid_clust.sens_stamp);

lid_clust.x_map_err = lid_clust.x_map-lid_clust.x_map_gt;
lid_clust.y_map_err = lid_clust.y_map-lid_clust.y_map_gt;
lid_clust.x_rel_err = lid_clust.x_rel-lid_clust.x_rel_gt;
lid_clust.y_rel_err = lid_clust.y_rel-lid_clust.y_rel_gt;
lid_clust.yaw_map_gt = deg2rad(unwrap(rad2deg(lid_clust.yaw_map_gt)));
lid_clust.yaw_map_err = lid_clust.yaw_map-lid_clust.yaw_map_gt;
lid_clust.yaw_map_err = deg2rad(unwrap(rad2deg(lid_clust.yaw_map_err)));

% RADAR CLUSTERING

rad_clust.x_map_gt = interp1(gt.stamp,gt.x_map,rad_clust.sens_stamp); 
rad_clust.y_map_gt = interp1(gt.stamp,gt.y_map,rad_clust.sens_stamp); 
rad_clust.x_rel_gt = interp1(gt.stamp,gt.x_rel,rad_clust.sens_stamp); 
rad_clust.y_rel_gt = interp1(gt.stamp,gt.y_rel,rad_clust.sens_stamp); 
rad_clust.yaw_map_gt = interp1(gt.stamp,gt.yaw_map,rad_clust.sens_stamp);

rad_clust.x_map_err = rad_clust.x_map-rad_clust.x_map_gt;
rad_clust.y_map_err = rad_clust.y_map-rad_clust.y_map_gt;
rad_clust.x_rel_err = rad_clust.x_rel-rad_clust.x_rel_gt;
rad_clust.y_rel_err = rad_clust.y_rel-rad_clust.y_rel_gt;
rad_clust.yaw_map_gt = deg2rad(unwrap(rad2deg(rad_clust.yaw_map_gt)));
rad_clust.yaw_map_err = rad_clust.yaw_map-rad_clust.yaw_map_gt;
rad_clust.yaw_map_err = deg2rad(unwrap(rad2deg(rad_clust.yaw_map_err)));

% LIDAR POINTPILLARS

lid_pp.x_map_gt = interp1(gt.stamp,gt.x_map,lid_pp.sens_stamp); 
lid_pp.y_map_gt = interp1(gt.stamp,gt.y_map,lid_pp.sens_stamp); 
lid_pp.x_rel_gt = interp1(gt.stamp,gt.x_rel,lid_pp.sens_stamp); 
lid_pp.y_rel_gt = interp1(gt.stamp,gt.y_rel,lid_pp.sens_stamp);
lid_pp.yaw_map_gt = interp1(gt.stamp,gt.yaw_map,lid_pp.sens_stamp);

lid_pp.x_map_err = lid_pp.x_map-lid_pp.x_map_gt;
lid_pp.y_map_err = lid_pp.y_map-lid_pp.y_map_gt;
lid_pp.x_rel_err = lid_pp.x_rel-lid_pp.x_rel_gt;
lid_pp.y_rel_err = lid_pp.y_rel-lid_pp.y_rel_gt;
lid_pp.yaw_map_gt = deg2rad(unwrap(rad2deg(lid_pp.yaw_map_gt)));
lid_pp.yaw_map_err = lid_pp.yaw_map-lid_pp.yaw_map_gt;
lid_pp.yaw_map_err = deg2rad(unwrap(rad2deg(lid_pp.yaw_map_err)));


% CAM YOLO

cam_yolo.x_map_gt = interp1(gt.stamp,gt.x_map,cam_yolo.sens_stamp); 
cam_yolo.y_map_gt = interp1(gt.stamp,gt.y_map,cam_yolo.sens_stamp); 
cam_yolo.x_rel_gt = interp1(gt.stamp,gt.x_rel,cam_yolo.sens_stamp); 
cam_yolo.y_rel_gt = interp1(gt.stamp,gt.y_rel,cam_yolo.sens_stamp); 
cam_yolo.yaw_map_gt = interp1(gt.stamp,gt.yaw_map,cam_yolo.sens_stamp);

cam_yolo.x_map_err = cam_yolo.x_map-cam_yolo.x_map_gt;
cam_yolo.y_map_err = cam_yolo.y_map-cam_yolo.y_map_gt;
cam_yolo.x_rel_err = cam_yolo.x_rel-cam_yolo.x_rel_gt;
cam_yolo.y_rel_err = cam_yolo.y_rel-cam_yolo.y_rel_gt;
cam_yolo.yaw_map_gt = deg2rad(unwrap(rad2deg(cam_yolo.yaw_map_gt)));
cam_yolo.yaw_map_err = cam_yolo.yaw_map-cam_yolo.yaw_map_gt;
cam_yolo.yaw_map_err = deg2rad(unwrap(rad2deg(cam_yolo.yaw_map_err)));