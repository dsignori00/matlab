%% R_BIAS_TRACK_POSITION_TEST
% Tests whether the measurement bias b = lowpass(meas - GT) has a SPATIAL
% origin (map / localization error, fixed on the track) versus a TEMPORAL
% drift (reference / clock), by folding all laps onto the opponent's
% curvilinear track position s and checking lap-to-lap repeatability.
%
%   b(s) reproducible across laps        -> spatially fixed -> map/localization
%   b drifts in time, no structure in s  -> temporal drift  (GT/reference/clock)
%
% Also includes (added after review):
%  - FIG A: power spectrum of the RAW (unsmoothed) bias signal, to give an
%    actual basis for the drift_win_s low-pass window instead of an inherited,
%    unjustified value. Plus a console sensitivity sweep of the spatial R^2
%    across several candidate windows, to check robustness of the conclusion.
%  - FIG 2 now has a second row showing the ACTUAL residual (data - model),
%    binned over s, instead of relying on visual comparison between fitted
%    model curves (which had previously led to an overreaching interpretation
%    of "bumps" that were partly a model-curve artifact, not confirmed data
%    structure).
%
% Self-contained inside the pipeline: uses sensors, gt, opp_idx (already in
% scope) and auto-locates the raw log struct (the one with opponents__* fields).

has_gt = (exist('use_ref','var') && use_ref) || (exist('use_sim_ref','var') && use_sim_ref);
if ~has_gt
    warning('r_bias_track_position_test: ground truth required. Skipping.'); return;
end

% ---- parameters (consistent with r_bias_geometry_analysis) ----
r_field      = {'lidar','pp','radar','camera'};
geo_sensor   = 'lidar';
skip_start_s = 5; err_outlier = 3; drift_win_s = 20;
nbins_s      = 100;
sens_windows = [5 10 20 40 80];   % candidate windows [s] for the sensitivity sweep
psd_nseg     = 8;                  % Bartlett-averaging segments for the PSD estimate
if ~exist('opp_idx','var'); opp_idx = 1; end

% ---- auto-locate the raw log struct (search base + nested structs, depth<=3) ----
L = []; Lname = '';
cands = {};
try
    bn = evalin('base','who');
    for i=1:numel(bn)
        try; v = evalin('base', bn{i}); catch; continue; end
        cands = collect_structs(cands, bn{i}, v, 0);
    end
catch
end
ln = who;
for i=1:numel(ln)
    try; v = eval(ln{i}); catch; continue; end
    cands = collect_structs(cands, ln{i}, v, 0);
end
for i = 1:size(cands,1)
    v = cands{i,2};
    if isfield(v,'opponents__s') && (isfield(v,'stamp__tot') || isfield(v,'bag_stamp'))
        L = v; Lname = cands{i,1}; break;
    end
end
if isempty(L)
    paths = {};
    for i=1:size(cands,1)
        if isfield(cands{i,2},'opponents__s'); paths{end+1}=cands{i,1}; end %#ok<AGROW>
    end
    if ~isempty(paths)
        error('r_bias_track_position_test: found opponents__s but no time field, at: %s', strjoin(paths,', '));
    else
        error(['r_bias_track_position_test: could not find a struct with opponents__s ' ...
               'in base/local (searched 3 levels deep). Tell me the exact path, e.g. log.targets.']);
    end
end
if isfield(L,'stamp__tot'); t = L.stamp__tot(:); else; t = L.bag_stamp(:); end
fprintf('\n[track-position test] using log struct "%s", opponent slot %d.\n', Lname, opp_idx);

% ---- raw (UNSMOOTHED) measurement error for geo_sensor: ex = misura - GT ----
[gts, gtx] = local_mono(gt.stamp, gt.x_rel);
[~,   gty] = local_mono(gt.stamp, gt.y_rel);
bkg = find(strcmp(r_field, geo_sensor), 1);
if isempty(bkg) || numel(sensors) < bkg
    error('r_bias_track_position_test: geo_sensor "%s" not found in sensors{}.', geo_sensor);
end
[st_raw, ex_raw, ey_raw, base_raw] = local_raw_error(sensors{bkg}.s, gts, gtx, gty, skip_start_s, err_outlier);

