%% CAMERA - Range & Dispersion
% Figure 1: range over time (gt line vs camera measurements scatter), standalone
% Figure 2: 1) range error (measurement - gt) vs range, scatter -> shows
%              dispersion increasing with range
%           2) (optional) std of the error binned by range

%% Find the camera sensor inside the "sensors" cell array
cam_idx = [];
for i = 1:numel(sensors)
    if contains(lower(sensors{i}.name), 'cam')
        cam_idx = i;
        break;
    end
end
if isempty(cam_idx)
    error('Camera sensor not found in "sensors": check the .name field.');
end
cam = sensors{cam_idx}.s;
cam.range = sqrt(cam.x_rel.^2 + cam.y_rel.^2);

%% Ground truth range
if ~(use_ref || use_sim_ref)
    error('Ground truth is required (use_ref or use_sim_ref) to compare camera measurements.');
end
if use_sim_ref
    gt.rho = sqrt(gt.x_rel.^2 + gt.y_rel.^2);
end

%% Normalize sens_stamp and range into two column vectors of the same length
% Typical case: sens_stamp is [N x 1] (one timestamp per scan) while range
% is [N x max_det] (multiple detections per scan). We expand the stamp to
% match, then flatten everything and drop NaNs (invalid detections).
stamp_mat = cam.sens_stamp;
range_mat = cam.range;

if ~isequal(size(stamp_mat), size(range_mat))
    if isvector(stamp_mat) && size(range_mat,1) == numel(stamp_mat)
        stamp_mat = repmat(stamp_mat(:), 1, size(range_mat,2));
    elseif isvector(stamp_mat) && size(range_mat,2) == numel(stamp_mat)
        stamp_mat = repmat(stamp_mat(:)', size(range_mat,1), 1);
    else
        error('Cannot align sizes of sens_stamp (%s) and range (%s).', ...
            mat2str(size(stamp_mat)), mat2str(size(range_mat)));
    end
end

cam_stamp = stamp_mat(:);
cam_range = range_mat(:);
valid = ~isnan(cam_range) & ~isnan(cam_stamp);
cam_stamp = cam_stamp(valid);
cam_range = cam_range(valid);

%% --- Figure 1: range over time, gt vs camera scatter (dedicated figure) ---
figure('name', 'Filter - Camera Range (gt vs measurements)', 'NumberTitle', 'off');
hold on;
plot(gt.stamp, gt.rho, 'Color', col.ref, 'LineWidth', 1.5, 'DisplayName', 'gt');
scatter(cam_stamp, cam_range, 70, sensors{cam_idx}.col, 'filled', ...
    'MarkerFaceAlpha', 0.8, 'DisplayName', sensors{cam_idx}.name);
grid on; ylabel('range [m]'); xlabel('time [s]'); ylim([0 200]); legend show;
title('Range over time: gt vs camera measurements');

%% --- Figure 2: error dispersion analysis ---
figure('name', 'Filter - Camera Range Dispersion', 'NumberTitle', 'off');
tiledlayout(2,1,'Padding','compact');

% Plot 1: range error vs range (dispersion scatter)
nexttile; hold on;
% interpolate gt on camera timestamps to compute the error
gt_range_interp = interp1(gt.stamp, gt.rho, cam_stamp, 'linear', 'extrap');
range_error = cam_range - gt_range_interp;

scatter(cam_range, range_error, 70, sensors{cam_idx}.col, 'filled', ...
    'MarkerFaceAlpha', 0.6, 'DisplayName', 'camera error');
yline(0, '--k', 'HandleVisibility', 'off');
grid on; xlabel('range [m]'); ylabel('range error [m]'); legend show;
title('Camera error dispersion as a function of range');

% Plot 2 (optional): std of the error, binned by range
nexttile; hold on;
bin_edges = 0:10:200;                       % 10 m bins, adjust if needed
bin_centers = bin_edges(1:end-1) + 5;
std_err = nan(1, numel(bin_centers));
n_meas  = zeros(1, numel(bin_centers));

for b = 1:numel(bin_centers)
    mask = cam_range >= bin_edges(b) & cam_range < bin_edges(b+1);
    n_meas(b) = sum(mask);
    if n_meas(b) > 1
        std_err(b) = std(range_error(mask));
    end
end

bar(bin_centers, std_err, 'FaceColor', sensors{cam_idx}.col, 'FaceAlpha', 0.6, ...
    'DisplayName', 'camera error std');
grid on; xlabel('range [m]'); ylabel('range error std [m]'); legend show;
title('Standard deviation of camera error per range bin');