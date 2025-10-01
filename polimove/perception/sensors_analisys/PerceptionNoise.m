
clc
close all
clearvars -except log log_ref

src_corr = false;
map_errors = false;
use_sim_ref = false;
drop_out_analyses = false;


%% Paths

addpath("../../common/utilities/")
addpath("../../common/constants/")
addpath("../../common/plot/")
normal_path = "../../bags";

%% LOAD FILES

%load database
if(~exist('trajDatabase','var'))
    trajDatabase = choose_database();
    if(isempty(trajDatabase))
        error('No database selected');
    else
        load(trajDatabase);
    end
end

% load ref
if(~use_sim_ref)
    if (~exist('log_ref','var'))
    [file,path_dir] = uigetfile(fullfile(normal_path,'*.mat'),'Load ground truth mat');
    tmp = load(fullfile(path_dir,file));
    log_ref = tmp.log;
    clearvars tmp;
    end
end


DateTime = datetime(log.time_offset_nsec,'ConvertFrom','epochtime','TicksPerSecond',1e9,'Format','dd-MMM-yyyy HH:mm:ss');

%% PLOT DATA

% style
set(0,'DefaultFigureWindowStyle','docked');
set(0,'DefaultTextInterpreter', 'none');
set(0,'DefaultLegendInterpreter', 'none');
set(0, 'DefaultLineLineWidth', 2);


%% NAMING
col.lidar = '#77AC30';
col.radar = '#4DBEEE';
col.camera = '#EDB120';
col.pointpillars = '#D95319';
col.ref = '#000000';
sz=3; % Marker size
f=1;

%% LOAD DATA


% LIDAR CLUSTERING DETECTIONS
lid_clust_sens_stamp = log.perception__lidar__clustering_detections.sensor_stamp__tot;
% relative
lid_clust_x_rel = log.perception__lidar__clustering_detections.detections__x_rel;
lid_clust_y_rel = log.perception__lidar__clustering_detections.detections__y_rel;
lid_clust_z_rel = log.perception__lidar__clustering_detections.detections__z_rel;
lid_clust_x_rel(lid_clust_x_rel==0)=nan;
lid_clust_y_rel(lid_clust_y_rel==0)=nan;
lid_clust_z_rel(lid_clust_z_rel==0)=nan;
lid_clust_yaw_rel = log.perception__lidar__clustering_detections.detections__yaw_rel;
lid_clust_yaw_rel(lid_clust_yaw_rel==0)=nan;
% map
lid_clust_x_map = log.perception__lidar__clustering_detections.detections__x_map;
lid_clust_y_map = log.perception__lidar__clustering_detections.detections__y_map;
lid_clust_z_map = log.perception__lidar__clustering_detections.detections__z_map;
lid_clust_yaw_map = log.perception__lidar__clustering_detections.detections__yaw_map;
lid_clust_x_map(lid_clust_x_map==0)=nan;
lid_clust_y_map(lid_clust_y_map==0)=nan;
lid_clust_z_map(lid_clust_z_map==0)=nan;
lid_clust_yaw_map(lid_clust_yaw_map==0)=nan;

% RADAR CLUSTERING DETECTIONS
rad_clust_sens_stamp = log.perception__radar__clustering_detections.sensor_stamp__tot;
% relative
rad_clust_x_rel = log.perception__radar__clustering_detections.detections__x_rel;
rad_clust_y_rel = log.perception__radar__clustering_detections.detections__y_rel;
rad_clust_z_rel = log.perception__radar__clustering_detections.detections__z_rel;
rad_clust_x_rel(rad_clust_x_rel==0)=nan;
rad_clust_y_rel(rad_clust_y_rel==0)=nan;
rad_clust_z_rel(rad_clust_z_rel==0)=nan;
rad_clust_yaw_rel = log.perception__radar__clustering_detections.detections__yaw_rel;
rad_clust_yaw_rel(rad_clust_yaw_rel==0)=nan;
rad_clust_rho_dot = log.perception__radar__clustering_detections.detections__rho_dot;
rad_clust_rho_dot(rad_clust_rho_dot==0)=nan;
% map
rad_clust_x_map = log.perception__radar__clustering_detections.detections__x_map;
rad_clust_y_map = log.perception__radar__clustering_detections.detections__y_map;
rad_clust_z_map = log.perception__radar__clustering_detections.detections__z_map;
rad_clust_yaw_map = log.perception__radar__clustering_detections.detections__yaw_map;
rad_clust_x_map(rad_clust_x_map==0)=nan;
rad_clust_y_map(rad_clust_y_map==0)=nan;
rad_clust_z_map(rad_clust_z_map==0)=nan;
rad_clust_yaw_map(rad_clust_yaw_map==0)=nan;

% CAMERA CLUSTERING DETECTIONS
cam_yolo_sens_stamp = log.perception__camera__yolo_detections.sensor_stamp__tot;
% relative
cam_yolo_x_rel = log.perception__camera__yolo_detections.detections__x_rel;
cam_yolo_y_rel = log.perception__camera__yolo_detections.detections__y_rel;
cam_yolo_z_rel = log.perception__camera__yolo_detections.detections__z_rel;
cam_yolo_x_rel(cam_yolo_x_rel==0)=nan;
cam_yolo_y_rel(cam_yolo_y_rel==0)=nan;
cam_yolo_z_rel(cam_yolo_z_rel==0)=nan;
cam_yolo_yaw_rel = log.perception__camera__yolo_detections.detections__yaw_rel;
cam_yolo_yaw_rel(cam_yolo_yaw_rel==0)=nan;
% map
cam_yolo_x_map = log.perception__camera__yolo_detections.detections__x_map;
cam_yolo_y_map = log.perception__camera__yolo_detections.detections__y_map;
cam_yolo_z_map = log.perception__camera__yolo_detections.detections__z_map;
cam_yolo_yaw_map = log.perception__camera__yolo_detections.detections__yaw_map;
cam_yolo_x_map(cam_yolo_x_map==0)=nan;
cam_yolo_y_map(cam_yolo_y_map==0)=nan;
cam_yolo_yaw_map(cam_yolo_yaw_map==0)=nan;

% LIDAR POINTPILLARS DETECTIONS
lid_pp_sens_stamp = log.perception__lidar__pointpillars_detections.sensor_stamp__tot;
% relative
lid_pp_x_rel = log.perception__lidar__pointpillars_detections.detections__x_rel;
lid_pp_y_rel = log.perception__lidar__pointpillars_detections.detections__y_rel;
lid_pp_z_rel = log.perception__lidar__pointpillars_detections.detections__z_rel;
lid_pp_x_rel(lid_pp_x_rel==0)=nan;
lid_pp_y_rel(lid_pp_y_rel==0)=nan;
lid_pp_z_rel(lid_pp_z_rel==0)=nan;
lid_pp_yaw_rel = log.perception__lidar__pointpillars_detections.detections__yaw_rel;
lid_pp_yaw_rel(lid_pp_yaw_rel==0)=nan;
% map
lid_pp_x_map = log.perception__lidar__pointpillars_detections.detections__x_map;
lid_pp_y_map = log.perception__lidar__pointpillars_detections.detections__y_map;
lid_pp_z_map = log.perception__lidar__pointpillars_detections.detections__z_map;
lid_pp_yaw_map = log.perception__lidar__pointpillars_detections.detections__yaw_map;
lid_pp_x_map(lid_pp_x_map==0)=nan;
lid_pp_y_map(lid_pp_y_map==0)=nan;
lid_pp_z_map(lid_pp_z_map==0)=nan;
lid_pp_yaw_map(lid_pp_yaw_map==0)=nan;


