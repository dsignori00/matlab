close all
clearvars -except log log2 trajDatabase gt lid1 lid2

ground_truth = false;
compare = true;

NAME_1 = "Lidar clustering";
NAME_2 = "Lidar clustering - 2";

%#ok<*UNRCH>
%#ok<*INUSD>

%% Paths

proj = currentProject();
addpath(fullfile(proj.RootFolder, 'src', 'perception', 'utils'));

%% Load Data

% Load trajectory database.
if ~exist('trajDatabase', 'var')
    trajDatabase = choose_database();
    if isempty(trajDatabase)
        error('No database selected');
    end
    load(trajDatabase);
end

% Load primary log.
if ~exist('log', 'var')
    [file, path] = uigetfile(fullfile(get_bags_dir(), '*.mat'), 'Load log');
    if isequal(file, 0)
        error('No log selected');
    end
    load(fullfile(path, file));
end

% Load comparison log.
if compare && ~exist('log2', 'var')
    [file, path] = uigetfile(fullfile(get_bags_dir(), '*.mat'), 'Load log 2');
    if isequal(file, 0)
        error('No comparison log selected');
    end
    tmp = load(fullfile(path, file));
    log2 = tmp.log;
end

if ground_truth && ~exist('gt', 'var')
    [file, path] = uigetfile(fullfile(get_gt_dir(), '*.mat'), ...
        'Load ground truth log');
    if isequal(file, 0)
        error('No ground truth log selected');
    end
    tmp = load(fullfile(path, file));
    gt = tmp.out;
end

DateTime = datetime(log.time_offset_nsec, 'ConvertFrom', 'epochtime', ...
    'TicksPerSecond', 1e9, 'Format', 'dd-MMM-yyyy HH:mm:ss');

%% Plot Data

set(0, 'DefaultFigureWindowStyle', 'docked');
set(0, 'DefaultTextInterpreter', 'none');
set(0, 'DefaultLegendInterpreter', 'none');
set(0, 'DefaultLineLineWidth', 2);

x_lim = [0 inf];

%% Naming

col.lidar = '#77AC30';
col.lidar2 = '#A2142F';
col.rho_dot_max = '#EDB120';
col.rho_dot_max2 = '#7E2F8E';
col.ref = '#000000';
sz = 3;
f = 1;

%% Lidar Clustering Detections

lid1 = get_lidar_clustering_fields(log);
if compare
    lid2 = get_lidar_clustering_fields(log2);
end

%% Processing

lid1.range = sqrt(lid1.x_rel.^2 + lid1.y_rel.^2);

if ground_truth
    gt_timestamp = (gt.timestamp - double(log.time_offset_nsec)) * 1e-9;
end

if compare
    lid2.range = sqrt(lid2.x_rel.^2 + lid2.y_rel.^2);
    lid2_sens_stamp = lid2.sens_stamp + ...
        double(log2.time_offset_nsec) * 1e-9 - ...
        double(log.time_offset_nsec) * 1e-9;
    lid2_stamp = lid2.stamp + ...
        double(log2.time_offset_nsec) * 1e-9 - ...
        double(log.time_offset_nsec) * 1e-9;
end

%% STATE FIGURE COG

figure('Name', 'Detections - CoG')
tiledlayout(2, 1, 'Padding', 'compact');

axesHandles(f) = nexttile([1, 1]); f = f + 1;
hold on;
plot(safe_cols(lid1.sens_stamp, lid1.max_det), ...
    safe_cols(lid1.x_rel, lid1.max_det), 'o', ...
    'MarkerFaceColor', col.lidar, 'MarkerEdgeColor', col.lidar, ...
    'MarkerSize', sz, 'DisplayName', NAME_1);
if compare
    plot(safe_cols(lid2_sens_stamp, lid2.max_det), ...
        safe_cols(lid2.x_rel, lid2.max_det), 'o', ...
        'MarkerFaceColor', col.lidar2, 'MarkerEdgeColor', col.lidar2, ...
        'MarkerSize', sz, 'DisplayName', NAME_2);
end
if ground_truth
    plot(gt_timestamp, gt.x_rel, 'Color', col.ref, 'DisplayName', 'gt');
end
grid on; title('x rel [m]'); xlim(x_lim); ylim([-200 200]);

axesHandles(f) = nexttile([1, 1]); f = f + 1;
hold on;
plot(safe_cols(lid1.sens_stamp, lid1.max_det), ...
    safe_cols(lid1.y_rel, lid1.max_det), 'o', ...
    'MarkerFaceColor', col.lidar, 'MarkerEdgeColor', col.lidar, ...
    'MarkerSize', sz, 'DisplayName', NAME_1);
