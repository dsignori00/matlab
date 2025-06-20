% TO DO:
% - interpolate timestamp
% - check error in passing to rel frame
% - check validity of z gps measure
% - sistema calcolo rho_dot (velocità radiale)

close all
clearvars -except ego opp_dir_path 

%% Paths

addpath("../../01_Tools/00_GlobalFunctions/personal/")
addpath("../../01_Tools/00_GlobalFunctions/utilities/")
addpath("../../01_Tools/00_GlobalFunctions/constants/")
addpath("../../01_Tools/00_GlobalFunctions/plot/")
normal_path = "/home/dano00/Documents/PoliMOVE/04_Bags/";

%% Input

% load opponent gps file
if  (~exist('opp_dir_path','var'))
    opp_dir_path = uigetdir(normal_path,'Load opp data directory');   
end
files = dir(fullfile(opp_dir_path, '*.csv'));
files_list = string({files.name});
addpath(opp_dir_path)


% load ego log
if (~exist('ego','var'))
    [file,normal_path] = uigetfile(fullfile(normal_path,'*.mat'),'Load ego mat');
    tmp = load(fullfile(normal_path,file));
    ego = tmp.log;
    clearvars tmp;
end

%Select the opponent
lista_opponents = [0,6,9];
opp_id = -1;

while ~ismember(opp_id, lista_opponents)
    disp( "Choose opponent:" + newline + ...
          " 6: Unimore " + newline + ...
          " 9: Cavalier " + newline + ...
          " 0: Quit");
    opp_id = input("Choose opponent identifier: ");
end

%Select the gps
lista_gps = [0,1,2,3];
gps_id = -1;

while ~ismember(gps_id, lista_gps)
    disp( "Choose gps:" + newline + ...
          " 1: Vectornav " + newline + ...
          " 2: Novatel top " + newline + ...
          " 3: Novatel bot" + newline + ...
          " 0: Quit");
    gps_id = input("Choose gps identifier: ");
end

%Select the track
track_list = [0,1,2,3];
track_id = -1;
while ~ismember(track_id, track_list)
    disp( "Choose track:" + newline + ...
          " 1: KS " + newline + ...
          " 2: IMS " + newline + ...
          " 3: LVMS " + newline + ...
          " 0: Quit");
    track_id = input("Insert track identifier: ");
end


%% Create complete opponent mat

addpath(opp_dir_path)
for i = 1:length(files_list)

    try
        
        filename = files_list(i);
        file_name = sprintf("%s", erase(filename, ".csv"));
        if  (~exist(filename,'var'))
            fprintf("Loading: %s\n", filename);
            eval_string_1 = file_name + " = importCsv('" + filename + "');";
            eval(eval_string_1);
        
            eval_string_2 = "fieldnames(" + file_name + ");";
            fields = eval(eval_string_2);
        end

    catch e
            warning("WARNING: Could not parse topic: " + file_name);
            warning("Error type:  " + e.message);
            files_list = files_list([1:i-1,i+1:end]);
    end
end

% Save all data in just 1 struct
[~, output_filename, ~] = fileparts(opp_dir_path);
output_path = fullfile(opp_dir_path, output_filename + "_raw.mat");
fprintf("\nSaving data to: %s\n", output_path);

for i = 1:length(files_list)
    filename = files_list(i);
    topic_name = sprintf("%s", erase(filename, ".csv"));

    isCellCol = varfun(@iscell, eval(topic_name), 'OutputFormat', 'uniform');
    
    eval_string_9 = topic_name + "(:, isCellCol) = [];";
    eval(eval_string_9);

    eval_string_10 = "fields = fieldnames(" + topic_name + ");";
    eval(eval_string_10);

    for j = 1:length(fields)
        

        eval_string_value = topic_name + "." + fields{j};
        field_value = eval(eval_string_value);  

        if  (~iscell(field_value))             
            eval_string_11 = "opp_log.(fields{j}) = " + eval_string_value + ";";
            eval(eval_string_11);
        end  
    end
end

