close all
clearvars -except log log_ref trajDatabase

use_ref = true;
use_sim_ref = false;
imm = false;

%#ok<*UNRCH>
%#ok<*INUSD>

%% Paths

addpath("../../common/utilities/")
addpath("../../common/constants/")
addpath("../../common/plot/")
addpath("../utils/")
normal_path = "../../bags";
opp_dir = "../opponent_gps/mat/";

%% Load Data

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

% load log ref
if(use_ref)
    if  (~exist('log_ref','var'))
        [file,path] = uigetfile(fullfile(opp_dir,'*.mat'),'Load ground truth');
        tmp = load(fullfile(path,file));
        log_ref = tmp.out;
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
x_lim = [0 inf];

load_perception;
cam_yolo.sens_stamp(cam_yolo.sens_stamp < 0) = NaN;

% TARGET TRACKING MAIN
tt.stamp = log.perception__opponents.stamp__tot;
% relative
tt.x_rel = log.perception__opponents.opponents__x_rel;
tt.y_rel = log.perception__opponents.opponents__y_rel;
tt.x_rel(tt.x_rel==0)=nan;
tt.y_rel(tt.y_rel==0)=nan;
tt.rho_dot = log.perception__opponents.opponents__rho_dot;
tt.rho_dot(tt.rho_dot==0)=nan;
tt.yaw_rel = log.perception__opponents.opponents__psi_rel;
tt.yaw_rel(tt.yaw_rel==0)=nan;
% map
tt.x_map = log.perception__opponents.opponents__x_geom;
tt.y_map = log.perception__opponents.opponents__y_geom;
tt.x_map(tt.x_map==0)=nan;
tt.y_map(tt.y_map==0)=nan;
tt.vx = log.perception__opponents.opponents__vx;
tt.vx(tt.vx==0)=nan;
tt.ax = log.perception__opponents.opponents__ax;
tt.ax(tt.ax==0)=nan;
tt.yaw_map = log.perception__opponents.opponents__psi;
tt.yaw_map(tt.yaw_map==0)=nan;
tt.count = log.perception__opponents.count;
max_opp = max(tt.count);

% Range Computation
lid_clust.range = sqrt(lid_clust.x_rel.^2 + lid_clust.y_rel.^2);
rad_clust.range = sqrt(rad_clust.x_rel.^2 + rad_clust.y_rel.^2);
cam_yolo.range = sqrt(cam_yolo.x_rel.^2 + cam_yolo.y_rel.^2);
lid_pp.range = sqrt(lid_pp.x_rel.^2 + lid_pp.y_rel.^2);
tt.range = sqrt(tt.x_rel.^2 + tt.y_rel.^2);

%% INFO
figure('Name','Info');

if(exist("log.planner_manager","var"))
    % racetype
    tiledlayout(2,1,'Padding','compact');
    axes(f) = nexttile([1,1]); f=f+1; hold on;
    plot(log.planner_manager.stamp__tot, log.planner_manager.race_type,'Color',col.tt);
    ylim([-1 5]); grid on; title('RaceType');
end

% decision maker
axes(f) = nexttile([1,1]); f=f+1; hold on;
plot(log.decision_maker.stamp__tot, log.decision_maker.current_state__type, 'Color',col.tt);
yticks(0:4);
yticklabels({'RACING','TAILGATING','OVERTAKE','ABORT','CRITICAL'});
ylim([-1 5]); grid on; title('Decision Maker state');


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

%% STATE FIGURE MAP
figure('name', 'Filter - Map');
tiledlayout(2,1,'Padding','compact');

% pos x
axes(f) = nexttile([1,1]); f=f+1; hold on;
plot(lid_clust.sens_stamp,lid_clust.x_map(:,1:max_opp),'o','MarkerFaceColor',col.lidar,'MarkerEdgeColor',col.lidar,'MarkerSize',sz,'DisplayName','Lid Clust');
plot(rad_clust.sens_stamp,rad_clust.x_map(:,1:max_opp),'o','MarkerFaceColor',col.radar,'MarkerEdgeColor',col.radar,'MarkerSize',sz,'DisplayName','Rad Clust');
plot(cam_yolo.sens_stamp,cam_yolo.x_map(:,1:max_opp),'o','MarkerFaceColor',col.camera,'MarkerEdgeColor',col.camera,'MarkerSize',sz,'DisplayName','Camera');
plot(lid_pp.sens_stamp,lid_pp.x_map(:,1:max_opp),'o','MarkerFaceColor',col.pointpillars,'MarkerEdgeColor',col.pointpillars,'MarkerSize',sz,'DisplayName','Lid PP');
plot(tt.stamp,tt.x_map(:,1:max_opp),'Color',col.tt,'DisplayName','tt');
if(use_ref || use_sim_ref); plot(gt.stamp,gt.x_map,'Color',col.ref,'DisplayName','Ground Truth'); end
grid on; title('x map [m]'); 