% GROUND TRUTH
if(use_sim_ref)
    gt_stamp = log.sim_out.bag_stamp;
    % relative
    gt_x_rel = log.sim_out.opponents__x_rel(:,1);
    gt_y_rel = log.sim_out.opponents__y_rel(:,1);
    gt_rho_dot = log.sim_out.opponents__rho_dot(:,1);
    gt_yaw_rel = log.sim_out.opponents__psi_rel(:,1);
    gt_yaw_rel = deg2rad(UnwrapPi(rad2deg(gt_yaw_rel)));
    % map
    gt_x_map = log.sim_out.opponents__x_geom(:,1);
    gt_y_map = log.sim_out.opponents__y_geom(:,1);
    gt_vx = log.sim_out.opponents__vx(:,1);
    gt_yaw_map = log.sim_out.opponents__psi(:,1);
    gt_yaw_map = deg2rad(UnwrapPi(rad2deg(gt_yaw_map)));
else
    gt_stamp = (log_ref.timestamp - double(log.time_offset_nsec))*1e-9;
    % relative
    gt_x_rel = log_ref.x_rel;
    gt_y_rel = log_ref.y_rel;
    gt_z_rel = log_ref.z_rel;    
    gt_rho_dot = log_ref.rho_dot;
    gt_yaw_rel = log_ref.yaw_rel;
    gt_yaw_rel = deg2rad(UnwrapPi(rad2deg(gt_yaw_rel)));
    % map
    gt_x_map = log_ref.x_map;
    gt_y_map = log_ref.y_map;
    gt_z_map = log_ref.z_map;
    gt_vx = log_ref.speed;
    gt_yaw_map = log_ref.yaw_map;
    gt_yaw_map = deg2rad(UnwrapPi(rad2deg(gt_yaw_map)));
end

% EGO
ego_speed_stamp = log.estimation.stamp__tot;
ego_speed = log.estimation.vx;
ego_rpm_stamp = log.vehicle_fbk.stamp__tot;
ego_rpm = log.vehicle_fbk.engine_rpm;

%% SHRINK GT
too_dist_idxs = abs(gt_x_rel)>150 | abs(gt_y_rel)>30;
% relative
gt_x_rel(too_dist_idxs)     = NaN;
gt_y_rel(too_dist_idxs)     = NaN;
gt_z_rel(too_dist_idxs)     = NaN;
gt_rho_dot(too_dist_idxs)   = NaN;
gt_yaw_rel(too_dist_idxs)   = NaN;

%% VALID MEAS

% LIDAR CLUSTERING
valid_idxs = ~isnan(lid_clust_x_map);
valid_idxs = valid_idxs(:,1);
lid_clust_sens_stamp = lid_clust_sens_stamp(valid_idxs);
lid_clust_x_map = lid_clust_x_map(valid_idxs);
lid_clust_y_map = lid_clust_y_map(valid_idxs);
lid_clust_z_map = lid_clust_z_map(valid_idxs);
lid_clust_yaw_map = lid_clust_yaw_map(valid_idxs);
lid_clust_x_rel = lid_clust_x_rel(valid_idxs);
lid_clust_y_rel = lid_clust_y_rel(valid_idxs);
lid_clust_z_rel = lid_clust_z_rel(valid_idxs);
lid_clust_yaw_rel = lid_clust_yaw_rel(valid_idxs);
lid_clust_yaw_rel = UnwrapPi(rad2deg(lid_clust_yaw_rel));


% RADAR CLUSTERING
valid_idxs = ~isnan(rad_clust_x_map);
valid_idxs = valid_idxs(:,1);
rad_clust_sens_stamp = rad_clust_sens_stamp(valid_idxs);
rad_clust_x_map = rad_clust_x_map(valid_idxs);
rad_clust_y_map = rad_clust_y_map(valid_idxs);
rad_clust_z_map = rad_clust_z_map(valid_idxs);
rad_clust_yaw_map = rad_clust_yaw_map(valid_idxs);
rad_clust_x_rel = rad_clust_x_rel(valid_idxs);
rad_clust_y_rel = rad_clust_y_rel(valid_idxs);
rad_clust_z_rel = rad_clust_z_rel(valid_idxs);
rad_clust_rho_dot = rad_clust_rho_dot(valid_idxs);
rad_clust_yaw_rel = rad_clust_yaw_rel(valid_idxs);
rad_clust_yaw_rel = UnwrapPi(rad2deg(rad_clust_yaw_rel));


% LIDAR POINTPILLARS    
valid_idxs = ~isnan(lid_pp_x_map);
valid_idxs = valid_idxs(:,1);
lid_pp_sens_stamp = lid_pp_sens_stamp(valid_idxs);
lid_pp_x_map = lid_pp_x_map(valid_idxs);
lid_pp_y_map = lid_pp_y_map(valid_idxs);
lid_pp_z_map = lid_pp_z_map(valid_idxs);
lid_pp_yaw_map = lid_pp_yaw_map(valid_idxs);
lid_pp_x_rel = lid_pp_x_rel(valid_idxs);
lid_pp_y_rel = lid_pp_y_rel(valid_idxs);
lid_pp_z_rel = lid_pp_z_rel(valid_idxs);
lid_pp_yaw_rel = lid_pp_yaw_rel(valid_idxs);
lid_pp_yaw_rel = UnwrapPi(rad2deg(lid_pp_yaw_rel));

% CAM YOLO   
valid_idxs = ~isnan(cam_yolo_x_map);
valid_idxs = valid_idxs(:,1);
cam_yolo_sens_stamp = cam_yolo_sens_stamp(valid_idxs);
cam_yolo_x_map = cam_yolo_x_map(valid_idxs);
cam_yolo_y_map = cam_yolo_y_map(valid_idxs);
cam_yolo_z_map = cam_yolo_z_map(valid_idxs);
cam_yolo_yaw_map = cam_yolo_yaw_map(valid_idxs);
cam_yolo_x_rel = cam_yolo_x_rel(valid_idxs);
cam_yolo_y_rel = cam_yolo_y_rel(valid_idxs);
cam_yolo_z_rel = cam_yolo_z_rel(valid_idxs);
cam_yolo_yaw_rel = cam_yolo_yaw_rel(valid_idxs);
cam_yolo_yaw_rel = UnwrapPi(rad2deg(cam_yolo_yaw_rel));

%% Interpolation
% interpolate opp ground truth on our measures

% LIDAR CLUSTERING

lid_clust_x_map_gt = interp1(gt_stamp,gt_x_map,lid_clust_sens_stamp); 
lid_clust_y_map_gt = interp1(gt_stamp,gt_y_map,lid_clust_sens_stamp); 
lid_clust_x_rel_gt = interp1(gt_stamp,gt_x_rel,lid_clust_sens_stamp); 
lid_clust_y_rel_gt = interp1(gt_stamp,gt_y_rel,lid_clust_sens_stamp); 
lid_clust_yaw_map_gt = interp1(gt_stamp,gt_yaw_map,lid_clust_sens_stamp);

lid_clust_x_map_err = lid_clust_x_map-lid_clust_x_map_gt;
lid_clust_y_map_err = lid_clust_y_map-lid_clust_y_map_gt;
lid_clust_x_rel_err = lid_clust_x_rel-lid_clust_x_rel_gt;
lid_clust_y_rel_err = lid_clust_y_rel-lid_clust_y_rel_gt;
lid_clust_yaw_map_gt = deg2rad(UnwrapPi(rad2deg(lid_clust_yaw_map_gt)));
lid_clust_yaw_map_err = lid_clust_yaw_map-lid_clust_yaw_map_gt;
lid_clust_yaw_map_err = deg2rad(UnwrapPi(rad2deg(lid_clust_yaw_map_err)));

% RADAR CLUSTERING

