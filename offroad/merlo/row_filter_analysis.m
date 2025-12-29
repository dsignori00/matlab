clearvars -except bag1 bag2
close all
clc

paths.utils_path =  "utils";
%%% Replace bag_path with desired path
paths.bag_path = fullfile("/home","alessandro","adehome_merlo","cingo_code","bags");
paths.graphic_tools = fullfile("..","..","common","graphic_tools");

addpath(genpath(paths.bag_path));
addpath(genpath(paths.graphic_tools));
addpath(genpath(paths.utils_path));

graphics_options;

patch_properties = {'FaceColor', colors.orange{1}, 'FaceAlpha', 0.3, 'EdgeColor', 'none', 'HandleVisibility', 'off'};
R2D = 57.2958;
ax = gobjects(0); f=1;

log_row_eq = true;

%% load structs
load_structs;

%% load log

if (~exist('bag1','var'))
    [file,path] = uigetfile(fullfile(paths.bag_path,'*.mat'),'Load log');
    bag1.log = load(fullfile(path,file));
    bag1.log_name = "bag";
end
bag1.lines = parseLineEquations(bag1.log, 'perception__row_filter__line_equations');
if (log_row_eq) bag1.rows = parseLineEquations(bag1.log,'perception__row_filter__debug__rows_equations'); end
bag1.state = parseRowFilterMsg(bag1.log);

% Convert lines to desired form for visualization
OUTPUT_LINE_FORM = LINEFORM.NORMAL;

bag1.lines = convertLines(bag1.lines, OUTPUT_LINE_FORM, LINEFORM);
if (log_row_eq) bag1.rows = convertLines(bag1.rows, OUTPUT_LINE_FORM, LINEFORM); end


%% IN ROW STATE

strategies = unique(bag1.log.perception__row_filter__debug__info.inrowdet_strategy);
bag1.inrow = logical(bag1.log.perception__row_filter__row_filter_msg.in_row);
bag1.perc_time = bag1.log.perception__row_filter__row_filter_msg.stamp;

if isfield(bag1.log, 'supervisor__vehicle_status')
    bag1.sup_time = bag1.log.supervisor__vehicle_status.stamp;
    bag1.inrow_sup = bag1.log.supervisor__vehicle_status.state == VEH_STATUS.IN_ROW |... % in row 
                      bag1.log.supervisor__vehicle_status.state == VEH_STATUS.PAUSED;    % paused
                      % bag1.log.supervisor__vehicle_status.state == VEH_STATUS.ENTERING |... % entering
                      % bag1.log.supervisor__vehicle_status.state == VEH_STATUS.EXITING |...  % exiting
    bag1.inrow_sup = logical(bag1.inrow_sup);
end

if (ismember(strategies, INROWDETSTR.AUTOMATIC))
    in_row_label = "Automatic In-Row det";
elseif (ismember(strategies, INROWDETSTR.TRAJECTORY))
    in_row_label = "Trajectory In-Row det";

elseif (ismember(strategies, INROWDETSTR.MANUAL))
    in_row_label = "Manual In-Row det";
end

bag1.inrow = bag1.log.perception__row_filter__row_filter_msg.in_row;
figure('Name','InRow Detection');
tiledlayout(1,1,"TileSpacing","compact");
ax(1) = nexttile; hold on;
plot(bag1.perc_time, bag1.inrow,'DisplayName',in_row_label);
ylim([ -0.1 1.1 ])
if isfield(bag1.log, 'supervisor__vehicle_status')
    plot(bag1.sup_time, bag1.inrow_sup,'DisplayName','Traj In‑Row');
end
xlabel("Time [s]")
legend show