try
    opp_log = rmfield(opp_log, {'Properties','Variables'});
    save(output_path, 'opp_log', '-v7.3');
catch e
    warning("WARNING: Could not save files");
    warning("Error type:  " + e.message);
end

%% Constants

WEEK2SEC = 7 * 24 * 60 * 60;
GPS_UTC_DELTA_SEC = 315964800;
LEAP_SEC = 18;
YEAR2SEC = 31500000;

%% Ego State

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

%% Geodetic to ENU

% Get timestamp and Geodetic coordinates

% NB undulation already included in novatel measures, not in vectornav ones
undulation = ego.novatel_bottom__bestgnsspos.undulation(1);

switch opp_id
    case 6
        if(gps_id==1)
        log.gps             = "vectornav";
        log.primary_antenna = "front";
        log.bag_timestamp   = opp_log.vectornav_gps_a_stamp;
        log.header          = opp_log.vectornav_gps_a_head_stamp;
        log.timestamp       = opp_log.vectornav_gps_a_utcStamp;     
        log.latitude        = opp_log.vectornav_gps_a_latitude;
        log.longitude       = opp_log.vectornav_gps_a_longitude;
        log.altitude        = opp_log.vectornav_gps_a_altitude-undulation;
        raw_speed.ve        = opp_log.vectornav_gps_a_speed_value0;
        raw_speed.vn        = opp_log.vectornav_gps_a_speed_value1;
        raw_speed.vz        = opp_log.vectornav_gps_a_speed_value2;

        elseif(gps_id==2)         
        log.gps             = "novatel_top";
        log.primary_antenna = "front";
        log.bag_timestamp   = opp_log.novatel_btm_gps_stamp;
        log.header          = opp_log.novatel_top_gps_head_stamp;
        log.timestamp       = opp_log.novatel_top_gps_utcStamp;
        log.latitude        = opp_log.novatel_top_gps_latitude;
        log.longitude       = opp_log.novatel_top_gps_longitude;
        log.altitude        = opp_log.novatel_top_gps_altitude;
        raw_speed.ve        = opp_log.novatel_top_gps_speed_value0;
        raw_speed.vn        = opp_log.novatel_top_gps_speed_value1;
        raw_speed.vz        = opp_log.novatel_top_gps_speed_value2;

        elseif(gps_id==3)
        log.gps             = "novatel_btm";
        log.primary_antenna = "right";
        log.bag_timestamp   = opp_log.novatel_btm_gps_stamp;
        log.header          = opp_log.novatel_btm_gps_head_stamp;
        log.timestamp       = opp_log.novatel_btm_gps_utcStamp;
        log.latitude        = opp_log.novatel_btm_gps_latitude;
        log.longitude       = opp_log.novatel_btm_gps_longitude;
        log.altitude        = opp_log.novatel_btm_gps_altitude;
        raw_speed.ve        = opp_log.novatel_btm_gps_speed_value0;
        raw_speed.vn        = opp_log.novatel_btm_gps_speed_value1;
        raw_speed.vz        = opp_log.novatel_btm_gps_speed_value2;
        end

        log.timestamp = utcToGpsEpoch(log.timestamp);
    
    case 9
        if(gps_id==1)
        error("VectorNav data not present!")

        elseif(gps_id==2)
        log.gps             = "novatel_top";
        log.primary_antenna = "front";
        log.bag_timestamp   = opp_log.novatel_top__bestpos__bag_timestamp;
        log.header_stamp    = opp_log.novatel_top__bestpos__header__stamp__sec*10^9+opp_log.novatel_top__bestpos__header__stamp__nanosec;
        log.latitude        = opp_log.novatel_top__bestpos__lat;
        log.longitude       = opp_log.novatel_top__bestpos__lon;
        log.altitude        = opp_log.novatel_top__bestpos__hgt;
        %week                =     
        week_msec           = opp_log.novatel_top__bestpos__nov_header__gps_week_milliseconds;

        elseif(gps_id==3)
        log.gps             = "novatel_btm";
        log.primary_antenna = "right";
        log.bag_timestamp   = opp_log.novatel_bottom__bestpos__bag_timestamp;
        log.timestamp       = opp_log.novatel_bottom__bestpos__header__stamp__sec*10^9+opp_log.novatel_bottom__bestpos__header__stamp__nanosec;
        log.latitude        = opp_log.novatel_bottom__bestpos__lat;
        log.longitude       = opp_log.novatel_bottom__bestpos__lon;
        log.altitude        = opp_log.novatel_bottom__bestpos__hgt;
        end
        
        log.timestamp = towToGpsEpoch(week,week_msec);

    case 0
        error("Quit");
    otherwise
        error('Error in opponent selection')
