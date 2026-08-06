%% R_BIAS_SENSOR_STABILITY_MULTIBAG
% For each sensor INDEPENDENTLY, fits the heading-offset bias model and
% overlays the track-position-binned bias b(s), across MULTIPLE bags loaded
% one at a time in this same run - to test whether a GIVEN sensor has a
% STABLE bias signature across sessions, and whether that signature is
% consistent with a fixed ego localization offset.
%
% Model (real ego heading, log.estimation.heading vs log.estimation.stamp__tot):
%   b_x =  dX*cos(theta_ego) + dY*sin(theta_ego)
%   b_y = -dX*sin(theta_ego) + dY*cos(theta_ego)
% i.e. a CONSTANT vector (dX, dY) in the GLOBAL/map frame, which - expressed
% in the ego's own rotating frame - shows up as a bias that varies with the
% ego's instantaneous heading.
%
% Dispersion metric (meters, always >= 0 - no R^2, which can go negative
% when the robust/coupled x-y fit is worse than predicting the mean on one
% axis alone):
%   sraw  = std of the raw bias (no model, "predict the mean")
%   sres  = std of the bias left over after subtracting the model
%   sres << sraw -> model explains a lot; sres ~ sraw -> explains little;
%   sres > sraw  -> model is actively worse than the mean on that axis.
%
% For each of N_BAGS runs, you'll be prompted to pick the ontrack log .mat
% and the ground-truth .mat, exactly as in the main pipeline.
% Run from the same working directory as the rest of the analysis pipeline
% (same addpath conventions as target_tracking_analysis.m).

default_n_bags = 4;
N_BAGS = input(sprintf('Quante bag vuoi confrontare? [invio per default = %d]: ', default_n_bags));
if isempty(N_BAGS) || ~isnumeric(N_BAGS) || ~isscalar(N_BAGS) || N_BAGS < 1 || mod(N_BAGS,1) ~= 0
    N_BAGS = default_n_bags;
end
fprintf('Confronto %d bag.\n', N_BAGS);

sensors_to_check = {'lidar','pp','radar'};
r_field      = {'lidar','pp','radar','camera'};
skip_start_s = 5;
err_outlier  = 3;     % [m]
nbins_s      = 100;
min_samples  = 30;
use_sim_ref  = false;
use_ref      = true;

normal_path = "../../../bags";
opp_dir     = "../../opponent_gps/mat/";
addpath("../../../common/utilities/")
addpath("../../../../common/constants/")
addpath("../../../common/plot/")
addpath("../../../../common/graphic_tools/")
addpath("../../utils/")
addpath("func/")

disp_map = containers.Map( ...
    {'lidar','pp','radar','camera'}, ...
    {'lidar clustering','lidar point pillars','radar','camera'});
dname = @(k) char(disp_map(k));

bag_colors = lines(N_BAGS);

% per-sensor storage for the b(s) visual comparison: one cell slot per bag
data = struct();
for si = 1:numel(sensors_to_check)
    data.(sensors_to_check{si}) = cell(1,N_BAGS);
end

% per-sensor, per-bag fit results
results = struct([]);

opp_idx_local = 1; if exist('opp_idx','var'); opp_idx_local = opp_idx; end