%% VEHICLE STATUS
if isfield(bag1.log, 'supervisor__vehicle_status')
    figure('Name','Supervisor state');
    tiledlayout(1,1);
    ax(f) = nexttile; f = f+1;
    hold on;
    plot(bag1.sup_time, double(bag1.log.supervisor__vehicle_status.state),'DisplayName','Traj State');
    xlabel("Time [s]")
    yticks(double([VEH_STATUS.IDLE, ...
                   VEH_STATUS.PAUSED, ...
                   VEH_STATUS.FINISH, ...
                   VEH_STATUS.IN_ROW, ...
                   VEH_STATUS.OUT_ROW, ...
                   VEH_STATUS.EXITING, ...
                   VEH_STATUS.ENTERING, ...
                   VEH_STATUS.OBSTACLE_INSIDE, ...
                   VEH_STATUS.ERROR, ...
                   VEH_STATUS.MANUAL]));
    
    yticklabels({'IDLE', ...
                 'PAUSED', ...
                 'FINISH', ...
                 'IN\_ROW', ...
                 'OUT\_ROW', ...
                 'EXITING', ...
                 'ENTERING', ...
                 'OBSTACLE\_INSIDE', ...
                 'ERROR', ...
                 'MANUAL'});
    legend show
end

%% IN ROW DETECTION (visualize only if automatic inrow-det was enabled)

strategies = unique(bag1.log.perception__row_filter__debug__info.inrowdet_strategy);
if (ismember(strategies, INROWDETSTR.AUTOMATIC))

    inrowdet_idx = true(size(bag1.perc_time));
    inrowdet_idx(bag1.log.perception__row_filter__debug__info.inrowdet_strategy ~= INROWDETSTR.AUTOMATIC) = false;
    
    figure("Name","InRowDet - Chunks");
    tiledlayout(6,2, "TileSpacing","compact")
    ax(f) = nexttile([2,2]); f=f+1;
    grid on; hold on;
    plot(bag1.perc_time(inrowdet_idx), bag1.log.perception__row_filter__debug__info.chunks__end_row_detection_len(inrowdet_idx,1), 'DisplayName', bag1.log_name + " L");
    plot(bag1.perc_time(inrowdet_idx), bag1.log.perception__row_filter__debug__info.chunks__end_row_detection_len(inrowdet_idx,2), 'DisplayName',bag1.log_name+  " R");
    plot_patches(bag1.perc_time(inrowdet_idx), ~bag1.inrow(inrowdet_idx), ax(f-1), patch_properties);
    xlabel("time [s]")
    title("chunk length")
    legend show
    
    
    ax(f) = nexttile([2,2]); f=f+1;
    grid on; hold on;
    plot(bag1.perc_time(inrowdet_idx), bag1.log.perception__row_filter__debug__info.chunks__density(inrowdet_idx,1), 'DisplayName', bag1.log_name + " - L");
    plot(bag1.perc_time(inrowdet_idx), bag1.log.perception__row_filter__debug__info.chunks__density(inrowdet_idx,2), 'DisplayName',bag1.log_name +" - R");
    plot_patches(bag1.perc_time(inrowdet_idx), ~bag1.inrow(inrowdet_idx), ax(f-1), patch_properties);
    xlabel("timestamp [s]")
    title("density chunk ")
    legend show
    
    ax(f) = nexttile([2,1]); f=f+1;
    grid on; hold on;
    plot(bag1.perc_time(inrowdet_idx), bag1.log.perception__row_filter__debug__info.chunks__state(inrowdet_idx,1), 'DisplayName', bag1.log_name + " - L");
    plot_patches(bag1.perc_time(inrowdet_idx), ~bag1.inrow(inrowdet_idx), ax(f-1), patch_properties);
    xlabel("timestamp [s]")
    ax(f-1).YTickLabel = {'forgot','not fitted','fitted', 'discarded'};
    title("state ")
    legend show
    
    ax(f) = nexttile([2,1]); f=f+1;
    grid on; hold on;
    plot(bag1.perc_time(inrowdet_idx), bag1.log.perception__row_filter__debug__info.chunks__state(inrowdet_idx,2), 'DisplayName', bag1.log_name + " - R");
    plot_patches(bag1.perc_time(inrowdet_idx), ~bag1.inrow(inrowdet_idx), ax(f-1), patch_properties);
    xlabel("timestamp [s]")
    ax(f-1).YTickLabel = {'forgot','not fitted','fitted', 'discarded'};
    title("state ")
    legend show
end

