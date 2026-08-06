%% VELOCITY (+ RADAR rho_dot MEASURES) AND ACCELERATION - log1 vs log2
%
% FIGURE 1 - velocity: tt.vx, tt2.vx (state estimates, first two logs) + GT
%            v_x, PLUS radar rho_dot measurements converted to absolute v_x
%            (same logic as "latency_delay": rho_dot is the RELATIVE
%            range-rate, so the ego motion projected on the LOS is added
%            back, then rotated by the aspect angle - assumes no-slip):
%                beta   = atan2(y_rel, x_rel)
%                aspect = yaw_rel - beta
%                vx     = (rho_dot + vx_ego*cos(beta)) / cos(aspect)
%            Each measurement is drawn TWICE: a circle at sens_stamp
%            (sensor acquisition instant) and a cross at stamp (instant the
%            measurement arrives at the filter, i.e. delayed) - the
%            horizontal shift circle->cross IS the latency. Same rotated
%            value, just two different x-abscissas.
%
% FIGURE 2 - acceleration: tt.ax, tt2.ax (state estimates, first two logs)
%            vs GT a_x. No radar measurements here (not requested).
%
% IMPORTANT: the state estimates (v_x/a_x) come ONLY from the first two
% logs (tt, tt2). The ego state used to compensate the radar measurement
% comes from the THIRD log (log_3), which is assumed to have the
% "estimation" field that log/log_2 may lack. The raw radar cluster
% measurements (rad_clust) are assumed shared across log/log_2/log_3
% (same underlying sensor data, only the filter config differs between
% runs) - taken from the workspace variable rad_clust if present,
% otherwise recomputed from log_3 via load_perception.
%
% Requires in workspace: tt, tt2, gt, col, opp_idx, log_3

%% ---------- knobs ----------
cos_min  = 0.15;   % |cos(aspect)| minimum: below this, the measurement is discarded
rho_sign = +1;     % flip to -1 if measurements look "mirrored" during overtakes
mk_o     = 4;      % marker size, circle (sens_stamp)
mk_x     = 5;      % marker size, cross (filter stamp)

%% ---------- ego velocity (to reconstruct the ABSOLUTE vx), from log_3 ----------
assert(exist('log_3', 'var') == 1, ...
    'log_3 not found in workspace: needed for log_3.estimation (ego state).');
assert(isfield(log_3, 'estimation') && isfield(log_3.estimation, 'stamp__tot') && isfield(log_3.estimation, 'vx'), ...
    'log_3.estimation.stamp__tot / log_3.estimation.vx not found.');

ego.stamp = log_3.estimation.stamp__tot(:);
ego.vx    = log_3.estimation.vx(:);

%% ---------- radar source (raw clusters, assumed shared across logs) ----------
if exist('rad_clust', 'var')
    s = rad_clust;
    fprintf('DEBUG: using rad_clust already in workspace.\n');
else
    fprintf('DEBUG: rad_clust not found, recomputing from log_3 via load_perception.\n');
    [~, s, ~, ~] = load_perception(log_3);
end

%% ---------- measurements: rho_dot -> vx ----------
rd   = s.rho_dot;  rd(rd==0) = nan;
xr   = s.x_rel;    xr(xr==0) = nan;
yr   = s.y_rel;    yr(yr==0) = nan;
yawr = s.yaw_rel;
if max(abs(yawr(:)), [], 'omitnan') > 2*pi   % autodetect deg vs rad
    yawr = deg2rad(yawr);
end

beta   = atan2(yr, xr);
aspect = yawr - beta;
c      = cos(aspect);
c(abs(c) < cos_min) = nan;

% ego projected on the LOS, interpolated at the ACQUISITION instant (sens_stamp)
vego_i   = interp1(ego.stamp, ego.vx, s.sens_stamp(:), 'linear', 'extrap');
vego_los = vego_i .* cos(beta);

vx_meas = (rho_sign*rd + vego_los) ./ c;

ncol   = size(vx_meas, 2);
t_sens = repmat(s.sens_stamp(:), 1, ncol);
t_arr  = repmat(s.stamp(:),      1, ncol);
good   = isfinite(vx_meas) & isfinite(t_sens) & isfinite(t_arr);
vv = vx_meas(good);
ts = t_sens(good);   % circle abscissa (acquisition)
ta = t_arr(good);    % cross abscissa (filter arrival)

fprintf('DEBUG: radar measurements valid = %d\n', numel(vv));

%% ---------- GT (opponent column opp_idx) ----------
gt_vx = gt.vx; gt_vx(gt_vx==0) = nan;
oi_g  = min(opp_idx, size(gt_vx,2));
vx_gt = gt_vx(:,oi_g);

gt_ax = gt.ax; gt_ax(gt_ax==0) = nan;
ax_gt = gt_ax(:,oi_g);

