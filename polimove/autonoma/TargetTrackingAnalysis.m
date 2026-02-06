close all
clearvars -except log log_2 log_ref trajDatabase

use_ref     = false;
imm         = true;
compare     = false;

%#ok<*UNRCH>
%#ok<*INUSD>

%% Paths

addpath("../common/utilities/")
addpath("../../common/constants/")
addpath("../common/plot/")
addpath("../../common/graphic_tools/")
addpath("../perception/utils/")
normal_path = "../bags";

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

% load log 2
if(compare)
    if (~exist('log_2','var'))
        [file,path] = uigetfile(fullfile(normal_path,'*.mat'),'Load log_2');
        if isequal(file, 0)  
        disp('User canceled file selection.');
        else
        tmp = load(fullfile(path,file));
        log_2 = tmp.log;
        clearvars tmp;
        end
    end
    name2 = 'New TT';
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

%% NAMING
graphics_options;
col.lidar        = colors.green{2};
col.radar        = '#4DBEEE';
col.camera       = colors.yellow{2};
col.pp = colors.orange{2};
col.v2v          = colors.red{2};
col.tt           = colors.blue{2};
col.tt2          = colors.blue{1};
col.ref          = colors.black;
sz=3; % Marker size
f=1;
x_lim = [0 inf];

%%