% pos y
axes(f) = nexttile([1,1]); f=f+1; hold on;
plot(lid_clust.sens_stamp,lid_clust.y_map(:,1:max_opp),'o','MarkerFaceColor',col.lidar,'MarkerEdgeColor',col.lidar,'MarkerSize',sz,'DisplayName','Lid Clust');
plot(rad_clust.sens_stamp,rad_clust.y_map(:,1:max_opp),'o','MarkerFaceColor',col.radar,'MarkerEdgeColor',col.radar,'MarkerSize',sz,'DisplayName','Rad Clust');
plot(cam_yolo.sens_stamp,cam_yolo.y_map(:,1:max_opp),'o','MarkerFaceColor',col.camera,'MarkerEdgeColor',col.camera,'MarkerSize',sz,'DisplayName','Camera');
plot(lid_pp.sens_stamp,lid_pp.y_map(:,1:max_opp),'o','MarkerFaceColor',col.pointpillars,'MarkerEdgeColor',col.pointpillars,'MarkerSize',sz,'DisplayName','Lid PP');
plot(tt.stamp,tt.y_map(:,1:max_opp),'Color',col.tt,'DisplayName','tt');
if(use_ref || use_sim_ref); plot(gt.stamp,gt.y_map,'Color',col.ref,'DisplayName','Ground Truth'); end
grid on; title('y map [m]'); 

%% YAW
figure('name', 'Filter - Yaw');

% yaw
tt.yaw_map = mod(tt.yaw_map,2*pi);
lid_clust.yaw_map = mod(lid_clust.yaw_map,2*pi);
cam_yolo.yaw_map = mod(cam_yolo.yaw_map,2*pi);
rad_clust.yaw_map = mod(rad_clust.yaw_map,2*pi);
lid_pp.yaw_map = mod(lid_pp.yaw_map,2*pi);

axes(f) = nexttile([1,1]); f=f+1; hold on;
plot(lid_clust.sens_stamp,lid_clust.yaw_map(:,1:max_opp),'o','MarkerFaceColor',col.lidar,'MarkerEdgeColor',col.lidar,'MarkerSize',sz,'DisplayName','Lid Clust');
plot(rad_clust.sens_stamp,rad_clust.yaw_map(:,1:max_opp),'o','MarkerFaceColor',col.radar,'MarkerEdgeColor',col.radar,'MarkerSize',sz,'DisplayName','Rad Clust');
plot(cam_yolo.sens_stamp,cam_yolo.yaw_map(:,1:max_opp),'o','MarkerFaceColor',col.camera,'MarkerEdgeColor',col.camera,'MarkerSize',sz,'DisplayName','Camera');
plot(lid_pp.sens_stamp,lid_pp.yaw_map(:,1:max_opp),'o','MarkerFaceColor',col.pointpillars,'MarkerEdgeColor',col.pointpillars,'MarkerSize',sz,'DisplayName','Lidar PP');
plot(tt.stamp,tt.yaw_map(:,1:max_opp),'Color',col.tt,'DisplayName','tt');
if(use_ref || use_sim_ref)
    gt.yaw_map = mod(gt.yaw_map,2*pi);
    plot(gt.stamp,gt.yaw_map,'Color',col.ref,'DisplayName','Ground Truth');
end
grid on; title('yaw [deg]'); 

%% STATE FIGURE REL
figure('name', 'Filter - CoG');
tiledlayout(3,1,'Padding','compact');

% pos x
axes(f) = nexttile([1,1]); f=f+1; hold on;
plot(lid_clust.sens_stamp,lid_clust.x_rel(:,1:max_opp),'o','MarkerFaceColor',col.lidar,'MarkerEdgeColor',col.lidar,'MarkerSize',sz,'DisplayName','Lid Clust');
plot(rad_clust.sens_stamp,rad_clust.x_rel(:,1:max_opp),'o','MarkerFaceColor',col.radar,'MarkerEdgeColor',col.radar,'MarkerSize',sz,'DisplayName','Rad Clust');
plot(cam_yolo.sens_stamp,cam_yolo.x_rel(:,1:max_opp),'o','MarkerFaceColor',col.camera,'MarkerEdgeColor',col.camera,'MarkerSize',sz,'DisplayName','Camera');
plot(lid_pp.sens_stamp,lid_pp.x_rel(:,1:max_opp),'o','MarkerFaceColor',col.pointpillars,'MarkerEdgeColor',col.pointpillars,'MarkerSize',sz,'DisplayName','Lid PP');
plot(tt.stamp, tt.x_rel(:,1:max_opp), 'Color',col.tt,'DisplayName','tt');
if(use_ref || use_sim_ref); plot(gt.stamp, gt.x_rel, 'Color',col.ref,'DisplayName','Ground Truth'); end
grid on; title('x rel [m]'); 

