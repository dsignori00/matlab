%% R_BIAS_CROSS_CORRELATION
% Compares the LOW-FREQUENCY measurement bias across sensors (lidar
% clustering, lidar pointpillars, radar, camera): are they wrong in the
% SAME DIRECTION at the same time? A shared bias would point to a common
% cause (e.g. ego-pose offset, shared extrinsic calibration error)
% instead of an independent drift per sensor.
%
% FIGURE 1: bias b_x(t), b_y(t) per sensor (movmean of the measurement-vs-gt
%           error, window = drift_win_s), overlaid, PLUS the same quantity
%           computed on the filter's own estimate (tt), smoothed with its
%           own configurable window tt_drift_win_s (both default to 5s -
%           change the two variables below to compare other windows).
%           The bias line is blanked (NaN) during long stretches with no
%           actual measurement for that sensor (instead of bridging the
%           gap with a stale average).
%
% FIGURE 2: filter's velocity estimate (tt.rho_dot, computed by the
%           filter in the exact same physical quantity as the radar) vs
%           the radar's raw rho_dot measurement (+ gt reference if
%           available).
%
% uses: sensors, tt, gt, opp_idx, use_ref, use_sim_ref, axes (optional)

if ~exist('axes','var'); axes = []; end

legend_fontsize = 20; % legend font size (both figures) - raise/lower to taste

r_field = {'lidar','pp','radar','camera'};

% reference tracked opponent (same convention used elsewhere in the project)
opp_col = 1;
if exist('opp_idx','var'); opp_col = opp_idx; end

has_gt = (exist('use_ref','var') && use_ref) || (exist('use_sim_ref','var') && use_sim_ref);
if ~has_gt
    warning('r_bias_cross_correlation: ground truth required. Skipping figure 1 (bias over time).');
else

disp_map = containers.Map( ...
    {'lidar','pp','radar','camera'}, ...
    {'lidar clustering','lidar point pillars','radar','camera'});
dname = @(k) char(disp_map(k));

% --- parameters ---
compare_sensors = {'lidar','pp','radar','camera'};
skip_start_s = 0;          % discard the first N seconds (initial transient)
err_outlier  = 3;          % [m] discard |error| above this threshold (x/y)
drift_win_s  = 10;         % low-pass window of the sensors' drift b(t) [s]
tt_drift_win_s = 10;       % low-pass window of the filter estimate's bias [s] - set independently if you want it smoother/rawer than the sensors
gap_factor   = 5;          % blank the bias if the nearest real measurement is
min_gap_s    = 2.0;        % farther away than max(min_gap_s, gap_factor*median_dt)

% monotonic ground truth (relative position)
[gts, gtx] = mono_interp_src(gt.stamp, gt.x_rel);
[~,   gty] = mono_interp_src(gt.stamp, gt.y_rel);

% --- locate the requested sensors inside "sensors" ---
n_cmp = numel(compare_sensors);
bk_list = nan(1,n_cmp);
for ii = 1:n_cmp
    bk_list(ii) = find(strcmp(r_field, compare_sensors{ii}), 1);
end
if any(isnan(bk_list)) || numel(sensors) < max(bk_list)
    warning('r_bias_cross_correlation: one or more compare_sensors not found in sensors{}. Skipping.');
