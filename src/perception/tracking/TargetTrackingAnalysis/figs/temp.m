%% R_BIAS_TMP  (figura temporanea)
% Riproduce il bias a bassa frequenza b_x(t), b_y(t) misura-vs-gt per sensore
% (come FIGURA 1 di r_bias_cross_correlation), ma su DUE configurazioni:
%   fig 1 -> sensori {lidar, pp, radar, camera}  + stima log 1 (tt)
%   fig 2 -> sensori {lidar, radar, camera}       + stima log 2 (tt2)
% Ogni sensore e' disegnato sui propri timestamp nativi (nessun allineamento):
% se le curve salgono/scendono insieme, il bias e' verosimilmente condiviso.
%
% uses: sensors, tt, tt2, gt, opp_idx, use_ref/use_sim_ref, col

if ~exist('axes','var'); axes = []; end %#ok<NASGU>  % evita shadowing builtin

legend_fontsize = 20;

r_field = {'lidar','pp','radar','camera'};   % ordine allineato a sensors{}
disp_map = containers.Map( ...
    {'lidar','pp','radar','camera'}, ...
    {'lidar clustering','lidar point pillars','radar','camera'});
dname = @(k) char(disp_map(k));

opp_col = 1;
if exist('opp_idx','var'); opp_col = opp_idx; end

has_gt = (exist('use_ref','var') && use_ref) || (exist('use_sim_ref','var') && use_sim_ref);
if ~has_gt
    warning('r_bias_tmp: serve la ground truth. Skip.');
    return;
end

% --- parametri (come nel riferimento) ---
skip_start_s   = 0;     % scarta i primi N secondi (transitorio iniziale)
err_outlier    = 3;     % [m] scarta |errore| oltre questa soglia (x/y)
drift_win_s    = 10;    % finestra low-pass del bias sensori b(t) [s]
tt_drift_win_s = 10;    % finestra low-pass del bias della stima filtro [s]
gap_factor     = 5;     % azzera il bias se la misura reale piu' vicina e'
min_gap_s      = 2.0;   % oltre max(min_gap_s, gap_factor*median_dt)

% ground truth monotona (posizione relativa) - calcolata una volta
[gts, gtx] = mono_interp_src(gt.stamp, gt.x_rel);
[~,   gty] = mono_interp_src(gt.stamp, gt.y_rel);

% ---------- configurazioni delle figure ----------
% ogni config: set di sensori (chiavi r_field) + struttura stima (tt / tt2)
configs = {};
configs{end+1} = struct('keys', {{'lidar','pp','radar','camera'}}, 'est', tt);
if exist('tt2','var')
    configs{end+1} = struct('keys', {{'lidar','radar','camera'}}, 'est', tt2);
else
    warning('r_bias_tmp: tt2 non disponibile, salto la seconda figura (log 2).');
end

axx_all = gobjects(0);   % pannelli b_x delle figure (per linkage)
axy_all = gobjects(0);   % pannelli b_y delle figure (per linkage)

