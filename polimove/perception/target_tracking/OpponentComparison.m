close all
clearvars -except log log_ref trajDatabase ego_index

%#ok<*UNRCH>
%#ok<*INUSD>
%#ok<*USENS>

%% Paths

addpath("../../common/utilities/")
addpath("../../common/constants/")
addpath("../../common/plot/")
normal_path = "/home/daniele/Documents/PoliMOVE/04_Bags/";

run('PhysicalConstants.m');


%% Settings

% style
set(0,'DefaultFigureWindowStyle','docked');
set(0,'DefaultTextInterpreter', 'none');
set(0,'DefaultLegendInterpreter', 'none');
set(0, 'DefaultLineLineWidth', 2);
colors = lines(20); 

% opponent names
opponent = containers.Map({'HUMBDA', 'TII'}, [1, 2]);
opponent_names = keys(opponent);
opponent_values = values(opponent);
name_map = containers.Map(cell2mat(opponent_values), opponent_names);

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

DateTime = datetime(log.time_offset_nsec,'ConvertFrom','epochtime','TicksPerSecond',1e9,'Format','dd-MMM-yyyy HH:mm:ss');

% V2V DETECTIONS
v2v_sens_stamp = log.perception__v2v__detections.sensor_stamp__tot;

% map
v2v_x = log.perception__v2v__detections.detections__x_map;
v2v_y = log.perception__v2v__detections.detections__y_map;
v2v_vx = log.perception__v2v__detections.detections__vx*MPS2KPH;
v2v_yaw = log.perception__v2v__detections.detections__yaw_map;
v2v_index = log.perception__v2v__detections.detections__closest_idx;
v2v_x(v2v_x==0)=nan;
v2v_y(v2v_y==0)=nan;
v2v_vx(v2v_vx==0)=nan;
v2v_yaw(v2v_yaw==0)=nan;
v2v_yaw = unwrap(v2v_yaw);
v2v_count = log.perception__v2v__detections.count;
max_opp = max(v2v_count);

% ESTIMATION
ego_x = log.estimation.x_cog;
ego_y = log.estimation.y_cog;
ego_vx = log.estimation.vx*MPS2KPH; 
ego_yaw = log.estimation.heading;

ego_x(ego_x==0)=nan;
ego_y(ego_y==0)=nan;
ego_vx(ego_vx==0)=nan;
ego_yaw(ego_yaw==0)=nan;
ego_yaw = unwrap(ego_yaw);

%% PROCESSING

% compute ego closest idx
if(~exist('ego_index','var'))
    ego_index = NaN(size(ego_x));
    for i = 1:length(ego_x)
        if ~isnan(ego_x(i)) && ~isnan(ego_y(i))
            ego_index(i) = ComputeClosestIdx(ego_x(i), ego_y(i), trajDatabase(10));
        end
    end
end

% assign lap number
v2v_laps = NaN(size(v2v_index));
ego_laps = AssignLap(ego_index);
for k=1:max_opp
    v2v_laps(:,k) = AssignLap(v2v_index(:,k));
end
max_lap = max(v2v_laps(:), [], 'omitnan');


%% PLOTTING

% Trajectory figure
fig_traj = figure('Name','Trajectory');
ax_traj = axes('Parent', fig_traj, 'Position', [0.1 0.2 0.85 0.75]);

% Create dropdown menu for lap selection in Trajectory figure
popup_traj = uicontrol('Style', 'popupmenu', ...
          'String', compose("Lap %d", 1:max_lap), ...
          'Position', [20 20 100 25], ...
          'Callback', @(src, evt) updateLapSelection(src, evt, 'traj'));

setappdata(fig_traj, 'ax', ax_traj);
setappdata(fig_traj, 'popup', popup_traj);

% Speed figure
fig_speed = figure('Name','Speed Profile');
ax_speed = axes('Parent', fig_speed, 'Position', [0.1 0.2 0.85 0.75]);

% Create dropdown menu for lap selection in Speed figure
popup_speed = uicontrol('Style', 'popupmenu', ...
          'String', compose("Lap %d", 1:max_lap), ...
          'Position', [20 20 100 25], ...
          'Callback', @(src, evt) updateLapSelection(src, evt, 'speed'));

setappdata(fig_speed, 'ax', ax_speed);
setappdata(fig_speed, 'popup', popup_speed);

