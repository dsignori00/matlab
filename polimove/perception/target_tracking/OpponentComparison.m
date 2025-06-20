close all
clearvars -except log log_ref trajDatabase

%#ok<*UNRCH>
%#ok<*INUSD>

%% Paths

addpath("../../common/personal/")
addpath("../../common/utilities/")
addpath("../../common/constants/")
addpath("../../common/plot/")
normal_path = "/home/daniele/Documents/PoliMOVE/04_Bags/";

%% Load Data

col.ego = '#A2142F';

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
v2v_vx = log.perception__v2v__detections.detections__vx;
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
ego_vx = log.estimation.vx;
ego_yaw = log.estimation.heading;

ego_x(ego_x==0)=nan;
ego_y(ego_y==0)=nan;
ego_vx(ego_vx==0)=nan;
ego_yaw(ego_yaw==0)=nan;
ego_yaw = unwrap(ego_yaw);

%% PROCESSING
ego_index = NaN(size(ego_x));

% compute ego closest idx
for i = 1:length(ego_x)
    if ~isnan(ego_x(i)) && ~isnan(ego_y(i))
        ego_index(i) = compute_closestIdx(ego_x(i), ego_y(i), trajDatabase(10));
    end
end

%% TRAJECTORY 
figure('Name','Ego vs V2V Detections');
hold on;
plot(ego_x, ego_y, '.','DisplayName', '0 - ego');
colors = lines(max_opp);  

for k = 1:max_opp
    plot(v2v_x(:,k), v2v_y(:,k), ...
         'DisplayName', [num2str(k) ' - v2v']);
end

title('Ego vs V2V Detections');
xlabel('X Position (m)');
ylabel('Y Position (m)');
legend('Location', 'best');
grid on;
axis equal;

%% SPEED
figure('Name','Ego vs V2V Speed');
hold on;
plot(ego_index(209861:232006), ego_vx(209861:232006)*3.6, 'DisplayName', 'Ego Speed');
%for k = 1:max_opp
    plot(v2v_index(49200:60689,1), v2v_vx(49200:60689,1)*3.6,'DisplayName', [num2str(k) 'HUMBDA - Speed']);
    plot(v2v_index(50639:61864,2), v2v_vx(50639:61864,2)*3.6, 'DisplayName', [num2str(k) 'TII - Speed']);
%end

legend('show')

