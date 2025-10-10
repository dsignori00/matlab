clc
close all
clearvars -except log log_ref trajDatabase

use_ref             = true;
use_sim_ref         = false;
search_correlations = false;
show_error_series   = false;
drop_out_analyses   = false;

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
x_lim = [0 inf];

%% LOAD DATA

load_perception;
cam_yolo.sens_stamp(cam_yolo.sens_stamp < 0) = NaN;

% ego
ego_speed_stamp = log.estimation.stamp__tot;
ego_speed = log.estimation.vx;
ego_rpm_stamp = log.vehicle_fbk.stamp__tot;
ego_rpm = log.vehicle_fbk.engine_rpm;

% target tracking
tt_stamp = log.perception__opponents.stamp__tot;
tt_count = log.perception__opponents.count;
max_opp = max(tt_count);

%% LATENCY FIGURE

figure('name','Latency')
tiledlayout(4,1,'Padding','compact');

axes(f) = nexttile; f=f+1; hold on;
plot(lid_clust.stamp,lid_clust.stamp - lid_clust.sens_stamp);
grid on; title('lidar_clust [s]')

axes(f) = nexttile; f=f+1; hold on;
plot(rad_clust.stamp, rad_clust.stamp - rad_clust.sens_stamp);
grid on; title('radar_clust [s]')

axes(f) = nexttile; f=f+1; hold on;
plot(cam_yolo.stamp,cam_yolo.stamp - cam_yolo.sens_stamp);
grid on; title('camera_yolo [s]')

axes(f) = nexttile; f=f+1; hold on;
plot(lid_pp.stamp,lid_pp.stamp - lid_pp.sens_stamp);
grid on; title('lidar_pp [s]')

%% PROCESSING 

% keep only not NaN measures
validate_meas;

% interpolate opp ground truth on our measures
interp1_opp;

% Range Computation
lid_clust.range = sqrt(lid_clust.x_rel.^2 + lid_clust.y_rel.^2);
rad_clust.range = sqrt(rad_clust.x_rel.^2 + rad_clust.y_rel.^2);
cam_yolo.range = sqrt(cam_yolo.x_rel.^2 + cam_yolo.y_rel.^2);
lid_pp.range = sqrt(lid_pp.x_rel.^2 + lid_pp.y_rel.^2);

%% DETECTIONS FIGURE - MAP

figure('Name','Detections - Map')
tiledlayout(2,1,'Padding','compact')

% x map
axes(f) = nexttile([1,1]); f=f+1; hold on;
plot(gt.stamp,gt.x_map,'Color',col.ref,'DisplayName','Ground Truth')
plot(lid_clust.sens_stamp,lid_clust.x_map,'*','Color',col.lidar,'DisplayName','Lidar Clust')
plot(rad_clust.sens_stamp,rad_clust.x_map,'*','Color',col.radar,'DisplayName','Radar Clust')
plot(lid_pp.sens_stamp,lid_pp.x_map,'*','Color',col.pointpillars,'DisplayName','Lidar PP')
plot(cam_yolo.sens_stamp,cam_yolo.x_map,'*','Color',col.camera,'DisplayName','Camera Yolo')
xlim(x_lim); grid on; title('x_map [m]');

% y map
axes(f) = nexttile([1,1]); f=f+1; hold on;
plot(gt.stamp,gt.y_map,'Color',col.ref,'DisplayName','Ground Truth')
plot(lid_clust.sens_stamp,lid_clust.y_map,'*','Color',col.lidar,'DisplayName','Lidar Clust')
plot(rad_clust.sens_stamp,rad_clust.y_map,'*','Color',col.radar,'DisplayName','Radar Clust')
plot(lid_pp.sens_stamp,lid_pp.y_map,'*','Color',col.pointpillars,'DisplayName','Lidar PP')
plot(cam_yolo.sens_stamp,cam_yolo.y_map,'*','Color',col.camera,'DisplayName','Camera Yolo')
xlim(x_lim); grid on; title('y_map [m]');

%% DETECTIONS FIGURE - REL

figure('Name','Detections - Rel')
tiledlayout(2,1,'Padding','compact')

