%% Create Standard Mat
% save the opponent most useful data in a standard mat struct

% DATA:                     % DESCRIPTION:

% gps                       % gps used to extract the data
% primary_antenna           % primary antenna
% bag_timestamp             % msg timestamp
% timestamp                 % timestamp in epoch format (nanoseconds)
% header_stamp              % header stamp from driver
% latitude                  % latitude
% longitude                 % longiude
% bag_avg_frequency         % average publishing frequency
% x_map                     % x in global reference frame (ENU)
% y_map                     % y in global reference frame (ENU)
% z_map                     % z in global reference frame (ENU)
% yaw_map                   % heading in global reference frame 
% timestamp_diff            % difference between ego and opp timestamp
% x_rel                     % x in car reference frame 
% y_rel                     % y in car reference frame 
% z_rel                     % z in car reference frame 
% yaw_rel                   % relative yaw between ego and opp car 
% speed                     % opp speed
% calculated speed          % true if speed calculated from gps pos measures
% rho                       % distance from opponent (range)
% rho_dot                   % range rate (relative speed)

%% TO DO
% apply a low pass filter to filter out high frequency noise do to ego-opponent timestamp difference 

%% Paths
clc; close all; clearvars -except ego opp_log closest_idxs opp_idxs file_name

addpath("../../common/utilities/")
addpath("../../common/constants/")
addpath("../../common/plot/")
addpath("opp_data/")
addpath("../utils/")
normal_path = "../../bags";
output_path = "mat/";

%% Load Data

% load ego log
if (~exist('ego','var'))
    [file,normal_path] = uigetfile(fullfile(normal_path,'*.mat'),'Load ego mat');
    tmp = load(fullfile(normal_path,file));
    ego = tmp.log;
    clearvars tmp;
end

% load opponent estimation file
if  (~exist('opp_log','var'))
    [file,normal_path] = uigetfile(fullfile("opp_data",'*.csv'),'Load opp localization');
    file = dir(fullfile(normal_path,file));
    files_list = string(file.name);

    %%Create complete opponent mat
    T = struct();
    i = 1;
    while i <= numel(files_list)
        try
            filename = files_list{i};
            [~, file_name, ~] = fileparts(filename);
    
            if ~isfield(T, file_name)
                fprintf("Loading: %s\n", filename);
                T = importCsv(filename);
            end
    
            i = i + 1;
        catch e
            warning("WARNING: Could not parse topic: %s", file_name);
            warning("Error type: " + e.message);
            files_list(i) = []; % remove bad entry
        end
    end

    % Remove file-name prefix from any columns
    vars = T.Properties.VariableNames;
    prefix = file_name + "_";
    for k = 1:numel(vars)
        if startsWith(vars{k}, prefix)
            vars{k} = erase(vars{k}, prefix);  
        end
    end
    T.Properties.VariableNames = vars;

    % Store all data in just 1 struct
    opp_log = table2struct(T, "ToScalar", true);
end

%% Fill out log

%Select opponent and gps
opp_id = -1;
lista_opponents = [0,3,6];
while ~ismember(opp_id, lista_opponents)
    disp( "Choose opponent:" + newline + ...
        " 3: Tum " + newline + ...
        " 6: Unimore " + newline + ...
        " 0: Quit");
    opp_id = input("Choose opponent identifier: ");
end

diff1 = opp_log.stamp(2:length(opp_log.stamp))-opp_log.stamp(1:length(opp_log.stamp)-1);
valid_stamps = [true; abs(diff1 - 0.01) < 0.003];

switch(opp_id)
    case 3
        out.timestamp = opp_log.stamp(valid_stamps)*10^9;
        out.x_map = opp_log.x_cog(valid_stamps);
        out.y_map = opp_log.y_cog(valid_stamps);
        out.yaw_map = unwrap(opp_log.heading((valid_stamps)));
        out.speed = opp_log.vx(valid_stamps);

end

opp_sz = length(out.timestamp);
out.gps = NaN;
out.primary_antenna = NaN;
out.bag_timestamp = NaN(opp_sz,1);
out.header_stamp = NaN(opp_sz,1);
out.latitude = NaN(opp_sz,1);
out.longitude = NaN(opp_sz,1);
out.z_map = NaN(opp_sz,1);
out.z_rel = NaN(opp_sz,1);
out.calculated_speed = false;

