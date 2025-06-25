close all
clearvars -except log log_ref trajDatabase ego_index

%#ok<*UNRCH>
%#ok<*INUSD>
%#ok<*USENS>

%% Flags
multi_run = false;   % if true, a different mat for ego and opponent will be loaded
save_v2v  = false;   % if true, save the processed v2v data

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
opponent = containers.Map({'TUM','CONSTRUCTOR','HUMBDA', 'TII','MODENA','KINETIZ'}, [1, 4, 3, 2, 5, 6]);
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
if(~exist('log','var'))
    [opp_file,path] = uigetfile(fullfile(normal_path,'*.mat'),'Load log');
    load(fullfile(path, opp_file));
end
if(multi_run)
    if(~exist('log_ego','var'))
        [file,path] = uigetfile(fullfile(normal_path,'*.mat'),'Load ego log');
        tmp = load(fullfile(path,file));
        log_ego = tmp.log;
        clearvars tmp;
    end
else
    log_ego = log;
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
ego_stamp = log_ego.estimation.stamp__tot;
ego_x = log_ego.estimation.x_cog;
ego_y = log_ego.estimation.y_cog;
ego_vx = log_ego.estimation.vx*MPS2KPH; 
ego_yaw = log_ego.estimation.heading;
ego_ay = log_ego.estimation.ay;
ego_x(ego_x==0)=nan;
ego_y(ego_y==0)=nan;
ego_vx(ego_vx==0)=nan;
ego_yaw(ego_yaw==0)=nan;
ego_yaw = unwrap(ego_yaw);
ego_ay(ego_ay==0)=nan;

%% PROCESSING

% Keep only valid detections
v2v_x(:,max_opp+1:end)=[];
v2v_y(:,max_opp+1:end)=[];
v2v_vx(:,max_opp+1:end)=[];
v2v_yaw(:,max_opp+1:end)=[];
v2v_index(:,max_opp+1:end)=[];

% Compute ego closest idx
if(~exist('ego_index','var'))
    ego_index = NaN(size(ego_x));
    for i = 1:length(ego_x)
        if ~isnan(ego_x(i)) && ~isnan(ego_y(i))
            ego_index(i) = ComputeClosestIdx(ego_x(i), ego_y(i), trajDatabase(10));
        end
    end
end

% Assign lap number and calc curvature
v2v_laps = NaN(size(v2v_index,1),max_opp);
v2v_curv = NaN(size(v2v_index,1),max_opp);
ego_curv = CalcCurvature(ego_x, ego_y, 1, false);
ego_laps = AssignLap(ego_index);
for k=1:max_opp
    v2v_laps(:,k) = AssignLap(v2v_index(:,k));
    v2v_curv(:,k) = CalcCurvature(v2v_x(:,k), v2v_y(:,k), 1, false);
end
max_lap = max(v2v_laps(:), [], 'omitnan');

% % Trajectory smoothing
% ego_line.x = ego_x;
% ego_line.y = ego_y;
% ego_line = LineSmoothingEdgeCost(ego_line, 0.1, 2000, 1000, 5, 1e-07, 1e-07);
% for k=1:max_opp
%         opp_line.x = v2v_x(:,k);
%         opp_line.y = v2v_y(:,k);
%         opp_line = LineSmoothingEdgeCost(opp_line, 0.1, 2000, 1000, 5, 1e-07, 1e-07);
%         v2v_curv(:,k) = CalcCurvature(opp_line.x, opp_line.y, 1, true);
% end

% compute lateral acceleration
v2v_ay = v2v_curv.*v2v_vx.^2;

% Lap Time progression
ego_lap_time = NaN(size(ego_stamp));  
v2v_lap_time = NaN(size(v2v_index,1),max_opp);  

unique_laps = unique(ego_laps(~isnan(ego_laps)));
for lap = unique_laps'
    idx = (ego_laps == lap);
    ego_lap_time(idx) = ego_stamp(idx) - ego_stamp(find(idx, 1, 'first'));
end