axes(f) = nexttile([1,1]); f=f+1; hold on;
plot(gt.stamp,gt.x_rel,'Color',col.ref,'DisplayName','Ground Truth')
plot(lid_clust.sens_stamp,lid_clust.x_rel,'*','Color',col.lidar,'DisplayName','Lidar Clust')
plot(rad_clust.sens_stamp,rad_clust.x_rel,'*','Color',col.radar,'DisplayName','Radar Clust')
plot(lid_pp.sens_stamp,lid_pp.x_rel,'*','Color',col.pointpillars,'DisplayName','Lidar PP')
plot(cam_yolo.sens_stamp,cam_yolo.x_rel,'*','Color',col.camera,'DisplayName','Camera Yolo')
xlim(x_lim); ylim([-200 200]); grid on; title('x_rel [m]');

axes(f) = nexttile([1,1]); f=f+1; hold on;
plot(gt.stamp,gt.y_rel,'Color',col.ref,'DisplayName','Ground Truth')
plot(lid_clust.sens_stamp,lid_clust.y_rel,'*','Color',col.lidar,'DisplayName','Lidar Clust')
plot(rad_clust.sens_stamp,rad_clust.y_rel,'*','Color',col.radar,'DisplayName','Radar Clust')
plot(lid_pp.sens_stamp,lid_pp.y_rel,'*','Color',col.pointpillars,'DisplayName','Lidar PP')
plot(cam_yolo.sens_stamp,cam_yolo.y_rel,'*','Color',col.camera,'DisplayName','Camera Yolo')
xlim(x_lim); ylim([-100 100]); grid on; title('y_rel [m]');

%% DETECTIONS FIGURE - YAW

figure('Name','Detections - Yaw')
tiledlayout(2,1,'Padding','compact')

axes(f) = nexttile([1,1]); f=f+1; hold on;
plot(gt.stamp,gt.yaw_map,'Color',col.ref,'DisplayName','Ground Truth')
plot(lid_clust.sens_stamp,lid_clust.yaw_map,'*','Color',col.lidar,'DisplayName','Lidar Clust')
plot(rad_clust.sens_stamp,rad_clust.yaw_map,'*','Color',col.radar,'DisplayName','Radar Clust')
plot(lid_pp.sens_stamp,lid_pp.yaw_map,'*','Color',col.pointpillars,'DisplayName','Lidar PP')
plot(cam_yolo.sens_stamp,cam_yolo.yaw_map,'*','Color',col.camera,'DisplayName','Camera Yolo')
xlim(x_lim); grid on; title('yaw_map [deg]');

% count
axes(f) = nexttile([1,1]); f=f+1; hold on;
area(tt_stamp,log.perception__opponents.opponents__rad_clust_meas(:,1:max_opp),'FaceColor',col.radar,'EdgeColor',col.radar,'DisplayName','Rad Clust');
area(tt_stamp,log.perception__opponents.opponents__lid_pp_meas(:,1:max_opp),'FaceColor',col.pointpillars,'EdgeColor',col.pointpillars,'DisplayName','Lid PP');
area(tt_stamp,log.perception__opponents.opponents__lid_clust_meas(:,1:max_opp),'FaceColor',col.lidar,'EdgeColor',col.lidar,'DisplayName','Lid Clust');
area(tt_stamp,log.perception__opponents.opponents__cam_yolo_meas(:,1:max_opp),'FaceColor',col.camera,'EdgeColor',col.camera,'DisplayName','Camera');
grid on; grid on; title('Associated Measures Count');

%% DETECTIONS FIGURE - RANGE

figure('Name','Detections - Range')
tiledlayout(2,1,'Padding','compact')

% Rho 
axes(f) = nexttile([1,1]); f=f+1; hold on;
plot(gt.stamp,gt.rho,'Color',col.ref,'DisplayName','Ground Truth')
plot(lid_clust.sens_stamp,lid_clust.range,'*','Color',col.lidar,'DisplayName','Lidar Clust')
plot(rad_clust.sens_stamp,rad_clust.range,'*','Color',col.radar,'DisplayName','Radar Clust')
plot(lid_pp.sens_stamp,lid_pp.range,'*','Color',col.pointpillars,'DisplayName','Lidar PP')
plot(cam_yolo.sens_stamp,cam_yolo.range,'*','Color',col.camera,'DisplayName','Camera Yolo')
title("range [m]"); xlim(x_lim); ylim([0 200]); grid on; xlabel('time [s]'); ylabel('range [m]')

