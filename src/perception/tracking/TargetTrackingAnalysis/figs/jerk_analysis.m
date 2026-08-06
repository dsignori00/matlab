%% JERK ANALYSIS (GT + filter) + RADAR
% FIG 1: acceleration + jerk (GT vs filter), hysteresis bands
% FIG 2: acceleration (GT vs filter), GT consistency, sensor innovations
% FIG 3: jerk from radar measurements (velocity, jerk)
% FIG 4: acceleration from radar measurements
%
% Requires: tt, gt, col, use_ref, use_sim_ref, opp_idx (opt.), rad_clust, log

%% Parameters
sg_order    = 2;
sg_window_s = 0.3;      % SG window for tt [s]
gt_sg_window_s = 0.2;   % SG window for GT [s] (independent, different sample rate)
sg_causal   = true;

jerk_thr_on  = 10;      % [m/s^3] Q boost ON
jerk_thr_off = 5;      % [m/s^3] Q boost OFF (hysteresis)

radar_cos_min  = 0.15;
gap_tol_factor = 2;
outlier_thr_vx = 3;     % [m/s] radar outlier rejection vs GT
radar_sg_window_s = 0.6;

plot_col = 1;
if exist('opp_idx', 'var'); plot_col = opp_idx; end
has_gt = (exist('use_ref','var') && use_ref) || (exist('use_sim_ref','var') && use_sim_ref);

%% Dedup timestamps (SG filter assumes strictly increasing time)
[tt_stamp_u, tt_keep] = unique(tt.stamp, 'stable');
tt_ax_u = tt.ax(tt_keep, :);
tt_vx_u = tt.vx(tt_keep, plot_col);

if has_gt
    [gt_stamp_u, gt_keep] = unique(gt.stamp, 'stable');
    gt_ax_u = gt.ax(gt_keep);
    gt_vx_u = gt.vx(gt_keep);
end

if has_gt
    fprintf('tt.stamp: %d samples, gt.stamp: %d samples\n', numel(tt.stamp), numel(gt.stamp));
else
    fprintf('tt.stamp: %d samples (no GT)\n', numel(tt.stamp));
end

dt_tt = median(diff(tt_stamp_u(diff(tt_stamp_u) > 0)), 'omitnan');
sg_window = odd_window(sg_window_s, dt_tt, sg_order);
fprintf('dt_tt = %.4fs (%.1f Hz) -> sg_window = %d samples (~%.3fs)\n', dt_tt, 1/dt_tt, sg_window, (sg_window-1)*dt_tt);

%% ===================================================================
%% FIG 1: acceleration + jerk
%% ===================================================================
[ax_f, jerk_sg] = sg_jerk_matrix(tt_stamp_u, tt_ax_u, sg_order, sg_window, sg_causal);

% Use the filter's own native jerk output if available, otherwise derive
% it from tt.ax via SG.
has_native_jerk = isfield(log,'perception__opponents') && isfield(log.perception__opponents,'opponents__jerk');
if has_native_jerk
    jerk_t = tt.stamp;
    jerk_mat = mask_sentinel(log.perception__opponents.opponents__jerk);
    jerk_label = 'filter jerk (native)';
    fprintf('Using native opponents__jerk field.\n');
else
    jerk_t = tt_stamp_u;
    jerk_mat = jerk_sg;
    jerk_label = 'filter jerk (SG)';
    fprintf('opponents__jerk not found, deriving jerk from tt.ax via SG.\n');
end

if has_gt
    dt_gt = median(diff(gt_stamp_u(diff(gt_stamp_u) > 0)), 'omitnan');
    gt_sg_window = odd_window(gt_sg_window_s, dt_gt, sg_order);
    fprintf('dt_gt = %.4fs (%.1f Hz) -> gt_sg_window = %d samples (~%.3fs)\n', dt_gt, 1/dt_gt, gt_sg_window, (gt_sg_window-1)*dt_gt);
    [~, gt_jerk] = sg_jerk_matrix(gt_stamp_u, gt_ax_u(:), sg_order, gt_sg_window, sg_causal);
