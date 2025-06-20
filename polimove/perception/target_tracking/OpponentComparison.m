close all
clearvars -except log log_ref trajDatabase ego_index

%#ok<*UNRCH>
%#ok<*INUSD>

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
if(~exist('trajDatabase','var'))
    ego_index = NaN(size(ego_x));
    for i = 1:length(ego_x)
        if ~isnan(ego_x(i)) && ~isnan(ego_y(i))
            ego_index(i) = ComputeClosestIdx(ego_x(i), ego_y(i), trajDatabase(10));
        end
    end
end

%% TRAJECTORY 
figure('Name','Trajectory');
hold on;
plot(ego_x, ego_y, '.','Color', colors(1,:),'DisplayName', '0 - POLIMOVE');
for k = 1:max_opp
    opp_name = name_map(k);  
    plot(v2v_x(:,k), v2v_y(:,k), ...
         'Color', colors(k+1,:), ...
         'DisplayName', sprintf('%d - %s', k, opp_name));
end

xlabel('X Position (m)');
ylabel('Y Position (m)');
legend('Location', 'best');
grid on;
box on;
axis equal;

%% SPEED
figure('Name','Speed Profile');
hold on;
plot(ego_index(:), ego_vx(:), 'DisplayName', 'Ego Speed');
for k = 1:max_opp
    opp_name = name_map(k);  
    plot(v2v_index(:,k), v2v_vx(:,k), ...
    'Color', colors(k+1,:), ...
    'DisplayName', sprintf('%d - %s', k, opp_name));
end
xlabel('Closest Index');
ylabel('Speed (km/h)');
grid on;
box on;
legend('show')