rad_clust_x_map_gt = interp1(gt_stamp,gt_x_map,rad_clust_sens_stamp); 
rad_clust_y_map_gt = interp1(gt_stamp,gt_y_map,rad_clust_sens_stamp); 
rad_clust_x_rel_gt = interp1(gt_stamp,gt_x_rel,rad_clust_sens_stamp); 
rad_clust_y_rel_gt = interp1(gt_stamp,gt_y_rel,rad_clust_sens_stamp); 
rad_clust_yaw_map_gt = interp1(gt_stamp,gt_yaw_map,rad_clust_sens_stamp);

rad_clust_x_map_err = rad_clust_x_map-rad_clust_x_map_gt;
rad_clust_y_map_err = rad_clust_y_map-rad_clust_y_map_gt;
rad_clust_x_rel_err = rad_clust_x_rel-rad_clust_x_rel_gt;
rad_clust_y_rel_err = rad_clust_y_rel-rad_clust_y_rel_gt;
rad_clust_yaw_map_gt = deg2rad(UnwrapPi(rad2deg(rad_clust_yaw_map_gt)));
rad_clust_yaw_map_err = rad_clust_yaw_map-rad_clust_yaw_map_gt;
rad_clust_yaw_map_err = deg2rad(UnwrapPi(rad2deg(rad_clust_yaw_map_err)));

% LIDAR POINTPILLARS

lid_pp_x_map_gt = interp1(gt_stamp,gt_x_map,lid_pp_sens_stamp); 
lid_pp_y_map_gt = interp1(gt_stamp,gt_y_map,lid_pp_sens_stamp); 
lid_pp_x_rel_gt = interp1(gt_stamp,gt_x_rel,lid_pp_sens_stamp); 
lid_pp_y_rel_gt = interp1(gt_stamp,gt_y_rel,lid_pp_sens_stamp);
lid_pp_yaw_map_gt = interp1(gt_stamp,gt_yaw_map,lid_pp_sens_stamp);

lid_pp_x_map_err = lid_pp_x_map-lid_pp_x_map_gt;
lid_pp_y_map_err = lid_pp_y_map-lid_pp_y_map_gt;
lid_pp_x_rel_err = lid_pp_x_rel-lid_pp_x_rel_gt;
lid_pp_y_rel_err = lid_pp_y_rel-lid_pp_y_rel_gt;
lid_pp_yaw_map_gt = deg2rad(UnwrapPi(rad2deg(lid_pp_yaw_map_gt)));
lid_pp_yaw_map_err = lid_pp_yaw_map-lid_pp_yaw_map_gt;
lid_pp_yaw_map_err = deg2rad(UnwrapPi(rad2deg(lid_pp_yaw_map_err)));


% CAM YOLO

cam_yolo_x_map_gt = interp1(gt_stamp,gt_x_map,cam_yolo_sens_stamp); 
cam_yolo_y_map_gt = interp1(gt_stamp,gt_y_map,cam_yolo_sens_stamp); 
cam_yolo_x_rel_gt = interp1(gt_stamp,gt_x_rel,cam_yolo_sens_stamp); 
cam_yolo_y_rel_gt = interp1(gt_stamp,gt_y_rel,cam_yolo_sens_stamp); 
cam_yolo_yaw_map_gt = interp1(gt_stamp,gt_yaw_map,cam_yolo_sens_stamp);

cam_yolo_x_map_err = cam_yolo_x_map-cam_yolo_x_map_gt;
cam_yolo_y_map_err = cam_yolo_y_map-cam_yolo_y_map_gt;
cam_yolo_x_rel_err = cam_yolo_x_rel-cam_yolo_x_rel_gt;
cam_yolo_y_rel_err = cam_yolo_y_rel-cam_yolo_y_rel_gt;
cam_yolo_yaw_map_gt = deg2rad(UnwrapPi(rad2deg(cam_yolo_yaw_map_gt)));
cam_yolo_yaw_map_err = cam_yolo_yaw_map-cam_yolo_yaw_map_gt;
cam_yolo_yaw_map_err = deg2rad(UnwrapPi(rad2deg(cam_yolo_yaw_map_err)));

% TARGET TRACKING

tt_stamp = log.perception__opponents.stamp__tot;
tt_count = log.perception__opponents.count;
max_opp = max(tt_count);


%% LATENCY FIGURE
figure('name','Latency')
tiledlayout(4,1,'Padding','compact');

axes(f) = nexttile;
f=f+1;
hold on;
plot(log.perception__lidar__clustering_detections.stamp__tot,log.perception__lidar__clustering_detections.stamp__tot-log.perception__lidar__clustering_detections.sensor_stamp__tot);
grid on;
title('lidar_clust [s]')

axes(f) = nexttile;
f=f+1;
hold on;
plot(log.perception__radar__clustering_detections.stamp__tot,log.perception__radar__clustering_detections.stamp__tot-log.perception__radar__clustering_detections.sensor_stamp__tot);
grid on;
title('radar_clust [s]')

axes(f) = nexttile;
f=f+1;
hold on;
plot(log.perception__camera__yolo_detections.stamp__tot,log.perception__camera__yolo_detections.stamp__tot-log.perception__camera__yolo_detections.sensor_stamp__tot);
grid on;
title('camera_yolo [s]')

axes(f) = nexttile;
f=f+1;
hold on;
plot(log.perception__lidar__pointpillars_detections.stamp__tot,log.perception__lidar__pointpillars_detections.stamp__tot-log.perception__lidar__pointpillars_detections.sensor_stamp__tot);
grid on;
title('lidar_pp [s]')

linkaxes(axes,'x')

lid_clust.latency = mean(log.perception__lidar__clustering_detections.stamp__tot-log.perception__lidar__clustering_detections.sensor_stamp__tot);
rad_clust.latency = mean(log.perception__radar__clustering_detections.stamp__tot-log.perception__radar__clustering_detections.sensor_stamp__tot);
cam_yolo.latency = mean(log.perception__camera__yolo_detections.stamp__tot-log.perception__camera__yolo_detections.sensor_stamp__tot);
lid_pp.latency = mean(log.perception__lidar__pointpillars_detections.stamp__tot-log.perception__lidar__pointpillars_detections.sensor_stamp__tot);


%% DETECTIONS FIGURE - MAP

figure('Name','Detections - Map')
tiledlayout(3,1,'Padding','compact')

x_max = max([lid_clust_sens_stamp; rad_clust_sens_stamp; lid_pp_sens_stamp; cam_yolo_sens_stamp]);

axes(f) = nexttile;
f=f+1;
hold on;
plot(gt_stamp,gt_x_map,'Color',col.ref,'DisplayName','Ground Truth')
plot(lid_clust_sens_stamp,lid_clust_x_map,'*','Color',col.lidar,'DisplayName','Lidar Clust')
plot(rad_clust_sens_stamp,rad_clust_x_map,'*','Color',col.radar,'DisplayName','Radar Clust')
plot(lid_pp_sens_stamp,lid_pp_x_map,'*','Color',col.pointpillars,'DisplayName','Lidar PP')
plot(cam_yolo_sens_stamp,cam_yolo_x_map,'*','Color',col.camera,'DisplayName','Camera Yolo')
xlim([0 inf])
legend('Location','northwest')
grid on;
title('x_map [m]')

axes(f) = nexttile;
f=f+1;
hold on;
plot(gt_stamp,gt_y_map,'Color',col.ref,'DisplayName','Ground Truth')
plot(lid_clust_sens_stamp,lid_clust_y_map,'*','Color',col.lidar,'DisplayName','Lidar Clust')
plot(rad_clust_sens_stamp,rad_clust_y_map,'*','Color',col.radar,'DisplayName','Radar Clust')
plot(lid_pp_sens_stamp,lid_pp_y_map,'*','Color',col.pointpillars,'DisplayName','Lidar PP')
plot(cam_yolo_sens_stamp,cam_yolo_y_map,'*','Color',col.camera,'DisplayName','Camera Yolo')
xlim([0 inf])
legend('Location','northwest')
grid on;
title('y_map [m]')