% ---- opponent track position s + global position (masked correctly), interpolated
% onto the sensor's own (raw) time grid - independent of any smoothing window ----
s_raw_full = L.opponents__s(:,opp_idx);  s_raw_full(s_raw_full<=-9999) = nan;
ms_raw = squeeze(double(L.opponents__meas_stamp(:,opp_idx,:)));
valid_slot = isfinite(ms_raw) & ms_raw > 0;
xm = squeeze(double(L.opponents__meas_x_map(:,opp_idx,:)));
ym = squeeze(double(L.opponents__meas_y_map(:,opp_idx,:)));
xm(~valid_slot) = nan; ym(~valid_slot) = nan;
mx_full = mean(xm,2,'omitnan'); my_full = mean(ym,2,'omitnan');

s  = interp1(t, s_raw_full, st_raw, 'linear', nan);
gx = interp1(t, mx_full,    st_raw, 'linear', nan);
gy = interp1(t, my_full,    st_raw, 'linear', nan);

% ---- lap segmentation from wraps in s (s resets ~0 each lap) ----
track_len = max(s) - min(s);
ds   = [0; diff(s)];
wrap = ds < -0.5*track_len;       % big backward jump = new lap
lap  = cumsum(wrap);
s_fold = mod(s - min(s), track_len);
laps = unique(lap(isfinite(lap)));

lap_times = st_raw(wrap);
T_lap = median(diff(lap_times),'omitnan');   % rough lap period, for reference on the PSD plot

edges = linspace(0, track_len, nbins_s+1);
sc = 0.5*(edges(1:end-1)+edges(2:end));

% ---- main bias signal (the one analysed everywhere below): apply the chosen
% drift_win_s low-pass to the raw error ----
B = local_smooth_bias(st_raw, ex_raw, ey_raw, base_raw, drift_win_s);
bx = B.bx(:); by = B.by(:);

% ===================== FIG A: frequency content of the RAW bias (justifies drift_win_s) =====================
% NEW figure, separate question from the spatial test below: is there a
% principled basis for the 20 s low-pass window, or was it arbitrary?
% (It was arbitrary - inherited from the original script with no stated
% justification. This is the first attempt to check it properly.)
exc = ex_raw; exc(~base_raw) = nan;
eyc = ey_raw; eyc(~base_raw) = nan;
src_ok = isfinite(st_raw) & isfinite(exc);
dt_grid = median(diff(st_raw),'omitnan');
fs = 1/dt_grid;
tg = (min(st_raw(src_ok)) : dt_grid : max(st_raw(src_ok))).';
exg = interp1(st_raw(src_ok), exc(src_ok), tg, 'linear');
eyg = interp1(st_raw(isfinite(st_raw)&isfinite(eyc)), eyc(isfinite(st_raw)&isfinite(eyc)), tg, 'linear');

nseg = max(1, min(psd_nseg, floor(numel(tg)/200)));
[fpx, Px] = local_psd(exg, fs, nseg);
[fpy, Py] = local_psd(eyg, fs, nseg);

figure('name','Frequency content of the raw bias (justifies drift_win_s)','NumberTitle','off');
axP = subplot(1,1,1); hold(axP,'on'); grid(axP,'on'); set(axP,'XScale','log','YScale','log');
plot(axP, fpx(2:end), Px(2:end), 'LineWidth',1.4, 'DisplayName','PSD(e_x)  [raw, pre-smoothing]');
plot(axP, fpy(2:end), Py(2:end), 'LineWidth',1.4, 'DisplayName','PSD(e_y)  [raw, pre-smoothing]');
xline(axP, 1/drift_win_s, '--r', 'LineWidth',1.4, 'DisplayName', sprintf('current cutoff: 1/%ds = %.3f Hz', drift_win_s, 1/drift_win_s));
if isfinite(T_lap) && T_lap>0
    xline(axP, 1/T_lap, '--', 'Color',[0.49 0.18 0.56], 'LineWidth',1.4, 'DisplayName', sprintf('lap frequency: 1/%.0fs = %.3f Hz', T_lap, 1/T_lap));
end
xlabel(axP,'frequency [Hz]'); ylabel(axP,'PSD  [m^2/Hz]','Interpreter','tex');
title(axP, 'Raw bias spectrum: look for a knee separating low-freq drift from high-freq sensor noise');
legend(axP,'show','Location','southwest');

