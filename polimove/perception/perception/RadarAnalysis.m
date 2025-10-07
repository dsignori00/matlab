close all
clearvars -except log log2 trajDatabase ego_idxs ego_idxs2 opp_yaw_matrix1 opp_yaw_matrix2

ground_truth = false;
compare = true;

NAME_1 = "Radar";
NAME_2 = "Radar - 2";

%#ok<*UNRCH>
%#ok<*INUSD>

%% Paths

addpath("../../common/utilities/")
addpath("../../common/constants/")
addpath("../../common/plot/")
normal_path = "../../bags";

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

% load log2
if (compare && ~exist('log2','var'))
    clearvars opp_yaw_matrix2
    [file,path] = uigetfile(fullfile(normal_path,'*.mat'),'Load log 2');
    tmp = load(fullfile(path,file));
    log2 = tmp.log;
end

DateTime = datetime(log.time_offset_nsec,'ConvertFrom','epochtime','TicksPerSecond',1e9,'Format','dd-MMM-yyyy HH:mm:ss');

%% PLOT DATA

% style
set(0,'DefaultFigureWindowStyle','docked');
set(0,'DefaultTextInterpreter', 'none');
set(0,'DefaultLegendInterpreter', 'none');
set(0, 'DefaultLineLineWidth', 2);
x_lim = [0 inf];

%% NAMING
col.radar = '#4DBEEE';
col.radar2 = '#D95319';
col.ref = '#EDB120';
sz=3; % Marker size
f=1;

% LIVELINESS
liveliness_stamp = log.liveliness__state.bag_stamp;
log.liveliness__state.nodes_states__current_rate(:,21);

% RADAR CLUSTERING DETECTIONS
rad1 = get_radar_fields(log);
if(compare)
    rad2 = get_radar_fields(log2);
else
    rad2 = nan_struct(rad1);
    rad2.max_det = 0;
end


%% PROCESSING
if (~exist('opp_yaw_matrix1','var'))
    opp_yaw_matrix1 = NaN(size(rad1.x_map));
    for i = 1:rad1.max_det
        opp_pos = [rad1.x_map(:,i), rad1.y_map(:,i)];
        opp_yaw = get_heading(opp_pos, trajDatabase);
        opp_yaw_matrix1(:,i) = opp_yaw;
    end
end

ego_timestamp = (log.estimation.stamp__tot)*10^9+double(log.time_offset_nsec);
rad1_stamp = rad1.sens_stamp*10^9 + double(log.time_offset_nsec);

if (~exist('ego_idxs','var'))
    [ego_idxs, ~] = find_closest_stamp(rad1_stamp,ego_timestamp);
end
ego_pos(:,1) = log.estimation.x_cog(ego_idxs);
ego_pos(:,2) = log.estimation.y_cog(ego_idxs);
ego_yaw = log.estimation.heading(ego_idxs);
ego_v(:,1) = log.estimation.vx(ego_idxs);
ego_v(:,2) = log.estimation.vy(ego_idxs);

for i = 1:rad1.max_det
    opp_yaw = opp_yaw_matrix1(:,i);
    rad1.vx(:,i) = compensate_ego_speed(ego_pos, ego_v, ego_yaw, opp_yaw, ...
                        rad1.rho_dot(:,i), rad1.x_map(:,i), rad1.y_map(:,i));
end

if (~exist('opp_yaw_matrix2','var'))
    opp_yaw_matrix2 = NaN(size(rad2.x_map));
    for i = 1:rad2.max_det
        opp_pos = [rad2.x_map(:,i), rad2.y_map(:,i)];
        opp_yaw = get_heading(opp_pos, trajDatabase);
        opp_yaw_matrix2(:,i) = opp_yaw;
    end
end

if(compare)
    rad2_stamp = rad2.sens_stamp*10^9 + double(log2.time_offset_nsec);
    if (~exist('ego_idxs2','var'))
        [ego_idxs2, ~] = find_closest_stamp(rad2_stamp,ego_timestamp);
        if (isempty(ego_idxs2))
            error('Have you ');
        end
    end
    clearvars ego_pos ego_yaw ego_v
    ego_pos(:,1) = log.estimation.x_cog(ego_idxs2);
    ego_pos(:,2) = log.estimation.y_cog(ego_idxs2);
    ego_yaw = log.estimation.heading(ego_idxs2);
    ego_v(:,1) = log.estimation.vx(ego_idxs2);
    ego_v(:,2) = log.estimation.vy(ego_idxs2);

    for i = 1:max(rad2.max_det,1)
        opp_yaw = opp_yaw_matrix2(:,i);
        rad2.vx(:,i) = compensate_ego_speed(ego_pos, ego_v, ego_yaw, opp_yaw, ...
                             rad2.rho_dot(:,i), rad2.x_map(:,i), rad2.y_map(:,i));
    end
end

rad2.sens_stamp = rad2.sens_stamp + double(log2.time_offset_nsec)*10^-9 - double(log.time_offset_nsec)*10^-9; 
rad2.stamp = rad2.stamp + double(log2.time_offset_nsec)*10^-9 - double(log.time_offset_nsec)*10^-9; 
%% LATENCY FIGURE
figure('name','Latency')
tiledlayout(3,1,'Padding','compact');

axes(f) = nexttile; f=f+1;
hold on;
plot(liveliness_stamp, log.liveliness__state.nodes_states__current_rate(:,21), 'DisplayName','RR');
plot(liveliness_stamp, log.liveliness__state.nodes_states__current_rate(:,23), 'DisplayName','RF');
plot(liveliness_stamp, log.liveliness__state.nodes_states__current_rate(:,25), 'DisplayName','RL');
plot(liveliness_stamp, log.liveliness__state.nodes_states__current_rate(:,27), 'DisplayName','RB');
grid on; title('radar points rate [s]'); legend; xlim(x_lim);

