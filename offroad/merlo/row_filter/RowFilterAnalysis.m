clearvars -except bag1 bag2
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

if (~exist('bag1','var'))
    [file,path] = uigetfile(fullfile("bags",'*.mat'),'Load log');
    bag1.log = load(fullfile(path,file)); 
end
bag1.log_name = "";

switch line_form
    case 'normal'
        OUTPUT_LINE_FORM = LINEFORM.NORMAL;
    case 'explicit'
        OUTPUT_LINE_FORM = LINEFORM.EXPLICIT;
    otherwise
        error('Unknown line form %s', line_form);
end

bag1.lines = parse_line_equations(bag1.log, 'perception__row_filter__line_equations');
bag1.lines = convert_lines(bag1.lines, OUTPUT_LINE_FORM, LINEFORM);
bag1.state = parse_row_filter_msg(bag1.log);
bag1.inrow = bag1.log.perception__row_filter__row_filter_msg.in_row;
bag1.perc_time = bag1.log.perception__row_filter__row_filter_msg.stamp;

if isfield(bag1.log, 'supervisor__vehicle_status')
    bag1.sup_time  =  bag1.log.supervisor__vehicle_status.stamp;
    bag1.inrow_sup =  bag1.log.supervisor__vehicle_status.state == VEH_STATUS.IN_ROW | ... % in row 
                      bag1.log.supervisor__vehicle_status.state == VEH_STATUS.PAUSED;      % paused
                      % bag1.log.supervisor__vehicle_status.state == VEH_STATUS.ENTERING |... % entering
                      % bag1.log.supervisor__vehicle_status.state == VEH_STATUS.EXITING |...  % exiting
    bag1.inrow_sup = logical(bag1.inrow_sup);
end

if (log_row_eq) 
    bag1.rows = parse_line_equations(bag1.log,'perception__row_filter__debug__rows_equations'); 
    bag1.rows = convert_lines(bag1.rows, OUTPUT_LINE_FORM, LINEFORM); 
end

strategies = unique(bag1.log.perception__row_filter__debug__info.inrowdet_strategy);

if (ismember(strategies, INROWDETSTR.AUTOMATIC))
    in_row_label = "Automatic In-Row det";
elseif (ismember(strategies, INROWDETSTR.TRAJECTORY))
    in_row_label = "Trajectory In-Row det";
elseif (ismember(strategies, INROWDETSTR.MANUAL))
    in_row_label = "Manual In-Row det";
end

%% Plotting

% vehicle_status;
% in_row_state;
in_row_det_chunks;
in_row_det_rows;
line_distance;
line_equations;
line_coefficients;
line_viz;

linkaxes(ax,'x');