%% IN ROW DET CHUNKS (visualize only if automatic inrow-det was enabled)
if (ismember(strategies,INROWDETSTR.AUTOMATIC))
    figure("Name","InRowDet - Closest Rows");
    tiledlayout(3,2, "TileSpacing","compact")
    ax(f) = nexttile([1,1]); f=f+1;
    grid on; hold on;
    x_length(:,1) = abs(bag1.log.perception__row_filter__debug__info.closest_rows__x_min(inrowdet_idx,1) - bag1.log.perception__row_filter__debug__info.closest_rows__x_max(inrowdet_idx,1)); 
    x_length(:,2) = abs(bag1.log.perception__row_filter__debug__info.closest_rows__x_min(inrowdet_idx,2) - bag1.log.perception__row_filter__debug__info.closest_rows__x_max(inrowdet_idx,2)); 
    plot(bag1.perc_time(inrowdet_idx), x_length(:,1), 'DisplayName', bag1.log_name + " L");
    plot(bag1.perc_time(inrowdet_idx), x_length(:,2), 'DisplayName',bag1.log_name+  " R");
    plot_patches(bag1.perc_time(inrowdet_idx), ~bag1.inrow(inrowdet_idx), ax(f-1), patch_properties);
    xlabel("time [s]")
    title("x length")
    legend show
    
    ax(f) = nexttile([1,1]); f=f+1;
    grid on; hold on;
    y_length(:, 1) = abs(bag1.log.perception__row_filter__debug__info.closest_rows__y_min(inrowdet_idx,1) - bag1.log.perception__row_filter__debug__info.closest_rows__y_max(inrowdet_idx,1)); 
    y_length(:, 2) = abs(bag1.log.perception__row_filter__debug__info.closest_rows__y_min(inrowdet_idx,2) - bag1.log.perception__row_filter__debug__info.closest_rows__y_max(inrowdet_idx,2)); 
    plot(bag1.perc_time(inrowdet_idx), y_length(inrowdet_idx,1), 'DisplayName', bag1.log_name + " L");
    plot(bag1.perc_time(inrowdet_idx), y_length(inrowdet_idx,2), 'DisplayName',bag1.log_name+  " R");
    plot_patches(bag1.perc_time(inrowdet_idx), ~bag1.inrow(inrowdet_idx), ax(f-1), patch_properties);
    xlabel("time [s]")
    title("y length")
    legend show
    
    ax(f) = nexttile([1,1]); f=f+1;
    grid on; hold on;
    z_length(:, 1) = abs(bag1.log.perception__row_filter__debug__info.closest_rows__z_min(inrowdet_idx,1) - bag1.log.perception__row_filter__debug__info.closest_rows__z_max(inrowdet_idx,1)); 
    z_length(:, 2) = abs(bag1.log.perception__row_filter__debug__info.closest_rows__z_min(inrowdet_idx,2) - bag1.log.perception__row_filter__debug__info.closest_rows__z_max(inrowdet_idx,2)); 
    plot(bag1.perc_time(inrowdet_idx), z_length(inrowdet_idx,1), 'DisplayName', bag1.log_name + " L");
    plot(bag1.perc_time(inrowdet_idx), z_length(inrowdet_idx,2), 'DisplayName',bag1.log_name+  " R");
    plot_patches(bag1.perc_time(inrowdet_idx), ~bag1.inrow(inrowdet_idx), ax(f-1), patch_properties);
    xlabel("time [s]")
    title("z length")
    legend show
    
    ax(f) = nexttile([1,1]); f=f+1;
    grid on; hold on;
    plot(bag1.perc_time(inrowdet_idx), bag1.log.perception__row_filter__debug__info.closest_rows__p1(inrowdet_idx,1), 'DisplayName', bag1.log_name + " L");
    plot(bag1.perc_time(inrowdet_idx), bag1.log.perception__row_filter__debug__info.closest_rows__p1(inrowdet_idx,2), 'DisplayName',bag1.log_name+  " R");
    plot_patches(bag1.perc_time(inrowdet_idx), ~bag1.inrow(inrowdet_idx), ax(f-1), patch_properties);
    xlabel("time [s]")
    title("m")
    legend show
    
    ax(f) = nexttile([1,1]); f=f+1;
    grid on; hold on;
    plot(bag1.perc_time(inrowdet_idx), bag1.log.perception__row_filter__debug__info.closest_rows__p2(inrowdet_idx,1), 'DisplayName', bag1.log_name + " L");
    plot(bag1.perc_time(inrowdet_idx), bag1.log.perception__row_filter__debug__info.closest_rows__p2(inrowdet_idx,2), 'DisplayName',bag1.log_name+  " R");
    plot_patches(bag1.perc_time(inrowdet_idx), ~bag1.inrow(inrowdet_idx), ax(f-1), patch_properties);
    xlabel("time [s]")
    title("q")
    legend show