fprintf('\n[PSD] sensor native rate ~ %.1f Hz (dt=%.3fs),  lap period ~ %.1f s (%d laps)\n', fs, dt_grid, T_lap, numel(laps));
fprintf('  Inspect FIG A: if the spectrum is flat-ish above the red line and rises steeply below it,\n');
fprintf('  the current cutoff sits near a real knee. If the knee is visibly elsewhere, drift_win_s should move.\n');
fprintf('  This was NOT verified before - the 20s value was inherited from the original script, unjustified.\n\n');

% ---- sensitivity sweep: does the spatial R^2 conclusion depend on drift_win_s? ----
fprintf('[sensitivity sweep] spatial R^2 (b vs track position s) for different smoothing windows:\n');
for w = sens_windows
    Bw = local_smooth_bias(st_raw, ex_raw, ey_raw, base_raw, w);
    [~, R2xw] = fold_stats(s_fold, Bw.bx, edges);
    [~, R2yw] = fold_stats(s_fold, Bw.by, edges);
    fprintf('  win = %3d s :  R^2_x = %.2f   R^2_y = %.2f%s\n', w, R2xw, R2yw, ternary(w==drift_win_s,'   <- current default',''));
end
fprintf('  Stable R^2 across windows -> the spatial conclusion is robust to this choice.\n');
fprintf('  R^2 that collapses at short windows -> some of the "spatial" signal was actually high-freq noise\n');
fprintf('  being averaged out, not a real low-frequency drift; re-check with the PSD above.\n\n');

% ===================== FIG 1: bias on the global track =====================
ok = isfinite(gx) & isfinite(gy);
figure('name','Bias on the global track','NumberTitle','off');
ax1 = subplot(1,2,1);
scatter(ax1, gx(ok), gy(ok), 12, bx(ok), 'filled'); axis(ax1,'equal'); grid(ax1,'on');
colorbar(ax1); caxis(ax1, [-1 1]*max(0.2,prctile(abs(bx(ok)),95)));
xlabel(ax1,'x_{map} [m]','Interpreter','tex'); ylabel(ax1,'y_{map} [m]','Interpreter','tex');
title(ax1,'b_x on track','Interpreter','tex');
ax2 = subplot(1,2,2);
scatter(ax2, gx(ok), gy(ok), 12, by(ok), 'filled'); axis(ax2,'equal'); grid(ax2,'on');
colorbar(ax2); caxis(ax2, [-1 1]*max(0.2,prctile(abs(by(ok)),95)));
xlabel(ax2,'x_{map} [m]','Interpreter','tex'); ylabel(ax2,'y_{map} [m]','Interpreter','tex');
title(ax2,'b_y on track','Interpreter','tex');

% ===================== heading-offset + curvature models (used in FIG 2) =====================
[muX, R2x] = fold_stats(s_fold, bx, edges);
[muY, R2y] = fold_stats(s_fold, by, edges);

smooth_win_bins = 5;
xb = nan(1,nbins_s); yb = nan(1,nbins_s);
for i = 1:nbins_s
    if i<nbins_s; m = s_fold>=edges(i) & s_fold<edges(i+1); else; m = s_fold>=edges(i) & s_fold<=edges(i+1); end
    if nnz(isfinite(gx(m)) & isfinite(gy(m))) > 5
        xb(i) = mean(gx(m),'omitnan'); yb(i) = mean(gy(m),'omitnan');
    end
end
xb = fillmissing(xb,'linear','EndValues','nearest');
yb = fillmissing(yb,'linear','EndValues','nearest');
xb = circ_smooth(xb, smooth_win_bins);
yb = circ_smooth(yb, smooth_win_bins);

theta_bin_raw = atan2(gradient(yb), gradient(xb));
[cb, sb] = circ_smooth_angle(theta_bin_raw, smooth_win_bins);
theta_bin = atan2(sb, cb);

ds_bin = mean(diff(sc));
dtheta_bin = [angdiff(theta_bin(1), theta_bin(end)), arrayfun(@(i) angdiff(theta_bin(i-1),theta_bin(i)), 2:numel(theta_bin))];
kappa_bin = dtheta_bin ./ ds_bin;

