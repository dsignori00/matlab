%% Q_FEED_FORWARD_INNOVATION_FLAG
% FIGURE 1 - subplot 1: acceleration (GT vs filter), gray bands = QFF
%                        active, blue bands = jerk flag active
%          - subplot 2: jerk (GT vs filter, SG), hysteresis thresholds
% FIGURE 2: raw vs filtered rho_dot innovation, same flag shading
%
% Requires in workspace: tt2, gt, log_2, opp_idx (opt.)

%% Parameters
sg_order    = 2;
gt_sg_window_s = 0.2;   % SG window for GT [s] (GT has no native jerk field)
sg_causal   = true;

jerk_thr_on  = 15;      % [m/s^3] Q boost ON
jerk_thr_off = 10;      % [m/s^3] Q boost OFF (hysteresis)

plot_col = 1;
if exist('opp_idx', 'var'); plot_col = opp_idx; end

po = log_2.perception__opponents;

%% ===================================================================
%% Flags for this target
%% ===================================================================
flag_qff = [];
if isfield(po, 'opponents__flag_qff_active')
    flag_qff = logical(po.opponents__flag_qff_active(:,plot_col));
end

flag_curve = [];
if isfield(po, 'opponents__flag_curve')
    flag_curve = logical(po.opponents__flag_curve(:,plot_col));
end

flag_jerk = [];
if isfield(po, 'opponents__flag_jerk_active')
    flag_jerk = logical(po.opponents__flag_jerk_active(:,plot_col));
end

%% ===================================================================
%% Raw vs filtered rho_dot innovation
%% ===================================================================
innov_raw = [];
innov_filt = [];
if isfield(po, 'opponents__innovation_rho_dot_meas')
    innov_raw = mask_sentinel(po.opponents__innovation_rho_dot_meas(:,plot_col));
end
if isfield(po, 'opponents__innovation_rho_dot_filtered')
    innov_filt = mask_sentinel(po.opponents__innovation_rho_dot_filtered(:,plot_col));
end

%% ===================================================================
%% Jerk: filter uses its OWN native output (opponents__jerk), GT is
%% derived via SG (no native jerk field available for GT)
%% ===================================================================
jerk_filter = [];
if isfield(po, 'opponents__jerk')
    jerk_filter = mask_sentinel(po.opponents__jerk(:,plot_col));
else
    warning('Q_feed_forward_innovation_flag: opponents__jerk not found.');
end

[gt_stamp_u, gt_keep] = unique(gt.stamp, 'stable');
gt_ax_u = gt.ax(gt_keep);
dt_gt = median(diff(gt_stamp_u(diff(gt_stamp_u) > 0)), 'omitnan');
gt_sg_window = odd_window(gt_sg_window_s, dt_gt, sg_order);
[~, gt_jerk] = sg_jerk_matrix(gt_stamp_u, gt_ax_u(:), sg_order, gt_sg_window, sg_causal);

%% ===================================================================
%% FIGURE 1: acceleration + jerk
%% ===================================================================
figure('Name', 'Acceleration + jerk + QFF/jerk flags', 'Position', [80 80 1400 900]);
tl1 = tiledlayout(2,1, 'TileSpacing', 'compact', 'Padding', 'compact');

ax1 = nexttile(tl1); hold on; grid on; box on;
plot(gt.stamp, gt.ax, 'k-', 'LineWidth', 1.5, 'DisplayName', 'GT a_x');
plot(tt2.stamp, tt2.ax(:,plot_col), '-', 'Color', [0.2 0.4 0.8], 'LineWidth', 1.2, 'DisplayName', 'filter a_x');
ylabel('a_x [m/s^2]', 'Interpreter', 'tex');
title('Acceleration: GT vs filter', 'Interpreter', 'tex');
if ~isempty(flag_qff)
    shade_active_region(ax1, tt2.stamp, flag_qff, [0.3 0.3 0.3], 0.15);
    patch(ax1, nan(1,4), nan(1,4), [0.3 0.3 0.3], 'FaceAlpha', 0.25, 'EdgeColor', 'none', 'DisplayName', 'QFF active');
end
if ~isempty(flag_jerk)
    shade_active_region(ax1, tt2.stamp, flag_jerk, [0.10 0.45 0.85], 0.15);
    patch(ax1, nan(1,4), nan(1,4), [0.10 0.45 0.85], 'FaceAlpha', 0.25, 'EdgeColor', 'none', 'DisplayName', 'jerk active');
end
if ~isempty(flag_curve)
    yl1 = ylim(ax1);
    y_level = yl1(1) + 0.05*(yl1(2)-yl1(1));
    plot(ax1, tt2.stamp(flag_curve), y_level*ones(nnz(flag_curve),1), '.', ...
        'MarkerSize', 6, 'Color', [0.90 0.55 0.10], 'DisplayName', 'curve flag active');
    ylim(ax1, yl1);
end
mklegend();

ax2 = nexttile(tl1); hold on; grid on; box on;
plot(gt_stamp_u, gt_jerk, 'k-', 'LineWidth', 1.5, 'DisplayName', 'GT jerk');
if ~isempty(jerk_filter)
    plot(tt2.stamp, jerk_filter, '-', 'Color', [0.2 0.4 0.8], 'LineWidth', 1.2, 'DisplayName', 'filter jerk (native)');
end
yline(jerk_thr_on, '--r', 'DisplayName', 'thr ON'); yline(-jerk_thr_on, '--r', 'HandleVisibility', 'off');
yline(jerk_thr_off, ':b', 'DisplayName', 'thr OFF'); yline(-jerk_thr_off, ':b', 'HandleVisibility', 'off');
if ~isempty(flag_qff)
    shade_active_region(ax2, tt2.stamp, flag_qff, [0.3 0.3 0.3], 0.15);