end

% sort opp data wrt timestamp
[log.timestamp, sorted_idx] = sort(log.timestamp);

log.bag_timestamp   = log.bag_timestamp(sorted_idx);
log.latitude        = log.latitude(sorted_idx);
log.longitude       = log.longitude(sorted_idx);
log.altitude        = log.altitude(sorted_idx);

% average frequency 
diff = log.timestamp(2:length(log.timestamp))-log.timestamp(1:length(log.timestamp)-1);
freq = 1./diff;
avg_freq = mean(freq)*10^9;
log.bag_avg_freq = avg_freq;

% Geodetic to Enu
wgs84 = wgs84Ellipsoid;
switch (track_id) 
    case 1 
        % KS
        lat0    = 38.711552404047440;
        lon0    = -84.916952255229230;
        alt0    = 182.9;
        load("../../04_Bags/00_Databases/Ks.mat");
    case 2
        % IMS
        lat0    =  39.793145808368780;	
        lon0    = -86.236780583175840;
        alt0    =  221.8500178;
        load("../../04_Bags/00_Databases/Ims.mat");
    case 3
        % LVMS
        lat0    =  36.272904305728540;
        lon0    = -115.0110198639284+1e-5;
        alt0    =  594.6250982;
        load("../../04_Bags/00_Databases/Lvms.mat");
    case 0
        error("Quit");
    otherwise
        error("Error in track selection");  
end

[x_map,y_map,z_map] = geodetic2enu(log.latitude,log.longitude,log.altitude,lat0,lon0,alt0,wgs84);
log.x_map = x_map;
log.y_map = y_map;
log.z_map = z_map;
opp_sz = length(x_map);



%% Opponent and ego sync

%[log.timestamp] = latency_removal(log.timestamp,log.gps);
[closest_idxs, opp_idxs] = find_closest_stamp(log.timestamp,ego_timestamp);
ego_bag_timestamp = ego_bag_timestamp(closest_idxs);

time_diff_nsec = NaN(opp_sz,1); 
time_diff_nsec(opp_idxs) = ego_timestamp(closest_idxs) - log.timestamp(opp_idxs);
log.timestamp_diff = time_diff_nsec;


%% Orientation

pitch = zeros(size(opp_sz));
roll = zeros(size(opp_sz));
yaw = zeros(size(opp_sz));
z_dat = zeros(size(opp_sz));

for j=1:length(x_map)
    x = x_map(j);
    y = y_map(j);
    min_dist = inf;
    traj = 0;
    for i=1:length(trajDatabase)
        [dist, idx] = compute_dist(x,y,trajDatabase(i).X,trajDatabase(i).Y);
        if(dist<min_dist)
            min_dist = dist;
            clos_idx = idx;
            traj = i;
        end
    end
    pitch(j) = trajDatabase(traj).Slope(clos_idx);
    roll(j) = trajDatabase(traj).Banking(clos_idx);
    yaw(j) = trajDatabase(traj).Heading(clos_idx);
    z_rel_dat(j) = trajDatabase(traj).
end
yaw = deg2rad(UnwrapPi(rad2deg(yaw)));
yaw = correct_yaw(x_map,y_map,log.timestamp,log.bag_avg_freq,yaw);

log.roll = roll;
log.pitch = pitch;
log.yaw_map = yaw;


%% Opponent speed