% V2V DETECTIONS
v2v.sens_stamp = log.perception__v2v__detections.sensor_stamp__tot;
% relative
v2v.x_rel = log.perception__v2v__detections.detections__x_rel;
v2v.y_rel = log.perception__v2v__detections.detections__y_rel;
v2v.x_rel(v2v.x_rel==0)=nan;
v2v.y_rel(v2v.y_rel==0)=nan;
% map
v2v.x_map = log.perception__v2v__detections.detections__x_map;
v2v.y_map = log.perception__v2v__detections.detections__y_map;
v2v.yaw_map = log.perception__v2v__detections.detections__yaw_map;
v2v.vx_map = log.perception__v2v__detections.detections__vx;
v2v.max_opp = max(sum(~isnan(v2v.x_rel')));
v2v.x_map(v2v.x_map==0)=nan;
v2v.y_map(v2v.y_map==0)=nan;
v2v.yaw_map(v2v.yaw_map==0)=nan;
v2v.vx_map(v2v.vx_map==0)=nan;
v2v.yaw_map = unwrap(v2v.yaw_map);

tt = load_target_tracking(log);
if(compare) 
    tt2 = load_target_tracking(log_2); 
    tt2.stamp = tt2.stamp + double(log_2.time_offset_nsec-log.time_offset_nsec)*1e-9;
end

% GROUND TRUTH
if(use_ref)
    tt.stamp_ref = (log_ref.timestamp - double(log.time_offset_nsec))*1e-9;
    % relative
    tt.x_rel_ref = log_ref.x_rel;
    tt.y_rel_ref = log_ref.y_rel;
    tt.rho_dot_ref = log_ref.rho_dot;
    % map
    tt.x_map_ref = log_ref.x_map;
    tt.y_map_ref = log_ref.y_map;
    tt.vx_ref = log_ref.speed;
    tt.yaw_map_ref = log_ref.yaw_map;
end

tt.max_opp = 1;
v2v.max_opp = 2;

% %% INFO
% figure('Name','Info');
% tiledlayout(3,1,'Padding','compact');
% 
% % racetype
% axes(f) = nexttile([1,1]);
% f=f+1;
% hold on;
% plot(log.planner_manager.bag_stamp, log.planner_manager.race_type,'Color',col.tt);
% ylim([-1 5])
% grid on;
% ylabel('RaceType');
% 
% % decision maker
% axes(f) = nexttile([1,1]); f=f+1; hold on;
% plot(log.decision_maker.stamp__tot, log.decision_maker.current_state__type, 'Color',col.tt, 'HandleVisibility','off');
% yticks(0:4);
% ylim([-1 5]); grid on; ylabel('Decision Maker state');
% labels = {'0 - RACING','1 - TAILGATING','2 - OVERTAKE','3 - ABORT','4 - CRITICAL'};
% for i = 1:numel(labels)
%     plot(nan, nan, 'DisplayName', labels{i}, 'Color', 'none');
% end
% legend;
% 
% % v2v frequency
% v2v.frequency = message_freq(v2v.sens_stamp);
% axes(f) = nexttile([1,1]);
% f=f+1;
% hold on;
% plot(v2v.sens_stamp,v2v.frequency,'Color',col.v2v,'DisplayName','v2v');
% grid on;
% ylabel('Frequency [Hz]');
% legend


%% STATE FIGURE REL
figure('name', 'State Rel');
tiledlayout(3,2,'Padding','compact');

% pos x
axes(f) = nexttile([1,1]);
f=f+1;
hold on;
scatter(repmat(v2v.sens_stamp,v2v.max_opp,1), reshape(v2v.x_rel(:,1:v2v.max_opp), [], 1), sz.^2, col.v2v, 'filled', 'DisplayName','v2v');
plot(repmat(tt.stamp,tt.max_opp, 1), reshape(tt.x_rel(:,1:tt.max_opp), [], 1), 'Color',col.tt,'DisplayName',name1);
if(use_ref)
    plot(tt.stamp_ref, tt.x_rel_ref, 'Color',col.ref,'DisplayName','gt');
end
grid on;
ylabel('x rel [m]');
legend

% pos y
axes(f) = nexttile([1,1]);
f=f+1;
hold on;
scatter(repmat(v2v.sens_stamp,v2v.max_opp,1), reshape(v2v.y_rel(:,1:v2v.max_opp), [], 1), sz.^2, col.v2v, 'filled', 'DisplayName','v2v');
plot(repmat(tt.stamp,tt.max_opp, 1), reshape(tt.y_rel(:,1:tt.max_opp), [], 1), 'Color',col.tt,'DisplayName',name1);
if(use_ref)
    plot(tt.stamp_ref, tt.y_rel_ref, 'Color',col.ref,'DisplayName','gt');
end
grid on;
ylabel('y rel [m]');
legend

% rho dot
axes(f) = nexttile([1,2]);
f=f+1;
hold on;
plot(repmat(tt.stamp,tt.max_opp, 1), reshape(tt.rho_dot(:,1:tt.max_opp), [], 1), 'Color',col.tt,'DisplayName',name1);
if(use_ref)
    plot(tt.stamp_ref, tt.rho_dot_ref, 'Color',col.ref,'DisplayName','gt');
end
grid on;
ylabel('rho dot [m/s]');
legend

% count
axes(f) = nexttile([1,2]);
f=f+1;
hold on;
area(tt.stamp,log.perception__opponents.opponents__v2v_meas(:,1:v2v.max_opp),'FaceColor',col.v2v,'EdgeColor',col.v2v,'DisplayName','v2v');
grid on;
ylabel('detections count')
legend


%% STATE FIGURE MAP
figure('name', 'State Map');
tiledlayout(3,2,'Padding','compact');

% pos X
axes(f) = nexttile([1,1]);
f=f+1;
hold on;
scatter(repmat(v2v.sens_stamp,v2v.max_opp,1), reshape(v2v.x_map(:,1:v2v.max_opp), [], 1), sz.^2, col.v2v, 'filled', 'DisplayName','v2v');
plot(repmat(tt.stamp,tt.max_opp, 1), reshape(tt.x_map(:,1:tt.max_opp), [], 1), 'Color', col.tt, 'DisplayName',name1);
if(use_ref)
    plot(tt.stamp_ref,tt.x_map_ref,'Color',col.ref,'DisplayName','gt');
end
grid on;
ylabel('x map [m]');
legend

% pos y
axes(f) = nexttile([1,1]);
f=f+1;
hold on;
scatter(repmat(v2v.sens_stamp,v2v.max_opp,1), reshape(v2v.y_map(:,1:v2v.max_opp), [], 1), sz.^2, col.v2v, 'filled', 'DisplayName','v2v');
plot(repmat(tt.stamp,tt.max_opp, 1), reshape(tt.y_map(:,1:tt.max_opp), [], 1), 'Color', col.tt, 'DisplayName',name1);
if(use_ref)
    plot(tt.stamp_ref,tt.y_map_ref,'Color',col.ref,'DisplayName','gt');
end
grid on;
ylabel('y map [m]');
legend

% vx
axes(f) = nexttile([1,1]);
f=f+1;
hold on;
scatter(repmat(v2v.sens_stamp,v2v.max_opp,1), reshape(v2v.vx_map(:,1:v2v.max_opp), [], 1), sz.^2, col.v2v, 'filled', 'DisplayName','v2v');
plot(repmat(tt.stamp,tt.max_opp, 1), reshape(tt.vx(:,1:tt.max_opp), [], 1), 'Color', col.tt, 'DisplayName',name1);
if(use_ref)
    plot(tt.stamp_ref,tt.vx_ref,'Color',col.ref,'DisplayName','gt');
end
grid on;
ylabel('vx [m/s]');
legend

% ax
axes(f) = nexttile([1,1]);
f=f+1;
hold on;
plot(repmat(tt.stamp,tt.max_opp, 1), reshape(tt.ax(:,1:tt.max_opp), [], 1), 'Color', col.tt, 'DisplayName',name1);
grid on;
ylabel('ax [m/s$^2$]');
legend

% yaw
axes(f) = nexttile([1,2]);
f=f+1;
hold on;
scatter(repmat(v2v.sens_stamp,v2v.max_opp,1), reshape(v2v.yaw_map(:,1:v2v.max_opp), [], 1), sz.^2, col.v2v, 'filled', 'DisplayName','v2v');
plot(repmat(tt.stamp,tt.max_opp, 1), reshape(tt.yaw_map(:,1:tt.max_opp), [], 1), 'Color', col.tt, 'DisplayName',name1);
if(use_ref)
    plot(tt.stamp_ref,tt.yaw_map_ref,'Color',col.ref,'DisplayName','gt');
end
grid on;
ylabel('yaw [deg]');
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
    col = evalin('base', 'col');
    v2v = evalin('base', 'v2v');
    tt=evalin('base',name1);

    t_lim=xlim(axes(1));
    t1_v2v = find(v2v.sens_stamp>t_lim(1),1);
    tend_v2v = find(v2v.sens_stamp<t_lim(2),1,'last');
    t1_tt = find(tt.stamp>t_lim(1),1);
    tend_tt = find(tt.stamp<t_lim(2),1,'last');
    if(use_ref)
        t1_tt.ref = find(tt.stamp_ref>t_lim(1),1);
        tend_tt.ref = find(tt.stamp_ref<t_lim(2),1,'last');
    end

    subplot(1,1,1)
    cla reset 
    ylabel('map')
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

    for k=1:v2v.max_opp
        plot(v2v.x_map(t1_v2v:tend_v2v,k), v2v.y_map(t1_v2v:tend_v2v,k),'.','markersize',20,'Color',col.v2v,'displayname',[num2str(k),' - v2v' ]);
    end
    for k=1:tt.max_opp
        plot(tt.x_map(t1_tt:tend_tt,k),tt.y_map(t1_tt:tend_tt,k),'Color',col.tt,'DisplayName',[num2str(k),' - tt' ]);
    end
    if(use_ref)
        plot(tt.x_map_ref(t1_tt.ref:tend_tt.ref),tt.y_map_ref(t1_tt.ref:tend_tt.ref),'Color',col.ref,'DisplayName','Grond Truth');
    end
    legend show
end

%% IMM
imm_fig;