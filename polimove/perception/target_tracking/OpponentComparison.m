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

% Checkbox for opponents selection
ids = sort(cell2mat(values(opponent))); 
names = cellfun(@(k) name_map(k), num2cell(ids), 'UniformOutput', false);
checklist_strings = compose("%d - %s", ids(:), string(names(:)));
default_selection = 1:max_opp;

% === TRAJECTORY FIGURE ===
fig_traj = figure('Name','Trajectory');

% Opponent panel (left side, vertical layout)
panel_traj = uipanel('Parent', fig_traj, ...
    'Units','normalized', ...
    'Position',[0.02 0.1 0.12 0.8], ...
    'Title','Controls');

% Axes
ax_left = 0.14 + 0.05; 
ax_traj = axes('Parent', fig_traj, ...
    'Position', [ax_left, 0.1, 1-ax_left-0.05, 0.8]);

% --- Checklist (top of the panel) ---
checkbox_traj = createOpponentCheckboxes(panel_traj, checklist_strings, default_selection, 'traj');
setappdata(fig_traj, 'checklist', checkbox_traj);

% Compute vertical offset below checklist
n_cb = numel(checkbox_traj);
checklist_height = n_cb * 0.04 + 0.05;  
nextY = 1 - checklist_height - 0.08;

% --- Opponent Lap label and dropdown ---
uicontrol('Parent', panel_traj, 'Style', 'text', 'String', 'Opponent Lap:', ...
    'Units','normalized', 'Position', [0.05, nextY, 0.9, 0.05], 'HorizontalAlignment', 'left');
nextY = nextY - 0.04;

popup_opp_traj = uicontrol('Parent', panel_traj, 'Style', 'popupmenu', ...
    'String', compose("Lap %d", 1:max_lap), ...
    'Units','normalized', 'Position', [0.05, nextY, 0.9, 0.06], ...
    'Callback', @(src,evt)updateLapSelection(src,evt,'opp'));

nextY = nextY - 0.05;

% --- Ego Lap label and dropdown ---
uicontrol('Parent', panel_traj, 'Style', 'text', 'String', 'Ego Lap:', ...
    'Units','normalized', 'Position', [0.05, nextY, 0.9, 0.05], 'HorizontalAlignment', 'left');
nextY = nextY - 0.04;

popup_ego_traj = uicontrol('Parent', panel_traj, 'Style', 'popupmenu', ...
    'String', compose("Lap %d", 1:max_lap), ...
    'Units','normalized', 'Position', [0.05, nextY, 0.9, 0.06], ...
    'Callback', @(src,evt)updateLapSelection(src,evt,'ego'));

% Save to appdata
setappdata(fig_traj, 'popup_ego', popup_ego_traj);
setappdata(fig_traj, 'popup_opp', popup_opp_traj);
setappdata(fig_traj, 'ax', ax_traj);


% === SPEED FIGURE (mirrors Trajectory layout) ===
fig_speed = figure('Name','Speed Profile');

% Main axis on the right
ax_left = 0.14 + 0.05;
ax_lapdiff = axes('Parent', fig_speed, ...
    'Position', [ax_left, 0.575, 1 - ax_left - 0.05, 0.30]);  % Top axis
ax_speed = axes('Parent', fig_speed, ...
    'Position', [ax_left, 0.175, 1 - ax_left - 0.05, 0.30]);  % Bottom axis

% Control panel (left)
panel_speed = uipanel('Parent', fig_speed, ...
    'Units','normalized', 'Position',[0.02 0.1 0.12 0.8], ...
    'Title','Controls');

% Opponent checkboxes
checkbox_speed = createOpponentCheckboxes(panel_speed, checklist_strings, default_selection, 'speed');
setappdata(fig_speed, 'checklist', checkbox_speed);

% Compute vertical offset
n_cb = numel(checkbox_speed);
checklist_height = n_cb * 0.04 + 0.05;
nextY = 1 - checklist_height - 0.08;

% Opponent Lap label & dropdown
uicontrol('Parent', panel_speed, 'Style', 'text', 'String', 'Opponent Lap:', ...
    'Units','normalized', 'Position', [0.05, nextY, 0.9, 0.05], 'HorizontalAlignment', 'left');
nextY = nextY - 0.04;
popup_opp_speed = uicontrol('Parent', panel_speed, 'Style', 'popupmenu', ...
    'String', compose("Lap %d", 1:max_lap), ...
    'Units','normalized', 'Position', [0.05, nextY, 0.9, 0.06], ...
    'Callback', @(src,evt) updateLapSelection(src,evt,'opp'));
nextY = nextY - 0.05;

