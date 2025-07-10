close all
clearvars -except log log trajDatabase ego_index v2v_index

%#ok<*UNRCH>
%#ok<*USENS>
%#ok<*NASGU>

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

%% LOAD DATA 

% load database
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

% ESTIMATION
ego_stamp = log.estimation.stamp__tot;
ego_x = log.estimation.x_cog;
ego_y = log.estimation.y_cog;
ego_vx = log.estimation.vx*MPS2KPH; 
ego_yaw = log.estimation.heading;
ego_ay = log.estimation.ay;
ego_x(ego_x==0)=nan;
ego_y(ego_y==0)=nan;
ego_vx(ego_vx==0)=nan;
ego_yaw(ego_yaw==0)=nan;
ego_yaw = unwrap(ego_yaw);
ego_ay(ego_ay==0)=nan;

%% PROCESSING

% Compute ego closest idx
if ~exist('ego_index', 'var')
    ego_index = NaN(size(ego_x));
    trajX = trajDatabase(10).X(:);
    trajY = trajDatabase(10).Y(:);

    for i = 1:length(ego_x)
        if ~isnan(ego_x(i)) && ~isnan(ego_y(i))
            dx = trajX - ego_x(i);
            dy = trajY - ego_y(i);
            [~, ego_index(i)] = min(dx.^2 + dy.^2);
        end
    end
end

% Assign lap number 
ego_laps = AssignLap(ego_index);
max_lap = max(ego_laps(:), [], 'omitnan');

% Lap Time progression
ego_lap_time = NaN(size(ego_stamp));  
unique_laps = unique(ego_laps(~isnan(ego_laps)));
for lap = unique_laps'
    idx = (ego_laps == lap);
    ego_lap_time(idx) = ego_stamp(idx) - ego_stamp(find(idx, 1, 'first'));
end

% Lap time computation
validLapIdx  = ~isnan(ego_laps);
lapNumbers   = unique(ego_laps(validLapIdx));

lapTime = zeros(size(lapNumbers));
for ii = 1:numel(lapNumbers)
    thisLap     = lapNumbers(ii);
    idx         = ego_laps == thisLap;          % all samples in this lap
    lapTime(ii) = ego_stamp(find(idx,1,'last')) ...
                - ego_stamp(find(idx,1,'first'));
end
LapTimeEgo.seconds = lapTime;
LapTimeEgo.fulltime  = Sec2LapTime(LapTimeEgo.seconds);