%% ---------- QFF feedforward flag from log (log1) ----------
flag_qff1 = [];
if isfield(log, 'perception__opponents') && isfield(log.perception__opponents, 'opponents__flag_qff_active')
    oi1_flag = min(opp_idx, size(log.perception__opponents.opponents__flag_qff_active, 2));
    flag_qff1 = logical(log.perception__opponents.opponents__flag_qff_active(:,oi1_flag));
    fprintf('DEBUG: log flag_qff_active -> %d samples active out of %d (%.1f%%)\n', ...
        nnz(flag_qff1), numel(flag_qff1), 100*nnz(flag_qff1)/numel(flag_qff1));
else
    warning('opponents__flag_qff_active not found in log.perception__opponents.');
end

%% ===================================================================
%% FIGURE: subplot 1 = velocity (+ radar measurements), subplot 2 = acceleration
%% ===================================================================
figure('Name', 'Velocity + acceleration: log1 vs log2 vs GT', 'NumberTitle', 'off', 'Position', [80 80 1400 900]);
tl = tiledlayout(2,1, 'TileSpacing', 'compact', 'Padding', 'compact');

oi1 = min(opp_idx, size(tt.vx,2));
oi2 = min(opp_idx, size(tt2.vx,2));

% ----- SUBPLOT 1: velocity + radar measurements -----
ax_v = nexttile(tl); hold(ax_v, 'on'); grid(ax_v, 'on'); box(ax_v, 'on');
plot(tt.stamp,  tt.vx(:,oi1),  '-', 'Color', col.tt,  'LineWidth', 1.4, 'DisplayName', tt.name);
plot(tt2.stamp, tt2.vx(:,oi2), '-', 'Color', col.tt2, 'LineWidth', 1.4, 'DisplayName', tt2.name);
plot(gt.stamp, vx_gt, '-', 'Color', col.ref, 'LineWidth', 1.8, 'DisplayName', 'GT');
plot(ts, vv, 'o', 'MarkerEdgeColor', col.radar, 'MarkerSize', mk_o, 'LineWidth', 0.5, ...
    'LineStyle', 'none', 'DisplayName', 'radar (sensor stamp)');
plot(ta, vv, 'x', 'Color', col.radar, 'MarkerSize', mk_x, 'LineWidth', 0.8, ...
    'LineStyle', 'none', 'DisplayName', 'radar (filter stamp)');

xlabel('time [s]', 'Interpreter', 'tex', 'FontSize', 8);
ylabel('v_x [m/s]', 'Interpreter', 'tex');
title('Velocity: log1 vs log2 vs GT, with radar measurements (acquisition vs filter arrival)', 'Interpreter', 'tex');
if ~isempty(flag_qff1)
    shade_active_region(ax_v, tt.stamp, flag_qff1, [0.3 0.3 0.3], 0.15);
    patch(ax_v, nan(1,4), nan(1,4), [0.3 0.3 0.3], 'FaceAlpha', 0.25, 'EdgeColor', 'none', ...
        'DisplayName', 'QFF active (log1)');
end
legend('show', 'Location', 'southoutside', 'Orientation', 'horizontal', 'Box', 'off', 'FontSize', 10, 'Interpreter', 'tex');

% ----- SUBPLOT 2: acceleration -----
ax_a = nexttile(tl); hold(ax_a, 'on'); grid(ax_a, 'on'); box(ax_a, 'on');
plot(tt.stamp,  tt.ax(:,oi1),  '-', 'Color', col.tt,  'LineWidth', 1.4, 'DisplayName', tt.name);
plot(tt2.stamp, tt2.ax(:,oi2), '-', 'Color', col.tt2, 'LineWidth', 1.4, 'DisplayName', tt2.name);
plot(gt.stamp, ax_gt, '-', 'Color', col.ref, 'LineWidth', 1.8, 'DisplayName', 'GT');

xlabel('time [s]', 'Interpreter', 'tex', 'FontSize', 8);
ylabel('a_x [m/s^2]', 'Interpreter', 'tex');
title('Acceleration: log1 vs log2 vs GT', 'Interpreter', 'tex');
if ~isempty(flag_qff1)
    shade_active_region(ax_a, tt.stamp, flag_qff1, [0.3 0.3 0.3], 0.15);
end
legend('show', 'Location', 'southoutside', 'Orientation', 'horizontal', 'Box', 'off', 'FontSize', 10, 'Interpreter', 'tex');

linkaxes([ax_v, ax_a], 'x');

%% ===================== local functions =====================
function shade_active_region(ax, t, mask, color, alpha)
% SHADE_ACTIVE_REGION  Draws semi-transparent patches on "ax" over the
% time intervals where "mask" (logical vector, same length as t) is true.
    t = t(:); mask = mask(:);
    if ~any(mask)
        return;
    end
    d = diff([false; mask; false]);   % length(t)+1
    rise_idx = find(d(1:end-1) == 1); % start-of-active-region indices
    fall_idx = find(d == -1) - 1;     % end-of-active-region indices

    yl = ylim(ax);
    for i = 1:numel(rise_idx)
        t_start = t(rise_idx(i));
        t_end   = t(min(fall_idx(i), numel(t)));
        patch(ax, [t_start t_end t_end t_start], [yl(1) yl(1) yl(2) yl(2)], color, ...
            'FaceAlpha', alpha, 'EdgeColor', 'none', 'HandleVisibility', 'off');
    end
end