end

boost = jerk_hysteresis(jerk_mat, jerk_thr_on, jerk_thr_off); %#ok<NASGU>

figure('Name', 'Acceleration + jerk (filter vs GT)', 'Position', [80 80 1400 900]);
tl1 = tiledlayout(2,1, 'TileSpacing', 'compact', 'Padding', 'compact');

ax1 = nexttile(tl1); hold on; grid on; box on;
if has_gt; plot(gt.stamp, gt.ax, 'k-', 'LineWidth', 1.5, 'DisplayName', 'GT a_x'); end
plot(tt.stamp, tt.ax(:,plot_col), '-', 'Color', [0.5 0.5 0.5], 'DisplayName', 'filter a_x (raw)');
plot(tt_stamp_u, ax_f(:,plot_col), '-', 'Color', col.tt, 'LineWidth', 1.5, 'DisplayName', 'filter a_x (SG)');
ylabel('a_x [m/s^2]', 'Interpreter', 'tex');
title('Acceleration: GT vs filter', 'Interpreter', 'tex');
mklegend();

ax2 = nexttile(tl1); hold on; grid on; box on;
if has_gt; plot(gt_stamp_u, gt_jerk, 'k-', 'LineWidth', 1.5, 'DisplayName', 'GT jerk'); end
plot(jerk_t, jerk_mat(:,plot_col), '-', 'Color', col.tt, 'DisplayName', jerk_label);
yline(jerk_thr_on, '--r', 'DisplayName', 'thr ON'); yline(-jerk_thr_on, '--r', 'HandleVisibility', 'off');
yline(jerk_thr_off, ':b', 'DisplayName', 'thr OFF'); yline(-jerk_thr_off, ':b', 'HandleVisibility', 'off');
ylabel('jerk [m/s^3]', 'Interpreter', 'tex');
xlabel('time [s]', 'Interpreter', 'tex', 'FontSize', 8);
title('Jerk: GT vs filter', 'Interpreter', 'tex');
mklegend();

%% ===================================================================
%% FIG 2: sensor innovations
%% ===================================================================
sensor_list = {'lid_clustering', [0.20 0.65 0.30]; 'lid_pp', [0.90 0.55 0.10]; ...
               'rad_clust', [0.75 0.10 0.10]; 'rho_dot', [0.20 0.40 0.85]};
raw_field = containers.Map({'lid_clustering','lid_pp','rad_clust','rho_dot'}, ...
    {'opponents__innovation_lid_clust','opponents__innovation_lid_pp', ...
     'opponents__innovation_rad_clust','opponents__innovation_rho_dot'});

innov_data = {}; innov_stamp = {}; innov_names = {}; innov_cols = {};
for si = 1:size(sensor_list,1)
    key = sensor_list{si,1};
    raw = [];
    if isfield(tt,'innov') && isfield(tt.innov, key)
        raw = tt.innov.(key);
    elseif isfield(log,'perception__opponents') && isfield(log.perception__opponents, raw_field(key))
        raw = log.perception__opponents.(raw_field(key));
    else
        continue;
    end
    if ndims(raw) == 3
        d = double(squeeze(raw(:,plot_col,:)));
        col_data = sqrt(sum(d.^2,2));
    else
        col_data = double(raw(:,plot_col));
    end
    col_data = mask_sentinel(col_data);
    col_data(col_data==0) = nan;
    stale = [false; diff(col_data) == 0];  % sample-and-hold: value not updated this frame
    fresh = ~stale & isfinite(col_data);   % only genuine updates

    innov_data{end+1}  = col_data(fresh);   %#ok<SAGROW>
    innov_stamp{end+1} = tt.stamp(fresh);   %#ok<SAGROW>
    innov_names{end+1} = key;               %#ok<SAGROW>
    innov_cols{end+1}  = sensor_list{si,2}; %#ok<SAGROW>