axes(f) = nexttile;
f=f+1;
hold on;
plot(gt_stamp,gt_z_map,'Color',col.ref,'DisplayName','Ground Truth')
plot(lid_clust_sens_stamp,lid_clust_z_map,'*','Color',col.lidar,'DisplayName','Lidar Clust')
plot(rad_clust_sens_stamp,rad_clust_z_map,'*','Color',col.radar,'DisplayName','Radar Clust')
plot(lid_pp_sens_stamp,lid_pp_z_map,'*','Color',col.pointpillars,'DisplayName','Lidar PP')
plot(cam_yolo_sens_stamp,cam_yolo_z_map,'*','Color',col.camera,'DisplayName','Camera Yolo')
xlim([0 inf])
legend('Location','northwest')
grid on;
title('z_map [m]')

linkaxes(axes,'x')


%% DETECTIONS FIGURE - REL

figure('Name','Detections - Rel')
tiledlayout(3,1,'Padding','compact')

axes(f) = nexttile;
f=f+1;
hold on;
plot(gt_stamp,gt_x_rel,'Color',col.ref,'DisplayName','Ground Truth')
plot(lid_clust_sens_stamp,lid_clust_x_rel,'*','Color',col.lidar,'DisplayName','Lidar Clust')
plot(rad_clust_sens_stamp,rad_clust_x_rel,'*','Color',col.radar,'DisplayName','Radar Clust')
plot(lid_pp_sens_stamp,lid_pp_x_rel,'*','Color',col.pointpillars,'DisplayName','Lidar PP')
plot(cam_yolo_sens_stamp,cam_yolo_x_rel,'*','Color',col.camera,'DisplayName','Camera Yolo')
xlim([0 inf])
ylim([-inf inf])
legend('Location','northwest')
grid on;
title('x_rel [m]')

axes(f) = nexttile;
f=f+1;
hold on;
plot(gt_stamp,gt_y_rel,'Color',col.ref,'DisplayName','Ground Truth')
plot(lid_clust_sens_stamp,lid_clust_y_rel,'*','Color',col.lidar,'DisplayName','Lidar Clust')
plot(rad_clust_sens_stamp,rad_clust_y_rel,'*','Color',col.radar,'DisplayName','Radar Clust')
plot(lid_pp_sens_stamp,lid_pp_y_rel,'*','Color',col.pointpillars,'DisplayName','Lidar PP')
plot(cam_yolo_sens_stamp,cam_yolo_y_rel,'*','Color',col.camera,'DisplayName','Camera Yolo')
xlim([0 inf])
ylim([-inf inf])
legend('Location','northwest')
grid on;
title('y_rel [m]')

axes(f) = nexttile;
f=f+1;
hold on;
plot(gt_stamp,gt_z_rel,'Color',col.ref,'DisplayName','Ground Truth')
plot(lid_clust_sens_stamp,lid_clust_z_rel,'*','Color',col.lidar,'DisplayName','Lidar Clust')
plot(rad_clust_sens_stamp,rad_clust_z_rel,'*','Color',col.radar,'DisplayName','Radar Clust')
plot(lid_pp_sens_stamp,lid_pp_z_rel,'*','Color',col.pointpillars,'DisplayName','Lidar PP')
plot(cam_yolo_sens_stamp,cam_yolo_z_rel,'*','Color',col.camera,'DisplayName','Camera Yolo')
xlim([0 inf])
ylim([-inf inf])
legend('Location','northwest')
grid on;
title('z_rel [m]')


%% DETECTIONS FIGURE - YAW

figure('Name','Detections - Yaw')
tiledlayout(3,1,'Padding','compact')

axes(f) = nexttile;
f=f+1;
hold on;
plot(gt_stamp,gt_yaw_map,'Color',col.ref,'DisplayName','Ground Truth')
plot(lid_clust_sens_stamp,lid_clust_yaw_map,'*','Color',col.lidar,'DisplayName','Lidar Clust')
plot(rad_clust_sens_stamp,rad_clust_yaw_map,'*','Color',col.radar,'DisplayName','Radar Clust')
plot(lid_pp_sens_stamp,lid_pp_yaw_map,'*','Color',col.pointpillars,'DisplayName','Lidar PP')
plot(cam_yolo_sens_stamp,cam_yolo_yaw_map,'*','Color',col.camera,'DisplayName','Camera Yolo')
xlim([0 inf])
legend('Location','northwest')
grid on;
title('yaw_map [deg]')

axes(f) = nexttile;
f=f+1;
hold on;
plot(gt_stamp,rad2deg(gt_yaw_rel),'Color',col.ref,'DisplayName','Ground Truth')
plot(lid_clust_sens_stamp,lid_clust_yaw_rel,'*','Color',col.lidar,'DisplayName','Lidar Clust')
plot(rad_clust_sens_stamp,rad_clust_yaw_rel,'*','Color',col.radar,'DisplayName','Radar Clust')
plot(lid_pp_sens_stamp,lid_pp_yaw_rel,'*','Color',col.pointpillars,'DisplayName','Lidar PP')
%plot(cam_yolo_sens_stamp,cam_yolo_yaw_rel,'*','Color',col.camera,'DisplayName','Camera Yolo')
xlim([0 inf])
legend('Location','northwest')
grid on;
title('yaw_rel [deg]')

% count
axes(f) = nexttile;
f=f+1;
hold on;
area(tt_stamp,log.perception__opponents.opponents__rad_clust_meas(:,1:max_opp),'FaceColor',col.radar,'EdgeColor',col.radar,'DisplayName','Rad Clust');
area(tt_stamp,log.perception__opponents.opponents__lid_pp_meas(:,1:max_opp),'FaceColor',col.pointpillars,'EdgeColor',col.pointpillars,'DisplayName','Lid PP');
area(tt_stamp,log.perception__opponents.opponents__lid_clust_meas(:,1:max_opp),'FaceColor',col.lidar,'EdgeColor',col.lidar,'DisplayName','Lid Clust');
area(tt_stamp,log.perception__opponents.opponents__cam_yolo_meas(:,1:max_opp),'FaceColor',col.camera,'EdgeColor',col.camera,'DisplayName','Camera');
grid on;
title('Associated Measures Count')

linkaxes(axes,'x')

%% ERROR FIGURES - MAP

gat_thr = 10;