if compare
    plot(safe_cols(lid2_sens_stamp, lid2.max_det), ...
        safe_cols(lid2.y_rel, lid2.max_det), 'o', ...
        'MarkerFaceColor', col.lidar2, 'MarkerEdgeColor', col.lidar2, ...
        'MarkerSize', sz, 'DisplayName', NAME_2);
end
if ground_truth
    plot(gt_timestamp, gt.y_rel, 'Color', col.ref, 'DisplayName', 'gt');
end
grid on; title('y rel [m]'); xlim(x_lim); ylim([-100 100]);

%% STATE FIGURE RANGE

figure('Name', 'Detections - Range')
tiledlayout(1, 1, 'Padding', 'compact');

axesHandles(f) = nexttile([1, 1]); f = f + 1;
hold on;
plot(safe_cols(lid1.sens_stamp, lid1.max_det), ...
    safe_cols(lid1.range, lid1.max_det), 'o', ...
    'MarkerFaceColor', col.lidar, 'MarkerEdgeColor', col.lidar, ...
    'MarkerSize', sz, 'DisplayName', NAME_1);
if compare
    plot(safe_cols(lid2_sens_stamp, lid2.max_det), ...
        safe_cols(lid2.range, lid2.max_det), 'o', ...
        'MarkerFaceColor', col.lidar2, 'MarkerEdgeColor', col.lidar2, ...
        'MarkerSize', sz, 'DisplayName', NAME_2);
end
if ground_truth
    plot(gt_timestamp, gt.rho, 'Color', col.ref, 'DisplayName', 'gt');
end
grid on; title('range [m]'); xlim(x_lim); ylim([0 200]);

%% STATE FIGURE MAP

figure('Name', 'Detections - Map')
tiledlayout(2, 1, 'Padding', 'compact');

axesHandles(f) = nexttile([1, 1]); f = f + 1;
hold on;
plot(safe_cols(lid1.sens_stamp, lid1.max_det), ...
    safe_cols(lid1.x_map, lid1.max_det), 'o', ...
    'MarkerFaceColor', col.lidar, 'MarkerEdgeColor', col.lidar, ...
    'MarkerSize', sz, 'DisplayName', NAME_1);
if compare
    plot(safe_cols(lid2_sens_stamp, lid2.max_det), ...
        safe_cols(lid2.x_map, lid2.max_det), 'o', ...
        'MarkerFaceColor', col.lidar2, 'MarkerEdgeColor', col.lidar2, ...
        'MarkerSize', sz, 'DisplayName', NAME_2);
end
if ground_truth
    plot(gt_timestamp, gt.x_map, 'Color', col.ref, 'DisplayName', 'gt');
end
grid on; title('x map [m]'); xlim(x_lim);

axesHandles(f) = nexttile([1, 1]); f = f + 1;
hold on;
plot(safe_cols(lid1.sens_stamp, lid1.max_det), ...
    safe_cols(lid1.y_map, lid1.max_det), 'o', ...
    'MarkerFaceColor', col.lidar, 'MarkerEdgeColor', col.lidar, ...
    'MarkerSize', sz, 'DisplayName', NAME_1);
if compare
    plot(safe_cols(lid2_sens_stamp, lid2.max_det), ...
        safe_cols(lid2.y_map, lid2.max_det), 'o', ...
        'MarkerFaceColor', col.lidar2, 'MarkerEdgeColor', col.lidar2, ...
        'MarkerSize', sz, 'DisplayName', NAME_2);
end
if ground_truth
    plot(gt_timestamp, gt.y_map, 'Color', col.ref, 'DisplayName', 'gt');
end
grid on; title('y map [m]'); xlim(x_lim);

%% DETECTION COUNT FIGURE

countFigure = figure('Name', 'Detections - Count');
tiledlayout(1, 1, 'Padding', 'compact');

axesHandles(f) = nexttile([1, 1]); f = f + 1;
countAxes = axesHandles(f - 1);
hold on;
stairs(lid1.stamp, lid1.count, 'Color', col.lidar, ...
    'DisplayName', NAME_1);
if compare
    stairs(lid2_stamp, lid2.count, 'Color', col.lidar2, ...
        'DisplayName', NAME_2);
    comparisonStamp = lid2_stamp;
    comparisonCount = lid2.count;
else
    comparisonStamp = [];
    comparisonCount = [];
end
grid on;
xlabel('timestamp [s]');
ylabel('detections [#]');
xlim(x_lim);
legend show;
countTitle = title('Detections [#]');

% Link every time-series axis. The spatial MAP GUI is intentionally excluded.
linkaxes(axesHandles, 'x');

updateDetectionTotal(countAxes, countTitle, lid1.stamp, lid1.count, ...
    NAME_1, compare, comparisonStamp, comparisonCount, NAME_2);