% Store shared data in base workspace or a struct accessible to both callbacks
sharedData.v2v_laps = v2v_laps;
sharedData.v2v_x = v2v_x;
sharedData.v2v_y = v2v_y;
sharedData.ego_x = ego_x;
sharedData.ego_y = ego_y;
sharedData.ego_laps = ego_laps;
sharedData.colors = colors;
sharedData.max_opp = max_opp;
sharedData.name_map = name_map;
sharedData.trajDatabase = trajDatabase;
sharedData.ego_index = ego_index;
sharedData.ego_vx = ego_vx;
sharedData.v2v_index = v2v_index;
sharedData.v2v_vx = v2v_vx;

% Save to root for callback access (or use nested functions / guidata)
setappdata(0, 'sharedData', sharedData);

% Initial plots, lap 1
updateTrajectory(1);
updateSpeed(1);

%% Callback to sync selections and update both plots
function updateLapSelection(src, ~, source)
    %sharedData = getappdata(0, 'sharedData');
    lap_selected = src.Value;

    % Update both dropdowns except the one that triggered the callback to avoid recursion
    if strcmp(source, 'traj')
        fig_speed = findobj('Name', 'Speed Profile');
        popup_speed = getappdata(fig_speed, 'popup');
        set(popup_speed, 'Value', lap_selected);
    else
        fig_traj = findobj('Name', 'Trajectory');
        popup_traj = getappdata(fig_traj, 'popup');
        set(popup_traj, 'Value', lap_selected);
    end

    % Update both plots
    updateTrajectory(lap_selected);
    updateSpeed(lap_selected);
end

function updateTrajectory(lap_selected)
    sharedData = getappdata(0, 'sharedData');
    fig_traj = findobj('Name', 'Trajectory');
    ax_traj = getappdata(fig_traj, 'ax');
    cla(ax_traj);
    hold(ax_traj, 'on');
    title(ax_traj, sprintf('Trajectory - Lap %d', lap_selected));

    idx = (sharedData.ego_laps == lap_selected);
    plot(ax_traj, sharedData.ego_x(idx), sharedData.ego_y(idx), '.', 'Color', sharedData.colors(1,:), 'DisplayName', '0 - POLIMOVE');

    for kk = 1:sharedData.max_opp
        opp_name = sharedData.name_map(kk);
        idx_opp = (sharedData.v2v_laps(:,kk) == lap_selected);
        plot(ax_traj, sharedData.v2v_x(idx_opp,kk), sharedData.v2v_y(idx_opp,kk), '.', 'Color', sharedData.colors(kk+1,:), ...
            'DisplayName', sprintf('%d - %s', kk, opp_name));
    end

    id_left = length(sharedData.trajDatabase) - 2;
    id_right = length(sharedData.trajDatabase) - 1;
    plot(ax_traj, sharedData.trajDatabase(id_left).X, sharedData.trajDatabase(id_left).Y, 'k', 'LineWidth', 1, 'HandleVisibility','off');
    plot(ax_traj, sharedData.trajDatabase(id_right).X, sharedData.trajDatabase(id_right).Y, 'k', 'LineWidth', 1, 'HandleVisibility','off');

    xlabel(ax_traj, 'X Position (m)');
    ylabel(ax_traj, 'Y Position (m)');
    legend(ax_traj, 'Location', 'best');
    grid(ax_traj, 'on');
    box(ax_traj, 'on');
    axis(ax_traj, 'equal');
end

function updateSpeed(lap_selected)
    sharedData = getappdata(0, 'sharedData');
    fig_speed = findobj('Name', 'Speed Profile');
    ax_speed = getappdata(fig_speed, 'ax');
    cla(ax_speed);
    hold(ax_speed, 'on');
    title(ax_speed, sprintf('Speed Profile - Lap %d', lap_selected));

    idx_ego = (sharedData.ego_laps == lap_selected);
    plot(ax_speed, sharedData.ego_index(idx_ego), sharedData.ego_vx(idx_ego), 'DisplayName', 'Ego Speed', 'Color', sharedData.colors(1,:));

    for kk = 1:sharedData.max_opp
        opp_name = sharedData.name_map(kk);
        idx_opp = (sharedData.v2v_laps(:, kk) == lap_selected);
        plot(ax_speed, sharedData.v2v_index(idx_opp, kk), sharedData.v2v_vx(idx_opp, kk), ...
            'Color', sharedData.colors(kk+1, :), 'DisplayName', sprintf('%d - %s', kk, opp_name));
    end

    xlabel(ax_speed, 'Closest Index');
    ylabel(ax_speed, 'Speed (km/h)');
    grid(ax_speed, 'on');
    box(ax_speed, 'on');
    legend(ax_speed, 'Location', 'best');
end