% Rho Dot 
axes(f) = nexttile([1,1]); f=f+1; hold on;
plot(gt.stamp,gt.rho_dot,'Color',col.ref,'DisplayName','Ground Truth');
scatter(rad_clust.sens_stamp,rad_clust.rho_dot,'diamond','MarkerEdgeColor',col.radar,'DisplayName','Radar Clust')
title("range rate [m/s]"); xlim(x_lim); grid on; xlabel('time [s]'); ylabel('range rate [m/s]')

%% AUXILIARY FIGURES

compute_perception_error;
error_summary;
error_series;
correlation_fig;

linkaxes(axes,'x');

%% FOV

[fov.cam_x,fov.cam_y]  = compute_fov(85,0);
[fov.lid_x,fov.lid_y]  = compute_fov(10,179);
[fov.rad_x,fov.rad_y]  = compute_fov(90,0);

[range.x_25m, range.y_25m] = calculate_ellipse(25,25,0,0); 
[range.x_50m, range.y_50m] = calculate_ellipse(50,50,0,0); 
[range.x_75m, range.y_75m] = calculate_ellipse(75,75,0,0); 
[range.x_100m, range.y_100m] = calculate_ellipse(100,100,0,0); 

fov_fig = figure('name','FOV');

l = uicontrol('Style','pushbutton');
l.String = {'Refresh'};
l.Callback = @fovButtonPushed;

