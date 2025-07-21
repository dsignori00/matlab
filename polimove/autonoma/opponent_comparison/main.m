close all
clearvars -except log log_ego trajDatabase ego.index v2v.index opp_file

%#ok<*UNRCH>
%#ok<*INUSD>
%#ok<*USENS>
%#ok<*NASGU>
%#ok<*SAGROW>

%% Flags
multi_run           = false;                % if true, a different mat for ego and opponent will be loaded
ego_vs_ego          = false;               % if true, ego vs ego will be plotted
save_v2v            = false;               % if true, save the processed v2v data
opponent            = containers.Map({'KINETIZ','TUM','CONSTRUCTOR','UNIMORE','TII'}, [1,2,3,4,5]); 

%% Paths

import casadi.*;

addpath("../../common/utilities/")
addpath("../../common/constants/")
addpath("../../common/plot/")
addpath("func")
bags = "../../bags/";

%% Settings

run('PhysicalConstants.m');
run('PlottingStyle.m');
colors = lines(20); 

% opponent names
if(ego_vs_ego)
    opponent = containers.Map({'POLIMOVE 2'}, 1); 
end
opponent_names = keys(opponent);
opponent_values = values(opponent);
name_map = containers.Map(opponent_values, opponent_names);

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
fprintf("Loading data...")
if(~exist('log','var'))
    if(ego_vs_ego)
        [opp_file,path] = uigetfile(fullfile(bags,'*.mat'),'Load ego2 log');
    else
        [opp_file,path] = uigetfile(fullfile(bags,'*.mat'),'Load opponent log');
    end
        load(fullfile(path, opp_file));
end

if(multi_run)
    if(~exist('log_ego','var'))
        [file,path] = uigetfile(fullfile(bags,'*.mat'),'Load ego log');
        tmp = load(fullfile(path,file));
        log_ego = tmp.log;
        clearvars tmp;
    end
else
    log_ego = log;
end

[v2v,ego] = get_data(log, log_ego, ego_vs_ego);
v2v = valid_opponents(v2v);
fprintf(" done. \n")
DateTime = datetime(log.time_offset_nsec,'ConvertFrom','epochtime','TicksPerSecond',1e9,'Format','dd-MMM-yyyy HH:mm:ss');

%% PROCESSING

% Compute ego closest idx
if ~exist('ego.index', 'var')
    fprintf("Computing ego indexes ...")
    ego.index = NaN(size(ego.x));
    ego.index = compute_idx_sim(ego.x,ego.y, trajDatabase(10).X(:), trajDatabase(10).Y(:));
    fprintf(" done. \n")
end

if ~exist('v2v.index', 'var')
    fprintf("Computing opponent indexes ...")
    v2v.index = NaN(size(v2v.x));
    for i=1:size(v2v.x,2)
        v2v.index(:,i) = compute_idx_sim(v2v.x(:,i),v2v.y(:,i), trajDatabase(10).X(:), trajDatabase(10).Y(:));
    end
    fprintf(" done. \n")
end

% Assign lap number
v2v.laps = NaN(size(v2v.index,1),v2v.max_opp);
ego.laps = assign_lap(ego.index);
for k=1:v2v.max_opp 
    v2v.laps(:,k) = assign_lap(v2v.index(:,k));
end

% Lap Time progression
ego.laptime_prog = NaN(size(ego.stamp));  
v2v.laptime_prog = NaN(size(v2v.index,1),v2v.max_opp);  

unique_laps = unique(ego.laps(~isnan(ego.laps)));
ego.laptime = struct();
for lap = unique_laps'
    idx = (ego.laps == lap);
    ego.laptime_prog(idx) = ego.stamp(idx) - ego.stamp(find(idx, 1, 'first'));
    ego.laptime.seconds(lap) = max(ego.laptime_prog(idx));
    ego.laptime.fulltime(lap) = sec2laptime(ego.laptime.seconds(lap));
end

v2v.laptime = struct();
for k = 1:v2v.max_opp
    laps_k = v2v.laps(:,k);
    unique_laps = unique(laps_k(~isnan(laps_k)));
    
    for lap = unique_laps'
        idx = (laps_k == lap);
        lap_start_time = v2v.sens_stamp(find(idx, 1, 'first'));
        v2v.laptime_prog(idx, k) = v2v.sens_stamp(idx) - lap_start_time;
        v2v.laptime(k).seconds(lap) = max(v2v.laptime_prog(idx, k));
        v2v.laptime(k).fulltime(lap) = sec2laptime(v2v.laptime(k).seconds(lap));        
    end
