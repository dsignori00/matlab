clc
close all
clearvars -except log log_ref

src_corr = false;
show_error_series = false;
use_sim_ref = false;
drop_out_analyses = false;
use_ref = true;


%% Paths

addpath("../../common/utilities/")
addpath("../../common/constants/")
addpath("../../common/plot/")
addpath("../utils/")
opp_dir = "../opponent_gps/mat/";
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

% load log
if (~exist('log','var'))
    [file,path] = uigetfile(fullfile(normal_path,'*.mat'),'Load log');
    load(fullfile(path,file));
end

% load ref
if(~use_sim_ref)
    if (~exist('log_ref','var'))
    [file,path_dir] = uigetfile(fullfile(opp_dir,'*.mat'),'Load ground truth mat');
    tmp = load(fullfile(path_dir,file));
    fields = fieldnames(tmp);
    log_ref = tmp.(fields{1});
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

load_perception;

% ego
ego_speed_stamp = log.estimation.stamp__tot;
ego_speed = log.estimation.vx;
ego_rpm_stamp = log.vehicle_fbk.stamp__tot;
ego_rpm = log.vehicle_fbk.engine_rpm;

% target tracking
tt_stamp = log.perception__opponents.stamp__tot;
tt_count = log.perception__opponents.count;
max_opp = max(tt_count);

%% SHRINK GT

too_dist_idxs = abs(gt.x_rel)>150 | abs(gt.y_rel)>30;

% relative
gt.x_rel(too_dist_idxs)     = NaN;
gt.y_rel(too_dist_idxs)     = NaN;
gt.z_rel(too_dist_idxs)     = NaN;
gt.rho_dot(too_dist_idxs)   = NaN;
gt.yaw_rel(too_dist_idxs)   = NaN;

% keep only not NaN measures
validate_meas;

% interpolate opp ground truth on our measures
interp1_opp;

%% LATENCY FIGURE
figure('name','Latency')
tiledlayout(4,1,'Padding','compact');

axes(f) = nexttile; f=f+1; hold on;
plot(log.perception__lidar__clustering_detections.stamp__tot,log.perception__lidar__clustering_detections.stamp__tot-log.perception__lidar__clustering_detections.sensor_stamp__tot);
grid on; title('lidar_clust [s]')

axes(f) = nexttile; f=f+1; hold on;
plot(log.perception__radar__clustering_detections.stamp__tot,log.perception__radar__clustering_detections.stamp__tot-log.perception__radar__clustering_detections.sensor_stamp__tot);
grid on; title('radar_clust [s]')

axes(f) = nexttile; f=f+1; hold on;
plot(log.perception__camera__yolo_detections.stamp__tot,log.perception__camera__yolo_detections.stamp__tot-log.perception__camera__yolo_detections.sensor_stamp__tot);
grid on; title('camera_yolo [s]')

axes(f) = nexttile; f=f+1; hold on;
plot(log.perception__lidar__pointpillars_detections.stamp__tot,log.perception__lidar__pointpillars_detections.stamp__tot-log.perception__lidar__pointpillars_detections.sensor_stamp__tot);
grid on; title('lidar_pp [s]')

lid_clust.latency = mean(log.perception__lidar__clustering_detections.stamp__tot-log.perception__lidar__clustering_detections.sensor_stamp__tot);
rad_clust.latency = mean(log.perception__radar__clustering_detections.stamp__tot-log.perception__radar__clustering_detections.sensor_stamp__tot);
cam_yolo.latency = mean(log.perception__camera__yolo_detections.stamp__tot-log.perception__camera__yolo_detections.sensor_stamp__tot);
lid_pp.latency = mean(log.perception__lidar__pointpillars_detections.stamp__tot-log.perception__lidar__pointpillars_detections.sensor_stamp__tot);


%% DETECTIONS FIGURE - MAP

figure('Name','Detections - Map')
tiledlayout(3,1,'Padding','compact')