function fovButtonPushed(~,~)
    axes = evalin('base', 'axes');
    col = evalin('base', 'col');
    lid_clust = evalin('base', 'lid_clust');
    rad_clust = evalin('base', 'rad_clust');
    cam_yolo = evalin('base', 'cam_yolo');
    lid_pp = evalin('base', 'lid_pp');
    fov = evalin('base', 'fov');
    range = evalin('base', 'range');
  
    t_lim=xlim(axes(1));
    t1_lid_clust = find(lid_clust.sens_stamp>t_lim(1),1);
    tend_lid_clust = find(lid_clust.sens_stamp<t_lim(2),1,'last');
    t1_rad_clust = find(rad_clust.sens_stamp>t_lim(1),1);
    tend_rad_clust = find(rad_clust.sens_stamp<t_lim(2),1,'last');
    t1_cam_yolo = find(cam_yolo.sens_stamp>t_lim(1),1);
    tend_cam_yolo = find(cam_yolo.sens_stamp<t_lim(2),1,'last');
    t1_lid_pp = find(lid_pp.sens_stamp>t_lim(1),1);
    tend_lid_pp = find(lid_pp.sens_stamp<t_lim(2),1,'last');

    % Sensor Plot
    subplot(1,2,1)
    cla reset 
    ax1 = gca;
    title('Map')
    legend('Location','west')
    hold on
    grid on
    xlabel('y[m]')
    ylabel('x[m]')
    axis equal

    plot(lid_pp.y_rel(t1_lid_pp:tend_lid_pp),lid_pp.x_rel(t1_lid_pp:tend_lid_pp),'*','Color',col.pointpillars,'DisplayName','Lidar PP')
    plot(lid_clust.y_rel(t1_lid_clust:tend_lid_clust),lid_clust.x_rel(t1_lid_clust:tend_lid_clust),'*','Color',col.lidar,'DisplayName','Lidar Clust')
    plot(rad_clust.y_rel(t1_rad_clust:tend_rad_clust),rad_clust.x_rel(t1_rad_clust:tend_rad_clust),'*','Color',col.radar,'DisplayName','Radar Clust')
    plot(cam_yolo.y_rel(t1_cam_yolo:tend_cam_yolo),cam_yolo.x_rel(t1_cam_yolo:tend_cam_yolo),'*','Color',col.camera,'DisplayName','Camera Yolo')

    plot(fov.rad_y,fov.rad_x,'-','LineWidth',0.5,'Color',col.radar,'HandleVisibility','off')
    plot(fov.rad_y,-fov.rad_x,'-','LineWidth',0.5,'Color',col.radar,'HandleVisibility','off')
    plot(fov.lid_y,fov.lid_x,'-','LineWidth',0.5,'Color',col.lidar,'HandleVisibility','off')
    plot(fov.cam_y,fov.cam_x,'-','LineWidth',0.5,'Color',col.camera,'HandleVisibility','off')
    plot(fov.cam_y,-fov.cam_x,'-','LineWidth',0.5,'Color',col.camera,'HandleVisibility','off')

    plot(range.x_25m,range.y_25m,'--','LineWidth',0.3,'Color',[0.5 0.5 0.5],'HandleVisibility','off')
    plot(range.x_50m,range.y_50m,'--','LineWidth',0.3,'Color',[0.5 0.5 0.5],'HandleVisibility','off')
    plot(range.x_75m,range.y_75m,'--','LineWidth',0.3,'Color',[0.5 0.5 0.5],'HandleVisibility','off')
    plot(range.x_100m,range.y_100m,'--','LineWidth',0.3,'Color',[0.5 0.5 0.5],'HandleVisibility','off')
    plot(0,0,'d','Color','default','LineWidth',1,'DisplayName','Ego','MarkerSize',10)

    % Intensity Plot
    subplot(1,2,2)
    cla reset
    ylabel('X [m]')
    xlabel('Y [m]')
    grid on;
    axis equal
    title('Detection Error')
    ax2 = gca;
    hold on

    camera_err = sqrt(cam_yolo.x_map_err.^2+cam_yolo.y_map_err.^2);
    lid_err = sqrt(lid_clust.x_map_err.^2+lid_clust.y_map_err.^2);
    pp_err = sqrt(lid_pp.x_map_err.^2+lid_pp.y_map_err.^2);
    rad_err = sqrt(rad_clust.x_map_err.^2+rad_clust.y_map_err.^2);

    scatter(cam_yolo.y_rel(t1_cam_yolo:tend_cam_yolo),cam_yolo.x_rel(t1_cam_yolo:tend_cam_yolo),[],camera_err(t1_cam_yolo:tend_cam_yolo),'filled','o','DisplayName','Camera Yolo')
    scatter(lid_clust.y_rel(t1_lid_clust:tend_lid_clust),lid_clust.x_rel(t1_lid_clust:tend_lid_clust),[],lid_err(t1_lid_clust:tend_lid_clust),'filled','square','DisplayName','Lid Clust')
    scatter(lid_pp.y_rel(t1_lid_pp:tend_lid_pp),lid_pp.x_rel(t1_lid_pp:tend_lid_pp),[],pp_err(t1_lid_pp:tend_lid_pp),'filled','^','DisplayName','Lid PP')
    scatter(rad_clust.y_rel(t1_rad_clust:tend_rad_clust),rad_clust.x_rel(t1_rad_clust:tend_rad_clust),[],rad_err(t1_rad_clust:tend_rad_clust),'filled','diamond','DisplayName','Rad Clust')

    plot(range.x_25m,range.y_25m,'--','LineWidth',0.3,'Color',[0.5 0.5 0.5],'HandleVisibility','off')
    plot(range.x_50m,range.y_50m,'--','LineWidth',0.3,'Color',[0.5 0.5 0.5],'HandleVisibility','off')
    plot(range.x_75m,range.y_75m,'--','LineWidth',0.3,'Color',[0.5 0.5 0.5],'HandleVisibility','off')
    plot(range.x_100m,range.y_100m,'--','LineWidth',0.3,'Color',[0.5 0.5 0.5],'HandleVisibility','off')
    plot(0,0,'d','Color','default','LineWidth',1,'DisplayName','Ego','MarkerSize',10)

    colorbar('Location','eastoutside');
    colormap('jet');
    clim([0 3]);
    ax1Pos = get(ax1, 'Position');
    ax2Pos = get(ax2, 'Position');
    ax2Pos(3:4) = ax1Pos(3:4);
    set(ax2, 'Position', ax2Pos);
    colorbar('Position', [0.93 0.15 0.02 0.7]);  % normalized 
    legend('Location','west')

    linkaxes([ax1,ax2],'xy')
end

%% MAP
fig = figure('name','MAP');

c = uicontrol('Style','pushbutton');
c.String = {'Refresh'};
c.Callback = @mapButtonPushed;

function mapButtonPushed(~,~)
    axes = evalin('base', 'axes');
    traj_db = evalin('base', 'trajDatabase');
    col = evalin('base', 'col');
    lid_clust = evalin('base', 'lid_clust');
    rad_clust = evalin('base', 'rad_clust');
    cam_yolo = evalin('base', 'cam_yolo');
    lid_pp = evalin('base', 'lid_pp');
    gt = evalin('base','gt');
  
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