end

figure('Name', 'Acceleration + innovations', 'Position', [80 60 1400 900]);
tl2 = tiledlayout(2,1, 'TileSpacing', 'compact', 'Padding', 'compact');

ax3 = nexttile(tl2); hold on; grid on; box on;
if has_gt; plot(gt.stamp, gt.ax, 'k-', 'LineWidth', 1.5, 'DisplayName', 'GT a_x'); end
plot(tt_stamp_u, tt_ax_u(:,plot_col), '-', 'Color', [0.2 0.4 0.8], 'DisplayName', 'filter a_x');
ylabel('a_x [m/s^2]', 'Interpreter', 'tex');
title('Acceleration: GT vs filter', 'Interpreter', 'tex');
mklegend();

ax5 = nexttile(tl2); hold on; grid on; box on;
innov_ma_win = 5;       % moving average window [samples of the FRESH sequence] -> more responsive
gap_tol_innov = 5;      % break the line if the gap between updates exceeds gap_tol_innov x the typical update interval
for si = 1:numel(innov_data)
    t_fresh = innov_stamp{si}; v_fresh = innov_data{si};
    plot(t_fresh, v_fresh, '.', 'MarkerSize', 4, 'Color', [innov_cols{si} 0.35], 'HandleVisibility', 'off');
    ma = movmean(v_fresh, innov_ma_win);
    [t_plot, ma_plot] = break_gaps(t_fresh, ma, gap_tol_innov);
    plot(t_plot, ma_plot, '-', 'LineWidth', 1.5, 'Color', innov_cols{si}, 'DisplayName', innov_names{si});
end
yline(0, 'k:', 'HandleVisibility', 'off');
xlabel('time [s]', 'Interpreter', 'tex', 'FontSize', 8);
ylabel('innovation', 'Interpreter', 'tex');
title('Per-sensor innovation', 'Interpreter', 'tex');
mklegend();