if(map_errors)

    % X MAP
    figure('name','Error: x_map')
    tiledlayout(4,1,'Padding','compact');
    
    axes(f) = nexttile;
    f=f+1;
    hold on;
    plot(linspace(0,x_max,100),zeros(100,1),'--','Color','k','LineWidth',0.3);
    plot(lid_clust_sens_stamp,lid_clust_x_map_err,'*','Color',col.lidar);
    grid on;
    title('lidar_clust_x_map [m]')
    xlim([0 inf])
    ylim([-gat_thr gat_thr])
    
    axes(f) = nexttile;
    f=f+1;
    hold on;
    plot(linspace(0,x_max,100),zeros(100,1),'--','Color','k','LineWidth',0.3);
    plot(rad_clust_sens_stamp,rad_clust_x_map_err,'*','Color',col.radar);
    grid on;
    title('radar_clust_x_map [m]')
    xlim([0 inf])
    ylim([-gat_thr gat_thr])
    
    axes(f) = nexttile;
    f=f+1;
    hold on;
    plot(linspace(0,x_max,100),zeros(100,1),'--','Color','k','LineWidth',0.3);
    plot(lid_pp_sens_stamp,lid_pp_x_map_err,'*','Color',col.pointpillars);
    grid on;
    title('lidar_pp_x_map [m]')
    xlim([0 inf])
    ylim([-gat_thr gat_thr])
    
    axes(f) = nexttile;
    f=f+1;
    hold on;
    plot(linspace(0,x_max,100),zeros(100,1),'--','Color','k','LineWidth',0.3);
    plot(cam_yolo_sens_stamp,cam_yolo_x_map_err,'*','Color',col.camera);
    grid on;
    title('camera_yolo_x_map [m]')
    xlim([0 inf])
    ylim([-gat_thr gat_thr])
    
    linkaxes(axes,'x')
    
    % Y 
    figure('name','Error: y_map')
    tiledlayout(4,1,'Padding','compact');
    
    axes(f) = nexttile;
    f=f+1;
    hold on;
    plot(linspace(0,x_max,100),zeros(100,1),'--','Color','k','LineWidth',0.3);
    plot(lid_clust_sens_stamp,lid_clust_y_map_err,'*','Color',col.lidar);
    grid on;
    title('lidar_clust_y_map [m]')
    xlim([0 inf])
    ylim([-gat_thr gat_thr])
    
    axes(f) = nexttile;
    f=f+1;
    hold on;
    plot(linspace(0,x_max,100),zeros(100,1),'--','Color','k','LineWidth',0.3);
    plot(rad_clust_sens_stamp,rad_clust_y_map_err,'*','Color',col.radar);
    grid on;
    title('radar_clust_y_map [m]')
    xlim([0 inf])
    ylim([-gat_thr gat_thr])
    
    axes(f) = nexttile;
    f=f+1;
    hold on;
    plot(linspace(0,x_max,100),zeros(100,1),'--','Color','k','LineWidth',0.3);
    plot(lid_pp_sens_stamp,lid_pp_y_map_err,'*','Color',col.pointpillars);
    grid on;
    title('lidar_pp_y_map [m]')
    xlim([0 inf])
    ylim([-gat_thr gat_thr])
    
    axes(f) = nexttile;
    f=f+1;
    hold on;
    plot(linspace(0,x_max,100),zeros(100,1),'--','Color','k','LineWidth',0.3);
    plot(cam_yolo_sens_stamp,cam_yolo_y_map_err,'*','Color',col.camera);
    grid on;
    title('camera_yolo_y_map [m]')
    xlim([0 inf])
    ylim([-gat_thr gat_thr])
    
    linkaxes(axes,'x')
    
    
    % YAW MAP
    figure('name','Error: yaw_map')
    tiledlayout(4,1,'Padding','compact');
    
    axes(f) = nexttile;
    f=f+1;
    hold on;
    plot(linspace(0,x_max,100),zeros(100,1),'--','Color','k','LineWidth',0.3);
    plot(lid_clust_sens_stamp,rad2deg(lid_clust_yaw_map_err),'*','Color',col.lidar);
    grid on;
    title('lidar_clust_yaw_map [m]')
    xlim([0 inf])
    ylim([-10 10])
    
    axes(f) = nexttile;
    f=f+1;
    hold on;
    plot(linspace(0,x_max,100),zeros(100,1),'--','Color','k','LineWidth',0.3);
    plot(rad_clust_sens_stamp,rad2deg(rad_clust_yaw_map_err),'*','Color',col.radar);
    grid on;
    title('radar_clust_yaw_map [m]')
    xlim([0 inf])
    ylim([-10 10])
    
    axes(f) = nexttile;
    f=f+1;
    hold on;
    plot(linspace(0,x_max,100),zeros(100,1),'--','Color','k','LineWidth',0.3);
    plot(lid_pp_sens_stamp,rad2deg(lid_pp_yaw_map_err),'*','Color',col.pointpillars);
    grid on;
    title('lidar_pp_yaw_map [m]')
    xlim([0 inf])
    ylim([-10 10])
    
    axes(f) = nexttile;
    f=f+1;
    hold on;
    plot(linspace(0,x_max,100),zeros(100,1),'--','Color','k','LineWidth',0.3);
    plot(cam_yolo_sens_stamp,rad2deg(cam_yolo_yaw_map_err),'*','Color',col.camera);
    grid on;
    title('camera_yolo_yaw_map [m]')
    xlim([0 inf])
    ylim([-10 10])
    
    linkaxes(axes,'x')

end

%% DETECTIONS - FOV


[cam_x_fov,cam_y_fov]  = compute_fov(35,0);
[lid_x_fov,lid_y_fov]  = compute_fov(10,179);
[rad_x_fov,rad_y_fov]  = compute_fov(80,0);

[x_25m, y_25m] = calculate_ellipse(25,25,0,0); 
[x_50m, y_50m] = calculate_ellipse(50,50,0,0); 
[x_75m, y_75m] = calculate_ellipse(75,75,0,0); 
[x_100m, y_100m] = calculate_ellipse(100,100,0,0); 

figure('Name','Detections - FoV')
subplot(1,2,1)
ax1 = gca;
hold on;
%Lidar
plot(lid_pp_y_rel,lid_pp_x_rel,'*','Color',col.pointpillars,'DisplayName','Lidar PP')
plot(lid_clust_y_rel,lid_clust_x_rel,'*','Color',col.lidar,'DisplayName','Lidar Clust')
plot(lid_y_fov,lid_x_fov,'-','LineWidth',0.5,'Color',col.lidar,'HandleVisibility','off')
%Radar
plot(rad_clust_y_rel,rad_clust_x_rel,'*','Color',col.radar,'DisplayName','Radar Clust')
plot(rad_y_fov,rad_x_fov,'-','LineWidth',0.5,'Color',col.radar,'HandleVisibility','off')
%Camera
plot(cam_yolo_y_rel,cam_yolo_x_rel,'*','Color',col.camera,'DisplayName','Camera Yolo')
plot(cam_y_fov,cam_x_fov,'-','LineWidth',0.3,'Color',col.camera,'HandleVisibility','off')
plot(cam_y_fov,-cam_x_fov,'-','LineWidth',0.3,'Color',col.camera,'HandleVisibility','off')

plot(x_25m,y_25m,'--','LineWidth',0.3,'Color',[0.5 0.5 0.5],'HandleVisibility','off')
plot(x_50m,y_50m,'--','LineWidth',0.3,'Color',[0.5 0.5 0.5],'HandleVisibility','off')
plot(x_75m,y_75m,'--','LineWidth',0.3,'Color',[0.5 0.5 0.5],'HandleVisibility','off')
plot(x_100m,y_100m,'--','LineWidth',0.3,'Color',[0.5 0.5 0.5],'HandleVisibility','off')
plot(0,0,'d','Color','default','LineWidth',1,'DisplayName','Ego','MarkerSize',10)
ylabel('X [m]')
xlabel('Y [m]')
legend('Location','northwest')
grid on;
axis equal
ylim([-20 100])
xlim([-50 50])
title('Field of View')

subplot(1,2,2)
ax2 = gca;
hold on

% Camera
camera_err = sqrt(cam_yolo_x_map_err.^2+cam_yolo_y_map_err.^2);
scatter(cam_yolo_y_rel,cam_yolo_x_rel,[],camera_err,'filled','o','DisplayName','Camera Yolo')
% Lidar
lid_err = sqrt(lid_clust_x_map_err.^2+lid_clust_y_map_err.^2);
scatter(lid_clust_y_rel,lid_clust_x_rel,[],lid_err,'filled','square','DisplayName','Lid Clust')
pp_err = sqrt(lid_pp_x_map_err.^2+lid_pp_y_map_err.^2);
scatter(lid_pp_y_rel,lid_pp_x_rel,[],pp_err,'filled','^','DisplayName','Lid PP')
% Radar
rad_err = sqrt(rad_clust_x_map_err.^2+rad_clust_y_map_err.^2);
scatter(rad_clust_y_rel,rad_clust_x_rel,[],rad_err,'filled','diamond','DisplayName','Rad Clust')

