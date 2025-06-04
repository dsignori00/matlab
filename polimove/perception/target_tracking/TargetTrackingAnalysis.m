close all
clearvars -except log log_ref trajDatabase

use_ref = false;
use_sim_ref = false;
imm = false;

%% Paths

addpath("../../common/personal/")
addpath("../../common/utilities/")
addpath("../../common/constants/")
addpath("../../common/plot/")
normal_path = "/home/daniele/Documents/PoliMOVE/04_Bags/";

%% Load Data

%load database
if(~exist('trajDatabase','var'))
    trajDatabase = ChooseDatabase();
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

% load log ref
if(use_ref)
    if  (~exist('log_ref','var')) %#ok<*UNRCH>
        [file,path] = uigetfile(fullfile(normal_path,'*.mat'),'Load ground truth');
        tmp = load(fullfile(path,file));
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
col.tt = '#0072BD';
col.lidar = '#77AC30';
col.radar = '#4DBEEE';
col.camera = '#EDB120';
col.pointpillars = '#D95319';
col.ref = '#000000';
sz=3; % Marker size
f=1;


% LIDAR CLUSTERING DETECTIONS
lid_clust_sens_stamp = log.perception__lidar__clustering_detections.sensor_stamp__tot;
% relative
lid_clust_x_rel = log.perception__lidar__clustering_detections.detections__x_rel;
lid_clust_y_rel = log.perception__lidar__clustering_detections.detections__y_rel;
lid_clust_x_rel(lid_clust_x_rel==0)=nan;
lid_clust_y_rel(lid_clust_y_rel==0)=nan;
% map
lid_clust_x_map = log.perception__lidar__clustering_detections.detections__x_map;
lid_clust_y_map = log.perception__lidar__clustering_detections.detections__y_map;
lid_clust_yaw_map = log.perception__lidar__clustering_detections.detections__yaw_map;
lid_clust_x_map(lid_clust_x_map==0)=nan;
lid_clust_y_map(lid_clust_y_map==0)=nan;
lid_clust_yaw_map(lid_clust_yaw_map==0)=nan;

% RADAR CLUSTERING DETECTIONS
rad_clust_sens_stamp = log.perception__radar__clustering_detections.sensor_stamp__tot;
% relative
rad_clust_x_rel = log.perception__radar__clustering_detections.detections__x_rel;
rad_clust_y_rel = log.perception__radar__clustering_detections.detections__y_rel;
rad_clust_x_rel(rad_clust_x_rel==0)=nan;
rad_clust_y_rel(rad_clust_y_rel==0)=nan;
rad_clust_rho_dot = log.perception__radar__clustering_detections.detections__rho_dot;
rad_clust_rho_dot(rad_clust_rho_dot==0)=nan;
% map
rad_clust_x_map = log.perception__radar__clustering_detections.detections__x_map;
rad_clust_y_map = log.perception__radar__clustering_detections.detections__y_map;
rad_clust_yaw_map = log.perception__radar__clustering_detections.detections__yaw_map;
rad_clust_x_map(rad_clust_x_map==0)=nan;
rad_clust_y_map(rad_clust_y_map==0)=nan;
rad_clust_yaw_map(rad_clust_yaw_map==0)=nan;

% CAMERA CLUSTERING DETECTIONS
cam_yolo_sens_stamp = log.perception__camera__yolo_detections.sensor_stamp__tot;
% relative
cam_yolo_x_rel = log.perception__camera__yolo_detections.detections__x_rel;
cam_yolo_y_rel = log.perception__camera__yolo_detections.detections__y_rel;
cam_yolo_x_rel(cam_yolo_x_rel==0)=nan;
cam_yolo_y_rel(cam_yolo_y_rel==0)=nan;
% map
cam_yolo_x_map = log.perception__camera__yolo_detections.detections__x_map;
cam_yolo_y_map = log.perception__camera__yolo_detections.detections__y_map;
cam_yolo_yaw_map = log.perception__camera__yolo_detections.detections__yaw_map;
cam_yolo_x_map(cam_yolo_x_map==0)=nan;
cam_yolo_y_map(cam_yolo_y_map==0)=nan;
cam_yolo_yaw_map(cam_yolo_yaw_map==0)=nan;

