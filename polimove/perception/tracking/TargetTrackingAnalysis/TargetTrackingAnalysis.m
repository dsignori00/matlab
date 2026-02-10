close all
clearvars -except log log_2 log_3 log_ref trajDatabase

use_ref     = true;
use_sim_ref = false;
compare     = true;
compare2    = true;

opp_idx     = 1;
err_thr     = 10;
err_stats = {'yaw_map','vx','ax'};

%#ok<*UNRCH>
%#ok<*INUSD>

%% Paths

addpath("../../../common/utilities/")
addpath("../../../../common/constants/")
addpath("../../../common/plot/")
addpath("../../../../common/graphic_tools/")
addpath("../../utils/")
addpath("func/")
addpath("figs/")
normal_path = "../../../bags";
opp_dir = "../../opponent_gps/mat/";

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
name1 = 'cca';

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
    name2 = 'ctra';
end

% load log 3
if(compare2)
    if (~exist('log_3','var'))
        [file,path] = uigetfile(fullfile(normal_path,'*.mat'),'Load log_3');
        if isequal(file, 0)  
        disp('User canceled file selection.');
        else
        tmp = load(fullfile(path,file));
        log_3 = tmp.log;
        clearvars tmp;
        end
    end
    name3 = 'ctrv';
end

% load log ref
if(use_ref)
    if  (~exist('log_ref','var'))
        [file,path] = uigetfile(fullfile(opp_dir,'*.mat'),'Load ground truth');
        tmp = load(fullfile(path,file));
        log_ref = tmp.out;
        clearvars tmp;
    end
else
    log_ref = [];
end

DateTime = datetime(log.time_offset_nsec,'ConvertFrom','epochtime','TicksPerSecond',1e9,'Format','dd-MMM-yyyy HH:mm:ss');

%% NAMING
graphics_options;
col.lidar        = colors.green{2};
col.radar        = [77 190 238] / 255;
col.camera       = colors.yellow{2};
col.pp = colors.orange{2};
% col.tt           = colors.blue{2};
% col.tt2          = colors.blue{1};
col.tt = colors.matlab{1};
col.tt2 = colors.matlab{2};
col.tt3 = colors.matlab{3};
col.ref          = colors.black;
sz=3; % Marker size
f=1;
c = 0;
x_lim = [0 inf];

%% PARSING

[lid_clust, rad_clust, cam_yolo, lid_pp, gt] = load_perception(log, use_sim_ref, use_ref, log_ref);
tt = load_target_tracking(log);
tt.col = col.tt;
tt.name = name1;
if(compare) 
    tt2 = load_target_tracking(log_2); 
    tt2.stamp = tt2.stamp + double(log_2.time_offset_nsec-log.time_offset_nsec)*1e-9;
    tt2.col = col.tt2;
    tt2.name = name2;
end
if(compare2)
    tt3 = load_target_tracking(log_3); 
    tt3.stamp = tt3.stamp + double(log_3.time_offset_nsec-log.time_offset_nsec)*1e-9;
    tt3.col = col.tt3;
    tt3.name = name3;
end

cam_yolo.sens_stamp(cam_yolo.sens_stamp < 0) = NaN;

sensors = { ...
    struct('s', lid_clust, 'col', col.lidar,        'name', 'Lid Clust'), ...
    struct('s', rad_clust, 'col', col.radar,        'name', 'Rad Clust'), ...
    struct('s', cam_yolo,  'col', col.camera,       'name', 'Camera'), ...
    struct('s', lid_pp,    'col', col.pp, 'name', 'Lid PP') ...
};

if(use_ref || use_sim_ref)
    errors = process_states(gt, tt, err_thr, err_stats);
    if(compare)
        errors2 = process_states(gt, tt2, err_thr, err_stats);
    end
    if(compare2)
        errors3 = process_states(gt, tt3, err_thr, err_stats);
    end
end


%% PLOTTING

info;
detections;
latency;
state_map;
state_cog;
range;
speed_acc;
map;
% covariance;
error_analysis;
imm;

linkaxes(axes,'x')