for k = 1:max_opp
    laps_k = v2v_laps(:,k);
    unique_laps = unique(laps_k(~isnan(laps_k)));
    
    for lap = unique_laps'
        idx = (laps_k == lap);
        lap_start_time = v2v_sens_stamp(find(idx, 1, 'first'));
        v2v_lap_time(idx, k) = v2v_sens_stamp(idx) - lap_start_time;
    end
end
%% SAVE PROCESSED DATA

if(save_v2v)
    v2v_data = struct();

    v2v_data.x        = v2v_x;          % [m]  posizione X dei veicoli rivali
    v2v_data.y        = v2v_y;          % [m]  posizione Y dei veicoli rivali
    v2v_data.vx       = v2v_vx;         % [m/s] velocità longitudinale
    v2v_data.yaw      = v2v_yaw;        % [rad] angolo di imbardata
    v2v_data.index    = v2v_index;      % indice punto traiettoria più vicino

    v2v_data.laps     = v2v_laps;       % numero di giro assegnato
    v2v_data.curv     = v2v_curv;       % curvatura (1/raggio)
    v2v_data.ay       = v2v_ay;         % accelerazione laterale
    v2v_data.lap_time = v2v_lap_time;   % tempo di percorrenza giro (s)

    v2v_data.max_opp  = max_opp;        % numero di avversari considerati
    v2v_data.max_lap  = max_lap;        % massimo numero di giri trovati

    [~, name, ~] = fileparts(opp_file);  % estrae il nome base senza estensione
    output_filename = fullfile(path, [name, '_processed.mat']);

    % Salvataggio
    save(output_filename, 'v2v_data');
    fprintf('Processed data saved: %s\n', output_filename);
end


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
ax_speed = subplot(2,1,1, 'Parent', fig_speed);  % Speed plot
ax_lapdiff = subplot(2,1,2, 'Parent', fig_speed);  % Lap time delta plot

% Create dropdown menu for lap selection in Speed figure
popup_speed = uicontrol('Style', 'popupmenu', ...
          'String', compose("Lap %d", 1:max_lap), ...
          'Position', [20 20 100 25], ...
          'Callback', @(src, evt) updateLapSelection(src, evt, 'speed'));

setappdata(fig_speed, 'ax', ax_speed);
setappdata(fig_speed, 'ax_lapdiff', ax_lapdiff);  % Add new axis handle
setappdata(fig_speed, 'popup', popup_speed);

% Curvature and Lateral Acceleration figure
fig_curv = figure('Name', 'Curvature and Lateral Acceleration');

ax_curv = subplot(2,1,1, 'Parent', fig_curv);
ax_ay = subplot(2,1,2, 'Parent', fig_curv);

% Create dropdown for lap selection
popup_curv = uicontrol('Style', 'popupmenu', ...
          'String', compose("Lap %d", 1:max_lap), ...
          'Position', [20 20 100 25], ...
          'Callback', @(src, evt) updateCurvPlot(src, evt, fig_curv));

setappdata(fig_curv, 'ax_curv', ax_curv);
setappdata(fig_curv, 'ax_ay', ax_ay);
setappdata(fig_curv, 'popup', popup_curv);

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
sharedData.v2v_curv = v2v_curv;
sharedData.v2v_ay = v2v_ay;
sharedData.ego_curv = ego_curv;
sharedData.ego_ay = ego_ay;
sharedData.ego_lap_time = ego_lap_time;
sharedData.v2v_lap_time = v2v_lap_time;

% Save to root for callback access (or use nested functions / guidata)
setappdata(0, 'sharedData', sharedData);

% Initial plots, lap 1
updateTrajectory(1);
updateSpeed(1);
updateCurvPlot(1);

%% Callback to sync selections and update both plots