else
    Scell = cell(1,n_cmp); cols = cell(1,n_cmp); nm = cell(1,n_cmp);
    for ii = 1:n_cmp
        Scell{ii} = compute_sensor_bias(sensors{bk_list(ii)}.s, gts, gtx, gty, ...
            skip_start_s, err_outlier, drift_win_s, gap_factor, min_gap_s);
        cols{ii}  = sensors{bk_list(ii)}.col;
        nm{ii}    = dname(compare_sensors{ii});
    end

    % --- bias of the filter's OWN ESTIMATE (tt), same movmean smoothing
    % as the raw sensors (window configurable separately via
    % tt_drift_win_s), for a fair visual comparison against the sensors'
    % low-frequency bias ---
    has_tt_bias = exist('tt','var') && isfield(tt,'x_rel') && isfield(tt,'y_rel') && isfield(tt,'stamp');
    if has_tt_bias
        opp_col_bias = opp_col;
        if isfield(tt,'max_opp') && opp_col_bias > tt.max_opp
            warning('r_bias_cross_correlation: opp_idx (%d) exceeds tt.max_opp (%d), using opp=1.', opp_col_bias, tt.max_opp);
            opp_col_bias = 1;
        end
        tt_s.sens_stamp = tt.stamp;
        tt_s.x_rel      = tt.x_rel(:,opp_col_bias);
        tt_s.y_rel      = tt.y_rel(:,opp_col_bias);
        tt_bias = compute_sensor_bias(tt_s, gts, gtx, gty, skip_start_s, err_outlier, tt_drift_win_s, gap_factor, min_gap_s);
    else
        tt_bias = [];
        warning('r_bias_cross_correlation: tt not available or missing x_rel/y_rel: skipping filter estimate overlay.');
    end

    % ===================== FIGURE 1: bias over time, overlaid =====================
    % No interpolation/alignment: each sensor is drawn on its own native
    % timestamps. If the curves rise/fall together (same peaks/troughs,
    % same sign), the bias is likely shared across sensors.
    % (Background raw-error scatter removed on request - smoothed bias only.)
    fig1 = figure('name', 'Cross-sensor bias - time series', 'NumberTitle','off', 'Color','w', ...
        'Position', [80 80 1150 650]);
    tl1 = tiledlayout(fig1, 2, 1, 'TileSpacing','compact', 'Padding','compact');

    ax1x = nexttile(tl1, 1); hold(ax1x,'on'); grid(ax1x,'on');
    for ii = 1:n_cmp
        plot(ax1x, Scell{ii}.st, Scell{ii}.bx, '-', 'Color', [cols{ii} 0.55], 'LineWidth', 1.8, 'DisplayName', nm{ii});
    end
    if ~isempty(tt_bias)
        plot(ax1x, tt_bias.st, tt_bias.bx, '--', 'Color', col.tt, 'LineWidth', 3.5, ...
            'DisplayName', sprintf('filter (estimate, %.0fs)', tt_drift_win_s));
    end
    yline(ax1x, 0, 'k:', 'HandleVisibility','off');
    ylabel(ax1x, 'b_x [m]', 'Interpreter','tex');
    title(ax1x, 'Low-frequency bias over time - x component', 'Interpreter','none');

    ax1y = nexttile(tl1, 2); hold(ax1y,'on'); grid(ax1y,'on');
    for ii = 1:n_cmp
        plot(ax1y, Scell{ii}.st, Scell{ii}.by, '-', 'Color', [cols{ii} 0.55], 'LineWidth', 1.8, 'DisplayName', nm{ii});
    end
    if ~isempty(tt_bias)
        plot(ax1y, tt_bias.st, tt_bias.by, '--', 'Color', col.tt, 'LineWidth', 3.5, ...
            'DisplayName', sprintf('filter (estimate, %.0fs)', tt_drift_win_s));
    end
    yline(ax1y, 0, 'k:', 'HandleVisibility','off');
    xlabel(ax1y, 'timestamp [s]'); ylabel(ax1y, 'b_y [m]', 'Interpreter','tex');
    title(ax1y, 'Low-frequency bias over time - y component', 'Interpreter','none');

    % legenda unica condivisa (stessi sensori + filtro in entrambi i
    % subplot), in basso invece di una per subplot
    lg1 = legend(ax1x, 'Orientation', 'horizontal', 'NumColumns', 3, 'FontSize', legend_fontsize);
    lg1.Layout.Tile = 'south';

    linkaxes([ax1x ax1y], 'x');

    % NOTE: ax1x/ax1y are NOT added to the shared "axes" array (the one
    % linked in time at the end of TargetTrackingAnalysis.m). If you'd
    % like the time zoom shared with the other time plots (range,
    % speed_acc, ...), let me know and I'll add:
    %   axes(end+1) = ax1x; axes(end+1) = ax1y;
    end
end

% ===================== FIGURE 2: filter velocity estimate vs radar rho_dot =====================
radar_idx = find(strcmp(r_field, 'radar'), 1);
has_radar = ~isempty(radar_idx) && numel(sensors) >= radar_idx && isfield(sensors{radar_idx}.s, 'rho_dot');
has_tt_rd = exist('tt','var') && isfield(tt,'rho_dot') && isfield(tt,'stamp');

if ~has_radar || ~has_tt_rd
    warning('r_bias_cross_correlation: tt.rho_dot or radar.rho_dot not available: skipping velocity comparison.');
