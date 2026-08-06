%% Plot curve segments on trajectory map
% Highlights trajectory indices where lambda > 1 (curve zones + buffer)
% Requires trajDatabase loaded in workspace

if ~exist('trajDatabase','var')
    error('trajDatabase not found in workspace. Load the database first.');
end

% Same parameters as ComputeLambda in kalman_filter.cpp
CURVE_BUFFER = 50;
TRAJ_LEN     = 5901;
curve_segments = [300, 790; 2300, 2900; 4800, 5030; 5300, 5500];

% Reference trajectory (OPT = index 1 in MATLAB)
traj_ref = trajDatabase(1);
X = traj_ref.X;
Y = traj_ref.Y;

% Build activation masks
mask_curve  = false(1, TRAJ_LEN);
mask_buffer = false(1, TRAJ_LEN);

for s = 1:size(curve_segments, 1)
    seg_start = curve_segments(s, 1);
    seg_end   = curve_segments(s, 2);
    buf_start = max(1,        seg_start - CURVE_BUFFER);
    buf_end   = min(TRAJ_LEN, seg_end   + CURVE_BUFFER);
    mask_buffer(buf_start : seg_start-1) = true;
    mask_curve (seg_start : seg_end)     = true;
    mask_buffer(seg_end+1 : buf_end)     = true;
end

figure('Name', 'Curve Segments - Lambda Activation', 'NumberTitle', 'off');
hold on; grid on; axis equal;
xlabel('x [m]', 'Interpreter', 'none');
ylabel('y [m]', 'Interpreter', 'none');
title('Lambda Activation Zones - Feed Forward Q', 'Interpreter', 'none');

% Track boundaries
id_left  = numel(trajDatabase) - 2;
id_right = numel(trajDatabase) - 1;
plot(trajDatabase(id_left).X,  trajDatabase(id_left).Y,  'k', 'LineWidth', 1.2, 'HandleVisibility', 'off');
plot(trajDatabase(id_right).X, trajDatabase(id_right).Y, 'k', 'LineWidth', 1.2, 'HandleVisibility', 'off');

% Reference trajectory
plot(X, Y, 'Color', [0.75 0.75 0.75], 'LineWidth', 1.5, 'DisplayName', 'Trajectory');

% Transition buffer
scatter(X(mask_buffer), Y(mask_buffer), 18, ...
    'filled', 'MarkerFaceColor', [1.0 0.65 0.0], ...
    'DisplayName', 'Transition buffer');

% Full curve zone
scatter(X(mask_curve), Y(mask_curve), 25, ...
    'filled', 'MarkerFaceColor', [0.85 0.1 0.1], ...
    'DisplayName', 'Curve zone  (lambda = max)');

% Segment number labels on the map (small circle + number at midpoint)
col_label = [0.5 0 0];
for s = 1:size(curve_segments, 1)
    seg_start = curve_segments(s, 1);
    seg_end   = curve_segments(s, 2);
    mid_idx   = round((seg_start + seg_end) / 2);
    % small white circle as background for readability
    scatter(X(mid_idx), Y(mid_idx), 120, 'o', ...
        'MarkerFaceColor', 'w', 'MarkerEdgeColor', col_label, ...
        'LineWidth', 1.5, 'HandleVisibility', 'off');
    text(X(mid_idx), Y(mid_idx), num2str(s), ...
        'FontSize', 9, 'FontWeight', 'bold', 'Color', col_label, ...
        'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', ...
        'Interpreter', 'none');
end

% Legend — clean, no interpreter issues
lgd = legend('show', 'Interpreter', 'none', 'Location', 'northwest');
lgd.FontSize = 10;
lgd.Box = 'on';

% Segment index table as annotation (bottom-left)
seg_strings = cell(size(curve_segments,1) + 1, 1);
seg_strings{1} = 'Segment    idx start    idx end';
for s = 1:size(curve_segments, 1)
    seg_strings{s+1} = sprintf('   %d          %4d         %4d', ...
        s, curve_segments(s,1), curve_segments(s,2));
end

annotation('textbox', ...
    [0.13, 0.02, 0.30, 0.20], ...
    'String',            seg_strings, ...
    'FontSize',          9, ...
    'FontName',          'Courier New', ...
    'Color',             [0.15 0.15 0.15], ...
    'BackgroundColor',   [0.97 0.97 0.97], ...
    'EdgeColor',         [0.6 0.6 0.6], ...
    'Interpreter',       'none', ...
    'FitBoxToText',      'on', ...
    'VerticalAlignment', 'bottom');