end

% compute lateral acceleration and curvature
[~, name, ~] = fileparts(opp_file);
parts = split(name, "_");
filename = fullfile("mat", parts{1} + "_" + parts{4} + "_best_laps.mat");
if(~isfile(filename))
    best_laps = fit_best_laps(v2v, log, opp_file);
else
    load(filename);
end

%% SAVE PROCESSED DATA

if(save_v2v)
    [~, name, ~] = fileparts(opp_file);  % estrae il nome base senza estensione
    output_filename = fullfile(path, [name, '_processed.mat']);
    % Salvataggio
    save(output_filename, 'v2v');
    fprintf('Processed data saved: %s\n', output_filename);
end

%% PLOTTING

% Prepare opponent checklist
ids = sort(cell2mat(values(opponent)));
names = cellfun(@(k) name_map(k), num2cell(ids), 'UniformOutput', false);
checklist_strings = compose("%d - %s", ids(:), string(names(:)));
default_selection = 1:v2v.max_opp;

% === TRAJECTORY ===
[fig_traj, panel_traj, checkbox_traj, popup_ego, popup_opp] = ...
    create_figures('Trajectory', checklist_strings, default_selection, v2v, ego, 'traj');
ax_traj = create_axes_layout(fig_traj, 1);
setappdata(fig_traj, 'checklist', checkbox_traj);
setappdata(fig_traj, 'popup_ego', popup_ego);
setappdata(fig_traj, 'popup_opp', popup_opp);
setappdata(fig_traj, 'ax', ax_traj);

% === SPEED ===
[fig_speed, panel_speed, checkbox_speed, popup_ego_speed, popup_opp_speed] = ...
    create_figures('Speed Profile', checklist_strings, default_selection, v2v, ego, 'speed');
ax_speed = create_axes_layout(fig_speed, 2);
setappdata(fig_speed, 'checklist', checkbox_speed);
setappdata(fig_speed, 'popup_ego', popup_ego_speed);
setappdata(fig_speed, 'popup_opp', popup_opp_speed);
setappdata(fig_speed, 'ax', ax_speed(1));
setappdata(fig_speed, 'ax_lapdiff', ax_speed(2));

% === ACCELERATION ===
[fig_curv, panel_curv, checkbox_curv, ~, ~] = ...
    create_figures('Acceleration Profile', checklist_strings, default_selection, v2v, ego, 'curv');
ax_curv = create_axes_layout(fig_curv, 3);
setappdata(fig_curv, 'checklist', checkbox_curv);
setappdata(fig_curv, 'ax_a', ax_curv(1));
setappdata(fig_curv, 'ax_ax', ax_curv(2));
setappdata(fig_curv, 'ax_ay', ax_curv(3));


% Store shared data in base workspace or a struct accessible to both callbacks
sharedData.ego.x = ego.x;
sharedData.ego.y = ego.y;
sharedData.ego.laps = ego.laps;
sharedData.ego.index = ego.index;
sharedData.ego.vx = ego.vx;
sharedData.ego.laptime = ego.laptime;
sharedData.ego.laptime_prog = ego.laptime_prog;
sharedData.v2v.x = v2v.x;
sharedData.v2v.y = v2v.y;
sharedData.v2v.laps = v2v.laps;
sharedData.v2v.index = v2v.index;
sharedData.v2v.vx = v2v.vx;
sharedData.v2v.laptime = v2v.laptime;
sharedData.v2v.laptime_prog = v2v.laptime_prog;
sharedData.v2v.max_opp = v2v.max_opp;
sharedData.colors = colors;
sharedData.name_map = name_map;
sharedData.trajDatabase = trajDatabase;
sharedData.lap_ego = 1;
sharedData.lap_opp = 1;
sharedData.best_laps = best_laps;
setappdata(0, 'sharedData', sharedData);

% Initial plots, lap 1
update_trajectory_laps();
update_speed_laps();
update_acc_fig();

% Link x-axis 
ax_speed = getappdata(fig_speed, 'ax');
ax_lapdiff = getappdata(fig_speed, 'ax_lapdiff');
ax_a = getappdata(fig_curv, 'ax_a');
ax_ax = getappdata(fig_curv, 'ax_ax');
ax_ay = getappdata(fig_curv, 'ax_ay');
% linkaxes([ax_speed, ax_lapdiff], 'x');
linkaxes([ax_a, ax_ax, ax_ay], 'x');