end
%% Rows - Lines analysis

figure('Name','Line distance')
tiledlayout(1,1)
ax(f) = nexttile([1,1]); f=f+1;hold on; grid on
plot(bag1.perc_time, bag1.state.dist_left_row, 'DisplayName','L');
plot(bag1.perc_time, bag1.state.dist_right_row, 'DisplayName','R');
plot_patches(bag1.perc_time, ~bag1.inrow, ax(f-1), patch_properties);
xlabel("timestamp [s]")
ylabel("distance [m]")
legend show

figure('Name','Line Equations')
tiledlayout(3,1)
ax(f) = nexttile([1,1]); f=f+1;hold on; grid on
num_lines = max(bag1.lines.num_fitted_lines);
if (OUTPUT_LINE_FORM == LINEFORM.EXPLICIT)
    p1_label = "m [-]";
elseif (OUTPUT_LINE_FORM == LINEFORM.NORMAL)
    p1_label = " alpha [deg]";
else
    p1_label = " ";
end
h = plot(bag1.lines.stamp, bag1.lines.p1(:, 1:num_lines) * R2D);
if(log_row_eq) scatter(bag1.rows.stamp, bag1.rows.p1(:, 1:num_lines) * R2D); end
plot_patches(bag1.perc_time, ~bag1.inrow, ax(f-1), patch_properties);
xlabel("timestamp [s]")
ylabel("p1 (" + p1_label + ")")
labels = "Line " + string(1:1:num_lines);    % e.g. "Line 1", "Line 3", ...
legend(h, labels, 'Location','northeast');
legend show

ax(f) = nexttile([1,1]); f=f+1;hold on; grid on
num_lines = max(bag1.lines.num_fitted_lines);
if (OUTPUT_LINE_FORM == LINEFORM.EXPLICIT)
    p2_label = "Q [-]";
elseif (OUTPUT_LINE_FORM == LINEFORM.NORMAL)
    p2_label = " ort dist [m]";
else
    p2_label = " ";
end
h = plot(bag1.lines.stamp, bag1.lines.p2(:, 1:num_lines));
if(log_row_eq) scatter(bag1.rows.stamp, bag1.rows.p2(:, 1:num_lines)); end
plot_patches(bag1.perc_time, ~bag1.inrow, ax(f-1), patch_properties);
xlabel("timestamp [s]")
ylabel("p2 (" + p2_label + ")")
labels = "Line " + string(1:1:num_lines);    % e.g. "Line 1", "Line 3", ...
legend(h, labels, 'Location','northeast');
legend show

ax(f) = nexttile([1,1]); f=f+1;hold on; grid on
num_lines = max(bag1.lines.num_fitted_lines);
h = plot(bag1.lines.stamp, bag1.lines.rho(:, 1:num_lines));
if(log_row_eq) scatter(bag1.rows.stamp, bag1.rows.rho(:, 1:num_lines)); end
plot_patches(bag1.perc_time, ~bag1.inrow, ax(f-1), patch_properties);
xlabel("timestamp [s]")
ylabel("signed dist")
labels = "Line " + string(1:1:num_lines);    % e.g. "Line 1", "Line 3", ...
legend(h, labels, 'Location','northeast');
legend show
%% Rows - Lines coefficients

figure('Name','Coeff distance')
tiledlayout(2,2)
ax(f) = nexttile([1,1]); f=f+1;hold on; grid on
plot(bag1.lines.stamp, bag1.lines.coeff(:,:,1), 'DisplayName','x0');
if(log_row_eq) scatter(bag1.rows.stamp, bag1.rows.coeff(:,:,1)); end
plot_patches(bag1.perc_time, ~bag1.inrow, ax(f-1), patch_properties);
xlabel("timestamp [s]")
ylabel("x0")