if  (exist('raw_speed','var'))
    speed = sqrt(raw_speed.ve.^2+raw_speed.vn.^2);
    log.computed_speed = false;
else
    speed = compute_opp_speed(x_map,y_map,log.timestamp,log.bag_avg_freq);
    log.compute_speed = true;
end
log.speed = speed;


%% Relative metrics computation

valid_x_rel = NaN(size(opp_idxs));
valid_y_rel = NaN(size(opp_idxs));
valid_z_rel = NaN(size(opp_idxs));
valid_idxs  = NaN(size(opp_idxs));
valid_yaw_rel = NaN(size(opp_idxs));
valid_roll_rel = NaN(size(opp_idxs));
valid_pitch_rel = NaN(size(opp_idxs));
% valid_rho_dot = speed(opp_idxs)-ego_speed(closest_idxs);

valid_count = 0;
j = 0;
for idx = 1:length(opp_idxs)
    i = opp_idxs(idx);
    j = j+1;
    M = zeros(4);
    translation = [ego_x_map(closest_idxs(j)); ego_y_map(closest_idxs(j)); ego_z_map(closest_idxs(j))];
    rotation = euler_to_rotation(ego_roll(closest_idxs(j)),ego_pitch(closest_idxs(j)),ego_yaw_map(closest_idxs(j)));
    
    M(1:3,1:3) = rotation;
    M(1:3,4) = translation;
    M(4,4) = 1;
    
    opp_map = [x_map(i);y_map(i);z_map(i); 1];
    opp_rel = M\opp_map;

    if any(isnan(opp_rel))
        error('nan')
    end

    if(abs(opp_rel(1))<150 && abs(opp_rel(2))<30)
        valid_count = valid_count+1;
        valid_x_rel(valid_count) = opp_rel(1);
        valid_y_rel(valid_count) = opp_rel(2);
        valid_z_rel(valid_count) = opp_rel(3);
        valid_yaw_rel(valid_count) = yaw(i)-ego_yaw_map(closest_idxs(j));
        valid_roll_rel(valid_count) = roll(i)-ego_roll(closest_idxs(j));
        valid_pitch_rel(valid_count) = pitch(i)-ego_pitch(closest_idxs(j));
        valid_idxs(valid_count) = i;
    end
end
valid_x_rel = valid_x_rel(~isnan(valid_idxs));
valid_y_rel = valid_y_rel(~isnan(valid_idxs));
valid_z_rel = valid_z_rel(~isnan(valid_idxs));
valid_yaw_rel = valid_yaw_rel(~isnan(valid_idxs));
valid_yaw_rel = deg2rad(UnwrapPi(rad2deg(valid_yaw_rel)));
valid_roll_rel = valid_roll_rel(~isnan(valid_idxs));
valid_pitch_rel = valid_pitch_rel(~isnan(valid_idxs));
valid_idxs = valid_idxs(~isnan(valid_idxs));

%% Compensate for antenna offset
% Adjust for the center_of_gravity if we know the offset (from antenna to center)

switch (log.primary_antenna)
    case "front"
        % Primary front  BOT_GPS_DXYZ = {1.405, 0.0, 0.483};
        x_offset = -1.405;
        y_offset = 0;
        z_offset = -0.483;
    case "top"
        % Primary top  VN_GPS2_DXYZ  = {-0.5, 0.0, 1.031}
        x_offset = 0.5;
        y_offset = 0;
        z_offset = - 1.031;
    case "right"
        % Primary lat dx TOP_GPS_DXYZ = {0.284, -0.497, 0.464};
        x_offset = -0.284;
        y_offset = 0.497;
        z_offset = -0.464; 
    case "left"
        % Primary lat sx TOP_GPS2_DXYZ = {0.284, 0.497, 0.464};
        x_offset = - 0.284;
        y_offset = - 0.497;
        z_offset = - 0.464; 
    otherwise
        error("Error in Antenna selection");

end

pos = zeros(6,1);
x_rel_cog = NaN(size(valid_idxs));
y_rel_cog = NaN(size(valid_idxs));
z_rel_cog = NaN(size(valid_idxs));