% LIDAR POINTPILLARS DETECTIONS
lid_pp_sens_stamp = log.perception__lidar__pointpillars_detections.sensor_stamp__tot;
% relative
lid_pp_x_rel = log.perception__lidar__pointpillars_detections.detections__x_rel;
lid_pp_y_rel = log.perception__lidar__pointpillars_detections.detections__y_rel;
lid_pp_x_rel(lid_pp_x_rel==0)=nan;
lid_pp_y_rel(lid_pp_y_rel==0)=nan;
% map
lid_pp_x_map = log.perception__lidar__pointpillars_detections.detections__x_map;
lid_pp_y_map = log.perception__lidar__pointpillars_detections.detections__y_map;
lid_pp_yaw_map = log.perception__lidar__pointpillars_detections.detections__yaw_map;
lid_pp_x_map(lid_pp_x_map==0)=nan;
lid_pp_y_map(lid_pp_y_map==0)=nan;
lid_pp_yaw_map(lid_pp_yaw_map==0)=nan;

% TARGET TRACKING MAIN
tt_stamp = log.perception__opponents.stamp__tot;
% relative
tt_x_rel = log.perception__opponents.opponents__x_rel;
tt_y_rel = log.perception__opponents.opponents__y_rel;
tt_x_rel(tt_x_rel==0)=nan;
tt_y_rel(tt_y_rel==0)=nan;
tt_rho_dot = log.perception__opponents.opponents__rho_dot;
tt_rho_dot(tt_rho_dot==0)=nan;
tt_yaw_rel = log.perception__opponents.opponents__psi_rel;
tt_yaw_rel(tt_yaw_rel==0)=nan;
% map
tt_x_map = log.perception__opponents.opponents__x_geom;
tt_y_map = log.perception__opponents.opponents__y_geom;
tt_x_map(tt_x_map==0)=nan;
tt_y_map(tt_y_map==0)=nan;
tt_vx = log.perception__opponents.opponents__vx;
tt_vx(tt_vx==0)=nan;
tt_ax = log.perception__opponents.opponents__ax;
tt_ax(tt_ax==0)=nan;
tt_yaw_map = log.perception__opponents.opponents__psi;
tt_yaw_map(tt_yaw_map==0)=nan;
tt_count = log.perception__opponents.count;
max_opp = max(tt_count);

% GROUND TRUTH
if(use_sim_ref)
    tt_stamp_ref = log.sim_out.bag_stamp;
    % relative
    tt_x_rel_ref = log.sim_out.opponents__x_rel(:,1);
    tt_y_rel_ref = log.sim_out.opponents__y_rel(:,1);
    tt_rho_dot_ref = log.sim_out.opponents__rho_dot(:,1);
    % map
    tt_x_map_ref = log.sim_out.opponents__x_geom(:,1);
    tt_y_map_ref = log.sim_out.opponents__y_geom(:,1);
    tt_vx_ref = log.sim_out.opponents__vx(:,1);
    tt_ax_ref = log.sim_out.opponents__ax(:,1);
    tt_yaw_map_ref = log.sim_out.opponents__psi(:,1);
    tt_yaw_map_ref = deg2rad(UnwrapPi(rad2deg(tt_yaw_map_ref)));
elseif(use_ref)
    tt_stamp_ref = (log_ref.timestamp - double(log.time_offset_nsec))*1e-9;
    % relative
    tt_x_rel_ref = log_ref.x_rel;
    tt_y_rel_ref = log_ref.y_rel;
    tt_rho_dot_ref = log_ref.rho_dot;
    % map
    tt_x_map_ref = log_ref.x_map;
    tt_y_map_ref = log_ref.y_map;
    tt_vx_ref = log_ref.speed;
    tt_yaw_map_ref = log_ref.yaw_map;
end