ax(f) = nexttile([1,1]); f=f+1;hold on; grid on
plot(bag1.lines.stamp, bag1.lines.coeff(:,:,2), 'DisplayName','y0');
if(log_row_eq) scatter(bag1.rows.stamp, bag1.rows.coeff(:,:,2)); end
plot_patches(bag1.perc_time, ~bag1.inrow, ax(f-1), patch_properties);
xlabel("timestamp [s]")
ylabel("y0")

ax(f) = nexttile([1,1]); f=f+1;hold on; grid on
plot(bag1.lines.stamp, bag1.lines.coeff(:,:,4), 'DisplayName','dx');
if(log_row_eq) scatter(bag1.rows.stamp, bag1.rows.coeff(:,:,4)); end
plot_patches(bag1.perc_time, ~bag1.inrow, ax(f-1), patch_properties);
xlabel("timestamp [s]")
ylabel("dx")

ax(f) = nexttile([1,1]); f=f+1;hold on; grid on
plot(bag1.lines.stamp, bag1.lines.coeff(:,:,5), 'DisplayName','dy');
if(log_row_eq) scatter(bag1.rows.stamp, bag1.rows.coeff(:,:,5)); end
plot_patches(bag1.perc_time, ~bag1.inrow, ax(f-1), patch_properties);
xlabel("timestamp [s]")
ylabel("dy")


%% ROW - LINE VISUALIZATION

%%% Select time portion on any plots, click refresh, use arrows to show
%%% each iteration in the selected range

linkaxes(ax,'x')

fig = figure('Name','COG Visualization');
set(fig,'KeyPressFcn',@keyPressed);   % <-- enable arrows

% Axes for map (left side)
axMap = axes('Parent',fig,'Units','normalized','Position',[0.06 0.10 0.50 0.85]);
title(axMap,'map');

% --- Two tables on the right, stacked (each half height) ---
colNames_lines = {'Line#','p1','p2','rho','x0','y0','dx','dy'};
colNames_rows = {'Row#','p1','p2','rho','assoc.','x0','y0','dx','dy'};

tblLines = uitable(fig, ...
    'Units','normalized', ...
    'Position',[0.60 0.53 0.38 0.42], ...   % top half
    'ColumnName', colNames_lines, ...
    'Data', cell(0,8));

tblRows = uitable(fig, ...
    'Units','normalized', ...
    'Position',[0.60 0.08 0.38 0.42], ...   % bottom half
    'ColumnName', colNames_rows, ...
    'Data', cell(0,9));

% Button
c = uicontrol('Style','pushbutton', ...
    'String','Refresh', ...
    'Units','normalized', ...
    'Position',[0.01 0.01 0.1 0.05], ...
    'Callback',@refreshTimeButtonPushed);

% Initialize empty state
S = struct();
S.ax       = axMap;
S.tblLines = tblLines;
S.tblRows  = tblRows;
guidata(fig,S);

function refreshTimeButtonPushed(~,~)
    % Pull needed vars
    fig        = evalin('base','fig');
    ax         = evalin('base', 'ax');
    bag1       = evalin('base', 'bag1');
    FOOTPRINT  = evalin('base','FOOTPRINT');

    % Determine range from x-limits
    t_lim = xlim(ax(1));
    t1_line_eq   = find(bag1.lines.stamp > t_lim(1), 1, 'first');
    tend_line_eq = find(bag1.lines.stamp < t_lim(2), 1, 'last');

    if isempty(t1_line_eq) || isempty(tend_line_eq) || t1_line_eq > tend_line_eq
        warning('No line samples in the selected x-limits interval.');
        return;
    end

    % Build/update state
    S = guidata(fig);

    S.bag1      = bag1;
    S.FOOTPRINT = FOOTPRINT;
    S.iStart    = t1_line_eq;
    S.iEnd      = tend_line_eq;
    S.iCur      = t1_line_eq;

    guidata(fig,S);

    drawCurrentSample();
end

function keyPressed(~, event)
    fig = evalin('base','fig');
    S = guidata(fig);

    if ~isfield(S,'iCur') || isempty(S.iCur)
        return;
    end

    switch event.Key
        case 'rightarrow'
            S.iCur = min(S.iCur + 1, S.iEnd);
            guidata(fig,S);
            drawCurrentSample();

        case 'leftarrow'
            S.iCur = max(S.iCur - 1, S.iStart);
            guidata(fig,S);
            drawCurrentSample();
    end