axes(f) = nexttile; f=f+1;
hold on;
plot(liveliness_stamp, log.liveliness__state.nodes_states__current_rate(:,22), 'DisplayName','RR');
plot(liveliness_stamp, log.liveliness__state.nodes_states__current_rate(:,24), 'DisplayName','RF');
plot(liveliness_stamp, log.liveliness__state.nodes_states__current_rate(:,26), 'DisplayName','RL');
plot(liveliness_stamp, log.liveliness__state.nodes_states__current_rate(:,28), 'DisplayName','RB');
grid on; title('radar udp packages rate [s]'); legend; xlim(x_lim);

axes(f) = nexttile; f=f+1;
hold on;
plot(rad1.stamp,rad1.stamp-rad1.sens_stamp, 'Color', col.radar,'DisplayName',NAME_1);
plot(rad2.stamp,rad2.stamp-rad2.sens_stamp, 'Color', col.radar2,'DisplayName',NAME_2);
grid on; title('radar clustering latency [s]'); legend; xlim(x_lim);


%% STATE FIGURE COG
figure('name','Detections - cog')
tiledlayout(3,1,'Padding','compact');

% pos x
axes(f) = nexttile([1,1]); f=f+1;
hold on;
plot(rad1.sens_stamp, safe_cols(rad1.x_rel, rad1.max_det), 'o', 'MarkerFaceColor', col.radar, 'MarkerEdgeColor', col.radar, 'MarkerSize', sz, 'DisplayName', NAME_1);
plot(rad2.sens_stamp, safe_cols(rad2.x_rel, rad2.max_det), 'o', 'MarkerFaceColor', col.radar2, 'MarkerEdgeColor', col.radar2, 'MarkerSize', sz, 'DisplayName', NAME_2);
grid on; title('x rel [m]'); legend; xlim(x_lim);

% pos y
axes(f) = nexttile([1,1]); f=f+1;
hold on;
plot(rad1.sens_stamp, safe_cols(rad1.y_rel, rad1.max_det), 'o', 'MarkerFaceColor', col.radar, 'MarkerEdgeColor', col.radar, 'MarkerSize', sz, 'DisplayName', NAME_1);
plot(rad2.sens_stamp, safe_cols(rad2.y_rel, rad2.max_det), 'o', 'MarkerFaceColor', col.radar2, 'MarkerEdgeColor', col.radar2, 'MarkerSize', sz, 'DisplayName', NAME_2);
grid on; title('y rel [m]'); legend; xlim(x_lim);

% rho dot
axes(f) = nexttile([1,1]); f=f+1;
hold on;
plot(rad1.sens_stamp, safe_cols(rad1.rho_dot, rad1.max_det), 'o', 'MarkerFaceColor', col.radar, 'MarkerEdgeColor', col.radar, 'MarkerSize', sz, 'DisplayName', NAME_1);
plot(rad2.sens_stamp, safe_cols(rad2.rho_dot, rad2.max_det), 'o', 'MarkerFaceColor', col.radar2, 'MarkerEdgeColor', col.radar2, 'MarkerSize', sz, 'DisplayName', NAME_2);
grid on; title('rho dot [m/s]'); legend; xlim(x_lim);


%% STATE FIGURE MAP
figure('name','Detections - map')
tiledlayout(3,1,'Padding','compact');

% pos X
axes(f) = nexttile([1,1]); f=f+1;
hold on;
plot(rad1.sens_stamp, safe_cols(rad1.x_map, rad1.max_det), 'o', 'MarkerFaceColor', col.radar, 'MarkerEdgeColor', col.radar, 'MarkerSize', sz, 'DisplayName', NAME_1);
plot(rad2.sens_stamp, safe_cols(rad2.x_map, rad2.max_det), 'o', 'MarkerFaceColor', col.radar2, 'MarkerEdgeColor', col.radar2, 'MarkerSize', sz, 'DisplayName', NAME_2);
grid on; title('x map [m]'); legend; xlim(x_lim);

% pos y
axes(f) = nexttile([1,1]); f=f+1;
hold on;
plot(rad1.sens_stamp, safe_cols(rad1.y_map, rad1.max_det), 'o', 'MarkerFaceColor', col.radar, 'MarkerEdgeColor', col.radar, 'MarkerSize', sz, 'DisplayName', NAME_1);
plot(rad2.sens_stamp, safe_cols(rad2.y_map, rad2.max_det), 'o', 'MarkerFaceColor', col.radar2, 'MarkerEdgeColor', col.radar2, 'MarkerSize', sz, 'DisplayName', NAME_2);
grid on; title('y map [m]'); legend; xlim(x_lim);

% vx
axes(f) = nexttile([1,1]); f=f+1;
hold on;
plot(rad1.sens_stamp, safe_cols(rad1.vx, rad1.max_det), 'o', 'MarkerFaceColor', col.radar, 'MarkerEdgeColor', col.radar, 'MarkerSize', sz, 'DisplayName', NAME_1);
plot(rad2.sens_stamp, safe_cols(rad2.vx, rad2.max_det), 'o', 'MarkerFaceColor', col.radar2, 'MarkerEdgeColor', col.radar2, 'MarkerSize', sz, 'DisplayName', NAME_2);
grid on; title('vx [m/s]'); legend; xlim(x_lim);


%% Detection count
figure('name','Detection Count')
f=f+1;
hold on;
plot(rad1.sens_stamp,rad1.count,'Color',col.radar,'DisplayName',NAME_1);
plot(rad2.sens_stamp,rad2.count,'Color',col.radar2,'DisplayName',NAME_2);
grid on; title('Detections [#]'); legend; xlim(x_lim);

linkaxes(axes,'x');