plot(x_25m,y_25m,'--','LineWidth',0.3,'Color',[0.5 0.5 0.5],'HandleVisibility','off')
plot(x_50m,y_50m,'--','LineWidth',0.3,'Color',[0.5 0.5 0.5],'HandleVisibility','off')
plot(x_75m,y_75m,'--','LineWidth',0.3,'Color',[0.5 0.5 0.5],'HandleVisibility','off')
plot(x_100m,y_100m,'--','LineWidth',0.3,'Color',[0.5 0.5 0.5],'HandleVisibility','off')
plot(0,0,'d','Color','default','LineWidth',1,'DisplayName','Ego','MarkerSize',10)
ylabel('X [m]')
xlabel('Y [m]')
colorbar('Location','east')
legend('Location','northwest')
grid on;
axis equal
ylim([-20 100])
xlim([-50 50])
clim([0 3])
title('Detection Error')

linkaxes([ax1,ax2],'xy')

%% ERROR STD

% LIDAR CLUSTERING
ass_idxs = sqrt(lid_clust_x_map_err.^2+lid_clust_y_map_err.^2)<10;
lid_clust.x_rel_std = std(lid_clust_x_rel_err(ass_idxs));
lid_clust.x_rel_mean = mean(lid_clust_x_rel_err(ass_idxs));
lid_clust.y_rel_std = std(lid_clust_y_rel_err(ass_idxs));
lid_clust.y_rel_mean = mean(lid_clust_y_rel_err(ass_idxs));
lid_clust.yaw_map_std = std(lid_clust_yaw_map_err(ass_idxs));
lid_clust.yaw_map_mean = mean(lid_clust_yaw_map_err(ass_idxs));

% RADAR CLUSTERING

ass_idxs = sqrt(rad_clust_x_map_err.^2+rad_clust_y_map_err.^2)<10;
rad_clust.x_rel_std = std(rad_clust_x_rel_err(ass_idxs));
rad_clust.x_rel_mean = mean(rad_clust_x_rel_err(ass_idxs));
rad_clust.y_rel_std = std(rad_clust_y_rel_err(ass_idxs));
rad_clust.y_rel_mean = mean(rad_clust_y_rel_err(ass_idxs));
rad_clust.yaw_map_std = std(rad_clust_yaw_map_err(ass_idxs));
rad_clust.yaw_map_mean = mean(rad_clust_yaw_map_err(ass_idxs));

% LIDAR POINTPILLARS
ass_idxs = sqrt(lid_pp_x_map_err.^2+lid_pp_y_map_err.^2)<10;
lid_pp.x_rel_std = std(lid_pp_x_rel_err(ass_idxs));
lid_pp.x_rel_mean = mean(lid_pp_x_rel_err(ass_idxs));
lid_pp.y_rel_std = std(lid_pp_y_rel_err(ass_idxs));
lid_pp.y_rel_mean = mean(lid_pp_y_rel_err(ass_idxs));
lid_pp.yaw_map_std = std(lid_pp_yaw_map_err(ass_idxs));
lid_pp.yaw_map_mean = mean(lid_pp_yaw_map_err(ass_idxs));


% CAMERA YOLO
ass_idxs = sqrt(cam_yolo_x_map_err.^2+cam_yolo_y_map_err.^2)<10;
cam_yolo.x_rel_mean = mean(cam_yolo_x_rel_err(ass_idxs));
cam_yolo.y_rel_mean = mean(cam_yolo_y_rel_err(ass_idxs));
cam_yolo.yaw_map_mean = mean(cam_yolo_yaw_map_err(ass_idxs));
cam_yolo.x_rel_std = std(cam_yolo_x_rel_err(ass_idxs));
cam_yolo.y_rel_std = std(cam_yolo_y_rel_err(ass_idxs));
cam_yolo.yaw_map_std = std(cam_yolo_yaw_map_err(ass_idxs));

% % Disp values
% disp("Lidar Clustering:")
% disp(lid_clust)
% disp("Radar Clustering:")
% disp(rad_clust)
% disp("Lidar Pointpillars:")
% disp(lid_pp)
% disp("Camera Yolo:")
% disp(cam_yolo)

[lid_clust_x_ellipse,lid_clust_y_ellipse] = calculate_ellipse(lid_clust.x_rel_std,lid_clust.y_rel_std,lid_clust.x_rel_mean, lid_clust.y_rel_mean);
[rad_clust_x_ellipse,rad_clust_y_ellipse] = calculate_ellipse(rad_clust.x_rel_std,rad_clust.y_rel_std,rad_clust.x_rel_mean, rad_clust.y_rel_mean);
[lid_pp_x_ellipse,lid_pp_y_ellipse] = calculate_ellipse(lid_pp.x_rel_std,lid_pp.y_rel_std,lid_pp.x_rel_mean, lid_pp.y_rel_mean);
[cam_yolo_x_ellipse,cam_yolo_y_ellipse] = calculate_ellipse(cam_yolo.x_rel_std,cam_yolo.y_rel_std,cam_yolo.x_rel_mean, cam_yolo.y_rel_mean);


figure("Name","Error - Summary")
subplot(2,4,[1 2 5 6])
hold on
plot(lid_clust_y_ellipse,lid_clust_x_ellipse, 'Color',col.lidar,"DisplayName","Lidar Clustering","HandleVisibility","on",'LineWidth',2)
plot(rad_clust_y_ellipse,rad_clust_x_ellipse, 'Color',col.radar,"DisplayName","Radar Clustering","HandleVisibility","on",'LineWidth',2)
plot(lid_pp_y_ellipse,lid_pp_x_ellipse, 'Color',col.pointpillars,"DisplayName","Lidar Pointpillars","HandleVisibility","on",'LineWidth',2)
plot(cam_yolo_y_ellipse,cam_yolo_x_ellipse, 'Color',col.camera,"DisplayName","Camera Yolo","HandleVisibility","on",'LineWidth',2)
scatter(lid_clust.y_rel_mean, lid_clust.x_rel_mean,'o','MarkerFaceColor',col.lidar,'HandleVisibility','off')
scatter(rad_clust.y_rel_mean, rad_clust.x_rel_mean,'o','MarkerFaceColor',col.radar,'HandleVisibility','off')
scatter(lid_pp.y_rel_mean, lid_pp.x_rel_mean,'o','MarkerFaceColor',col.pointpillars,'HandleVisibility','off')
scatter(cam_yolo.y_rel_mean, cam_yolo.x_rel_mean,'o','MarkerFaceColor',col.camera,'MarkerEdgeColor',col.camera,'HandleVisibility','off')

xlabel('Y Rel [m]')
ylabel('X Rel [m]')
title('Positional Errors')
xline(0,'--','LineWidth',0.3,"HandleVisibility","off")
yline(0,'--','LineWidth',0.3,"HandleVisibility","off")
legend
axis equal
grid on;

% Rho Dot Error
subplot(2,4,[3 4])
hold on;
plot(gt_stamp,gt_rho_dot,'Color',col.ref,'DisplayName','Ground Truth');
scatter(rad_clust_sens_stamp,rad_clust_rho_dot,'diamond','MarkerEdgeColor',col.radar,'DisplayName','Radar Clust')
title('Relative Speed Error')
xlim([0 inf])
legend('Location','northwest')
grid on;
xlabel('time [s]')
ylabel('rho_dot [m/s]')