for b = 1:N_BAGS
    fprintf('\n=========== BAG %d/%d ===========\n', b, N_BAGS);

    % ---- load the ontrack log ----
    [file, path] = uigetfile(fullfile(normal_path,'*.mat'), sprintf('Bag %d/%d - load ontrack log', b, N_BAGS));
    if isequal(file, 0)
        warning('Bag %d: nessun file selezionato, salto questa bag.', b);
        continue;
    end
    tmp = load(fullfile(path,file));
    log = tmp.log;
    clearvars tmp;
    bag_name = file;

    % ---- load the ground truth ----
    [file_ref, path_ref] = uigetfile(fullfile(opp_dir,'*.mat'), sprintf('Bag %d/%d - load ground truth', b, N_BAGS));
    if isequal(file_ref, 0)
        warning('Bag %d: nessun GT selezionato, salto questa bag.', b);
        continue;
    end
    tmp = load(fullfile(path_ref,file_ref));
    log_ref = tmp.out;
    clearvars tmp;

    % ---- parsing (same calls as the main pipeline) ----
    [lid_clust, rad_clust, cam_yolo, lid_pp] = load_perception(log);
    gt = load_ref(log, use_sim_ref, use_ref, log_ref);

    sensors = { ...
        struct('s', lid_clust, 'name', 'lidar'), ...
        struct('s', lid_pp,    'name', 'pp'), ...
        struct('s', rad_clust, 'name', 'radar'), ...
        struct('s', cam_yolo,  'name', 'camera'), ...
    };

    [gts, gtx] = local_mono(gt.stamp, gt.x_rel);
    [~,   gty] = local_mono(gt.stamp, gt.y_rel);

    % ---- locate the ego heading signal for THIS bag ----
    E = locate_struct_with_fields(log, {'heading','stamp__tot'});
    if isempty(E)
        warning('Bag %d (%s): struct con "heading"+"stamp__tot" non trovato. Salto questa bag.', b, bag_name);
        continue;
    end
    t_ego = E.stamp__tot(:);
    heading_ego = E.heading(:);

    % ---- locate the raw log struct + track position s (only needed for the
    % b(s) visual binning, not for the model fit itself) ----
    L = locate_struct_with_fields(log, {'opponents__s','stamp__tot'});
    if isempty(L); L = locate_struct_with_fields(log, {'opponents__s','bag_stamp'}); end
    if isempty(L)
        warning('Bag %d (%s): "opponents__s" non trovato. Salto il plot b(s) per questa bag.', b, bag_name);
        t = []; s_raw_full = []; track_len = 0;
    else
        if isfield(L,'stamp__tot'); t = L.stamp__tot(:); else; t = L.bag_stamp(:); end
        s_raw_full = L.opponents__s(:,opp_idx_local); s_raw_full(s_raw_full<=-9999) = nan;
        track_len = max(s_raw_full,[],'omitnan') - min(s_raw_full,[],'omitnan');
    end
    if track_len > 0
        edges = linspace(0, track_len, nbins_s+1);
        sc = 0.5*(edges(1:end-1) + edges(2:end));
    end

    % ---- per sensor: raw error vs GT, heading-offset model fit ----
    for si = 1:numel(sensors_to_check)
        sname = sensors_to_check{si};
        bk = find(strcmp(r_field, sname), 1);
        if isempty(bk) || numel(sensors) < bk
            warning('Bag %d (%s): sensore "%s" non trovato.', b, bag_name, sname);
            continue;
        end
        [st_raw, ex_raw, ey_raw, base_raw] = local_raw_error(sensors{bk}.s, gts, gtx, gty, skip_start_s, err_outlier);
        if nnz(base_raw) < min_samples
            warning('Bag %d (%s), sensore %s: troppo pochi campioni validi (%d).', b, bag_name, sname, nnz(base_raw));
            continue;
        end

        bx = ex_raw; bx(~base_raw) = nan;
        by = ey_raw; by(~base_raw) = nan;

        theta_ego_t = interp1(t_ego, heading_ego, st_raw, 'linear', 'extrap');
        cos_t = cos(theta_ego_t);
        sin_t = sin(theta_ego_t);

        okh = isfinite(bx) & isfinite(by) & isfinite(cos_t) & isfinite(sin_t);
        n_used = nnz(okh);
        if n_used < min_samples
            warning('Bag %d (%s), sensore %s: pochi campioni utilizzabili dopo allineamento heading (%d).', ...
                b, bag_name, sname, n_used);
            continue;
        end

        Ah = [ cos_t(okh),  sin_t(okh) ; -sin_t(okh),  cos_t(okh) ];
        dh = [ bx(okh) ; by(okh) ];
        p1 = robust_solve(Ah, dh);
        dX = p1(1); dY = p1(2);
        bx_mod = dX*cos_t + dY*sin_t;
        by_mod = -dX*sin_t + dY*cos_t;

        sraw_x = std(bx(okh), 'omitnan');
        sres_x = std(bx(okh) - bx_mod(okh), 'omitnan');
        sraw_y = std(by(okh), 'omitnan');
        sres_y = std(by(okh) - by_mod(okh), 'omitnan');

        k = numel(results) + 1;
        results(k).sensor = sname;  %#ok<SAGROW>
        results(k).name   = dname(sname);
        results(k).bag    = bag_name;
        results(k).n      = n_used;
        results(k).dX     = dX;
        results(k).dY     = dY;
        results(k).sraw_x = sraw_x;
        results(k).sres_x = sres_x;
        results(k).sraw_y = sraw_y;
        results(k).sres_y = sres_y;

        % ---- (visual only) binned mean over track position, for b(s) plot ----
        if track_len > 0
            s_sens = interp1(t, s_raw_full, st_raw, 'linear', nan);
            s_fold = mod(s_sens - min(s_raw_full,[],'omitnan'), track_len);
            muX = fold_stats(s_fold, bx, edges);
            muY = fold_stats(s_fold, by, edges);

            max_scatter_pts = 4000;
            ok_raw = isfinite(s_fold) & isfinite(bx) & isfinite(by);
            idx_raw = find(ok_raw);
            if numel(idx_raw) > max_scatter_pts
                idx_raw = idx_raw(randperm(numel(idx_raw), max_scatter_pts));
            end

            d = struct();
            d.bag    = bag_name;
            d.sc     = sc;
            d.muX    = muX;
            d.muY    = muY;
            d.s_raw  = s_fold(idx_raw);
            d.bx_raw = bx(idx_raw);
            d.by_raw = by(idx_raw);
            data.(sname){b} = d;
        end
    end