% Ego Lap label & dropdown
uicontrol('Parent', panel_speed, 'Style', 'text', 'String', 'Ego Lap:', ...
    'Units','normalized', 'Position', [0.05, nextY, 0.9, 0.05], 'HorizontalAlignment', 'left');
nextY = nextY - 0.04;
popup_ego_speed = uicontrol('Parent', panel_speed, 'Style', 'popupmenu', ...
    'String', compose("Lap %d", 1:max_lap), ...
    'Units','normalized', 'Position', [0.05, nextY, 0.9, 0.06], ...
    'Callback', @(src,evt) updateLapSelection(src,evt,'ego'));

% Store handles
setappdata(fig_speed, 'popup_opp', popup_opp_speed);
setappdata(fig_speed, 'popup_ego', popup_ego_speed);
setappdata(fig_speed, 'ax', ax_speed);
setappdata(fig_speed, 'ax_lapdiff', ax_lapdiff);


% === CURVATURE FIGURE (same layout) ===
fig_curv = figure('Name','Curvature and Lateral Acceleration');

ax_left = 0.14 + 0.05;
ax_curv = axes('Parent', fig_curv, ...
    'Position', [ax_left, 0.575, 1 - ax_left - 0.05, 0.30]);  % Top axis
ax_ay = axes('Parent', fig_curv, ...
    'Position', [ax_left, 0.175, 1 - ax_left - 0.05, 0.30]);  % Bottom axis

panel_curv = uipanel('Parent', fig_curv, ...
    'Units','normalized', 'Position',[0.02 0.1 0.12 0.8], ...
    'Title','Controls');

checkbox_curv = createOpponentCheckboxes(panel_curv, checklist_strings, default_selection, 'curv');
setappdata(fig_curv, 'checklist', checkbox_curv);

n_cb = numel(checkbox_curv);
checklist_height = n_cb * 0.04 + 0.05;
nextY = 1 - checklist_height - 0.08;

uicontrol('Parent', panel_curv, 'Style', 'text', 'String', 'Opponent Lap:', ...
    'Units','normalized', 'Position', [0.05, nextY, 0.9, 0.05], 'HorizontalAlignment', 'left');
nextY = nextY - 0.04;
popup_opp_curv = uicontrol('Parent', panel_curv, 'Style', 'popupmenu', ...
    'String', compose("Lap %d", 1:max_lap), ...
    'Units','normalized', 'Position', [0.05, nextY, 0.9, 0.06], ...
    'Callback', @(src,evt) updateLapSelection(src,evt,'opp'));
nextY = nextY - 0.05;

uicontrol('Parent', panel_curv, 'Style', 'text', 'String', 'Ego Lap:', ...
    'Units','normalized', 'Position', [0.05, nextY, 0.9, 0.05], 'HorizontalAlignment', 'left');
nextY = nextY - 0.04;
popup_ego_curv = uicontrol('Parent', panel_curv, 'Style', 'popupmenu', ...
    'String', compose("Lap %d", 1:max_lap), ...
    'Units','normalized', 'Position', [0.05, nextY, 0.9, 0.06], ...
    'Callback', @(src,evt) updateLapSelection(src,evt,'ego'));

setappdata(fig_curv, 'popup_opp', popup_opp_curv);
setappdata(fig_curv, 'popup_ego', popup_ego_curv);
setappdata(fig_curv, 'ax_curv', ax_curv);
setappdata(fig_curv, 'ax_ay', ax_ay);


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
sharedData.lap_ego = 1;
sharedData.lap_opp = 1;


% Save to root for callback access (or use nested functions / guidata)
setappdata(0, 'sharedData', sharedData);

% Initial plots, lap 1
updateTrajectoryLaps();
updateSpeedLaps();
updateCurvLaps();

%% Callback to sync selections and update both plots

function updateLapSelection(src,~,whichLap)
    shared = getappdata(0,'sharedData');
    shared.(['lap_' whichLap]) = src.Value;
    setappdata(0,'sharedData',shared);

    % Update all dropdowns to stay synced
    tags = {'traj','speed','curv'};
    for t = tags
        fig = findobj('Name', figureName(t{1}));
        if isempty(fig), continue; end
        popup = getappdata(fig, ['popup_' whichLap]);
        if ~isempty(popup) && isvalid(popup) && popup.Value ~= src.Value
            popup.Value = src.Value;
        end
    end

    % Refresh all plots
    updateTrajectoryLaps;
    updateSpeedLaps;
    updateCurvLaps;
end

function nm = figureName(tag)
    switch tag
        case 'traj', nm = 'Trajectory';
        case 'speed', nm = 'Speed Profile';
        case 'curv', nm = 'Curvature and Lateral Acceleration';
    end
