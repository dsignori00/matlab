%% R_BIAS_GEOMETRY_ANALYSIS
% Diagnostic figure to test whether the low-frequency measurement bias has
% a SYSTEMATIC origin (shared across sensors) rather than being independent
% per-sensor noise.
%
% Figure 1: low-frequency bias b(t) compared across MULTIPLE sensors
%           (e.g. lidar clustering, point pillars, radar), via a
%           QUANTILE-QUANTILE (QQ) comparison of the bias DISTRIBUTIONS
%           over the common time window of the bag - rather than a
%           point-by-point Pearson correlation of the time series.
%           A QQ comparison answers "do these sensors' biases have the
%           same shape/scale of distribution" without relying on exact
%           time alignment, and is not inflated by the autocorrelation
%           introduced by the low-pass smoothing (which a plain Pearson
%           correlation on two heavily smoothed signals tends to suffer
%           from). r_q close to 1 with slope ~1 on the QQ plot means the
%           two sensors see the same low-frequency bias, in the same
%           amount - consistent with a cause shared by the whole pipeline
%           (e.g. ego-pose used for the relative frame, or a timing/sync
%           offset) rather than a per-sensor algorithm artifact.
%
% NB: does NOT require adaptive R (works even if 'pp'/'radar' have no
% tt.R.* field).
% uses: tt, sensors, gt, opp_idx, axes (optional)

if ~exist('axes','var'); axes = []; end

has_gt = (exist('use_ref','var') && use_ref) || (exist('use_sim_ref','var') && use_sim_ref);
if ~has_gt
    warning('r_bias_geometry_analysis: ground truth required. Skipping.');
