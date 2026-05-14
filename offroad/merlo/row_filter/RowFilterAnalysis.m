clearvars -except log log2
close all
clc

compare     = false;
line_form   = 'normal';


%#ok<*UNRCH>
%#ok<*INUSD>

%% paths

addpath("bags/");
addpath("func/");
addpath("plot/");
addpath("../../../common/graphic_tools/");
addpath("../../../common/constants/");
addpath("../../../common/utils/");

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

if (~exist('log','var'))
    [file,path] = uigetfile(fullfile("bags",'*.mat'),'Load log');
    log = load(fullfile(path,file)); 
end
bag1 = load_row_filter_data(log);
bag1.lines = convert_lines(bag1.lines, OUTPUT_LINE_FORM, LINEFORM);
bag1.measures = convert_lines(bag1.measures, OUTPUT_LINE_FORM, LINEFORM);

if compare
    bag1.log_name = "Bag 1 - ";
    if (~exist('log2','var'))
        [file,path] = uigetfile(fullfile("bags",'*.mat'),'Load log');
        log2 = load(fullfile(path,file)); 
    end
    bag2 = load_row_filter_data(log2);
    bag2.log_name = "Bag 2 - ";
    bag2.lines = convert_lines(bag2.lines, OUTPUT_LINE_FORM, LINEFORM);
    bag2.measures = convert_lines(bag2.measures, OUTPUT_LINE_FORM, LINEFORM);
end

if isfield(log, 'supervisor__vehicle_status')
    bag1.supervisor.stamp  =  log.supervisor__vehicle_status.stamp;
    bag1.supervisor.state  =  log.supervisor__vehicle_status.state;
    bag1.supervisor.in_row =  log.supervisor__vehicle_status.state == VEH_STATUS.IN_ROW | ... % in row 
                              log.supervisor__vehicle_status.state == VEH_STATUS.PAUSED;      % paused
                             % log.supervisor__vehicle_status.state == VEH_STATUS.ENTERING |... % entering
                             % log.supervisor__vehicle_status.state == VEH_STATUS.EXITING |...  % exiting
    bag1.supervisor.in_row = logical(bag1.supervisor.in_row);
end

% In row detection strategy
strategies = unique(bag1.debug.in_row_det.in_row_det_strategy);
if compare
    strategies = unique([strategies; unique(bag2.debug.in_row_det.in_row_det_strategy)]);
end

%% Plotting

in_row_state;
in_row_det_chunks;
in_row_det_rows;
line_equations;
line_distance;
line_coefficients;
rows_angle;
line_viz;
chunk_viz;
map;
angles_estimates;

% linkaxes
t0 = 0;   
t1 = max(bag1.state.stamp);
if compare
    t1 = max([t1; max(bag2.state.stamp)]);
end     
for k = 1:numel(ax)
    ax(k).XLim = [t0 t1];
    ax(k).XLimMode = 'manual';      
end
if ~isempty(ax) && any(isgraphics(ax,'axes'))
    linkaxes(ax(isgraphics(ax,'axes')),'x');
end