for kc = 1:numel(configs)
    cmp = configs{kc}.keys;      % chiavi sensori di questa figura
    est = configs{kc}.est;       % struttura stima (log) di questa figura
    n_cmp = numel(cmp);

    % --- localizza i sensori richiesti in sensors{} ---
    bk_list = nan(1,n_cmp);
    for ii = 1:n_cmp
        idx = find(strcmp(r_field, cmp{ii}), 1);
        if ~isempty(idx); bk_list(ii) = idx; end
    end
    if any(isnan(bk_list)) || numel(sensors) < max(bk_list)
        warning('r_bias_tmp: sensore mancante in sensors{} per la config %d. Skip.', kc);
        continue;
    end

    % --- bias per ogni sensore ---
    Scell = cell(1,n_cmp); cols = cell(1,n_cmp); nm = cell(1,n_cmp);
    for ii = 1:n_cmp
        Scell{ii} = compute_sensor_bias(sensors{bk_list(ii)}.s, gts, gtx, gty, ...
            skip_start_s, err_outlier, drift_win_s, gap_factor, min_gap_s);
        cols{ii}  = sensors{bk_list(ii)}.col;
        nm{ii}    = dname(cmp{ii});
    end

    % --- bias della STIMA del log (est), stesso smoothing (tt_drift_win_s) ---
    tt_bias = []; est_name = 'filter';
    if isfield(est,'x_rel') && isfield(est,'y_rel') && isfield(est,'stamp')
        oc = opp_col;
        if isfield(est,'max_opp') && oc > est.max_opp
            warning('r_bias_tmp: opp_idx (%d) > max_opp (%d), uso opp=1.', oc, est.max_opp);
            oc = 1;
        end
        tt_s.sens_stamp = est.stamp;
        tt_s.x_rel      = est.x_rel(:,oc);
        tt_s.y_rel      = est.y_rel(:,oc);
        tt_bias = compute_sensor_bias(tt_s, gts, gtx, gty, skip_start_s, err_outlier, ...
                                      tt_drift_win_s, gap_factor, min_gap_s);
    else
        warning('r_bias_tmp: stima senza x_rel/y_rel: niente overlay filtro (config %d).', kc);
    end
    if isfield(est,'name'); est_name = est.name; end
    est_col = col.tt;
    if isfield(est,'col'); est_col = est.col; end

    % ===================== FIGURA: bias nel tempo =====================
    fig = figure('name', sprintf('Cross-sensor bias (tmp) | %s | %s', est_name, strjoin(cmp,'+')), ...
        'NumberTitle','off', 'Color','w', 'Position', [80 80 1150 650]);
    tl = tiledlayout(fig, 2, 1, 'TileSpacing','compact', 'Padding','compact');

    axx = nexttile(tl, 1); hold(axx,'on'); grid(axx,'on');
    for ii = 1:n_cmp
        plot(axx, Scell{ii}.st, Scell{ii}.bx, '-', 'Color', [cols{ii} 0.55], ...
             'LineWidth', 1.8, 'DisplayName', nm{ii});
    end
    if ~isempty(tt_bias)
        plot(axx, tt_bias.st, tt_bias.bx, '--', 'Color', est_col, 'LineWidth', 3.5, ...
             'DisplayName', sprintf('%s (estimate, %.0fs)', est_name, tt_drift_win_s));
    end
    yline(axx, 0, 'k:', 'HandleVisibility','off');
    ylabel(axx, 'b_x [m]', 'Interpreter','tex');
    title(axx, 'Low-frequency bias over time - x component', 'Interpreter','none');

    axy = nexttile(tl, 2); hold(axy,'on'); grid(axy,'on');
    for ii = 1:n_cmp
        plot(axy, Scell{ii}.st, Scell{ii}.by, '-', 'Color', [cols{ii} 0.55], ...
             'LineWidth', 1.8, 'DisplayName', nm{ii});
    end
    if ~isempty(tt_bias)
        plot(axy, tt_bias.st, tt_bias.by, '--', 'Color', est_col, 'LineWidth', 3.5, ...
             'DisplayName', sprintf('%s (estimate, %.0fs)', est_name, tt_drift_win_s));
    end
    yline(axy, 0, 'k:', 'HandleVisibility','off');
    xlabel(axy, 'timestamp [s]'); ylabel(axy, 'b_y [m]', 'Interpreter','tex');
    title(axy, 'Low-frequency bias over time - y component', 'Interpreter','none');

    % legenda unica condivisa in basso
    lg = legend(axx, 'Orientation', 'horizontal', 'NumColumns', 3, 'FontSize', legend_fontsize);
    lg.Layout.Tile = 'south';

    axx_all(end+1) = axx; axy_all(end+1) = axy; %#ok<SAGROW>
end

% ---------- linkage tra le figure ----------
% X: tempo comune su TUTTI i pannelli (b_x e b_y, entrambe le figure).
% Y: per componente -> i b_x tra loro, i b_y tra loro (stessa unita', confronto
%    diretto log1 vs log2). linkprop sulla YLim convive con linkaxes('x').
all_ax = [axx_all axy_all];
all_ax = all_ax(isgraphics(all_ax));
if numel(all_ax) >= 2
    linkaxes(all_ax, 'x');
end
if numel(axx_all) >= 2
    rbias_bx_ylink = linkprop(axx_all(isgraphics(axx_all)), 'YLim'); %#ok<NASGU>
end
if numel(axy_all) >= 2
    rbias_by_ylink = linkprop(axy_all(isgraphics(axy_all)), 'YLim'); %#ok<NASGU>
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

    if any(base)
        nearest_valid_t = interp1(st(base), st(base), st, 'nearest', 'extrap');
        gap = abs(st - nearest_valid_t);
    else
        gap = inf(size(st));
    end
    max_gap_s = max(min_gap_s, gap_factor * max(dt_med, eps));
    bx(gap > max_gap_s) = nan;
    by(gap > max_gap_s) = nan;

    out.st = st; out.ex = ex; out.ey = ey; out.bx = bx; out.by = by; out.base = base;
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