%% ===================================================================
%% FIG 3 & 4: radar-derived velocity / acceleration / jerk
%% ===================================================================
if exist('rad_clust','var') && isfield(log,'estimation') && has_gt

    t_meas = rad_clust.stamp(:);
    rho    = mask_sentinel(rad_clust.rho_dot(:,1));
    xr     = mask_sentinel(rad_clust.x_rel(:,1));
    yr     = mask_sentinel(rad_clust.y_rel(:,1));
    yawr   = mask_sentinel(rad_clust.yaw_rel(:,1));
    good   = isfinite(t_meas);
    t_meas = t_meas(good); rho = rho(good); xr = xr(good); yr = yr(good); yawr = yawr(good);
    if max(abs(yawr),[],'omitnan') > 2*pi; yawr = deg2rad(yawr); end

    vx_ego_i = interp1(log.estimation.stamp__tot, log.estimation.vx, t_meas, 'linear', 'extrap');
    beta   = atan2(yr, xr);
    aspect = yawr - beta;
    vx_r   = (rho + vx_ego_i.*cos(beta)) ./ cos(aspect);
    vx_r(abs(cos(aspect)) < radar_cos_min) = nan;

    [t_meas, si] = sort(t_meas); vx_r = vx_r(si);
    [t_meas, ui] = unique(t_meas, 'stable'); vx_r = vx_r(ui);

    gt_vx_i = interp1(gt.stamp, gt.vx, t_meas, 'linear', nan);
    vx_r(abs(vx_r - gt_vx_i) > outlier_thr_vx) = nan;

    valid = isfinite(t_meas) & isfinite(vx_r);
    tm = t_meas(valid); vm = vx_r(valid);

    dt_r = median(diff(tm(diff(tm)>0)), 'omitnan');
    radar_window = odd_window(radar_sg_window_s, dt_r, sg_order);
    fprintf('dt_radar = %.4fs (%.1f Hz) -> radar_window = %d samples (~%.3fs)\n', dt_r, 1/dt_r, radar_window, (radar_window-1)*dt_r);

    if numel(tm) >= radar_window
        [~, ax_r, jerk_r]     = sg_multi_deriv(tm, vm, sg_order, radar_window, true,  gap_tol_factor);
        [~, ax_r_off, jerk_r_off] = sg_multi_deriv(tm, vm, sg_order, radar_window, false, gap_tol_factor);

        figure('Name', 'Radar: velocity + jerk', 'Position', [80 60 1400 900]);
        tl3 = tiledlayout(2,1, 'TileSpacing', 'compact', 'Padding', 'compact');

        ax6 = nexttile(tl3); hold on; grid on; box on;
        plot(gt.stamp, gt.vx, 'k-', 'LineWidth', 1.5, 'DisplayName', 'GT v_x');
        plot(tm, vm, 'r.', 'MarkerSize', 6, 'DisplayName', 'radar v_x');
        ylabel('v_x [m/s]', 'Interpreter', 'tex');
        title('Velocity: GT vs radar', 'Interpreter', 'tex');
        mklegend();

        ax7 = nexttile(tl3); hold on; grid on; box on;
        plot(gt_stamp_u, gt_jerk, 'k-', 'LineWidth', 1.5, 'DisplayName', 'GT jerk');
        plot(jerk_t, jerk_mat(:,plot_col), '-', 'Color', [0.5 0.5 0.5], 'DisplayName', jerk_label);
        plot(tm, jerk_r, 'r-', 'LineWidth', 1.3, 'DisplayName', 'radar jerk (causal)');
        plot(tm, jerk_r_off, '--', 'Color', [0.9 0.3 0.1], 'DisplayName', 'radar jerk (offline)');
        yline(0, 'k:', 'HandleVisibility', 'off');
        xlabel('time [s]', 'Interpreter', 'tex', 'FontSize', 8);
        ylabel('jerk [m/s^3]', 'Interpreter', 'tex');
        title('Jerk: GT vs filter vs radar', 'Interpreter', 'tex');
        mklegend();

        figure('Name', 'Radar: acceleration', 'Position', [80 60 1400 700]);
        ax8 = gca; hold(ax8,'on'); grid(ax8,'on'); box(ax8,'on');
        plot(gt.stamp, gt.ax, 'k-', 'LineWidth', 1.5, 'DisplayName', 'GT a_x');
        plot(tt_stamp_u, ax_f(:,plot_col), '-', 'Color', [0.5 0.5 0.5], 'DisplayName', 'filter a_x');
        plot(tm, ax_r, 'r-', 'LineWidth', 1.3, 'DisplayName', 'radar a_x (causal)');
        plot(tm, ax_r_off, '--', 'Color', [0.9 0.3 0.1], 'DisplayName', 'radar a_x (offline)');
        xlabel('time [s]', 'Interpreter', 'tex', 'FontSize', 8);
        ylabel('a_x [m/s^2]', 'Interpreter', 'tex');
        title('Acceleration: GT vs filter vs radar', 'Interpreter', 'tex');
        mklegend();
    end
end

%% Register axes with the main script's shared axes/f linking mechanism
% (no internal linkaxes here - linking happens centrally in the main script)
if exist('axes', 'var') && exist('f', 'var')
    reg_axes = [ax1, ax2, ax3, ax5];
    if exist('ax6', 'var'); reg_axes = [reg_axes, ax6, ax7]; end
    if exist('ax8', 'var'); reg_axes = [reg_axes, ax8]; end
    for k = 1:numel(reg_axes)
        axes(f) = reg_axes(k); f = f+1; %#ok<AGROW>
    end
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
    v(v <= -9999) = nan;
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