for i=1:length(valid_idxs)
    pos(1)=valid_x_rel(i);
    pos(2)=valid_y_rel(i);
    pos(3)=valid_z_rel(i);
    pos(4)=valid_yaw_rel(i);
    pos(5)=valid_roll_rel(i);
    pos(6)=valid_pitch_rel(i);

    if any(isnan(pos))
        error('nan')
    end

    [correct_x_rel, correct_y_rel, correct_z_rel] = to_center_of_gravity(pos, x_offset, y_offset, z_offset);

    x_rel_cog(i) = correct_x_rel;
    y_rel_cog(i) = correct_y_rel;
    z_rel_cog(i) = correct_z_rel;

end

x_map_cog = NaN(opp_sz,1);
y_map_cog = NaN(opp_sz,1);
z_map_cog = NaN(opp_sz,1);

for i=1:opp_sz
    pos(1)=x_map(i);
    pos(2)=y_map(i);
    pos(3)=z_map(i);
    pos(4)=yaw(i);
    pos(5)=roll(i);
    pos(6)=pitch(i);

    if any(isnan(pos))
        x_map_cog(i) = x_map(i);
        y_map_cog(i) = y_map(i);
        z_map_cog(i) = z_map(i);
        continue
    end

    [correct_x_map, correct_y_map, correct_z_map] = to_center_of_gravity(pos, x_offset, y_offset, z_offset);

    x_map_cog(i) = correct_x_map;
    y_map_cog(i) = correct_y_map;
    z_map_cog(i) = correct_z_map;

end

log.x_map = x_map_cog;
log.y_map = y_map_cog;
log.z_map = z_map_cog;

corr_x_rel = NaN(opp_sz,1);
corr_y_rel = NaN(opp_sz,1);
corr_z_rel = NaN(opp_sz,1);
yaw_rel = NaN(opp_sz,1);
rho_dot = NaN(opp_sz,1);
%rho_dot(opp_idxs) = valid_rho_dot;
corr_x_rel(valid_idxs) = x_rel_cog;
corr_y_rel(valid_idxs) = y_rel_cog;
corr_z_rel(valid_idxs) = z_rel_cog;
yaw_rel(valid_idxs) = valid_yaw_rel;

log.x_rel = corr_x_rel;
log.y_rel = corr_y_rel;
log.z_rel = corr_z_rel;
log.yaw_rel = yaw_rel;

% without considering z differences TO CHECK
rho = NaN(opp_sz,1);
r = sqrt(log.x_rel.^2+log.y_rel.^2);
rho(log.x_rel>=0) = r(log.x_rel>=0);
rho(log.x_rel<0) = -r(log.x_rel<0);
log.rho = rho;
log.rho_dot = rho_dot;


%% Create Standard Mat
% save the opponent most useful data in a standard mat struct

% DATA:                     % DESCRIPTION:

% gps                       % gps used to extract the data
% primary_antenna           % primary antenna
% bag_timestamp             % msg timestamp
% timestamp                 % gps measure timestamp
% latitude                  % latitude
% longitude                 % longiude
% bag_avg_frequency         % average publishing frequency
% x_map                     % x in global reference frame (ENU)
% y_map                     % y in global reference frame (ENU)
% z_map                     % z in global reference frame (ENU)
% yaw_map                   % heading in global reference frame 
% timestamp diff            % difference between ego and opp timestamp
% x_rel                     % x in car reference frame 
% y_rel                     % y in car reference frame 
% z_rel                     % z in car reference frame 
% yaw_rel                   % relative yaw between ego and opp car 
% speed                     % opp speed
% calculated speed          % true if speed calculated from gps pos measures
% rho                       % distance from opponent (range)
% rho dot                   % range rate (relative speed)

try
    output_path = fullfile(opp_dir_path, output_filename + "_" +string(log.gps) +".mat");
    fprintf("Saving processed data to: %s\n", output_path);
    save(output_path, 'log', '-v7.3');