end


function sel = getSelectedOpponents(figH)
    % Return index vector of selected opponents for a given figure
    cbs = getappdata(figH,'checklist');
    sel = find(arrayfun(@(h) get(h,'Value'), cbs));
end

function syncCheckboxGroup(figH, selIdx)
    % Force the check-boxes in figH to reflect selIdx
    if isempty(figH), return; end
    cbs = getappdata(figH,'checklist');
    for k = 1:numel(cbs)
        cbs(k).Value = ismember(k, selIdx);
    end
end

function cb = createOpponentCheckboxes(parentFig, checklist_strings, default_selection, tag)
    nOpp = numel(checklist_strings);
    base_height_per_opp = 0.028;  
    panel_height = min(base_height_per_opp * nOpp + 0.05, 0.9);  

    panel = uipanel('Parent',parentFig, ...
        'Units', 'normalized', ...
        'Position', [0.02, 0.95 - panel_height, 0.90, panel_height], ...
        'Title','Opponents', ...
        'BorderType','etchedin');

    cb = gobjects(nOpp,1);
    for k = 1:nOpp
        base_height_per_opp = 0.15;
        ypos = 1 - (k * base_height_per_opp) - 0.08;  % Top to bottom
        cb(k) = uicontrol('Parent', panel, ...
            'Style', 'checkbox', ...
            'String', checklist_strings{k}, ...
            'Units', 'normalized', ...
            'Position', [0.05, ypos, 0.9, base_height_per_opp], ...
            'Value', ismember(k, default_selection), ...
            'Callback', @(src, evt) updateOpponentSelection(src, evt, tag));
    end
end

function updateOpponentSelection(~,~,sourceTag)
    % Determine source figure
    switch sourceTag
        case 'traj'
            fig_source = findobj('Name', 'Trajectory');
        case 'speed'
            fig_source = findobj('Name', 'Speed Profile');
        case 'curv'
            fig_source = findobj('Name', 'Curvature and Lateral Acceleration');
        otherwise
            return;
    end

    % Get selected opponents from the source figure
    selected_opps = getSelectedOpponents(fig_source);

    % Sync checkboxes across all figures
    fig_traj = findobj('Name', 'Trajectory');
    fig_speed = findobj('Name', 'Speed Profile');
    fig_curv = findobj('Name', 'Curvature and Lateral Acceleration');

    syncCheckboxGroup(fig_traj, selected_opps);
    syncCheckboxGroup(fig_speed, selected_opps);
    syncCheckboxGroup(fig_curv, selected_opps);

    % Update all plots using stored sharedData.lap_ego and lap_opp
    updateTrajectoryLaps();
    updateSpeedLaps();
    updateCurvLaps();
end




function updateTrajectoryLaps()
    shared = getappdata(0,'sharedData');
    fig = findobj('Name','Trajectory'); if isempty(fig), return; end
    ax = getappdata(fig,'ax'); cla(ax); hold(ax,'on');
    idxE = shared.ego_laps == shared.lap_ego;
    plot(ax, shared.ego_x(idxE), shared.ego_y(idxE), '.', 'Color',shared.colors(1,:),'DisplayName','Ego');
    opps = getSelectedOpponents(fig);
    for kk = opps(:)'
        idxO = shared.v2v_laps(:,kk) == shared.lap_opp;
        plot(ax, shared.v2v_x(idxO,kk), shared.v2v_y(idxO,kk), '.', 'Color',shared.colors(kk+1,:), 'DisplayName', shared.name_map(kk));
    end
    legend(ax,'Location','northeast'); axis(ax,'equal'); grid(ax,'on'); box(ax,'on');
    id_left = length(shared.trajDatabase) - 2;
    id_right = length(shared.trajDatabase) - 1;
    plot(ax, shared.trajDatabase(id_left).X, shared.trajDatabase(id_left).Y, 'k', 'LineWidth', 1, 'HandleVisibility','off');
    plot(ax, shared.trajDatabase(id_right).X, shared.trajDatabase(id_right).Y, 'k', 'LineWidth', 1, 'HandleVisibility','off');
    title(ax, sprintf('Trajectory - Opp Lap %d vs Ego Lap %d', shared.lap_opp, shared.lap_ego));
end