% %% INFO
% figure('Name','Info');
% tiledlayout(3,1,'Padding','compact');
% 
% % racetype
% axes(f) = nexttile([1,1]);
% f=f+1;
% hold on;
% plot(log.planning__race_type.bag_stamp, log.planning__race_type.type,'Color',col.tt);
% ylim([-1 5])
% grid on;
% title('RaceType');
% 
% % count
% axes(f) = nexttile([1,1]);
% f=f+1;
% hold on;
% area(tt_stamp,log.perception__opponents.opponents__rad_clust_meas(:,1:max_opp),'FaceColor',col.radar,'EdgeColor',col.radar,'DisplayName','Rad Clust');
% area(tt_stamp,log.perception__opponents.opponents__lid_pp_meas(:,1:max_opp),'FaceColor',col.pointpillars,'EdgeColor',col.pointpillars,'DisplayName','Lid PP');
% area(tt_stamp,log.perception__opponents.opponents__lid_clust_meas(:,1:max_opp),'FaceColor',col.lidar,'EdgeColor',col.lidar,'DisplayName','Lid Clust');
% area(tt_stamp,log.perception__opponents.opponents__cam_yolo_meas(:,1:max_opp),'FaceColor',col.camera,'EdgeColor',col.camera,'DisplayName','Camera');
% grid on;
% title('Count')
% legend
% 
% % decision maker
% axes(f) = nexttile([1,1]);
% f=f+1;
% hold on;
% plot(log.decision_maker.bag_stamp, log.decision_maker.current_state__type, 'Color',col.tt);
% yticks(0:4);
% yticklabels({'RACING','TAILGATING','OVERTAKE','ABORT','CRITICAL'});
% ylim([-1 5])
% grid on;
% title('Decision Maker state')
% 
% linkaxes(axes,'x')


%% STATE FIGURE REL
figure('name', 'State Rel');
tiledlayout(3,2,'Padding','compact');

% pos x
axes(f) = nexttile([1,1]);
f=f+1;
hold on;
plot(lid_clust_sens_stamp,lid_clust_x_rel(:,1:max_opp),'o','MarkerFaceColor',col.lidar,'MarkerEdgeColor',col.lidar,'MarkerSize',sz,'DisplayName','Lid Clust');
plot(rad_clust_sens_stamp,rad_clust_x_rel(:,1:max_opp),'o','MarkerFaceColor',col.radar,'MarkerEdgeColor',col.radar,'MarkerSize',sz,'DisplayName','Rad Clust');
plot(cam_yolo_sens_stamp,cam_yolo_x_rel(:,1:max_opp),'o','MarkerFaceColor',col.camera,'MarkerEdgeColor',col.camera,'MarkerSize',sz,'DisplayName','Camera');
plot(lid_pp_sens_stamp,lid_pp_x_rel(:,1:max_opp),'o','MarkerFaceColor',col.pointpillars,'MarkerEdgeColor',col.pointpillars,'MarkerSize',sz,'DisplayName','Lid PP');
plot(tt_stamp, tt_x_rel(:,1:max_opp), 'Color',col.tt,'DisplayName','tt');
if(use_ref || use_sim_ref)
    plot(tt_stamp_ref, tt_x_rel_ref, 'Color',col.ref,'DisplayName','Ground Truth');
end
grid on;
title('x rel [m]');
legend

% pos y
axes(f) = nexttile([1,1]);
f=f+1;
hold on;
plot(lid_clust_sens_stamp,lid_clust_y_rel(:,1:max_opp),'o','MarkerFaceColor',col.lidar,'MarkerEdgeColor',col.lidar,'MarkerSize',sz,'DisplayName','Lid Clust');
plot(rad_clust_sens_stamp,rad_clust_y_rel(:,1:max_opp),'o','MarkerFaceColor',col.radar,'MarkerEdgeColor',col.radar,'MarkerSize',sz,'DisplayName','Rad Clust');
plot(cam_yolo_sens_stamp,cam_yolo_y_rel(:,1:max_opp),'o','MarkerFaceColor',col.camera,'MarkerEdgeColor',col.camera,'MarkerSize',sz,'DisplayName','Camera');
plot(lid_pp_sens_stamp,lid_pp_y_rel(:,1:max_opp),'o','MarkerFaceColor',col.pointpillars,'MarkerEdgeColor',col.pointpillars,'MarkerSize',sz,'DisplayName','Lid PP');
plot(tt_stamp, tt_y_rel(:,1:max_opp), 'Color',col.tt,'DisplayName','tt');
if(use_ref || use_sim_ref)
    plot(tt_stamp_ref, tt_y_rel_ref, 'Color',col.ref,'DisplayName','Ground Truth');