catch e
    warning("WARNING: Could not save processed data");
    warning("Error type:  " + e.message);
end

fprintf("\nRemember to check if antenna's configuration has been changed!!!\n")
% clearvars -except ego opp_dir_path 

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%  USEFUL FUNCTIONS  %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function out = importCsv(filename)

    dataLines = [3, Inf];
    
    fid = fopen(filename, 'r');
    fields_names = textscan(fid, '%[^\n]', 1); 
    fields_names = split(fields_names{1}, ',');

    topic_name = sprintf("%s", erase(filename, ".csv"));

    % Modify CSV names for easier data analysys and to replace too long names
    fields_names = strrep(fields_names, "#", "");
    fields_names = strrep(fields_names, "//", "");
    fields_names = strrep(fields_names, "/", "_");

    stp_idx = strcmp(fields_names, 'stamp');
    fields_names(stp_idx)= {topic_name + "_" + "stamp"};

    fields_names = strip(fields_names);
    fields_names = fields_names(strlength(fields_names) > 0);

    
    for i = 1:length(fields_names)
        if length(fields_names{i}) > 63
            %fprintf("Name: %s is too long - Truncated!\n", fields_names{i});
            fields_names{i} = fields_names{i}(1:63);
        end
    end
    fields_names = string(fields_names)';

    % Set up the Import Options and import the data
    opts = detectImportOptions(filename, 'Delimiter',',', 'NumVariables', length(fields_names));
        
    % Specify column names and types
    opts.DataLines = dataLines;
    opts.VariableNames = fields_names;
    opts.SelectedVariableNames = fields_names;

    % Import the data
    out = readtable(filename, opts);

end


function [idx, opp_idx] = find_closest_stamp(timestamp, ego_timestamp)
    % Preallocazione dei risultati
    idx = zeros(length(timestamp), 1);
    opp_idx = zeros(length(timestamp), 1);
    % Itera su ogni elemento di timestamp, calcolando le differenze localmente
    for i = 1:length(timestamp)
        % Calcola le differenze solo per l'elemento corrente
        diff = abs(ego_timestamp - timestamp(i));
        
        % Trova il minimo e l'indice corrispondente
        [min_diff, closest_idx] = min(diff);

        % Applica la soglia
        if min_diff < 1e9
            idx(i) = closest_idx;
            opp_idx(i) = i;    
        end
    end
    idx = idx(idx~=0);
    opp_idx = opp_idx(opp_idx~=0);
end


function timestamp = latency_removal(timestamp,gps)
    for i=2:length(timestamp)
        ts = timestamp(i)-timestamp(i-1);
        if(strcmp(gps,'novatel_top') || strcmp(gps,'novatel_btm'))
             if((ts>6e+07) && ts<1e+09)
                timestamp(i) = timestamp(i-1)+5e+07;
             end
        elseif(strcmp(gps,'vectornav'))
             if((ts>2.18e+08 || ts<1.8e+08) && ts<1e+09)
                timestamp(i) = timestamp(i-1)+2e+08;
             end
        end
    end
end


function timestamp = latency_removal2(timestamp,gps)
    ts = timestamp(2:end)-timestamp(1:end-1);
    ts = [0; ts];
    for i=2:length(timestamp)
        if(strcmp(gps,'novatel_top') || strcmp(gps,'novatel_btm'))
             if(ts(i)<1e+09)
                timestamp(i) = timestamp(i-1)+5e+07;
             end
        elseif(strcmp(gps,'vectornav'))
             if(ts(i)<1e+09)
                timestamp(i) = timestamp(i-1)+2e+08;
             end
        end
    end
end