end

% ===================== one figure per sensor: b_x(s) and b_y(s) across bags =====================
for si = 1:numel(sensors_to_check)
    sname = sensors_to_check{si};
    entries = data.(sname);
    valid_idx = find(~cellfun(@isempty, entries));
    if isempty(valid_idx)
        warning('Sensore "%s": nessuna bag valida, salto il plot.', sname);
        continue;
    end

    fig = figure('name', sprintf('Bias stability across bags - %s', dname(sname)), ...
        'NumberTitle','off', 'Color','w', 'Position', [80 80 1100 750]);
    tl = tiledlayout(fig, 2, 1, 'TileSpacing','compact', 'Padding','compact');

    ax1 = nexttile(tl,1); hold(ax1,'on'); grid(ax1,'on');
    ax2 = nexttile(tl,2); hold(ax2,'on'); grid(ax2,'on');

    for jj = 1:numel(valid_idx)
        b = valid_idx(jj);
        d = entries{b};
        scatter(ax1, d.s_raw, d.bx_raw, 6, bag_colors(b,:), 'filled', ...
            'MarkerFaceAlpha', 0.12, 'MarkerEdgeColor', 'none', 'HandleVisibility', 'off');
        scatter(ax2, d.s_raw, d.by_raw, 6, bag_colors(b,:), 'filled', ...
            'MarkerFaceAlpha', 0.12, 'MarkerEdgeColor', 'none', 'HandleVisibility', 'off');
    end

    h_lines = gobjects(1, numel(valid_idx));
    h_names = cell(1, numel(valid_idx));
    for jj = 1:numel(valid_idx)
        b = valid_idx(jj);
        d = entries{b};
        h_lines(jj) = plot(ax1, d.sc, d.muX, '-', 'Color', bag_colors(b,:), 'LineWidth', 2.2, 'DisplayName', d.bag);
        plot(ax2, d.sc, d.muY, '-', 'Color', bag_colors(b,:), 'LineWidth', 2.2, 'DisplayName', d.bag);
        h_names{jj} = d.bag;
    end
    yline(ax1, 0, '-k', 'HandleVisibility','off');
    yline(ax2, 0, '-k', 'HandleVisibility','off');
    ylabel(ax1, 'b_x  [m]', 'Interpreter','tex');
    ylabel(ax2, 'b_y  [m]', 'Interpreter','tex'); xlabel(ax2, 's  [m]  (track position)');
    title(ax1, sprintf('%s: b_x(s) across bags', dname(sname)), 'Interpreter','tex');
    title(ax2, sprintf('%s: b_y(s) across bags', dname(sname)), 'Interpreter','tex');
    lg = legend(ax1, h_lines, h_names, 'Location','best', 'FontSize',9, 'Interpreter','none');
    try; lg.BoxFace.ColorType = 'truecoloralpha'; lg.BoxFace.ColorData = uint8([255;255;255;200]); catch; end
    linkaxes([ax1 ax2], 'x');
end

% ===================== consolidated table: all bags, per sensor =====================
if isempty(results)
    warning('Nessun fit disponibile: niente da stampare.');