function [h0, h1] = sg_causal_coeffs(order, window)
% Causal SG filter coefficients: least-squares polynomial fit over the
% window, evaluated at the last (most recent) sample.
    n = (0:window-1)'; A = n.^(0:order); Ainv = (A'*A)\A';
    t0 = window-1;
    h0 = t0.^(0:order) * Ainv;
    d1 = zeros(1,order+1);
    for k = 1:order; d1(k+1) = k*t0^(k-1); end
    h1 = d1 * Ainv;
end

function [h0, h1, h2] = sg_causal_coeffs2(order, window)
    [h0, h1] = sg_causal_coeffs(order, window);
    n = (0:window-1)'; A = n.^(0:order); Ainv = (A'*A)\A';
    t0 = window-1;
    d2 = zeros(1,order+1);
    for k = 2:order; d2(k+1) = k*(k-1)*t0^(k-2); end
    h2 = d2 * Ainv;
end

function boost = jerk_hysteresis(jerk, thr_on, thr_off)
% Schmitt trigger on |jerk| to drive Q boost without chattering.
    boost = false(size(jerk));
    for k = 1:size(jerk,2)
        state = false;
        for i = 1:size(jerk,1)
            j = abs(jerk(i,k));
            if ~isnan(j)
                if ~state && j > thr_on; state = true;
                elseif state && j < thr_off; state = false; end
            end
            boost(i,k) = state;
        end
    end
end

function [smoothed, d1, d2] = sg_multi_deriv(t, x, order, window, causal, gap_tol_factor)
% Value + 1st + 2nd derivative via SG, for irregularly-sampled x(t).
% Gaps in the window (real time span > gap_tol_factor * expected) -> NaN.
    t = t(:); x = x(:); N = numel(x);
    smoothed = nan(N,1); d1 = nan(N,1); d2 = nan(N,1);
    if N < window; return; end

    dt = median(diff(t), 'omitnan');
    span = t(window:N) - t(1:N-window+1);
    gap = span > gap_tol_factor * (window-1)*dt;

    if causal
        [h0, h1, h2] = sg_causal_coeffs2(order, window);
        smoothed = filter(fliplr(h0), 1, x);
        d1 = filter(fliplr(h1), 1, x) / dt;
        d2 = filter(fliplr(h2), 1, x) / dt^2;
        smoothed(1:window-1) = nan; d1(1:window-1) = nan; d2(1:window-1) = nan;
        smoothed(window:N) = fillmask(smoothed(window:N), gap);
        d1(window:N) = fillmask(d1(window:N), gap);
        d2(window:N) = fillmask(d2(window:N), gap);
    else
        [~, g] = sgolay(order, window);
        half = (window-1)/2;
        smoothed = sgolayfilt(x, order, window);
        d1(half+1:N-half) = conv(x, flipud(g(:,2)), 'valid') / dt;
        if order >= 2
            d2(half+1:N-half) = 2*conv(x, flipud(g(:,3)), 'valid') / dt^2;
        end
        smoothed(half+1:N-half) = fillmask(smoothed(half+1:N-half), gap);
        d1(half+1:N-half) = fillmask(d1(half+1:N-half), gap);
        d2(half+1:N-half) = fillmask(d2(half+1:N-half), gap);
    end
end

function y = fillmask(y, mask)
    y(mask) = nan;
end

function [t2, v2] = break_gaps(t, v, gap_tol_factor)
% Inserts a NaN between consecutive samples whenever their time gap
% exceeds gap_tol_factor x the typical (median) gap - so plot() breaks
% the line there instead of connecting across a real dropout.
    t = t(:); v = v(:);
    dt = diff(t);
    typical = median(dt(dt>0), 'omitnan');
    gap_idx = find(dt > gap_tol_factor * typical);
    t2 = t; v2 = v;
    for i = numel(gap_idx):-1:1
        idx = gap_idx(i);
        t_mid = (t2(idx) + t2(idx+1)) / 2;
        t2 = [t2(1:idx); t_mid; t2(idx+1:end)];
        v2 = [v2(1:idx); nan; v2(idx+1:end)];
    end
end