% x map
axes(f) = nexttile([1,1]); f=f+1; hold on;
plot(gt.stamp,gt.x_map,'Color',col.ref,'DisplayName','Ground Truth')
plot(lid_clust.sens_stamp,lid_clust.x_map,'*','Color',col.lidar,'DisplayName','Lidar Clust')
plot(rad_clust.sens_stamp,rad_clust.x_map,'*','Color',col.radar,'DisplayName','Radar Clust')
plot(lid_pp.sens_stamp,lid_pp.x_map,'*','Color',col.pointpillars,'DisplayName','Lidar PP')
plot(cam_yolo.sens_stamp,cam_yolo.x_map,'*','Color',col.camera,'DisplayName','Camera Yolo')
xlim([0 inf]); legend('Location','northwest'); grid on; title('x_map [m]');

% y map
axes(f) = nexttile([1,1]); f=f+1; hold on;
plot(gt.stamp,gt.y_map,'Color',col.ref,'DisplayName','Ground Truth')
plot(lid_clust.sens_stamp,lid_clust.y_map,'*','Color',col.lidar,'DisplayName','Lidar Clust')
plot(rad_clust.sens_stamp,rad_clust.y_map,'*','Color',col.radar,'DisplayName','Radar Clust')
plot(lid_pp.sens_stamp,lid_pp.y_map,'*','Color',col.pointpillars,'DisplayName','Lidar PP')
plot(cam_yolo.sens_stamp,cam_yolo.y_map,'*','Color',col.camera,'DisplayName','Camera Yolo')
xlim([0 inf]); legend('Location','northwest'); grid on; title('y_map [m]');

% count
axes(f) = nexttile([1,1]); f=f+1; hold on;
area(tt_stamp,log.perception__opponents.opponents__rad_clust_meas(:,1:max_opp),'FaceColor',col.radar,'EdgeColor',col.radar,'DisplayName','Rad Clust');
area(tt_stamp,log.perception__opponents.opponents__lid_pp_meas(:,1:max_opp),'FaceColor',col.pointpillars,'EdgeColor',col.pointpillars,'DisplayName','Lid PP');
area(tt_stamp,log.perception__opponents.opponents__lid_clust_meas(:,1:max_opp),'FaceColor',col.lidar,'EdgeColor',col.lidar,'DisplayName','Lid Clust');
area(tt_stamp,log.perception__opponents.opponents__cam_yolo_meas(:,1:max_opp),'FaceColor',col.camera,'EdgeColor',col.camera,'DisplayName','Camera');
grid on; title('Associated Measures Count');

%% DETECTIONS FIGURE - REL

figure('Name','Detections - Rel')
tiledlayout(3,1,'Padding','compact')

axes(f) = nexttile([1,1]); f=f+1; hold on;
plot(gt.stamp,gt.x_rel,'Color',col.ref,'DisplayName','Ground Truth')
plot(lid_clust.sens_stamp,lid_clust.x_rel,'*','Color',col.lidar,'DisplayName','Lidar Clust')
plot(rad_clust.sens_stamp,rad_clust.x_rel,'*','Color',col.radar,'DisplayName','Radar Clust')
plot(lid_pp.sens_stamp,lid_pp.x_rel,'*','Color',col.pointpillars,'DisplayName','Lidar PP')
plot(cam_yolo.sens_stamp,cam_yolo.x_rel,'*','Color',col.camera,'DisplayName','Camera Yolo')
xlim([0 inf]); legend('Location','northwest'); grid on; title('x_rel [m]');

axes(f) = nexttile([1,1]); f=f+1; hold on;
plot(gt.stamp,gt.y_rel,'Color',col.ref,'DisplayName','Ground Truth')
plot(lid_clust.sens_stamp,lid_clust.y_rel,'*','Color',col.lidar,'DisplayName','Lidar Clust')
plot(rad_clust.sens_stamp,rad_clust.y_rel,'*','Color',col.radar,'DisplayName','Radar Clust')
plot(lid_pp.sens_stamp,lid_pp.y_rel,'*','Color',col.pointpillars,'DisplayName','Lidar PP')
plot(cam_yolo.sens_stamp,cam_yolo.y_rel,'*','Color',col.camera,'DisplayName','Camera Yolo')
xlim([0 inf]); legend('Location','northwest'); grid on; title('y_rel [m]');

