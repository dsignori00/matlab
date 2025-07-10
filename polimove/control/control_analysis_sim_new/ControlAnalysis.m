clc
clearvars
% close all

%% Settings

% Database
database_name = 'YasMarinaSim';

%% Add paths

% Define folders

polimove_path                  = fullfile('..', '..');
global_functions_COMMON_folder = fullfile(polimove_path, 'common');
traj_database                  = fullfile(polimove_path, 'databases', strcat(database_name, '.mat'));
data_folder                    = "/home/daniele/Documents/PoliMOVE/04_Bags/";

 
% Add paths
addpath(genpath(global_functions_COMMON_folder));
addpath(genpath(data_folder));

addpath(genpath('plots'));
addpath(genpath('functions'));

plot_options;


%% Load data
% Load database
traj_DB = load(traj_database).trajDatabase;

% Load data
[data_filenames, data_path] = uigetfile(data_folder, '*.m', 'MultiSelect', 'on');
if ~iscell(data_filenames)
    data_filenames = {data_filenames};
end
n_logs = length(data_filenames);
logs = cell(1, n_logs);
for i = 1 : n_logs
    logs{i} = load(fullfile(data_path, data_filenames{i})).log;
end


%% Plot for each single bag
for i_log = 1 : n_logs
    %% For each bag
    disp(['Bag ' num2str(i) ': ' data_filenames{i}])
    log = logs{i_log};
    
    % Convert to new bag format if needed
    if ~isfield(log, 'vehicle_fbk')
        log = old2new_mat(log);
        if ~isfield(log, 'vehicle_fbk')
            log.vehicle_fbk = log.vehicle_fbk_eva;
        end
    end

    % Init axes vectors
    ax_time     = gobjects(0); % vector of axis for time plots
    ax_gg       = gobjects(0); % vector of axis for gg plots
    ax_mu       = gobjects(0); % vector of axis for mu-normalized gg plots
    ax_xy       = gobjects(0); % vector of axis for xy plots
    ax_space    = gobjects(0); % vector of axis for space plots

    %%% GENERAL %%%%
    track_progress
    track_map

    %%% TESTPLAN %%%
    % testplan_parameters

    %%% ACTUATORS %%%
    % actuators_throttle
    % actuators_gears
    % actuators_gears_stability
    actuators_brake
    % actuators_steer
    
    %%% VEHICLE DYNAMICS %%%
    dynamics_lateral
    dynamics_tires_lateral
    dynamics_tires_longitudinal
    dynamics_tires_combined
    dynamics_tires_xy
    dynamics_stability
    dynamics_vertical_loads
    dynamics_gg_plot

    %%% LONGITUDINAL CONTROL %%%
    % long_speed_ctrl
    % long_acceleration_ctrl
    % long_gear_ctrl
    % long_traction_ctrl
    long_slip_ctrl
    % long_distance_ctrl

    %%% LATERAL CONTROL %%%
    lat_ecog_ctrl
    lat_yawrate_ctrl

    %%% VEHICLE LIMTIS
    % Eva
    k_drag = 9.9057e-04;
    k_downforce = 0.0024;
    % vehicle_limits
    % vehicle_limits_gg

    %%% SPACE PLOTS %%%
    space_actuators
    % space_cmd
    space_tracking
    space_dynamics
    space_slips
    space_slips_long
    space_slips_lat
    space_tire_temp
    % space_vertical_loads_long
    % space_vertical_loads_lat

    % Link axes
    if ~isempty(ax_time)
        linkaxes(ax_time, 'x');
    end
    if ~isempty(ax_xy)
        linkaxes(ax_xy, 'xy');
    end
    if ~isempty(ax_space)
        linkaxes(ax_space, 'x');
    end

end

return
%% Plot for bag comparison
if n_bags > 1

    padding_idxs = 10;
    ax_space = [];

    % Select laps (counting from 0, leave empty to plot all laps)
    laps = [1];

    % Plots
    multibag_space_actuators
    % multibag_space_gear_shifts
    % multibag_control

end

    if ~isempty(ax_space)
        linkaxes(ax_space, 'x');
    end