else
    rad_s = sensors{radar_idx}.s;

    opp_col_rd = opp_col;
    if isfield(tt,'max_opp') && opp_col_rd > tt.max_opp
        warning('r_bias_cross_correlation: opp_idx (%d) exceeds tt.max_opp (%d), using opp=1.', opp_col_rd, tt.max_opp);
        opp_col_rd = 1;
    end

    % NOTE: using subplot(1,1,1) instead of axes(...) to get the axes
    % handle: "axes" is shadowed in this workspace by the shared
    % time-axes-list variable (axes = [] ...), so calling the builtin
    % axes() function here would actually read that variable instead.
    figure('name', 'Velocity estimate vs Radar rho_dot', 'NumberTitle','off', 'Color','w', ...
        'Position', [80 80 1100 450]);
    ax2 = subplot(1,1,1); hold(ax2,'on'); grid(ax2,'on');

    % (Background raw radar scatter removed on request - lines only.)
    if has_gt && isfield(gt,'rho_dot')
        plot(ax2, gt.stamp, gt.rho_dot, '-', 'Color', col.ref, 'LineWidth', 1.5, 'DisplayName', 'gt');
    end
    plot(ax2, tt.stamp, tt.rho_dot(:,opp_col_rd), '-', 'Color', col.tt, 'LineWidth', 1.8, 'DisplayName', 'filter (estimate)');

    yline(ax2, 0, 'k:', 'HandleVisibility','off');
    xlabel(ax2, 'timestamp [s]'); ylabel(ax2, 'rho_{dot} [m/s]', 'Interpreter','tex');
    title(ax2, 'Velocity estimate (filter) vs radar rho_{dot} measurement', 'Interpreter','tex');
    legend(ax2, 'show', 'Location', 'southoutside', 'Orientation', 'horizontal', 'FontSize', legend_fontsize);
end

% ===================== local helpers =====================

function out = compute_sensor_bias(s, gt_t, gt_x, gt_y, skip_start_s, err_outlier, drift_win_s, gap_factor, min_gap_s)
    st_raw = s.sens_stamp(:);
    mx_raw = mask_sentinel(s.x_rel(:,1));
    my_raw = mask_sentinel(s.y_rel(:,1));

    good = isfinite(st_raw);
    st_raw = st_raw(good); mx_raw = mx_raw(good); my_raw = my_raw(good);

    [st_sorted, sidx] = sort(st_raw);
    mx_sorted = mx_raw(sidx); my_sorted = my_raw(sidx);
    [st, iu] = unique(st_sorted, 'stable');
    mx = mx_sorted(iu); my = my_sorted(iu);

    t0 = gt_t(1);
    gtx_on = interp1(gt_t, gt_x, st, 'linear', nan);
    gty_on = interp1(gt_t, gt_y, st, 'linear', nan);
    ex = mx - gtx_on;
    ey = my - gty_on;

    base = isfinite(st) & isfinite(ex) & isfinite(ey) ...
           & (st - t0 >= skip_start_s) & (abs(ex) <= err_outlier) & (abs(ey) <= err_outlier);

    dt_med = median(diff(st), 'omitnan');
    win_n  = max(3, round(drift_win_s / max(dt_med, eps)));
    exf = ex; exf(~base) = nan;
    eyf = ey; eyf(~base) = nan;
    bx = movmean(exf, win_n, 'omitnan');
    by = movmean(eyf, win_n, 'omitnan');

    % Blank the smoothed bias wherever there is no ACTUAL measurement
    % nearby: movmean(...,'omitnan') would otherwise happily bridge a
    % long dropout using only far-away samples, showing a "mean" where
    % this sensor has no data at all.
    if any(base)
        nearest_valid_t = interp1(st(base), st(base), st, 'nearest', 'extrap');
        gap = abs(st - nearest_valid_t);
    else
        gap = inf(size(st));
    end
    max_gap_s = max(min_gap_s, gap_factor * max(dt_med, eps));
    bx(gap > max_gap_s) = nan;
    by(gap > max_gap_s) = nan;

    out.st   = st;
    out.ex   = ex;
    out.ey   = ey;
    out.bx   = bx;
    out.by   = by;
    out.base = base;
end

function [ts, vs] = mono_interp_src(t, v)
    ts = t(:); vs = v(:);
    good = isfinite(ts) & isfinite(vs);
    ts = ts(good); vs = vs(good);
    [ts, iu] = unique(ts, 'stable'); vs = vs(iu);
    [ts, is] = sort(ts);             vs = vs(is);
end

function v = mask_sentinel(v)
    v(v <= -9999) = NaN;
end