cos_t   = interp1(sc, cb, s_fold, 'linear', 'extrap');
sin_t   = interp1(sc, sb, s_fold, 'linear', 'extrap');
kappa_t = interp1(sc, kappa_bin, s_fold, 'linear', 'extrap');
nrm = hypot(cos_t, sin_t); cos_t = cos_t./nrm; sin_t = sin_t./nrm;

okh = isfinite(bx) & isfinite(by) & isfinite(cos_t) & isfinite(sin_t);

% model 1: heading-offset only (2 parameters)
Ah = [ cos_t(okh),  sin_t(okh) ; -sin_t(okh),  cos_t(okh) ];
dh = [ bx(okh) ; by(okh) ];
dtheta = robust_solve(Ah, dh);
dX = dtheta(1); dY = dtheta(2);

bx_model_full = dX*cos_t + dY*sin_t;
by_model_full = -dX*sin_t + dY*cos_t;
R2x_head = local_r2(bx(okh), bx_model_full(okh));
R2y_head = local_r2(by(okh), by_model_full(okh));
[muXmod,  ~]  = fold_stats(s_fold, bx_model_full, edges);
[muYmod,  ~]  = fold_stats(s_fold, by_model_full, edges);
[muXres1, R2x_res]  = fold_stats(s_fold, bx - bx_model_full, edges);
[muYres1, R2y_res]  = fold_stats(s_fold, by - by_model_full, edges);

% model 2 (EXPLORATORY): heading-offset + curvature term (4 parameters)
n2 = nnz(okh);
kt = kappa_t(okh);
Ah2 = [ cos_t(okh), sin_t(okh), kt,            zeros(n2,1) ; ...
        -sin_t(okh), cos_t(okh), zeros(n2,1),  kt ];
p2 = robust_solve(Ah2, dh);
dX2 = p2(1); dY2 = p2(2); c1 = p2(3); c2 = p2(4);

bx_model2_full = dX2*cos_t + dY2*sin_t + c1*kappa_t;
by_model2_full = -dX2*sin_t + dY2*cos_t + c2*kappa_t;
R2x_curv = local_r2(bx(okh), bx_model2_full(okh));
R2y_curv = local_r2(by(okh), by_model2_full(okh));
[muXmod2,~] = fold_stats(s_fold, bx_model2_full, edges);
[muYmod2,~] = fold_stats(s_fold, by_model2_full, edges);
[muXres2, R2x_res2] = fold_stats(s_fold, bx - bx_model2_full, edges);
[muYres2, R2y_res2] = fold_stats(s_fold, by - by_model2_full, edges);

% ===================== FIG 2: laps folded onto s, + actual residual (2x2) =====================
figure('name','Lap-folded bias b(s)','NumberTitle','off');

axF1 = subplot(2,2,1); hold(axF1,'on'); grid(axF1,'on');
for li = laps.'
    m = lap==li & isfinite(s_fold) & isfinite(bx);
    if nnz(m)>10; plot(axF1, s_fold(m), bx(m), '.', 'Color',[.8 .8 .8], 'MarkerSize',3); end
end
plot(axF1, sc, muX, '-o', 'Color',[0.2 0.5 0.1], 'LineWidth',1.8, 'MarkerSize',3, 'DisplayName','binned mean');
plot(axF1, sc, muXmod, '-', 'Color',[0.85 0.33 0.10], 'LineWidth',1.6, 'DisplayName','heading-offset (2p)');
plot(axF1, sc, muXmod2, '-', 'Color',[0.49 0.18 0.56], 'LineWidth',1.6, 'DisplayName','heading+curvature (4p, exploratory)');
yline(axF1,0,'-k','HandleVisibility','off'); ylabel(axF1,'b_x [m]','Interpreter','tex');
title(axF1, sprintf('b_x  (spatial R^2=%.2f, heading R^2=%.2f, +curv R^2=%.2f)', R2x, R2x_head, R2x_curv),'Interpreter','tex','FontSize',9);
legend(axF1,'show','Location','best');

axF2 = subplot(2,2,2); hold(axF2,'on'); grid(axF2,'on');
for li = laps.'
    m = lap==li & isfinite(s_fold) & isfinite(by);
    if nnz(m)>10; plot(axF2, s_fold(m), by(m), '.', 'Color',[.8 .8 .8], 'MarkerSize',3); end