function updateSpeedLaps
    shared = getappdata(0, 'sharedData');
    fig = findobj('Name', 'Speed Profile');
    if isempty(fig), return; end

    lapE = shared.lap_ego;
    lapO = shared.lap_opp;

    ax_speed = getappdata(fig, 'ax');
    ax_lapdiff = getappdata(fig, 'ax_lapdiff');

    cla(ax_speed); cla(ax_lapdiff);
    hold(ax_speed, 'on'); hold(ax_lapdiff, 'on');

    title(ax_speed, sprintf('Speed Profile - Opp Lap %d vs Ego Lap %d', lapO, lapE));
    title(ax_lapdiff, sprintf('Lap-relative Time Difference - Opp Lap %d vs Ego Lap %d', lapO, lapE));

    % Plot Ego Speed
    idxE = shared.ego_laps == lapE;
    plot(ax_speed, shared.ego_index(idxE), shared.ego_vx(idxE), ...
         'DisplayName', 'Ego Speed', 'Color', shared.colors(1,:));

    % Lap time interpolation setup
    ego_index = shared.ego_index(idxE);
    ego_lap_time = shared.ego_lap_time(idxE);
    [uI, ia] = unique(double(ego_index), 'stable');  % ensure double type
    egoLT = ego_lap_time;

    yline(ax_lapdiff, 0, 'Color', 'k', 'LineStyle', '--', 'HandleVisibility', 'off');

    % Plot Opponents
    selected_opps = getSelectedOpponents(fig);
    for kk = selected_opps(:)'
        idxO = shared.v2v_laps(:, kk) == lapO;
        if ~any(idxO), continue; end

        opp_index = double(shared.v2v_index(idxO, kk));  % ensure double
        opp_speed = shared.v2v_vx(idxO, kk);
        opp_lap_time = shared.v2v_lap_time(idxO, kk);
        opp_name = shared.name_map(kk);

        plot(ax_speed, opp_index, opp_speed, ...
             'Color', shared.colors(kk+1, :), ...
             'DisplayName', sprintf('%d - %s', kk, opp_name));

        if ~isempty(uI)
            egoInterp = interp1(uI, egoLT(ia), opp_index, 'linear', 'extrap');
            lap_time_diff = opp_lap_time - egoInterp;
            plot(ax_lapdiff, opp_index, lap_time_diff, ...
                 'Color', shared.colors(kk+1,:), ...
                 'DisplayName', sprintf('%d - %s', kk, opp_name));
        end
    end

    xlabel(ax_speed, 'Closest Index');
    ylabel(ax_speed, 'Speed (km/h)');
    legend(ax_speed, 'Location', 'northeast');
    grid(ax_speed, 'on'); box(ax_speed, 'on');

    xlabel(ax_lapdiff, 'Closest Index');
    ylabel(ax_lapdiff, 'Δ Lap Time (s)');
    legend(ax_lapdiff, 'Location', 'northeast');
    grid(ax_lapdiff, 'on'); box(ax_lapdiff, 'on');
end


function updateCurvLaps()
    shared = getappdata(0,'sharedData');
    fig = findobj('Name','Curvature and Lateral Acceleration'); if isempty(fig), return; end
    axC = getappdata(fig,'ax_curv'); axA = getappdata(fig,'ax_ay');
    cla(axC); cla(axA); hold(axC,'on'); hold(axA,'on');
    idxE = shared.ego_laps == shared.lap_ego;
    plot(axC, shared.ego_index(idxE), shared.ego_curv(idxE), 'DisplayName','Ego','Color',shared.colors(1,:));
    plot(axA, shared.ego_index(idxE), shared.ego_ay(idxE), 'DisplayName','Ego','Color',shared.colors(1,:));
    for kk = getSelectedOpponents(fig)'
        idxO = shared.v2v_laps(:,kk) == shared.lap_opp; if ~any(idxO), continue; end
        plot(axC, shared.v2v_index(idxO,kk), shared.v2v_curv(idxO,kk), 'DisplayName', shared.name_map(kk), 'Color',shared.colors(kk+1,:));
        plot(axA, shared.v2v_index(idxO,kk), shared.v2v_ay(idxO,kk), 'DisplayName', shared.name_map(kk), 'Color',shared.colors(kk+1,:));
    end
    xlabel(axC,'Index'); ylabel(axC,'Curvature (1/m)'); legend(axC,'Location','northeast');
    xlabel(axA,'Index'); ylabel(axA,'Lateral Accel (m/s²)'); legend(axA,'Location','northeast');
    grid(axC,'on'); grid(axA,'on'); box(axC,'on'); box(axA,'on');
end


% Link x-axis limits manually between Speed and Curvature figures
ax_speed = getappdata(fig_speed, 'ax');
ax_lapdiff = getappdata(fig_speed, 'ax_lapdiff');
ax_curv = getappdata(fig_curv, 'ax_curv');
ax_ay = getappdata(fig_curv, 'ax_ay');

linkaxes([ax_speed, ax_curv, ax_ay, ax_lapdiff], 'x');