function updateLapSelection(src, ~, source)
    lap_selected = src.Value;

    % Find all figures by name
    fig_traj = findobj('Name', 'Trajectory');
    fig_speed = findobj('Name', 'Speed Profile');
    fig_curv = findobj('Name', 'Curvature and Lateral Acceleration');

    % Update dropdowns of other figures (not the one that triggered this callback)
    switch source
        case 'traj'
            % Update speed popup
            if ~isempty(fig_speed)
                popup_speed = getappdata(fig_speed, 'popup');
                if popup_speed.Value ~= lap_selected
                    set(popup_speed, 'Value', lap_selected);
                end
            end
            % Update curvature popup
            if ~isempty(fig_curv)
                popup_curv = getappdata(fig_curv, 'popup');
                if popup_curv.Value ~= lap_selected
                    set(popup_curv, 'Value', lap_selected);
                end
            end
            
        case 'speed'
            % Update trajectory popup
            if ~isempty(fig_traj)
                popup_traj = getappdata(fig_traj, 'popup');
                if popup_traj.Value ~= lap_selected
                    set(popup_traj, 'Value', lap_selected);
                end
            end
            % Update curvature popup
            if ~isempty(fig_curv)
                popup_curv = getappdata(fig_curv, 'popup');
                if popup_curv.Value ~= lap_selected
                    set(popup_curv, 'Value', lap_selected);
                end
            end
            
        case 'curv'
            % Update trajectory popup
            if ~isempty(fig_traj)
                popup_traj = getappdata(fig_traj, 'popup');
                if popup_traj.Value ~= lap_selected
                    set(popup_traj, 'Value', lap_selected);
                end
            end
            % Update speed popup
            if ~isempty(fig_speed)
                popup_speed = getappdata(fig_speed, 'popup');
                if popup_speed.Value ~= lap_selected
                    set(popup_speed, 'Value', lap_selected);
                end
            end
    end

    % Update all plots regardless of source
    if ~isempty(fig_traj)
        updateTrajectory(lap_selected);
    end
    if ~isempty(fig_speed)
        updateSpeed(lap_selected);
    end
    if ~isempty(fig_curv)
        updateCurvPlot(lap_selected);
    end

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
    legend(ax_traj, 'Location', 'northeast');
    grid(ax_traj, 'on');
    box(ax_traj, 'on');
    axis(ax_traj, 'equal');
end

function updateSpeed(lap_selected)
    sharedData = getappdata(0, 'sharedData');
    fig_speed = findobj('Name', 'Speed Profile');
    ax_speed = getappdata(fig_speed, 'ax');
    ax_lapdiff = getappdata(fig_speed, 'ax_lapdiff');

    % Clear and prepare plots
    cla(ax_speed);
    cla(ax_lapdiff);
    hold(ax_speed, 'on');
    hold(ax_lapdiff, 'on');

    title(ax_speed, sprintf('Speed Profile - Lap %d', lap_selected));
    title(ax_lapdiff, sprintf('Lap-relative Time Difference - Lap %d', lap_selected));

    % Plot Ego Speed
    idx_ego = (sharedData.ego_laps == lap_selected);
    plot(ax_speed, sharedData.ego_index(idx_ego), sharedData.ego_vx(idx_ego), ...
         'DisplayName', 'Ego Speed', 'Color', sharedData.colors(1,:));

    ego_index = sharedData.ego_index(idx_ego);
    ego_lap_time = sharedData.ego_lap_time(idx_ego);
    
    % Ensure unique indices for ego
    [ego_index_unique, ia] = unique(ego_index, 'stable');
    ego_lap_time_unique = ego_lap_time(ia);

    yline(ax_lapdiff, [0 0], 'Color', 'k', 'LineStyle', '--', 'HandleVisibility', 'off');

    for kk = 1:sharedData.max_opp
        opp_name = sharedData.name_map(kk);
        idx_opp = (sharedData.v2v_laps(:, kk) == lap_selected);

        % Speed Plot
        plot(ax_speed, sharedData.v2v_index(idx_opp, kk), sharedData.v2v_vx(idx_opp, kk), ...
             'Color', sharedData.colors(kk+1, :), ...
             'DisplayName', sprintf('%d - %s', kk, opp_name));

        % Lap Time Difference Plot
        if nnz(idx_opp) > 1
            opp_index = double(sharedData.v2v_index(idx_opp, kk));
            opp_lap_time = sharedData.v2v_lap_time(idx_opp, kk);

            ego_interp = interp1(ego_index_unique, ego_lap_time_unique, opp_index, 'linear', 'extrap');
            lap_time_diff = opp_lap_time - ego_interp;

            plot(ax_lapdiff, opp_index, lap_time_diff, ...
                'Color', sharedData.colors(kk+1,:), ...
                'DisplayName', sprintf('%d - %s', kk, opp_name));
        end
    end

    % Final formatting
    xlabel(ax_speed, 'Closest Index');
    ylabel(ax_speed, 'Speed (km/h)');
    legend(ax_speed, 'Location', 'northeast');
    grid(ax_speed, 'on');
    box(ax_speed, 'on');

    xlabel(ax_lapdiff, 'Closest Index');
    ylabel(ax_lapdiff, 'Delta Lap Time (s)');
    legend(ax_lapdiff, 'Location', 'northeast');
    grid(ax_lapdiff, 'on');
    box(ax_lapdiff, 'on');

