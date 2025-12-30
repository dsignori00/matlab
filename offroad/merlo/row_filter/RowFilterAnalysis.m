clearvars -except bag1 
close all
clc

log_row_eq = true;
line_form = 'normal';

%% paths

addpath("bags/");
addpath("func/");
addpath("plot/");
addpath("../../../common/graphic_tools/");
addpath("../../../common/constants/");

LoadStruct; 
PhysicalConstants;
graphics_options;

patch_properties = {'FaceColor', colors.orange{1}, 'FaceAlpha', 0.3, 'EdgeColor', 'none', 'HandleVisibility', 'off'};
ax = gobjects(0); f=1;

%% load data

switch line_form
    case 'normal'
        OUTPUT_LINE_FORM = LINEFORM.NORMAL;
    case 'explicit'
        OUTPUT_LINE_FORM = LINEFORM.EXPLICIT;
    otherwise
        error('Unknown line form %s', line_form);
end

if (~exist('bag1','var'))
    if (~exist('log','var'))
        [file,path] = uigetfile(fullfile("bags",'*.mat'),'Load log');
        log = load(fullfile(path,file)); 
    end
    bag1.log_name = "";
    bag1.lines = parse_line_equations(log, 'perception__row_filter__line_equations');
    bag1.lines = convert_lines(bag1.lines, OUTPUT_LINE_FORM, LINEFORM);
    bag1.state = parse_row_filter_msg(log);
    bag1.inrow = log.perception__row_filter__row_filter_msg.in_row;
    bag1.perc_time = log.perception__row_filter__row_filter_msg.stamp;
    bag1.cloud = log.perception__row_filter__debug__proc_cloud.data;
    bag1.inliers = log.perception__row_filter__debug__line_inliers.data;
    bag1.virtual = log.perception__row_filter__virtual_cloud.data;
    bag1.roi_points = log.perception__row_filter__debug__inside_roi;
    bag1.info = log.perception__row_filter__debug__info;

    if (log_row_eq) 
        bag1.rows = parse_line_equations(log,'perception__row_filter__debug__rows_equations'); 
        bag1.rows = convert_lines(bag1.rows, OUTPUT_LINE_FORM, LINEFORM); 
    end

    if isfield(log, 'supervisor__vehicle_status')
        bag1.supervisor.stamp  =  log.supervisor__vehicle_status.stamp;
        bag1.supervisor.state = log.supervisor__vehicle_status.state;
        bag1.supervisor.in_row =  log.supervisor__vehicle_status.state == VEH_STATUS.IN_ROW | ... % in row 
                          log.supervisor__vehicle_status.state == VEH_STATUS.PAUSED;      % paused
                          % log.supervisor__vehicle_status.state == VEH_STATUS.ENTERING |... % entering
                          % log.supervisor__vehicle_status.state == VEH_STATUS.EXITING |...  % exiting
        bag1.supervisor.in_row = logical(bag1.supervisor.in_row);
    end
    clearvars log
end

% In row detection strategy
strategies = unique(bag1.info.inrowdet_strategy);
if (ismember(strategies, INROWDETSTR.AUTOMATIC))
    in_row_label = "Automatic";
elseif (ismember(strategies, INROWDETSTR.TRAJECTORY))
    in_row_label = "Trajectory";
elseif (ismember(strategies, INROWDETSTR.MANUAL))
    in_row_label = "Manual";
end

%% Plotting

in_row_state;
in_row_det_chunks;
in_row_det_rows;
line_distance;
line_equations;
line_coefficients;
line_viz;

linkaxes(ax,'x');