% pos y
axes(f) = nexttile([1,1]); f=f+1; hold on;
plot(lid_clust.sens_stamp,lid_clust.y_rel(:,1:max_opp),'o','MarkerFaceColor',col.lidar,'MarkerEdgeColor',col.lidar,'MarkerSize',sz,'DisplayName','Lid Clust');
plot(rad_clust.sens_stamp,rad_clust.y_rel(:,1:max_opp),'o','MarkerFaceColor',col.radar,'MarkerEdgeColor',col.radar,'MarkerSize',sz,'DisplayName','Rad Clust');
plot(cam_yolo.sens_stamp,cam_yolo.y_rel(:,1:max_opp),'o','MarkerFaceColor',col.camera,'MarkerEdgeColor',col.camera,'MarkerSize',sz,'DisplayName','Camera');
plot(lid_pp.sens_stamp,lid_pp.y_rel(:,1:max_opp),'o','MarkerFaceColor',col.pointpillars,'MarkerEdgeColor',col.pointpillars,'MarkerSize',sz,'DisplayName','Lid PP');
plot(tt.stamp, tt.y_rel(:,1:max_opp), 'Color',col.tt,'DisplayName','tt');
if(use_ref || use_sim_ref); plot(gt.stamp, gt.y_rel, 'Color',col.ref,'DisplayName','Ground Truth'); end
grid on; title('y rel [m]'); 

% rho dot
axes(f) = nexttile([1,1]); f=f+1; hold on;
plot(rad_clust.sens_stamp,rad_clust.rho_dot(:,1:max_opp),'o','MarkerFaceColor',col.radar,'MarkerEdgeColor',col.radar,'MarkerSize',sz,'DisplayName','Rad Clust');
plot(tt.stamp, tt.rho_dot(:,1:max_opp), 'Color',col.tt,'DisplayName','tt');
if(use_ref || use_sim_ref); plot(gt.stamp, gt.rho_dot, 'Color',col.ref,'DisplayName','Ground Truth'); end
grid on; title('rho dot [m/s]'); 

%% RANGE
figure('name', 'Filter - Range');
tiledlayout(3,1,'Padding','compact');

% rho 
axes(f) = nexttile([1,1]); f=f+1; hold on;
plot(lid_clust.sens_stamp,lid_clust.range(:,1:max_opp),'o','MarkerFaceColor',col.lidar,'MarkerEdgeColor',col.lidar,'MarkerSize',sz,'DisplayName','Lid Clust');
plot(rad_clust.sens_stamp,rad_clust.range(:,1:max_opp),'o','MarkerFaceColor',col.radar,'MarkerEdgeColor',col.radar,'MarkerSize',sz,'DisplayName','Rad Clust');
plot(cam_yolo.sens_stamp,cam_yolo.range(:,1:max_opp),'o','MarkerFaceColor',col.camera,'MarkerEdgeColor',col.camera,'MarkerSize',sz,'DisplayName','Camera');
plot(lid_pp.sens_stamp,lid_pp.range(:,1:max_opp),'o','MarkerFaceColor',col.pointpillars,'MarkerEdgeColor',col.pointpillars,'MarkerSize',sz,'DisplayName','Lid PP');
plot(tt.stamp, tt.range(:,1:max_opp), 'Color',col.tt,'DisplayName','tt');
if(use_ref || use_sim_ref); plot(gt.stamp, gt.rho, 'Color',col.ref,'DisplayName','Ground Truth'); end
grid on; title('range [m]'); 

% rho dot
axes(f) = nexttile([1,1]); f=f+1; hold on;
plot(rad_clust.sens_stamp,rad_clust.rho_dot(:,1:max_opp),'o','MarkerFaceColor',col.radar,'MarkerEdgeColor',col.radar,'MarkerSize',sz,'DisplayName','Rad Clust');
plot(tt.stamp, tt.rho_dot(:,1:max_opp), 'Color',col.tt,'DisplayName','tt');
if(use_ref || use_sim_ref); plot(gt.stamp, gt.rho_dot, 'Color',col.ref,'DisplayName','Ground Truth'); end
grid on; title('rho dot [m/s]'); 