end
if ~isempty(flag_jerk)
    shade_active_region(ax2, tt2.stamp, flag_jerk, [0.10 0.45 0.85], 0.15);
end
xlabel('time [s]', 'Interpreter', 'tex', 'FontSize', 8);
ylabel('jerk [m/s^3]', 'Interpreter', 'tex');
title('Jerk: GT vs filter', 'Interpreter', 'tex');
mklegend();

%% ===================================================================
%% FIGURE 2: rho_dot innovation (+ QFF/jerk flag shading)
%% ===================================================================
figure('Name', 'rho_dot innovation + QFF/jerk flags', 'Position', [80 80 1400 700]);
ax3 = gca; hold(ax3, 'on'); grid(ax3, 'on'); box(ax3, 'on');
if ~isempty(innov_raw)
    plot(tt2.stamp, innov_raw, '.', 'MarkerSize', 5, 'Color', [0.85 0.10 0.10], 'DisplayName', 'innovation (raw)');
end
if ~isempty(innov_filt)
    plot(tt2.stamp, innov_filt, '.', 'MarkerSize', 5, 'Color', [0.10 0.45 0.85], 'DisplayName', 'innovation (filtered)');
end
yline(0, 'k:', 'HandleVisibility', 'off');
if ~isempty(flag_qff)
    shade_active_region(ax3, tt2.stamp, flag_qff, [0.3 0.3 0.3], 0.15);
    patch(ax3, nan(1,4), nan(1,4), [0.3 0.3 0.3], 'FaceAlpha', 0.25, 'EdgeColor', 'none', 'DisplayName', 'QFF active');
end
if ~isempty(flag_jerk)
    shade_active_region(ax3, tt2.stamp, flag_jerk, [0.10 0.45 0.85], 0.15);
    patch(ax3, nan(1,4), nan(1,4), [0.10 0.45 0.85], 'FaceAlpha', 0.25, 'EdgeColor', 'none', 'DisplayName', 'jerk active');
end
xlabel('time [s]', 'Interpreter', 'tex', 'FontSize', 8);
ylabel('rho_{dot} innovation', 'Interpreter', 'tex');
title('rho_{dot} innovation: raw vs filtered', 'Interpreter', 'tex');
mklegend();

% linking handled centrally in the main script

%% Register axes with the main script's shared axes/f linking mechanism
if exist('axes', 'var') && exist('f', 'var')
    axes(f) = ax1; f = f+1; %#ok<AGROW>
    axes(f) = ax2; f = f+1; %#ok<AGROW>
    axes(f) = ax3; f = f+1; %#ok<AGROW>
end

%% ===================== local functions =====================
function mklegend()
    legend('show', 'Location', 'southoutside', 'Orientation', 'horizontal', ...
        'Box', 'off', 'FontSize', 10, 'Interpreter', 'tex');
end

function w = odd_window(window_s, dt, order)
    w = max(round(window_s/dt) + 1, order+1);
    if mod(w,2) == 0; w = w+1; end
end

function v = mask_sentinel(v)
    v = double(v);
    v(v == 0) = nan;
    v(v <= -9999) = nan;
end

function [h0, h1] = sg_causal_coeffs(order, window)
    n = (0:window-1)'; A = n.^(0:order); Ainv = (A'*A)\A';
    t0 = window-1;
    h0 = t0.^(0:order) * Ainv;
    d1 = zeros(1,order+1);
    for k = 1:order; d1(k+1) = k*t0^(k-1); end
    h1 = d1 * Ainv;
end

function [ax_filt, jerk] = sg_jerk_matrix(stamp, ax, order, window, causal)
% Value + jerk (1st derivative) via SG, vectorized across columns.
    [N, n_opp] = size(ax);
    ax_filt = nan(N,n_opp); jerk = nan(N,n_opp);
    valid = ~isnan(ax); ax_i = ax; idx = (1:N)';
    for k = 1:n_opp
        v = valid(:,k);
        if nnz(v) < window; continue; end
        ax_i(~v,k) = interp1(idx(v), ax(v,k), idx(~v), 'linear', 'extrap');
    end
    dt = median(diff(stamp(diff(stamp)>0)), 'omitnan');

    if causal
        [h0, h1] = sg_causal_coeffs(order, window);
        ax_filt = filter(fliplr(h0), 1, ax_i, [], 1);
        jerk    = filter(fliplr(h1), 1, ax_i, [], 1) / dt;
        ax_filt(1:window-1,:) = nan; jerk(1:window-1,:) = nan;
    else
        ax_filt = sgolayfilt(ax_i, order, window, [], 1);
        [~, g] = sgolay(order, window);
        half = (window-1)/2;
        for k = 1:n_opp
            if nnz(valid(:,k)) < window; continue; end
            jerk(half+1:N-half,k) = conv(ax_i(:,k), flipud(g(:,2)), 'valid') / dt;
        end
    end
    ax_filt(~valid) = nan; jerk(~valid) = nan;
end

function shade_active_region(ax, t, mask, color, alpha)
% Draws semi-transparent patches on "ax" over the time intervals where
% "mask" (logical vector, same length as t) is true.
    t = t(:); mask = mask(:);
    if ~any(mask)
        return;
    end
    d = diff([false; mask; false]);
    rise_idx = find(d(1:end-1) == 1);
    fall_idx = find(d == -1) - 1;

    yl = ylim(ax);
    for i = 1:numel(rise_idx)
        t_start = t(rise_idx(i));
        t_end   = t(min(fall_idx(i), numel(t)));
        patch(ax, [t_start t_end t_end t_start], [yl(1) yl(1) yl(2) yl(2)], color, ...
            'FaceAlpha', alpha, 'EdgeColor', 'none', 'HandleVisibility', 'off');
    end
end