end
grid on;
title('y rel [m]');
legend

% rho dot
axes(f) = nexttile([1,2]);
f=f+1;
hold on;
plot(rad_clust_sens_stamp,rad_clust_rho_dot(:,1:max_opp),'o','MarkerFaceColor',col.radar,'MarkerEdgeColor',col.radar,'MarkerSize',sz,'DisplayName','Rad Clust');
plot(tt_stamp, tt_rho_dot(:,1:max_opp), 'Color',col.tt,'DisplayName','tt');
if(use_ref || use_sim_ref)
    plot(tt_stamp_ref, tt_rho_dot_ref, 'Color',col.ref,'DisplayName','Ground Truth');
end
grid on;
title('rho dot [m/s]');
legend

% count
axes(f) = nexttile([1,2]);
f=f+1;
hold on;
area(tt_stamp,log.perception__opponents.opponents__rad_clust_meas(:,1:max_opp),'FaceColor',col.radar,'EdgeColor',col.radar,'DisplayName','Rad Clust');
area(tt_stamp,log.perception__opponents.opponents__lid_pp_meas(:,1:max_opp),'FaceColor',col.pointpillars,'EdgeColor',col.pointpillars,'DisplayName','Lid PP');
area(tt_stamp,log.perception__opponents.opponents__lid_clust_meas(:,1:max_opp),'FaceColor',col.lidar,'EdgeColor',col.lidar,'DisplayName','Lid Clust');
area(tt_stamp,log.perception__opponents.opponents__cam_yolo_meas(:,1:max_opp),'FaceColor',col.camera,'EdgeColor',col.camera,'DisplayName','Camera');
grid on;
title('Count')
linkaxes(axes,'x')
legend


%% STATE FIGURE MAP
figure('name', 'State Map');
tiledlayout(3,2,'Padding','compact');

% pos X
axes(f) = nexttile([1,1]);
f=f+1;
hold on;
plot(lid_clust_sens_stamp,lid_clust_x_map(:,1:max_opp),'o','MarkerFaceColor',col.lidar,'MarkerEdgeColor',col.lidar,'MarkerSize',sz,'DisplayName','Lid Clust');
plot(rad_clust_sens_stamp,rad_clust_x_map(:,1:max_opp),'o','MarkerFaceColor',col.radar,'MarkerEdgeColor',col.radar,'MarkerSize',sz,'DisplayName','Rad Clust');
plot(cam_yolo_sens_stamp,cam_yolo_x_map(:,1:max_opp),'o','MarkerFaceColor',col.camera,'MarkerEdgeColor',col.camera,'MarkerSize',sz,'DisplayName','Camera');
plot(lid_pp_sens_stamp,lid_pp_x_map(:,1:max_opp),'o','MarkerFaceColor',col.pointpillars,'MarkerEdgeColor',col.pointpillars,'MarkerSize',sz,'DisplayName','Lid PP');
plot(tt_stamp,tt_x_map(:,1:max_opp),'Color',col.tt,'DisplayName','tt');
if(use_ref || use_sim_ref)
    plot(tt_stamp_ref,tt_x_map_ref,'Color',col.ref,'DisplayName','Ground Truth');
end
grid on;
title('x map [m]');
legend