% count
axes(f) = nexttile([1,1]); f=f+1; hold on;
area(tt_stamp,log.perception__opponents.opponents__rad_clust_meas(:,1:max_opp),'FaceColor',col.radar,'EdgeColor',col.radar,'DisplayName','Rad Clust');
area(tt_stamp,log.perception__opponents.opponents__lid_pp_meas(:,1:max_opp),'FaceColor',col.pointpillars,'EdgeColor',col.pointpillars,'DisplayName','Lid PP');
area(tt_stamp,log.perception__opponents.opponents__lid_clust_meas(:,1:max_opp),'FaceColor',col.lidar,'EdgeColor',col.lidar,'DisplayName','Lid Clust');
area(tt_stamp,log.perception__opponents.opponents__cam_yolo_meas(:,1:max_opp),'FaceColor',col.camera,'EdgeColor',col.camera,'DisplayName','Camera');
grid on; title('Associated Measures Count');

%% DETECTIONS FIGURE - YAW

figure('Name','Detections - Yaw')
tiledlayout(3,1,'Padding','compact')

axes(f) = nexttile([1,1]); f=f+1; hold on;
plot(gt.stamp,gt.yaw_map,'Color',col.ref,'DisplayName','Ground Truth')
plot(lid_clust.sens_stamp,lid_clust.yaw_map,'*','Color',col.lidar,'DisplayName','Lidar Clust')
plot(rad_clust.sens_stamp,rad_clust.yaw_map,'*','Color',col.radar,'DisplayName','Radar Clust')
plot(lid_pp.sens_stamp,lid_pp.yaw_map,'*','Color',col.pointpillars,'DisplayName','Lidar PP')
plot(cam_yolo.sens_stamp,cam_yolo.yaw_map,'*','Color',col.camera,'DisplayName','Camera Yolo')
xlim([0 inf]); legend('Location','northwest'); grid on; title('yaw_map [deg]');

axes(f) = nexttile([1,1]); f=f+1; hold on;
plot(gt.stamp,rad2deg(gt.yaw_rel),'Color',col.ref,'DisplayName','Ground Truth')
plot(lid_clust.sens_stamp,lid_clust.yaw_rel,'*','Color',col.lidar,'DisplayName','Lidar Clust')
plot(rad_clust.sens_stamp,rad_clust.yaw_rel,'*','Color',col.radar,'DisplayName','Radar Clust')
plot(lid_pp.sens_stamp,lid_pp.yaw_rel,'*','Color',col.pointpillars,'DisplayName','Lidar PP')
plot(cam_yolo.sens_stamp,cam_yolo.yaw_rel,'*','Color',col.camera,'DisplayName','Camera Yolo')
xlim([0 inf]); legend('Location','northwest'); grid on; title('yaw_rel [deg]');

% count
axes(f) = nexttile([1,1]); f=f+1; hold on;
area(tt_stamp,log.perception__opponents.opponents__rad_clust_meas(:,1:max_opp),'FaceColor',col.radar,'EdgeColor',col.radar,'DisplayName','Rad Clust');
area(tt_stamp,log.perception__opponents.opponents__lid_pp_meas(:,1:max_opp),'FaceColor',col.pointpillars,'EdgeColor',col.pointpillars,'DisplayName','Lid PP');
area(tt_stamp,log.perception__opponents.opponents__lid_clust_meas(:,1:max_opp),'FaceColor',col.lidar,'EdgeColor',col.lidar,'DisplayName','Lid Clust');
area(tt_stamp,log.perception__opponents.opponents__cam_yolo_meas(:,1:max_opp),'FaceColor',col.camera,'EdgeColor',col.camera,'DisplayName','Camera');
grid on; legend('Location','northwest'); grid on; title('Associated Measures Count');

