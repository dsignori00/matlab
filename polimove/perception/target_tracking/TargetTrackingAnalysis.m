close all
clearvars -except log log_ref trajDatabase

use_ref = false;
use_sim_ref = false;
imm = false;

%#ok<*UNRCH>
%#ok<*INUSD>

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
    if  (~exist('log_ref','var')) 
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
col.v2v = '#A2142F';
col.ref = '#000000';
sz=3; % Marker size
f=1;

% V2V DETECTIONS
v2v_sens_stamp = log.perception__v2v__detections.sensor_stamp__tot;
% relative
v2v_x_rel = log.perception__v2v__detections.detections__x_rel;
v2v_y_rel = log.perception__v2v__detections.detections__y_rel;
v2v_x_rel(v2v_x_rel==0)=nan;
v2v_y_rel(v2v_y_rel==0)=nan;
% map
v2v_x_map = log.perception__v2v__detections.detections__x_map;
v2v_y_map = log.perception__v2v__detections.detections__y_map;
v2v_yaw_map = log.perception__v2v__detections.detections__yaw_map;
v2v_vx_map = log.perception__v2v__detections.detections__vx;
v2v_x_map(v2v_x_map==0)=nan;
v2v_y_map(v2v_y_map==0)=nan;
v2v_yaw_map(v2v_yaw_map==0)=nan;
v2v_vx_map(v2v_vx_map==0)=nan;

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


%% INFO
figure('Name','Info');
tiledlayout(3,1,'Padding','compact');

% racetype
axes(f) = nexttile([1,1]);
f=f+1;
hold on;
plot(log.planner_manager.bag_stamp, log.planner_manager.race_type,'Color',col.tt);
ylim([-1 5])
grid on;
title('RaceType');

% decision maker
axes(f) = nexttile([1,1]);
f=f+1;
hold on;
plot(log.decision_maker.bag_stamp, log.decision_maker.current_state__type, 'Color',col.tt);
yticks(0:4);
yticklabels({'RACING','TAILGATING','OVERTAKE','ABORT','CRITICAL'});
ylim([-1 5])
grid on;
title('Decision Maker state')

% v2v frequency
v2v_frequency = messageFreq(v2v_sens_stamp);
axes(f) = nexttile([1,1]);
f=f+1;
hold on;
plot(v2v_sens_stamp,v2v_frequency,'Color',col.v2v,'DisplayName','V2V');
grid on;
title('Frequency [Hz]');
legend

linkaxes(axes,'x')


%% STATE FIGURE REL
figure('name', 'State Rel');
tiledlayout(3,2,'Padding','compact');

% pos x
axes(f) = nexttile([1,1]);
f=f+1;
hold on;
plot(v2v_sens_stamp,v2v_x_rel(:,1:max_opp),'o','MarkerFaceColor',col.v2v,'MarkerEdgeColor',col.v2v,'MarkerSize',sz,'DisplayName','V2V');
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
plot(v2v_sens_stamp,v2v_y_rel(:,1:max_opp),'o','MarkerFaceColor',col.v2v,'MarkerEdgeColor',col.v2v,'MarkerSize',sz,'DisplayName','V2V');
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
area(tt_stamp,log.perception__opponents.opponents__v2v_meas(:,1:max_opp),'FaceColor',col.v2v,'EdgeColor',col.v2v,'DisplayName','V2V');
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
plot(v2v_sens_stamp,v2v_x_map(:,1:max_opp),'o','MarkerFaceColor',col.v2v,'MarkerEdgeColor',col.v2v,'MarkerSize',sz,'DisplayName','V2V');
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
plot(v2v_sens_stamp,v2v_y_map(:,1:max_opp),'o','MarkerFaceColor',col.v2v,'MarkerEdgeColor',col.v2v,'MarkerSize',sz,'DisplayName','V2V');
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
plot(v2v_sens_stamp,v2v_vx_map(:,1:max_opp),'Color',col.v2v,'DisplayName','v2v');
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
hold on;
v2v_yaw_map = mod(v2v_yaw_map,2*pi);
plot(v2v_sens_stamp,v2v_yaw_map(:,1:max_opp),'o','MarkerFaceColor',col.v2v,'MarkerEdgeColor',col.v2v,'MarkerSize',sz,'DisplayName','V2V');
plot(tt_stamp,tt_yaw_map(:,1:max_opp),'Color',col.tt,'DisplayName','tt');
if(use_ref || use_sim_ref)
    tt_yaw_map_ref = mod(tt_yaw_map_ref,2*pi);
    plot(tt_stamp_ref,tt_yaw_map_ref,'Color',col.ref,'DisplayName','Ground Truth');
end
grid on;
title('yaw [deg]');
linkaxes(axes,'x')
legend

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
    col.v2v = evalin('base', 'col.v2v');
    col.tt = evalin('base', 'col.tt');
    col.ref = evalin('base', 'col.ref');
    v2v_sens_stamp = evalin('base', 'v2v_sens_stamp');
    v2v_x_map = evalin('base', 'v2v_x_map');
    v2v_y_map = evalin('base', 'v2v_y_map');
    tt_stamp=evalin('base','tt_stamp');
    tt_x_map = evalin('base', 'tt_x_map');
    tt_y_map = evalin('base', 'tt_y_map');
    if(use_ref || use_sim_ref)
        tt_stamp_ref=evalin('base','tt_stamp_ref');
        tt_x_map_ref = evalin('base', 'tt_x_map_ref');
        tt_y_map_ref = evalin('base', 'tt_y_map_ref');
    end


    t_lim=xlim(axes(1));
    t1_v2v = find(v2v_sens_stamp>t_lim(1),1);
    tend_v2v = find(v2v_sens_stamp<t_lim(2),1,'last');
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


    plot(v2v_x_map(t1_v2v:tend_v2v), v2v_y_map(t1_v2v:tend_v2v),'.','markersize',20,'Color',col.v2v,'displayname','V2V');
    plot(tt_x_map(t1_tt:tend_tt),tt_y_map(t1_tt:tend_tt),'Color',col.tt,'DisplayName','tt');
    if(use_ref || use_sim_ref)
        plot(tt_x_map_ref(t1_tt_ref:tend_tt_ref),tt_y_map_ref(t1_tt_ref:tend_tt_ref),'Color',col.ref,'DisplayName','Grond Truth');
    end
    legend show
end

%% FIGURE IMM
if(imm)

    col.ctrv = '#D95319';
    col.ctra = '#4DBEEE';
    col.cma = '#77AC30';
    col.cmb = '#EDB120';

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
    plot(tt_stamp,log.perception__opponents.opponents__ctra_prob(:,1:max_opp),'Color',col.ctra,'DisplayName','CTRA');
    plot(tt_stamp,log.perception__opponents.opponents__ctrv_prob(:,1:max_opp),'Color',col.ctrv,'DisplayName','CTRV');
    plot(tt_stamp,log.perception__opponents.opponents__cm_acc_prob(:,1:max_opp),'Color',col.cma,'DisplayName','CONST ACC');
    plot(tt_stamp,log.perception__opponents.opponents__cm_dec_prob(:,1:max_opp),'Color',col.cmb,'DisplayName','CONST DEC');
    grid on;
    title('Model Prob')
    linkaxes(axes,'x')
    legend
end