else
    r_field = {'lidar','pp','radar','camera'};

    % --- parameters ---
    compare_sensors = {'lidar','pp','radar'};  % sensors compared in Figure 1
    skip_start_s = 5;         % discard the first N seconds (initial transient)
    err_outlier  = 3;         % [m] discard |error| above this threshold (x/y)
    drift_win_s  = 20;        % low-pass window of the drift b(t) [s]
    p_grid       = (0.01:0.01:0.99).';  % common probability grid for the QQ comparison
    leg_fs       = 10;        % legend font size

    disp_map = containers.Map( ...
        {'lidar','pp','radar','camera'}, ...
        {'lidar clustering','lidar point pillars','radar','camera'});
    dname = @(k) char(disp_map(k));

    % monotonic ground truth (relative position)
    [gts, gtx] = mono_interp_src(gt.stamp, gt.x_rel);
    [~,   gty] = mono_interp_src(gt.stamp, gt.y_rel);

    % ===================== FIGURE 1: cross-sensor low-frequency bias (QQ) =====================
    n_cmp = numel(compare_sensors);
    bk_list = nan(1,n_cmp);
    for ii = 1:n_cmp
        bk_list(ii) = find(strcmp(r_field, compare_sensors{ii}), 1);
    end
    if any(isnan(bk_list)) || numel(sensors) < max(bk_list)
        warning('r_bias_geometry_analysis: one or more compare_sensors not found in sensors{}. Skipping Figure 1.');
    else
        Scell = cell(1,n_cmp); cols = cell(1,n_cmp); nm = cell(1,n_cmp);
        for ii = 1:n_cmp
            Scell{ii} = compute_sensor_bias(sensors{bk_list(ii)}.s, gts, gtx, gty, skip_start_s, err_outlier, drift_win_s);
            cols{ii}  = sensors{bk_list(ii)}.col;
            nm{ii}    = dname(compare_sensors{ii});
        end

        % restrict each sensor to the common time window so the distributions
        % are compared over the same portion of the bag. A QQ comparison does
        % NOT need point-by-point time alignment (unlike the Pearson
        % correlation it replaces) - only a shared window for fairness.
        t_lo = max(cellfun(@(S) min(S.st(isfinite(S.bx))), Scell));
        t_hi = min(cellfun(@(S) max(S.st(isfinite(S.bx))), Scell));
        if ~(t_hi > t_lo)
            warning('r_bias_geometry_analysis: no time overlap across compare_sensors. Skipping Figure 1.');
        else
            Qx = nan(numel(p_grid), n_cmp); Qy = nan(numel(p_grid), n_cmp);
            for ii = 1:n_cmp
                mx_win = Scell{ii}.st >= t_lo & Scell{ii}.st <= t_hi & isfinite(Scell{ii}.bx);
                my_win = Scell{ii}.st >= t_lo & Scell{ii}.st <= t_hi & isfinite(Scell{ii}.by);
                Qx(:,ii) = local_quantile(Scell{ii}.bx(mx_win), p_grid);
                Qy(:,ii) = local_quantile(Scell{ii}.by(my_win), p_grid);
            end

            pairs   = nchoosek(1:n_cmp, 2);
            n_pairs = size(pairs,1);

            % NOTE: these axes are deliberately NOT appended to the script-level
            % "axes" array. That array is later passed to linkaxes(axes,'x') in
            % the main script to sync the TIME axis across all figures - but
            % these panels are quantile-vs-quantile (bias in meters on both
            % axes, no time at all). Linking them would force their xlim to
            % whatever the largest time range happens to be (seconds), which is
            % exactly the "0 / 500 / 1000" axis collapse seen before this fix.
            fig = figure('name', 'Low-frequency bias - quantile (QQ) comparison across sensors', ...
                'NumberTitle','off', 'Color','w', 'Position', [80 80 1500 850]);
            tl = tiledlayout(fig, 2, n_pairs, 'TileSpacing','compact', 'Padding','compact');

            for r = 1:2
                if r == 1; Q = Qx; lbl = 'b_x'; else; Q = Qy; lbl = 'b_y'; end
                for k = 1:n_pairs
                    ia = pairs(k,1); ib = pairs(k,2);
                    ax = nexttile(tl, (r-1)*n_pairs + k); hold(ax,'on'); grid(ax,'on'); axis(ax,'square');

                    qa = Q(:,ia); qb = Q(:,ib);
                    ok = isfinite(qa) & isfinite(qb);
                    if nnz(ok) >= 2
                        lim = [min([qa(ok);qb(ok)]), max([qa(ok);qb(ok)])];
                        if lim(1) == lim(2); lim = lim(1) + [-1 1]; end
                    else
                        lim = [-1 1];
                    end

                    plot(ax, lim, lim, '--k', 'LineWidth', 1.0, 'DisplayName', 'y = x');
                    sc = scatter(ax, qa(ok), qb(ok), 28, p_grid(ok), 'filled', 'MarkerEdgeColor', [0.3 0.3 0.3], ...
                        'LineWidth', 0.3, 'DisplayName', 'quantiles (p=0.01..0.99)'); %#ok<NASGU>
                    colormap(ax, parula); caxis(ax, [0 1]); %#ok<CAXIS>

                    rq = nan;
                    if nnz(ok) > 5
                        rq = corr(qa(ok), qb(ok));
                        pft = polyfit(qa(ok), qb(ok), 1);
                        xx = linspace(lim(1), lim(2), 2);
                        plot(ax, xx, polyval(pft, xx), '-', 'Color', [0.85 0.33 0.10], 'LineWidth', 1.4, ...
                            'DisplayName', sprintf('fit: slope=%.2f, b=%.2f', pft(1), pft(2)));
                    end

                    xlim(ax, lim); ylim(ax, lim);
                    xlabel(ax, sprintf('%s [m]', nm{ia}), 'Interpreter','tex');
                    ylabel(ax, sprintf('%s [m]', nm{ib}), 'Interpreter','tex');
                    title(ax, sprintf('%s:  %s vs %s   (r_q = %.2f)', lbl, nm{ia}, nm{ib}, rq), ...
                        'Interpreter','tex', 'FontSize', 10);
                    if r == 1 && k == 1
                        lg = legend(ax,'show','Location','southeast','FontSize',leg_fs-2);
                        try; lg.BoxFace.ColorType = 'truecoloralpha'; lg.BoxFace.ColorData = uint8([255;255;255;200]); catch; end
                    end
                end
            end
            cb = colorbar(ax); cb.Layout.Tile = 'east'; cb.Label.String = 'quantile level p';
            title(tl, 'Quantile-quantile comparison of the low-frequency bias across sensors (same bag, common time window)', ...
                'FontWeight','bold');

            fprintf('\n[r_bias_geometry] quantile (QQ) correlation of low-frequency bias across sensors, p=0.01:0.01:0.99:\n');
            for k = 1:n_pairs
                ia = pairs(k,1); ib = pairs(k,2);
                okx = isfinite(Qx(:,ia)) & isfinite(Qx(:,ib));
                oky = isfinite(Qy(:,ia)) & isfinite(Qy(:,ib));
                rqx = corr(Qx(okx,ia), Qx(okx,ib));
                rqy = corr(Qy(oky,ia), Qy(oky,ib));
                pftx = polyfit(Qx(okx,ia), Qx(okx,ib), 1);
                pfty = polyfit(Qy(oky,ia), Qy(oky,ib), 1);
                fprintf('  %s vs %s:  r_q(b_x) = %.2f (slope %.2f)   r_q(b_y) = %.2f (slope %.2f)\n', ...
                    nm{ia}, nm{ib}, rqx, pftx(1), rqy, pfty(1));
            end
            fprintf('  r_q close to 1 with slope ~1 means the two sensors'' bias DISTRIBUTIONS have the same\n');
            fprintf('  shape/scale over this window - consistent with a shared systematic cause - without relying\n');
            fprintf('  on point-by-point time alignment (unlike a time-series Pearson correlation on the raw\n');
            fprintf('  low-pass signals, which can be inflated by the smoothing''s autocorrelation).\n\n');
        end
    end
end

% ===================== local helpers =====================

% Computes the GT-relative measurement error and its low-frequency drift for
% a single sensor, independently of any adaptive R (no sigma needed).
% IMPORTANT: st is sorted and deduplicated before any interpolation, because
% interp1 requires strictly unique sample points when st is used as the X
% argument.
function out = compute_sensor_bias(s, gt_t, gt_x, gt_y, skip_start_s, err_outlier, drift_win_s)
    st_raw = s.sens_stamp(:);
    mx_raw = mask_sentinel(s.x_rel(:,1));
    my_raw = mask_sentinel(s.y_rel(:,1));

    good = isfinite(st_raw);
    st_raw = st_raw(good); mx_raw = mx_raw(good); my_raw = my_raw(good);

    % sort first, then drop duplicate timestamps (keep first occurrence)
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

    out.st   = st;
    out.ex   = ex;
    out.ey   = ey;
    out.bx   = movmean(exf, win_n, 'omitnan');
    out.by   = movmean(eyf, win_n, 'omitnan');
    out.base = base;
end

% Empirical quantiles via linear interpolation of the ECDF (no Statistics
% Toolbox dependency, equivalent to MATLAB's default quantile.m method).
function q = local_quantile(x, p)
    x = sort(x(isfinite(x)));
    n = numel(x);
    p = p(:);
    if n == 0
        q = nan(size(p));
        return;
    end
    if n == 1
        q = repmat(x, size(p));
        return;
    end
    pk = ((1:n).' - 0.5) / n;
    q = interp1(pk, x, p, 'linear', 'extrap');
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