% count
axes(f) = nexttile([1,1]); f=f+1; hold on;
area(tt.stamp,log.perception__opponents.opponents__rad_clust_meas(:,1:max_opp),'FaceColor',col.radar,'EdgeColor',col.radar,'DisplayName','Rad Clust');
area(tt.stamp,log.perception__opponents.opponents__lid_pp_meas(:,1:max_opp),'FaceColor',col.pointpillars,'EdgeColor',col.pointpillars,'DisplayName','Lid PP');
area(tt.stamp,log.perception__opponents.opponents__lid_clust_meas(:,1:max_opp),'FaceColor',col.lidar,'EdgeColor',col.lidar,'DisplayName','Lid Clust');
area(tt.stamp,log.perception__opponents.opponents__cam_yolo_meas(:,1:max_opp),'FaceColor',col.camera,'EdgeColor',col.camera,'DisplayName','Camera');
grid on; title('Count'); 

%% SPEED AND ACC
figure('name', 'Filter - Speed Acc');
tiledlayout(2,1,'Padding','compact');

% vx
axes(f) = nexttile([1,1]); f=f+1; hold on;
plot(tt.stamp,tt.vx(:,1:max_opp),'Color',col.tt,'DisplayName','tt');
if(use_ref || use_sim_ref); plot(gt.stamp,gt.vx,'Color',col.ref,'DisplayName','Ground Truth'); end
grid on; title('vx [m/s]'); 

% ax
axes(f) = nexttile([1,1]); f=f+1; hold on;
plot(tt.stamp,tt.ax(:,1:max_opp),'Color',col.tt,'DisplayName','tt');
if(use_sim_ref); plot(gt.stamp,gt.ax,'Color',col.ref,'DisplayName','Ground Truth'); end
grid on; title('ax [m/s^2]'); 

linkaxes(axes,'x');
xlim(x_lim);

%% MAP
fig = figure('name','MAP');

c = uicontrol('Style','pushbutton');
c.String = {'Refresh'};
c.Callback = @refreshTimeButtonPushed;


function refreshTimeButtonPushed(src,event)
    axes = evalin('base', 'axes');
    traj_db = evalin('base', 'trajDatabase');
    use_ref = evalin('base', 'use_ref');
    use_sim_ref = evalin('base', 'use_sim_ref');
    col = evalin('base', 'col');
    lid_clust = evalin('base', 'lid_clust');
    rad_clust = evalin('base', 'rad_clust');
    cam_yolo = evalin('base', 'cam_yolo');
    lid_pp = evalin('base', 'lid_pp');
    tt=evalin('base','tt');
    if(use_ref || use_sim_ref); gt =evalin('base','gt'); end

    t_lim=xlim(axes(1));
    t1_lid_clust = find(lid_clust.sens_stamp>t_lim(1),1);
    tend_lid_clust = find(lid_clust.sens_stamp<t_lim(2),1,'last');
    t1_rad_clust = find(rad_clust.sens_stamp>t_lim(1),1);
    tend_rad_clust = find(rad_clust.sens_stamp<t_lim(2),1,'last');
    t1_cam_yolo = find(cam_yolo.sens_stamp>t_lim(1),1);
    tend_cam_yolo = find(cam_yolo.sens_stamp<t_lim(2),1,'last');
    t1_lid_pp = find(lid_pp.sens_stamp>t_lim(1),1);
    tend_lid_pp = find(lid_pp.sens_stamp<t_lim(2),1,'last');
    t1_tt = find(tt.stamp>t_lim(1),1);
    tend_tt = find(tt.stamp<t_lim(2),1,'last');
    if(use_ref || use_sim_ref)
        t1_tt_ref = find(gt.stamp>t_lim(1),1);
        tend_tt_ref = find(gt.stamp<t_lim(2),1,'last');
    end

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
    plot(tt.x_map(t1_tt:tend_tt),tt.y_map(t1_tt:tend_tt),'Color',col.tt,'DisplayName','tt');
    if(use_ref || use_sim_ref)
        plot(gt.x_map(t1_tt_ref:tend_tt_ref),gt.y_map(t1_tt_ref:tend_tt_ref),'Color',col.ref,'DisplayName','Grond Truth');
    end
    legend show
end