% pos y
axes(f) = nexttile([1,1]);
f=f+1;
hold on;
plot(lid_clust_sens_stamp,lid_clust_y_map(:,1:max_opp),'o','MarkerFaceColor',col.lidar,'MarkerEdgeColor',col.lidar,'MarkerSize',sz,'DisplayName','Lid Clust');
plot(rad_clust_sens_stamp,rad_clust_y_map(:,1:max_opp),'o','MarkerFaceColor',col.radar,'MarkerEdgeColor',col.radar,'MarkerSize',sz,'DisplayName','Rad Clust');
plot(cam_yolo_sens_stamp,cam_yolo_y_map(:,1:max_opp),'o','MarkerFaceColor',col.camera,'MarkerEdgeColor',col.camera,'MarkerSize',sz,'DisplayName','Camera');
plot(lid_pp_sens_stamp,lid_pp_y_map(:,1:max_opp),'o','MarkerFaceColor',col.pointpillars,'MarkerEdgeColor',col.pointpillars,'MarkerSize',sz,'DisplayName','Lid PP');
plot(tt_stamp,tt_y_map(:,1:max_opp),'Color',col.tt,'DisplayName','tt');
if(use_ref || use_sim_ref)
    plot(tt_stamp_ref,tt_y_map_ref,'Color',col.ref,'DisplayName','Ground Truth');
end
grid on;
title('y map [m]');
legend

% vx
axes(f) = nexttile([1,1]);
f=f+1;
hold on;
plot(tt_stamp,tt_vx(:,1:max_opp),'Color',col.tt,'DisplayName','tt');
if(use_ref || use_sim_ref)
    plot(tt_stamp_ref,tt_vx_ref,'Color',col.ref,'DisplayName','Ground Truth');
end
grid on;
title('vx [m/s]');
legend

% ax
axes(f) = nexttile([1,1]);
f=f+1;
hold on;
plot(tt_stamp,tt_ax(:,1:max_opp),'Color',col.tt,'DisplayName','tt');
if(use_sim_ref)
    plot(tt_stamp_ref,tt_ax_ref,'Color',col.ref,'DisplayName','Ground Truth');
end
grid on;
title('ax [m/s^2]');
legend

% yaw
axes(f) = nexttile([1,2]);
f=f+1;
tt_yaw_map = mod(tt_yaw_map,2*pi);
lid_clust_yaw_map = mod(lid_clust_yaw_map,2*pi);
cam_yolo_yaw_map = mod(cam_yolo_yaw_map,2*pi);
rad_clust_yaw_map = mod(rad_clust_yaw_map,2*pi);
lid_pp_yaw_map = mod(lid_pp_yaw_map,2*pi);

hold on;
plot(lid_clust_sens_stamp,lid_clust_yaw_map(:,1:max_opp),'o','MarkerFaceColor',col.lidar,'MarkerEdgeColor',col.lidar,'MarkerSize',sz,'DisplayName','Lid Clust');
plot(rad_clust_sens_stamp,rad_clust_yaw_map(:,1:max_opp),'o','MarkerFaceColor',col.radar,'MarkerEdgeColor',col.radar,'MarkerSize',sz,'DisplayName','Rad Clust');
plot(cam_yolo_sens_stamp,cam_yolo_yaw_map(:,1:max_opp),'o','MarkerFaceColor',col.camera,'MarkerEdgeColor',col.camera,'MarkerSize',sz,'DisplayName','Camera');
plot(lid_pp_sens_stamp,lid_pp_yaw_map(:,1:max_opp),'o','MarkerFaceColor',col.pointpillars,'MarkerEdgeColor',col.pointpillars,'MarkerSize',sz,'DisplayName','Lidar PP');
plot(tt_stamp,tt_yaw_map(:,1:max_opp),'Color',col.tt,'DisplayName','tt');
if(use_ref || use_sim_ref)
    tt_yaw_map_ref = mod(tt_yaw_map_ref,2*pi);
    plot(tt_stamp_ref,tt_yaw_map_ref,'Color',col.ref,'DisplayName','Ground Truth');
end
grid on;
title('yaw [deg]');
linkaxes(axes,'x')
legend



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
xlim([0 inf])

%% MAP
fig = figure('name','MAP');

c = uicontrol('Style','pushbutton');
c.String = {'Refresh'};
c.Callback = @refreshTimeButtonPushed;