end


function updateCurvPlot(lap_selected)
    sharedData = getappdata(0, 'sharedData');
    fig_curv = findobj('Name', 'Curvature and Lateral Acceleration');
    ax_curv = getappdata(fig_curv, 'ax_curv');
    ax_ay = getappdata(fig_curv, 'ax_ay');

    % Clear axes
    cla(ax_curv);
    cla(ax_ay);
    hold(ax_curv, 'on');
    hold(ax_ay, 'on');

    % Plot curvature
    idx_ego = (sharedData.ego_laps == lap_selected);
    plot(ax_curv, sharedData.ego_index(idx_ego), sharedData.ego_curv(idx_ego), 'Color', sharedData.colors(1,:), 'DisplayName', '0 - POLIMOVE');
    for k=1:sharedData.max_opp
        idx_opp = (sharedData.v2v_laps(:,k) == lap_selected);
        plot(ax_curv, sharedData.v2v_index(idx_opp,k), sharedData.v2v_curv(idx_opp,k), ...
            'Color', sharedData.colors(k+1,:), 'DisplayName', sprintf('%d - %s', k, sharedData.name_map(k)));
    end
    ylabel(ax_curv, 'Curvature (1/m)');
    title(ax_curv, sprintf('Curvature - Lap %d', lap_selected));
    legend(ax_curv, 'Location', 'northeast');
    grid(ax_curv, 'on');
    box(ax_curv, 'on');
    % max_curv = 1e-3;
    % ylim(ax_curv, [-max_curv, max_curv]);

    % Plot lateral acceleration
    plot(ax_ay, sharedData.ego_index(idx_ego), sharedData.ego_ay(idx_ego), 'Color', sharedData.colors(1,:), 'DisplayName', '0 - POLIMOVE');
    for k=1:sharedData.max_opp
        idx_opp = (sharedData.v2v_laps(:,k) == lap_selected);
        plot(ax_ay, sharedData.v2v_index(idx_opp,k), sharedData.v2v_ay(idx_opp,k), ...
            'Color', sharedData.colors(k+1,:), 'DisplayName', sprintf('%d - %s', k, sharedData.name_map(k)));
    end
    ylabel(ax_ay, 'Lateral Acceleration (m/s^2)');
    xlabel(ax_ay, 'Closest Index');
    title(ax_ay, sprintf('Lateral Acceleration - Lap %d', lap_selected));
    legend(ax_ay, 'Location', 'northeast');
    grid(ax_ay, 'on');
    box(ax_ay, 'on');
    % max_ay = max_curv*(300*MPS2KPH)^2;
    % ylim(ax_ay, [-max_ay, max_ay]);

end


% Link x-axis limits manually between Speed and Curvature figures
ax_speed = getappdata(fig_speed, 'ax');
ax_lapdiff = getappdata(fig_speed, 'ax_lapdiff');
ax_curv = getappdata(fig_curv, 'ax_curv');
ax_ay = getappdata(fig_curv, 'ax_ay');

linkaxes([ax_speed, ax_curv, ax_ay, ax_lapdiff], 'x');