% average frequency 
diff = out.timestamp(2:length(out.timestamp))-out.timestamp(1:length(out.timestamp)-1);
freq = 1./diff;
avg_freq = mean(freq)*10^9;
out.bag_avg_freq = avg_freq;

%% Ego
ego_bag_timestamp = (ego.estimation.bag_stamp)*10^9+double(ego.time_offset_nsec);
ego_timestamp = (ego.estimation.stamp__tot)*10^9+double(ego.time_offset_nsec);
ego_x_map = ego.estimation.x_cog;
ego_y_map = ego.estimation.y_cog;
ego_z_map = ego.estimation.z_cog;
ego_yaw_map = ego.estimation.heading;
ego_roll = ego.estimation.roll;
ego_pitch = ego.estimation.pitch;
ego_speed = ego.estimation.vx;
ego_sz = length(ego_x_map);

% check if ros time is synchronized with gps time
gps_bag_stamp = ego.vectornav__raw__gps.bag_stamp;
if (gps_bag_stamp(1)>10)
    error("Ros time not sync to gps!")
end

%% Opponent and ego sync

if(~exist('closest_idxs','var') || ~exist('opp_idxs','var'))
    [closest_idxs, opp_idxs] = find_closest_stamp(out.timestamp,ego_timestamp);
end
ego_bag_timestamp = ego_bag_timestamp(closest_idxs);

time_diff_nsec = NaN(opp_sz,1); 
time_diff_nsec(opp_idxs) = ego_timestamp(closest_idxs) - out.timestamp(opp_idxs);
out.timestamp_diff = time_diff_nsec;

%% Relative metrics computation

dx = out.x_map(opp_idxs) - ego_x_map(closest_idxs);
dy = out.y_map(opp_idxs) - ego_y_map(closest_idxs);
dz = out.z_map(opp_idxs) - ego_z_map(closest_idxs);
yaw_rel = out.yaw_map(opp_idxs)-ego_yaw_map(closest_idxs);

x_rel = NaN(size(opp_idxs));
y_rel = NaN(size(opp_idxs));
z_rel = NaN(size(opp_idxs));

for i = 1:length(opp_idxs)
    psi = ego_yaw_map(closest_idxs(i));

    % 2D rotation matrix
    R_yaw = [cos(psi), -sin(psi);
             sin(psi),  cos(psi)];

    % translation vector in XY
    translation_xy = [dx(i); dy(i)];
    opp_rel_xy = R_yaw' * translation_xy;

    x_rel(i) = opp_rel_xy(1);
    y_rel(i) = opp_rel_xy(2);
    
end

tot_x_rel = NaN(opp_sz,1);
tot_y_rel = NaN(opp_sz,1);
tot_z_rel = NaN(opp_sz,1);
tot_yaw_rel = NaN(opp_sz,1);

tot_x_rel(opp_idxs) = x_rel;
tot_y_rel(opp_idxs) = y_rel;
tot_z_rel(opp_idxs) = z_rel;         
tot_yaw_rel(opp_idxs) = yaw_rel;

out.x_rel = tot_x_rel;
out.y_rel = tot_y_rel;
out.z_rel = tot_z_rel;
out.yaw_rel = tot_yaw_rel;

%% Range and Range Rate

range = NaN(opp_sz,1);
v = [dx;dy];
r = norm(v);
range(opp_idxs) = r;
out.range = range;

beta = atan2(dy,dx);
valid_rho_dot = (out.speed(opp_idxs).*cos(out.yaw_map(opp_idxs))-ego_speed(closest_idxs).*cos(ego_yaw_map(closest_idxs))).*cos(beta)+ ...
                (out.speed(opp_idxs).*cos(out.yaw_map(opp_idxs))-ego_speed(closest_idxs).*cos(ego_yaw_map(closest_idxs))).*sin(beta);

rho_dot = NaN(opp_sz,1);
rho_dot(opp_idxs) = valid_rho_dot;
out.rho_dot = rho_dot;


%% Save the output struct

try
    output_file = fullfile(output_path, file_name + ".mat");
    save(output_file, 'opp_log', '-v7.3');
catch e
    warning("WARNING: Could not save files");
    warning("Error type:  " + e.message);
end