end
plot(axF2, sc, muY, '-o', 'Color',[0.2 0.5 0.1], 'LineWidth',1.8, 'MarkerSize',3, 'DisplayName','binned mean');
plot(axF2, sc, muYmod, '-', 'Color',[0.85 0.33 0.10], 'LineWidth',1.6, 'DisplayName','heading-offset (2p)');
plot(axF2, sc, muYmod2, '-', 'Color',[0.49 0.18 0.56], 'LineWidth',1.6, 'DisplayName','heading+curvature (4p, exploratory)');
yline(axF2,0,'-k','HandleVisibility','off'); ylabel(axF2,'b_y [m]','Interpreter','tex');
title(axF2, sprintf('b_y  (spatial R^2=%.2f, heading R^2=%.2f, +curv R^2=%.2f)', R2y, R2y_head, R2y_curv),'Interpreter','tex','FontSize',9);
legend(axF2,'show','Location','best');

% ---- actual residual (data - model), binned: this is the honest answer to
% "are there real localized features left", not a visual read of fitted curves ----
axF3 = subplot(2,2,3); hold(axF3,'on'); grid(axF3,'on');
plot(axF3, sc, muXres1, '-o', 'Color',[0.85 0.33 0.10], 'LineWidth',1.6, 'MarkerSize',3, 'DisplayName','residual after 2p model');
plot(axF3, sc, muXres2, '-o', 'Color',[0.49 0.18 0.56], 'LineWidth',1.6, 'MarkerSize',3, 'DisplayName','residual after 4p model');
yline(axF3,0,'-k','HandleVisibility','off'); ylabel(axF3,'b_x - model [m]','Interpreter','tex'); xlabel(axF3,'s within lap [m]');
title(axF3, sprintf('b_x residual  (spatial R^2: %.2f -> %.2f)', R2x, R2x_res2),'Interpreter','tex','FontSize',9);
legend(axF3,'show','Location','best');

axF4 = subplot(2,2,4); hold(axF4,'on'); grid(axF4,'on');
plot(axF4, sc, muYres1, '-o', 'Color',[0.85 0.33 0.10], 'LineWidth',1.6, 'MarkerSize',3, 'DisplayName','residual after 2p model');
plot(axF4, sc, muYres2, '-o', 'Color',[0.49 0.18 0.56], 'LineWidth',1.6, 'MarkerSize',3, 'DisplayName','residual after 4p model');
yline(axF4,0,'-k','HandleVisibility','off'); ylabel(axF4,'b_y - model [m]','Interpreter','tex'); xlabel(axF4,'s within lap [m]');
title(axF4, sprintf('b_y residual  (spatial R^2: %.2f -> %.2f)', R2y, R2y_res2),'Interpreter','tex','FontSize',9);
legend(axF4,'show','Location','best');

fprintf('  laps detected: %d,  track length ~ %.1f m\n', numel(laps), track_len);
fprintf('  spatial R^2 (variance of b explained by track position s):  b_x = %.2f,  b_y = %.2f\n', R2x, R2y);
fprintf('  HIGH R^2 -> bias fixed on the track -> map / localization error.\n');
fprintf('  LOW  R^2 -> no spatial structure   -> temporal drift (GT/reference/clock).\n\n');

fprintf('[heading-offset fit, 2p] world-frame offset:  dX = %+.3f m,  dY = %+.3f m   (|delta| = %.3f m)\n', dX, dY, hypot(dX,dY));
fprintf('  model R^2:  b_x = %.2f,  b_y = %.2f\n', R2x_head, R2y_head);
fprintf('  spatial R^2 of residual after removing the model:  b_x  %.2f -> %.2f   |   b_y  %.2f -> %.2f\n\n', ...
    R2x, R2x_res, R2y, R2y_res);

fprintf('[heading+curvature fit, 4p, EXPLORATORY] dX=%+.3f dY=%+.3f  c1=%+.3f c2=%+.3f  (c units: m^2)\n', dX2, dY2, c1, c2);
fprintf('  model R^2:  b_x = %.2f (was %.2f),  b_y = %.2f (was %.2f)\n', R2x_curv, R2x_head, R2y_curv, R2y_head);
fprintf('  spatial R^2 of residual after removing the model:  b_x  %.2f -> %.2f   |   b_y  %.2f -> %.2f\n', ...
    R2x, R2x_res2, R2y, R2y_res2);