%% AUXILIARY FIGURES

compute_perception_error;
error_summary;
error_series;
correlation_fig;
fov_fig;

linkaxes(axes,'x');

%% MAP
fig = figure('name','MAP');

c = uicontrol('Style','pushbutton');
c.String = {'Refresh'};
c.Callback = @refreshTimeButtonPushed;


function refreshTimeButtonPushed(~,~)
    axes = evalin('base', 'axes');
    traj_db = evalin('base', 'trajDatabase');
    col.lidar = evalin('base', 'col.lidar');
    col.radar = evalin('base', 'col.radar');
    col.camera = evalin('base', 'col.camera');
    col.pointpillars = evalin('base', 'col.pointpillars');
    col.ref = evalin('base', 'col.ref');
    lid_clust.sens_stamp = evalin('base', 'lid_clust.sens_stamp');
    lid_clust.x_map = evalin('base', 'lid_clust.x_map');
    lid_clust.y_map = evalin('base', 'lid_clust.y_map');
    rad_clust.sens_stamp = evalin('base', 'rad_clust.sens_stamp');
    rad_clust.x_map = evalin('base', 'rad_clust.x_map');
    rad_clust.y_map = evalin('base', 'rad_clust.y_map');
    cam_yolo.sens_stamp = evalin('base', 'cam_yolo.sens_stamp');
    cam_yolo.x_map = evalin('base', 'cam_yolo.x_map');
    cam_yolo.y_map = evalin('base', 'cam_yolo.y_map');
    lid_pp.sens_stamp = evalin('base', 'lid_pp.sens_stamp');
    lid_pp.x_map = evalin('base', 'lid_pp.x_map');
    lid_pp.y_map = evalin('base', 'lid_pp.y_map');
    gt.stamp = evalin('base','gt.stamp');
    gt.x_map = evalin('base', 'gt.x_map');
    gt.y_map = evalin('base', 'gt.y_map');
  


    t_lim=xlim(axes(1));
    t1_lid_clust = find(lid_clust.sens_stamp>t_lim(1),1);
    tend_lid_clust = find(lid_clust.sens_stamp<t_lim(2),1,'last');
    t1_rad_clust = find(rad_clust.sens_stamp>t_lim(1),1);
    tend_rad_clust = find(rad_clust.sens_stamp<t_lim(2),1,'last');
    t1_cam_yolo = find(cam_yolo.sens_stamp>t_lim(1),1);
    tend_cam_yolo = find(cam_yolo.sens_stamp<t_lim(2),1,'last');
    t1_lid_pp = find(lid_pp.sens_stamp>t_lim(1),1);
    tend_lid_pp = find(lid_pp.sens_stamp<t_lim(2),1,'last');
    t1_gt = find(gt.stamp>t_lim(1),1);
    tend_gt = find(gt.stamp<t_lim(2),1,'last');

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


    plot(lid_clust.x_map(t1_lid_clust:tend_lid_clust), lid_clust.y_map(t1_lid_clust:tend_lid_clust),'.','markersize',20,'Color',col.lidar,'displayname','Lid Clust');
    plot(rad_clust.x_map(t1_rad_clust:tend_rad_clust), rad_clust.y_map(t1_rad_clust:tend_rad_clust),'.','markersize',20,'Color',col.radar,'displayname','Rad Clust');
    plot(cam_yolo.x_map(t1_cam_yolo:tend_cam_yolo), cam_yolo.y_map(t1_cam_yolo:tend_cam_yolo),'.','markersize',20,'Color',col.camera,'displayname','Camera');
    plot(lid_pp.x_map(t1_lid_pp:tend_lid_pp), lid_pp.y_map(t1_lid_pp:tend_lid_pp),'.','markersize',20,'Color',col.pointpillars,'displayname','Lid PP');
    plot(gt.x_map(t1_gt:tend_gt),gt.y_map(t1_gt:tend_gt),'Color',col.ref,'DisplayName','Grond Truth');
    legend show
end