function refreshTimeButtonPushed(~,~)
    axes = evalin('base', 'axes');
    traj_db = evalin('base', 'trajDatabase');
    use_ref = evalin('base', 'use_ref');
    use_sim_ref = evalin('base', 'use_sim_ref');
    col.lidar = evalin('base', 'col.lidar');
    col.radar = evalin('base', 'col.radar');
    col.camera = evalin('base', 'col.camera');
    col.pointpillars = evalin('base', 'col.pointpillars');
    col.tt = evalin('base', 'col.tt');
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
    tt_stamp=evalin('base','tt_stamp');
    tt_x_map = evalin('base', 'tt_x_map');
    tt_y_map = evalin('base', 'tt_y_map');
    if(use_ref || use_sim_ref)
        tt_stamp_ref=evalin('base','tt_stamp_ref');
        tt_x_map_ref = evalin('base', 'tt_x_map_ref');
        tt_y_map_ref = evalin('base', 'tt_y_map_ref');
    end


    t_lim=xlim(axes(1));
    t1_lid_clust = find(lid_clust_sens_stamp>t_lim(1),1);
    tend_lid_clust = find(lid_clust_sens_stamp<t_lim(2),1,'last');
    t1_rad_clust = find(rad_clust_sens_stamp>t_lim(1),1);
    tend_rad_clust = find(rad_clust_sens_stamp<t_lim(2),1,'last');
    t1_cam_yolo = find(cam_yolo_sens_stamp>t_lim(1),1);
    tend_cam_yolo = find(cam_yolo_sens_stamp<t_lim(2),1,'last');
    t1_lid_pp = find(lid_pp_sens_stamp>t_lim(1),1);
    tend_lid_pp = find(lid_pp_sens_stamp<t_lim(2),1,'last');
    t1_tt = find(tt_stamp>t_lim(1),1);
    tend_tt = find(tt_stamp<t_lim(2),1,'last');
    if(use_ref || use_sim_ref)
        t1_tt_ref = find(tt_stamp_ref>t_lim(1),1);
        tend_tt_ref = find(tt_stamp_ref<t_lim(2),1,'last');
    end

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
    plot(tt_x_map(t1_tt:tend_tt),tt_y_map(t1_tt:tend_tt),'Color',col.tt,'DisplayName','tt');
    if(use_ref || use_sim_ref)
        plot(tt_x_map_ref(t1_tt_ref:tend_tt_ref),tt_y_map_ref(t1_tt_ref:tend_tt_ref),'Color',col.ref,'DisplayName','Grond Truth');
    end
    legend show
end

%% FIGURE IMM
if(imm)
    figure('name','Imm')
    tiledlayout(3,1,'Padding','compact');
    
    % vx
    axes(f) = nexttile([1,1]);
    f=f+1;
    hold on;
    plot(tt_stamp,tt_vx(:,1:max_opp),'Color',col.tt,'DisplayName','tt');
    if(use_ref || use_sim_ref)
        plot(tt_stamp_ref,tt_vx_ref,'Color',col.ref,'DisplayName','Ground Truth');
    end
    grid on;
    title('vx [m/s]');
    legend
    
    % ax
    axes(f) = nexttile([1,1]);
    f=f+1;
    hold on;
    plot(tt_stamp,tt_ax(:,1:max_opp),'Color',col.tt,'DisplayName','tt');
    if(use_sim_ref)
        plot(tt_stamp_ref,tt_ax_ref,'Color',col.ref,'DisplayName','Ground Truth');
    end
    grid on;
    title('ax [m/s^2]');
    legend
    
    axes(f) = nexttile([1,1]);
    f=f+1;
    hold on;
    plot(tt_stamp,log.perception__opponents.opponents__ctra_prob(:,1:max_opp),'Color',col.radar,'DisplayName','CTRA');
    plot(tt_stamp,log.perception__opponents.opponents__ctrv_prob(:,1:max_opp),'Color',col.pointpillars,'DisplayName','CTRV');
    plot(tt_stamp,log.perception__opponents.opponents__cm_acc_prob(:,1:max_opp),'Color',col.lidar,'DisplayName','CONST ACC');
    plot(tt_stamp,log.perception__opponents.opponents__cm_dec_prob(:,1:max_opp),'Color',col.camera,'DisplayName','CONST DEC');
    grid on;
    title('Model Prob')
    linkaxes(axes,'x')
    legend
end