fprintf('  Read FIG 2 bottom row directly: it is the actual (data - model) residual, binned over s -\n');
fprintf('  any peak there is real unexplained structure in the data, NOT an artifact of comparing two\n');
fprintf('  fitted curves by eye (that comparison previously overstated a "bump" that was partly a model\n');
fprintf('  artifact - see the residual panel for the corrected, direct answer).\n\n');

% ===================== helpers =====================
function out = ternary(cond, a, b)
    if cond; out = a; else; out = b; end
end

function [f, Pxx] = local_psd(x, fs, nseg)
    % Bartlett-averaged periodogram (Hann-windowed, non-overlapping segments).
    % No Signal Processing Toolbox dependency.
    x = x(:); x = x - mean(x,'omitnan');
    x(~isfinite(x)) = 0;
    N = numel(x);
    Lseg = floor(N/max(nseg,1));
    if Lseg < 8; Lseg = N; nseg = 1; end
    win = 0.5 - 0.5*cos(2*pi*(0:Lseg-1)'/(Lseg-1));
    U = mean(win.^2);
    nfft = floor(Lseg/2) + 1;
    Pacc = zeros(nfft,1); cnt = 0;
    for k = 1:nseg
        idx = (k-1)*Lseg + (1:Lseg);
        if idx(end) > N; break; end
        seg = x(idx) .* win;
        X = fft(seg);
        Xh = X(1:nfft);
        P = (abs(Xh).^2) / (fs*Lseg*U);
        P(2:end-1) = 2*P(2:end-1);
        Pacc = Pacc + P; cnt = cnt+1;
    end
    if cnt==0; Pacc = nan(nfft,1); cnt = 1; end
    Pxx = Pacc/cnt;
    f = (0:nfft-1).' * fs/Lseg;
end

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

function out = local_smooth_bias(st, ex, ey, base, drift_win_s)
    win_n = max(3, round(drift_win_s/max(median(diff(st),'omitnan'),eps)));
    exf=ex; exf(~base)=nan; eyf=ey; eyf(~base)=nan;
    out.st=st; out.bx=movmean(exf,win_n,'omitnan'); out.by=movmean(eyf,win_n,'omitnan');
end

function [mu, R2] = fold_stats(sf, b, edges)
    nb = numel(edges)-1; mu = nan(1,nb); bhat = nan(size(b));
    for i = 1:nb
        if i<nb; m = sf>=edges(i) & sf<edges(i+1); else; m = sf>=edges(i) & sf<=edges(i+1); end
        if nnz(isfinite(b(m)))>5; mu(i) = mean(b(m),'omitnan'); bhat(m) = mu(i); end
    end
    ok = isfinite(b) & isfinite(bhat);
    R2 = 1 - sum((b(ok)-bhat(ok)).^2) / sum((b(ok)-mean(b(ok))).^2);
end

function v = circ_smooth(v, win)
    n = numel(v); k = floor(win/2);
    vext = [v(end-k+1:end), v, v(1:k)];
    vs = movmean(vext, win);
    v = vs(k+1:k+n);
end

function [c, s] = circ_smooth_angle(theta, win)
    c = circ_smooth(cos(theta), win);
    s = circ_smooth(sin(theta), win);
    nrm = hypot(c,s); c = c./nrm; s = s./nrm;
end

function d = angdiff(a, b)
    d = atan2(sin(b-a), cos(b-a));
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

function r2 = local_r2(y, yhat)
    ok2 = isfinite(y) & isfinite(yhat); y = y(ok2); yhat = yhat(ok2);
    ss_res = sum((y-yhat).^2); ss_tot = sum((y-mean(y)).^2);
    if ss_tot<=0; r2 = nan; else; r2 = 1 - ss_res/ss_tot; end
end

function [ts,vs] = local_mono(t,v)
    ts=t(:); vs=v(:); g=isfinite(ts)&isfinite(vs); ts=ts(g); vs=vs(g);
    [ts,iu]=unique(ts,'stable'); vs=vs(iu); [ts,is]=sort(ts); vs=vs(is);
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