% Heading Error
YawMaxStd = rad2deg(max([lid_clust.yaw_map_std,rad_clust.yaw_map_std,lid_pp.yaw_map_std,cam_yolo.yaw_map_std]));
error = rad2deg([lid_clust_yaw_map_err; rad_clust_yaw_map_err; lid_pp_yaw_map_err; cam_yolo_yaw_map_err]);
g1 = repmat({'Lid Clust'},length(lid_clust_yaw_map_err),1);
g2 = repmat({'Rad Clust'},length(rad_clust_yaw_map_err),1);
g3 = repmat({'Lid Pp'},length(lid_pp_yaw_map_err),1);
g4 = repmat({'Cam yolo'},length(cam_yolo_yaw_map_err),1);
g = [g1; g2; g3;g4];
subplot(2,4,[7 8])
hold on
yline(0,'--','LineWidth',0.3,"HandleVisibility","off")
boxplot(error,g,'Symbol','')
title('Heading Error')
ylabel('[deg]')
ylim([-2*YawMaxStd, 2*YawMaxStd])


%% AVERAGE SENSOR FREQUENCY - DROP OUT PROB

if(drop_out_analyses)
    t_start   = 550;
    t_stop    = 640;
    nominal_f = 20;
    
    val_lid_clust = sqrt(lid_clust_x_map_err.^2+lid_clust_y_map_err.^2)<15 & lid_clust_sens_stamp>t_start & lid_clust_sens_stamp<t_stop;
    lid_clust_count = sum(val_lid_clust);
    lid_clust_avg_freq = lid_clust_count/(t_stop-t_start);
    drop_out.lid_clust = lid_clust_count/(nominal_f*(t_stop-t_start));
    
    val_rad_clust = sqrt(rad_clust_x_map_err.^2+rad_clust_y_map_err.^2)<15 & rad_clust_sens_stamp>t_start & rad_clust_sens_stamp<t_stop;
    rad_clust_count = sum(val_rad_clust);
    rad_clust_avg_freq = rad_clust_count/(t_stop-t_start);
    drop_out.rad_clust = rad_clust_count/(nominal_f*(t_stop-t_start));
    
    val_lid_pp = sqrt(lid_pp_x_map_err.^2+lid_pp_y_map_err.^2)<15 & lid_pp_sens_stamp>t_start & lid_pp_sens_stamp<t_stop;
    lid_pp_count = sum(val_lid_pp);
    lid_pp_avg_freq = lid_pp_count/(t_stop-t_start);
    drop_out.lid_pp = lid_pp_count/(nominal_f*(t_stop-t_start));
    
    val_cam_yolo = sqrt(cam_yolo_x_map_err.^2+cam_yolo_y_map_err.^2)<15 & cam_yolo_sens_stamp>t_start & cam_yolo_sens_stamp<t_stop;
    cam_yolo_count = sum(val_cam_yolo);
    cam_yolo_avg_freq = cam_yolo_count/(t_stop-t_start);
    drop_out.cam_yolo = cam_yolo_count/(nominal_f*(t_stop-t_start));
end
% disp("Detection probability:")
% disp(drop_out)

%% CORRELATION

% Remember that:
% p-value: The probability of obtaining test results at least as extreme as
%          the result actually observed, under the assumption that the null
%          hypothesis is correct
%
% r coeff: The correlation coefficient is the specific measure that 
%          quantifies the strength of the linear relationship between 
%          two variables in a correlation analysis. Positive r values
%          indicate a positive correlation, where the values of both 
%          variables tend to increase together.


if(src_corr)

    % Speed
    corr_stamp = gt_stamp;
    corr_value = abs(log_ref.rho);
    corr_name = 'Opp distance';
    
    
    % Variable interpolation
    lid_clust_sens_stamp = lid_clust_sens_stamp(~isnan(lid_clust_x_map_err));
    lid_clust_x_map_err = lid_clust_x_map_err(~isnan(lid_clust_x_map_err));
    lid_clust_y_map_err = lid_clust_y_map_err(~isnan(lid_clust_y_map_err));
    for i = 1 : length(lid_clust_sens_stamp)
         corr_with_x_map = interp1(corr_stamp,corr_value,lid_clust_sens_stamp,'linear','extrap'); 
         corr_with_y_map = interp1(corr_stamp,corr_value,lid_clust_sens_stamp,'linear','extrap'); 
    end
    corr_with_x_map(end) = 0;
    corr_with_y_map(end) = 0;
    [R_x_lid_clust,P_x_lid_clust] = corrcoef(corr_with_x_map,abs(lid_clust_x_map_err));
    [R_y_lid_clust,P_y_lid_clust] = corrcoef(corr_with_y_map,abs(lid_clust_y_map_err));
    
    
    lid_pp_sens_stamp = lid_pp_sens_stamp(~isnan(lid_pp_x_map_err));
    lid_pp_x_map_err = lid_pp_x_map_err(~isnan(lid_pp_x_map_err));
    lid_pp_y_map_err = lid_pp_y_map_err(~isnan(lid_pp_y_map_err));
    for i = 1 : length(lid_pp_sens_stamp)
         corr_with_x_map = interp1(corr_stamp,corr_value,lid_pp_sens_stamp,'linear','extrap'); 
         corr_with_y_map = interp1(corr_stamp,corr_value,lid_pp_sens_stamp,'linear','extrap'); 
    end
    [R_x_lid_pp,P_x_lid_pp] = corrcoef(corr_with_x_map,abs(lid_pp_x_map_err));
    [R_y_lid_pp,P_y_lid_pp] = corrcoef(corr_with_y_map,abs(lid_pp_y_map_err));
    
    rad_clust_sens_stamp = rad_clust_sens_stamp(~isnan(rad_clust_x_map_err));
    rad_clust_x_map_err = rad_clust_x_map_err(~isnan(rad_clust_x_map_err));
    rad_clust_y_map_err = rad_clust_y_map_err(~isnan(rad_clust_y_map_err));
    for i = 1 : length(rad_clust_sens_stamp)
         corr_with_x_map = interp1(corr_stamp,corr_value,rad_clust_sens_stamp,'linear','extrap'); 
         corr_with_y_map = interp1(corr_stamp,corr_value,rad_clust_sens_stamp,'linear','extrap'); 
    end
    [R_x_rad_clust,P_x_rad_clust] = corrcoef(corr_with_x_map,abs(rad_clust_x_map_err));
    [R_y_rad_clust,P_y_rad_clust] = corrcoef(corr_with_y_map,abs(rad_clust_y_map_err));
    
    cam_yolo_sens_stamp = cam_yolo_sens_stamp(~isnan(cam_yolo_x_map_err));
    cam_yolo_x_map_err = cam_yolo_x_map_err(~isnan(cam_yolo_x_map_err));
    cam_yolo_y_map_err = cam_yolo_y_map_err(~isnan(cam_yolo_y_map_err));
    for i = 1 : length(cam_yolo_sens_stamp)
         corr_with_x_map = interp1(corr_stamp,corr_value,cam_yolo_sens_stamp,'linear','extrap'); 
         corr_with_y_map = interp1(corr_stamp,corr_value,cam_yolo_sens_stamp,'linear','extrap'); 
    end
    [R_x_cam_yolo,P_x_cam_yolo] = corrcoef(corr_with_x_map,abs(cam_yolo_x_map_err));
    [R_y_cam_yolo,P_y_cam_yolo] = corrcoef(corr_with_y_map,abs(cam_yolo_y_map_err));
    
    
    figure('Name','Correlations')
    tiledlayout(3,1,'Padding','compact');
    
    axes(f) = nexttile;
    f = f+1;
    hold on;
    grid on;
    plot(corr_stamp,corr_value,'DisplayName',string(corr_name))
    title('Searching correlation with: '+string(corr_name))
    
    axes(f) = nexttile;
    f = f+1;
    hold on;
    grid on;
    plot(linspace(0,x_max,100),zeros(100,1),'--','Color','k','LineWidth',0.3,'HandleVisibility','off');
    plot(lid_clust_sens_stamp, lid_clust_x_map_err, '*', 'Color', col.lidar,'DisplayName', ['Lidar Clust - p value: ' num2str(P_x_lid_clust(2,1))]);
    plot(rad_clust_sens_stamp,rad_clust_x_map_err,'*','Color',col.radar,'DisplayName', ['Radar Clust - p value: ' num2str(P_x_rad_clust(2,1))]);
    plot(lid_pp_sens_stamp,lid_pp_x_map_err,'*','Color',col.pointpillars,'DisplayName',['Lidar PP - p value: ' num2str(P_x_lid_pp(2,1))]);
    plot(cam_yolo_sens_stamp,cam_yolo_x_map_err,'*','Color',col.camera, 'DisplayName',['Camera - p value: ' num2str(P_x_cam_yolo(2,1))]);
    title('Detection Error - x map')
    xlim([0 inf])
    ylim([-gat_thr gat_thr])
    legend('Location','northwest')
    
    axes(f) = nexttile;
    f = f+1;
    hold on;
    grid on;
    plot(linspace(0,x_max,100),zeros(100,1),'--','Color','k','LineWidth',0.3,'HandleVisibility','off');
    plot(lid_clust_sens_stamp,lid_clust_y_map_err,'*','Color',col.lidar,'DisplayName',['Lidar Clust - p value: ' num2str(P_y_lid_clust(2,1))]);
    plot(rad_clust_sens_stamp,rad_clust_y_map_err,'*','Color',col.radar,'DisplayName',['Radar Clust - p value: ' num2str(P_y_rad_clust(2,1))]);
    plot(lid_pp_sens_stamp,lid_pp_y_map_err,'*','Color',col.pointpillars,'DisplayName',['Lidar PP - p value: ' num2str(P_y_lid_pp(2,1))]);
    plot(cam_yolo_sens_stamp,cam_yolo_y_map_err,'*','Color',col.camera,'DisplayName',['Camera - p value: ' num2str(P_y_cam_yolo(2,1))]);
    title('Detection Error - y map')
    xlim([0 inf])
    ylim([-gat_thr gat_thr])
    legend('Location','northwest')
    
    linkaxes(axes,'x')