countListener = addlistener(countAxes, 'XLim', 'PostSet', ...
    @(~, ~) updateDetectionTotal(countAxes, countTitle, ...
    lid1.stamp, lid1.count, NAME_1, compare, ...
    comparisonStamp, comparisonCount, NAME_2));
setappdata(countFigure, 'DetectionCountXLimListener', countListener);


%% MAP GUI

mapFigure = figure('Name', 'MAP');
refreshButton = uicontrol(mapFigure, 'Style', 'pushbutton', ...
    'String', 'Refresh', 'Callback', @refreshTimeButtonPushed);

function refreshTimeButtonPushed(src, ~)
    timeAxes = evalin('base', 'axesHandles');
    trajDb = evalin('base', 'trajDatabase');
    groundTruth = evalin('base', 'ground_truth');
    compareLogs = evalin('base', 'compare');
    colors = evalin('base', 'col');
    lidar1 = evalin('base', 'lid1');

    if groundTruth
        gtData = evalin('base', 'gt');
        gtTimestamp = evalin('base', 'gt_timestamp');
    end
    if compareLogs
        lidar2 = evalin('base', 'lid2');
        lidar2Timestamp = evalin('base', 'lid2_sens_stamp');
    end

    timeLimits = xlim(timeAxes(1));
    lidar1Idx = lidar1.sens_stamp > timeLimits(1) & ...
        lidar1.sens_stamp < timeLimits(2);
    if compareLogs
        lidar2Idx = lidar2Timestamp > timeLimits(1) & ...
            lidar2Timestamp < timeLimits(2);
    end
    if groundTruth
        gtIdx = gtTimestamp > timeLimits(1) & gtTimestamp < timeLimits(2);
    end

    figureHandle = ancestor(src, 'figure');
    mapAxes = findobj(figureHandle, 'Type', 'axes', ...
        'Tag', 'LidarClusteringMapAxes');
    if isempty(mapAxes)
        mapAxes = axes(figureHandle, 'Tag', 'LidarClusteringMapAxes');
    else
        cla(mapAxes, 'reset');
    end

    hold(mapAxes, 'on');
    grid(mapAxes, 'on');
    title(mapAxes, 'map');
    xlabel(mapAxes, 'x [m]');
    ylabel(mapAxes, 'y [m]');
    axis(mapAxes, 'equal');

    idLeft = length(trajDb) - 2;
    idRight = length(trajDb) - 1;
    plot(mapAxes, trajDb(idLeft).x, trajDb(idLeft).y, ...
        'Color', 'k', 'LineWidth', 1, 'HandleVisibility', 'off');
    plot(mapAxes, trajDb(idRight).x, trajDb(idRight).y, ...
        'Color', 'k', 'LineWidth', 1, 'HandleVisibility', 'off');

    scatter(mapAxes, lidar1.x_map(lidar1Idx), lidar1.y_map(lidar1Idx), ...
        20, 'filled', ...
        'MarkerEdgeColor', colors.lidar, ...
        'MarkerFaceColor', colors.lidar, ...
        'DisplayName', 'Lidar clustering');

    if compareLogs
        scatter(mapAxes, lidar2.x_map(lidar2Idx), ...
            lidar2.y_map(lidar2Idx), 20, 'filled', ...
            'MarkerEdgeColor', colors.lidar2, ...
            'MarkerFaceColor', colors.lidar2, ...
            'DisplayName', 'Lidar clustering - 2');
    end

    if groundTruth
        plot(mapAxes, gtData.x_map(gtIdx), gtData.y_map(gtIdx), ...
            'Color', colors.ref, 'DisplayName', 'Ground truth');
    end

    legend(mapAxes, 'show');
end

function updateDetectionTotal(countAxes, titleHandle, primaryStamp, ...
        primaryCount, primaryName, compareLogs, comparisonStamp, ...
        comparisonCount, comparisonName)
    timeLimits = xlim(countAxes);
    primaryIdx = primaryStamp >= timeLimits(1) & ...
        primaryStamp <= timeLimits(2);
    primaryTotal = sum(double(primaryCount(primaryIdx)), 'omitnan');

    if compareLogs
        comparisonIdx = comparisonStamp >= timeLimits(1) & ...
            comparisonStamp <= timeLimits(2);
        comparisonTotal = sum(double(comparisonCount(comparisonIdx)), ...
            'omitnan');
        titleHandle.String = sprintf( ...
            'Selected window totals - %s: %d, %s: %d', ...
            primaryName, primaryTotal, comparisonName, comparisonTotal);
    else
        titleHandle.String = sprintf( ...
            'Selected window total - %s: %d', primaryName, primaryTotal);
    end
end