else
    fprintf('\n========================================================================================\n');
    fprintf(' Heading-offset bias model (real ego heading) - all bags, per sensor\n');
    fprintf('========================================================================================\n');
    for si = 1:numel(sensors_to_check)
        sname = sensors_to_check{si};
        fprintf('\n--- %s ---\n', dname(sname));
        fprintf('%-45s %6s | %8s %8s | %8s %8s | %8s %8s\n', ...
            'bag', 'n', 'dX', 'dY', 'sraw_x', 'sres_x', 'sraw_y', 'sres_y');
        for k = 1:numel(results)
            r = results(k);
            if ~strcmp(r.sensor, sname); continue; end
            fprintf('%-45s %6d | %8.3f %8.3f | %8.3f %8.3f | %8.3f %8.3f\n', ...
                r.bag, r.n, r.dX, r.dY, r.sraw_x, r.sres_x, r.sraw_y, r.sres_y);
        end
    end
    fprintf('\ndX,dY        : world-frame heading-offset (constant vector, real ego heading).\n');
    fprintf('sraw_x/y     : std of the raw bias [m] (no model - "predict the mean").\n');
    fprintf('sres_x/y     : std of the bias left over [m] after subtracting the model''s heading-dependent\n');
    fprintf('               prediction. sres << sraw -> model explains a lot; sres ~ sraw -> explains little;\n');
    fprintf('               sres > sraw -> model is actively worse than the mean on that axis.\n\n');
    fprintf('Confronta dX,dY tra sensori (stesso segno/ampiezza per lidar/pp/radar = causa condivisa) e tra bag\n');
    fprintf('(stabili = vero offset di localizzazione; instabili = anomalia di sessione).\n\n');
end

% ===================== local helpers =====================

% Searches the given log struct (and, as a fallback, base/local workspace
% structs up to 3 levels deep) for one containing ALL of required_fields.
function L = locate_struct_with_fields(log, required_fields)
    L = [];
    cands = {};
    cands = collect_structs(cands, 'log', log, 0);
    try
        bn = evalin('base','who');
        for i = 1:numel(bn)
            try; v = evalin('base', bn{i}); catch; continue; end
            cands = collect_structs(cands, bn{i}, v, 0);
        end
    catch
    end
    for i = 1:size(cands,1)
        v = cands{i,2};
        ok = true;
        for f = 1:numel(required_fields)
            if ~isfield(v, required_fields{f}); ok = false; break; end
        end
        if ok; L = v; return; end
    end
end

function cands = collect_structs(cands, name, v, depth)
    if ~isstruct(v) || ~isscalar(v) || depth > 3; return; end
    cands(end+1,1:2) = {name, v}; %#ok<AGROW>
    fn = fieldnames(v);
    for k = 1:numel(fn)
        f = v.(fn{k});
        if isstruct(f) && isscalar(f)
            cands = collect_structs(cands, [name '.' fn{k}], f, depth+1);
        end
    end
end

% Raw (unsmoothed) GT-relative measurement error for a single sensor.
function [st, ex, ey, base] = local_raw_error(s, gt_t, gt_x, gt_y, skip_start_s, err_outlier)
    st = s.sens_stamp(:);
    mx = s.x_rel(:,1); my = s.y_rel(:,1);
    mx(mx<=-9999)=nan; my(my<=-9999)=nan;
    good = isfinite(st); st=st(good); mx=mx(good); my=my(good);
    [st,si]=sort(st); mx=mx(si); my=my(si);
    [st,iu]=unique(st,'stable'); mx=mx(iu); my=my(iu);
    t0 = gt_t(1);
    ex = mx - interp1(gt_t,gt_x,st,'linear',nan);
    ey = my - interp1(gt_t,gt_y,st,'linear',nan);
    base = isfinite(ex)&isfinite(ey)&(st-t0>=skip_start_s)&(abs(ex)<=err_outlier)&(abs(ey)<=err_outlier);
end

function mu = fold_stats(sf, b, edges)
    nb = numel(edges)-1; mu = nan(1,nb);
    for i = 1:nb
        if i<nb; m = sf>=edges(i) & sf<edges(i+1); else; m = sf>=edges(i) & sf<=edges(i+1); end
        if nnz(isfinite(b(m)))>5; mu(i) = mean(b(m),'omitnan'); end
    end
end

function theta = robust_solve(A, d)
    theta = A \ d;
    for it = 1:20
        r = d - A*theta;
        s = 1.4826 * median(abs(r - median(r)));
        if s < eps; break; end
        u = r ./ (4.685*s);
        w = (abs(u)<1) .* (1-u.^2).^2;
        W = sqrt(w);
        theta_new = (W.*A) \ (W.*d);
        if norm(theta_new-theta) < 1e-9*(1+norm(theta)); theta = theta_new; break; end
        theta = theta_new;
    end
end

function [ts,vs] = local_mono(t,v)
    ts=t(:); vs=v(:); g=isfinite(ts)&isfinite(vs); ts=ts(g); vs=vs(g);
    [ts,iu]=unique(ts,'stable'); vs=vs(iu); [ts,is]=sort(ts); vs=vs(is);
end