end


%% MAP
fig = figure('name','MAP');

c = uicontrol('Style','pushbutton');
c.String = {'Refresh'};
c.Callback = @refreshTimeButtonPushed;


function refreshTimeButtonPushed(src,event)
    axes = evalin('base', 'axes');
    traj_db = evalin('base', 'trajDatabase');
    col.lidar = evalin('base', 'col.lidar');
    col.radar = evalin('base', 'col.radar');
    col.camera = evalin('base', 'col.camera');
    col.pointpillars = evalin('base', 'col.pointpillars');
    col.ref = evalin('base', 'col.ref');
    lid_clust_sens_stamp = evalin('base', 'lid_clust_sens_stamp');
    lid_clust_x_map = evalin('base', 'lid_clust_x_map');
    lid_clust_y_map = evalin('base', 'lid_clust_y_map');
    rad_clust_sens_stamp = evalin('base', 'rad_clust_sens_stamp');
    rad_clust_x_map = evalin('base', 'rad_clust_x_map');
    rad_clust_y_map = evalin('base', 'rad_clust_y_map');
    cam_yolo_sens_stamp = evalin('base', 'cam_yolo_sens_stamp');
    cam_yolo_x_map = evalin('base', 'cam_yolo_x_map');
    cam_yolo_y_map = evalin('base', 'cam_yolo_y_map');
    lid_pp_sens_stamp = evalin('base', 'lid_pp_sens_stamp');
    lid_pp_x_map = evalin('base', 'lid_pp_x_map');
    lid_pp_y_map = evalin('base', 'lid_pp_y_map');
    gt_stamp = evalin('base','gt_stamp');
    gt_x_map = evalin('base', 'gt_x_map');
    gt_y_map = evalin('base', 'gt_y_map');
  


    t_lim=xlim(axes(1));
    t1_lid_clust = find(lid_clust_sens_stamp>t_lim(1),1);
    tend_lid_clust = find(lid_clust_sens_stamp<t_lim(2),1,'last');
    t1_rad_clust = find(rad_clust_sens_stamp>t_lim(1),1);
    tend_rad_clust = find(rad_clust_sens_stamp<t_lim(2),1,'last');
    t1_cam_yolo = find(cam_yolo_sens_stamp>t_lim(1),1);
    tend_cam_yolo = find(cam_yolo_sens_stamp<t_lim(2),1,'last');
    t1_lid_pp = find(lid_pp_sens_stamp>t_lim(1),1);
    tend_lid_pp = find(lid_pp_sens_stamp<t_lim(2),1,'last');
    t1_gt = find(gt_stamp>t_lim(1),1);
    tend_gt = find(gt_stamp<t_lim(2),1,'last');

    subplot(1,1,1)
    cla reset 
    title('map')
    hold on
    grid on
    xlabel('x[m]')
    ylabel('y[m]')
    % ylim([-1000,1500])
    axis 'equal'

    % plot track lines
    id_left = length(traj_db) - 2;
    id_right = length(traj_db) - 1;
    plot(traj_db(id_left).X, traj_db(id_left).Y, 'color', 'k', 'LineWidth', 1, 'HandleVisibility','off');
    plot(traj_db(id_right).X, traj_db(id_right).Y, 'color', 'k', 'LineWidth', 1, 'HandleVisibility','off');


    plot(lid_clust_x_map(t1_lid_clust:tend_lid_clust), lid_clust_y_map(t1_lid_clust:tend_lid_clust),'.','markersize',20,'Color',col.lidar,'displayname','Lid Clust');
    plot(rad_clust_x_map(t1_rad_clust:tend_rad_clust), rad_clust_y_map(t1_rad_clust:tend_rad_clust),'.','markersize',20,'Color',col.radar,'displayname','Rad Clust');
    plot(cam_yolo_x_map(t1_cam_yolo:tend_cam_yolo), cam_yolo_y_map(t1_cam_yolo:tend_cam_yolo),'.','markersize',20,'Color',col.camera,'displayname','Camera');
    plot(lid_pp_x_map(t1_lid_pp:tend_lid_pp), lid_pp_y_map(t1_lid_pp:tend_lid_pp),'.','markersize',20,'Color',col.pointpillars,'displayname','Lid PP');
    plot(gt_x_map(t1_gt:tend_gt),gt_y_map(t1_gt:tend_gt),'Color',col.ref,'DisplayName','Grond Truth');
    legend show
end

%% FUNCTIONS
function [x,y] = calculate_ellipse(std_x,std_y, mu_x, mu_y)

a = std_x;
b = std_y;

x1 = [linspace(-a,a,1000)];
x2 = [linspace(a,-a,1000)];

y  = [b*sqrt(1-x1.^2/a^2), -b*sqrt(1-x2.^2/a^2)];

x = [x1,x2];

x = x + mu_x;
y = y + mu_y;


end

function [x,y]=compute_fov(aper,center)

    center = deg2rad(center);
    ang = aper/2;
    x1 = linspace(0,100,1000)';
    y1 = x1*tan(deg2rad(ang))';

    x2 = x1;
    y2 = -y1;

    Rz = [cos(center), -sin(center);
          sin(center),  cos(center)];
    
    P1 = [x1,y1];
    P2 = [x2,y2];

    P1 = (Rz * P1')';
    P2 = (Rz * P2')';

    x1 = P1(:, 1);
    y1 = P1(:, 2);
    x2 = P2(:, 1);
    y2 = P2(:, 2);

    x = [x1;x2];
    y = [y1;y2];
    
end