function R = euler_to_rotation(phi, theta, psi)
    % euler_to_rotation - Calcola la matrice di rotazione a partire dagli angoli di Eulero (ZYX)
    % INPUT:
    %   phi   - angolo di rotazione attorno all'asse X (roll)
    %   theta - angolo di rotazione attorno all'asse Y (pitch)
    %   psi   - angolo di rotazione attorno all'asse Z (yaw)
    % OUTPUT:
    %   R     - Matrice di rotazione 3x3 risultante

    % Matrice di rotazione attorno all'asse X (roll)
    Rx = [1    0           0;
          0  cos(phi)  -sin(phi);
          0  sin(phi)   cos(phi)];
    
    % Matrice di rotazione attorno all'asse Y (pitch)
    Ry = [cos(theta)   0   sin(theta);
          0            1   0;
         -sin(theta)   0   cos(theta)];
    
    % Matrice di rotazione attorno all'asse Z (yaw)
    Rz = [cos(psi)  -sin(psi)  0;
          sin(psi)   cos(psi)  0;
          0          0         1];

    % Matrice di rotazione totale (ZYX)
    R = Rz*Ry*Rx;
end

function yaw_out = correct_yaw(x_map,y_map, timestamp, avg_freq, yaw_in)
    
    
    time_th = 3/avg_freq*10^9;
    yaw_out = yaw_in;

    for i = 2:length(x_map)
        if (timestamp(i)-timestamp(i-1)<time_th)
            dx = x_map(i)-x_map(i-1); 
            dy = y_map(i)-y_map(i-1);
            ds = sqrt(dx^2+dy^2);
            dt = 1/avg_freq;
            v = ds/dt;
            if v>16
                yaw_out(i) = atan2(dy,dx);
            end
        end      
    end

end


function [correct_x_rel, correct_y_rel, correct_z_rel] = to_center_of_gravity(pos, x_offset, y_offset, z_offset)
    
    x = pos(1);
    y = pos(2);
    z = pos(3);
    t = [x; y; z];

    % phi = angolo di rotazione attorno all'asse X (roll)
    % theta = angolo di rotazione attorno all'asse Y (pitch)
    % psi = angolo di rotazione attorno all'asse Z (yaw)
    psi = pos(4);
    phi = pos(5);
    theta = pos(6);
    
    R = euler_to_rotation(phi,theta,psi);

    % Costruire la matrice omogenea 4x4
    H = eye(4); % Matrice identità 4x4
    H(1:3, 1:3) = R; % Imposta la rotazione 3x3
    H(1:3, 4) = t;   % Imposta la traslazione

    % Applicare la trasformazione
    c = [x_offset; y_offset; z_offset; 1]; % Aggiungi la componente omogenea
    new_c = H * c;

    % Aggiornare i valori nella struttura 'row'
    correct_x_rel = new_c(1);
    correct_y_rel = new_c(2);
    correct_z_rel= new_c(3);
end

function speed = compute_opp_speed(x_map,y_map, timestamp, avg_freq)
    
    time_th = 3/avg_freq*10^9;
    speed = NaN(length(x_map),1);
    inst_speed = NaN(length(x_map),1);
    for i = 2:length(x_map)
        dt = timestamp(i)-timestamp(i-1);
        if (dt<time_th)
            dx = x_map(i)-x_map(i-1); 
            dy = y_map(i)-y_map(i-1);
            ds = sqrt(dx^2+dy^2);
            dts = dt*10^-9;
            if (dt~=0 && ds/dts<90)
                inst_speed(i) = ds/dts; 
            end

            if i>8
                speed(i) = mean(inst_speed(i-8:i));
            else
                speed(i) = inst_speed(i);
            end
        end      
    end

end

function gps_time_ns = utcToGpsEpoch(utc_time_ns)
    % Constants
    GPS_UTC_DELTA_SEC = 315964800; 
    LEAP_SEC = 18;                 

    % Convert nanoseconds to seconds and remainder nanoseconds
    utc_sec = floor(utc_time_ns / 1e9);
    remainder_ns = mod(utc_time_ns, 1e9);

    % Calculate GPS time by adjusting for GPS-UTC offset and leap seconds
    gps_sec = utc_sec + GPS_UTC_DELTA_SEC - LEAP_SEC;

    % Combine back into nanoseconds
    gps_time_ns = gps_sec * 1e9 + remainder_ns;
end

