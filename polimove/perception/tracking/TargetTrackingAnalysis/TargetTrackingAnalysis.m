close all
clearvars -except log log_2 log_ref trajDatabase

use_ref     = false;
use_sim_ref = false;
compare     = false;
opp_idx     = 2;

%#ok<*UNRCH>
%#ok<*INUSD>

%% Paths

addpath("../../../common/utilities/")
addpath("../../../../common/constants/")
addpath("../../../common/plot/")
addpath("../../../../common/graphic_tools/")
addpath("../../utils/")
addpath("plot/")
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
    name2 = 'tt old';
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
col.pointpillars = colors.orange{2};
col.tt           = colors.blue{2};
col.tt2          = colors.blue{1};
col.ref          = colors.black;
sz=3; % Marker size
f=1;
x_lim = [0 inf];

%% PARSING

[lid_clust, rad_clust, cam_yolo, lid_pp, gt] = load_perception(log, use_sim_ref, use_ref, log_ref);
tt = load_target_tracking(log);
if(compare) 
    tt2 = load_target_tracking(log_2); 
    tt2.stamp = tt2.stamp + double(log_2.time_offset_nsec-log.time_offset_nsec)*1e-9;
end

cam_yolo.sens_stamp(cam_yolo.sens_stamp < 0) = NaN;

sensors = { ...
    struct('s', lid_clust, 'col', col.lidar,        'name', 'Lid Clust'), ...
    struct('s', rad_clust, 'col', col.radar,        'name', 'Rad Clust'), ...
    struct('s', cam_yolo,  'col', col.camera,       'name', 'Camera'), ...
    struct('s', lid_pp,    'col', col.pointpillars, 'name', 'Lid PP') ...
};

%% PLOTTING

info;
detections;
latency;
state_map;
state_cog;
range;
speed_acc;
covariance;
map;
imm;

linkaxes(axes,'x')