end

function drawCurrentSample()
    fig = evalin('base','fig');
    log_row_eq = evalin('base','log_row_eq');
    S = guidata(fig);
    i = S.iCur;

    % --------- MAP DRAW ----------
    axes(S.ax);
    cla(S.ax,'reset');
    hold(S.ax,'on'); grid(S.ax,'on');
    xlabel(S.ax,'y[m]'); ylabel(S.ax,'x[m]');
    axis(S.ax,'equal'); xlim(S.ax,[-10,10]); ylim(S.ax,[-10,10]);

    rectangle('Position',[-S.FOOTPRINT.width/2 -S.FOOTPRINT.length/2 ...
                          S.FOOTPRINT.width S.FOOTPRINT.length], ...
              'EdgeColor','k','LineWidth',2);

    x = [S.bag1.lines.x_min(i,:) ; S.bag1.lines.x_max(i,:)];
    y = [S.bag1.lines.y_min(i,:) ; S.bag1.lines.y_max(i,:)];
    plot(-y, x, 'DisplayName','Lines','LineWidth',2.0);

    if log_row_eq
        rows_x = [S.bag1.rows.x_min(i,:) ; S.bag1.rows.x_max(i,:)];
        rows_y = [S.bag1.rows.y_min(i,:) ; S.bag1.rows.y_max(i,:)];
        plot(-rows_y, rows_x, 'LineStyle','--','LineWidth',0.3, 'DisplayName','Rows');
    end

    txt = sprintf('sample %d / %d', i-S.iStart+1, S.iEnd-S.iStart+1);
    title(S.ax, ['map — ' txt]);
    hold(S.ax,'off');

    % --------- TABLE 1: LINES ----------
    p1  = S.bag1.lines.p1(i,:);
    p2  = S.bag1.lines.p2(i,:);
    rho = S.bag1.lines.rho(i,:);
    x0  = S.bag1.lines.coeff(i,:,1);
    y0  = S.bag1.lines.coeff(i,:,2);
    dx  = S.bag1.lines.coeff(i,:,4);
    dy  = S.bag1.lines.coeff(i,:,5);

    nL = numel(rho);
    dataLines = cell(nL, 8);
    for k = 1:nL
        dataLines{k,1} = k;
        dataLines{k,2} = p1(k);
        dataLines{k,3} = p2(k);
        dataLines{k,4} = rho(k);
        dataLines{k,5} = x0(k);
        dataLines{k,6} = y0(k);
        dataLines{k,7} = dx(k);
        dataLines{k,8} = dy(k);
    end
    if isfield(S,'tblLines') && isvalid(S.tblLines)
        S.tblLines.Data = dataLines;
    end

    % --------- TABLE 2: ROWS ----------
    if log_row_eq
        p1r  = S.bag1.rows.p1(i,:);
        p2r  = S.bag1.rows.p2(i,:);
        rhor = S.bag1.rows.rho(i,:);
        associatedr = S.bag1.rows.associated(i,:);
        x0r  = S.bag1.rows.coeff(i,:,1);
        y0r  = S.bag1.rows.coeff(i,:,2);
        dxr  = S.bag1.rows.coeff(i,:,4);
        dyr  = S.bag1.rows.coeff(i,:,5);

        nR = numel(rhor);
        dataRows = cell(nR, 8);
        for k = 1:nR
            dataRows{k,1} = k;
            dataRows{k,2} = p1r(k);
            dataRows{k,3} = p2r(k);
            dataRows{k,4} = rhor(k);
            dataRows{k,5} = associatedr(k);
            dataRows{k,6} = x0r(k);
            dataRows{k,7} = y0r(k);
            dataRows{k,8} = dxr(k);
            dataRows{k,9} = dyr(k);
        end

        if isfield(S,'tblRows') && isvalid(S.tblRows)
            S.tblRows.Data = dataRows;
        end
    else
        if isfield(S,'tblRows') && isvalid(S.tblRows)
            S.tblRows.Data = cell(0,8);
        end
    end
end
    
%% functions
function deg = m2deg(m)
    deg = rad2deg(atan(m));
end