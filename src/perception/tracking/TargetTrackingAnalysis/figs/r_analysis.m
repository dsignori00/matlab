%% R_ANALYSIS
% One figure per sensor with adaptive R (diagonal only) and INNOVATION.
% NB: R in the RELATIVE frame. Sentinel samples (<= -9999) are set to NaN
% in pick_opp -> not plotted.
%
% FIGURE 1 (per sensor): adaptive R + raw innovation (original plot)
% FIGURE 2 (per sensor): consistency check — innovation scatter with
%   +/-sigma and +/-2sigma bands derived from the adaptive R. If R is well estimated,
%   ~68% of innovations fall within +/-sigma and ~95% within +/-2sigma.
%   This shows that the adaptive R is consistent with the innovations (what
%   it is designed for), separating this result from the low-frequency bias
%   problem that the innovations cannot see.
% FIGURE 3: PSD of innovations per sensor (x and y components) to assess
%   whether error energy is concentrated at low or high frequency, and
%   whether adaptive R makes sense for each sensor.
%
% uses: tt, opp_idx, x_lim, axes

if ~exist('axes','var'); axes = []; end

sens_list  = {'lidar','pp','radar','camera'};
sens_disp  = {'lidar clustering','lidar point pillars','radar','camera'};

comp_lab  = {'R_x_x (1,1)','R_x_y (1,2)','R_y_x (2,1)','R_y_y (2,2)'};

% plot style (mirrors r_error_analysis.m)
c_sig  = [0 0 0.55];    % banda +/-1sigma
c_2sig = [0 0.45 1];    % banda +/-2sigma
leg_fs = 10;
smooth_win = 3;          % light smoothing on sigma bands to reduce visual noise

% ---------- FIGURE 1 per sensor: adaptive R + raw innovation (original) ----------
for k = 1:numel(sens_list)
    s = sens_list{k};
    if ~isfield(tt,'R') || ~isfield(tt.R, s); continue; end

    figure('Name', ['R / innov - ' sens_disp{k}], 'NumberTitle', 'off', 'Color', 'w');
    R     = pick_opp(tt, 'R',     s, opp_idx);
    Innov = pick_opp(tt, 'innov', s, opp_idx);

    % keep only R diagonals: R_xx (1,1) and R_yy (2,2)
    diag_idx = [1 4];
    if size(R,2) >= 4
        R = R(:, diag_idx);
        R_lab = comp_lab(diag_idx);
    else
        R_lab = comp_lab;
    end

    ax1 = subplot(2,1,1); hold(ax1,'on'); grid(ax1,'on');
    plot(ax1, tt.stamp, R, 'LineWidth', 1, 'Marker', '.', 'MarkerSize', 4);
    ylabel(ax1, 'R  [m^2]', 'Interpreter', 'tex');
    title(ax1, ['Adaptive R - ' sens_disp{k}], 'Interpreter', 'none');
    add_comp_legend(R, R_lab, leg_fs);
    axes(end+1) = ax1; %#ok<SAGROW>

    ax2 = subplot(2,1,2); hold(ax2,'on'); grid(ax2,'on');
    plot(ax2, tt.stamp, Innov, 'LineWidth', 1, 'Marker', '.', 'MarkerSize', 4);
    ylabel(ax2, 'innovation  [m]', 'Interpreter', 'tex');
    xlabel(ax2, 't  [s]');
    title(ax2, 'Innovation');
    add_comp_legend(Innov, comp_lab, leg_fs);
    axes(end+1) = ax2; %#ok<SAGROW>

    linkaxes([ax1 ax2], 'x');
    if exist('x_lim','var') && all(isfinite(x_lim)); xlim(ax1, x_lim); end
end

% ---------- FIGURE 2 per sensor: consistency check innovations vs R ----------
for k = 1:numel(sens_list)
    s   = sens_list{k};
    col = sensors{k}.col;

    if ~isfield(tt,'R')     || ~isfield(tt.R,     s); continue; end
    if ~isfield(tt,'innov') || ~isfield(tt.innov, s); continue; end

    R_full = pick_opp(tt, 'R',     s, opp_idx);
    Innov  = pick_opp(tt, 'innov', s, opp_idx);

    % R diagonals
    if size(R_full,2) >= 4
        R_xx = R_full(:,1); R_yy = R_full(:,4);
    elseif size(R_full,2) == 2
        R_xx = R_full(:,1); R_yy = R_full(:,2);
    else
        warning('Sensor %s: unrecognized R format, skipping consistency check.', s);
        continue;
    end

    % sigma with light smoothing (reduces visual zigzag in the bands)
    sigma_x = sqrt(max(R_xx, 0));
    sigma_y = sqrt(max(R_yy, 0));
    if smooth_win > 1
        sigma_x = movmedian(sigma_x, smooth_win, 'omitnan');
        sigma_y = movmedian(sigma_y, smooth_win, 'omitnan');
    end

    % innovations
    if size(Innov,2) >= 2
        inn_x = Innov(:,1);
        inn_y = Innov(:,2);
    else
        warning('Sensor %s: scalar innovation, skipping consistency check.', s);
        continue;
    end

    % valid sample masks (excludes floor and NaN)
    ok_x = isfinite(inn_x) & isfinite(sigma_x) & sigma_x > 1e-4;
    ok_y = isfinite(inn_y) & isfinite(sigma_y) & sigma_y > 1e-4;

    % coverage percentages
    pct1x = 100 * mean(abs(inn_x(ok_x)) <= 1*sigma_x(ok_x));
    pct2x = 100 * mean(abs(inn_x(ok_x)) <= 2*sigma_x(ok_x));
    pct1y = 100 * mean(abs(inn_y(ok_y)) <= 1*sigma_y(ok_y));
    pct2y = 100 * mean(abs(inn_y(ok_y)) <= 2*sigma_y(ok_y));

    fig = figure('Name', sprintf('Consistency check innov vs R - %s', sens_disp{k}), ...
        'NumberTitle', 'off', 'Color', 'w', 'Position', [80 80 1100 600]);
    tl = tiledlayout(fig, 2, 1, 'Padding', 'compact', 'TileSpacing', 'compact');

    % --- x component ---
    ax_x = nexttile(tl, 1); hold(ax_x, 'on'); grid(ax_x, 'on');

    plot(ax_x, tt.stamp(ok_x), inn_x(ok_x), '.', 'Color', col, 'MarkerSize', 9, ...
        'DisplayName', sprintf('%s  innov x', sens_disp{k}));

    plot(ax_x, tt.stamp,  sigma_x, '-', 'Color', c_sig,  'LineWidth', 1.3, ...
        'DisplayName', '\pm\sigma');
    plot(ax_x, tt.stamp, -sigma_x, '-', 'Color', c_sig,  'LineWidth', 1.3, ...
        'HandleVisibility', 'off');
    plot(ax_x, tt.stamp,  2*sigma_x, '-', 'Color', c_2sig, 'LineWidth', 1.0, ...
        'DisplayName', '\pm2\sigma');
    plot(ax_x, tt.stamp, -2*sigma_x, '-', 'Color', c_2sig, 'LineWidth', 1.0, ...
        'HandleVisibility', 'off');

    yline(ax_x, 0, '--k', 'LineWidth', 0.8, 'HandleVisibility', 'off');
    ylabel(ax_x, 'innov x  [m]', 'Interpreter', 'tex');
    title(ax_x, sprintf('%s   innov x     1\\sigma %.0f%%     2\\sigma %.0f%%     (theoretical 68%% / 95%%)', ...
        sens_disp{k}, pct1x, pct2x), 'Interpreter', 'tex');
    lg = legend(ax_x, 'show', 'Location', 'northeast', 'FontSize', leg_fs, ...
        'Orientation', 'horizontal', 'NumColumns', 2, 'Interpreter', 'tex');
    try; lg.BoxFace.ColorType = 'truecoloralpha'; lg.BoxFace.ColorData = uint8([255;255;255;200]); catch; end

    % --- y component ---
    ax_y = nexttile(tl, 2); hold(ax_y, 'on'); grid(ax_y, 'on');

    plot(ax_y, tt.stamp(ok_y), inn_y(ok_y), '.', 'Color', col, 'MarkerSize', 9, ...
        'DisplayName', sprintf('%s  innov y', sens_disp{k}));

    plot(ax_y, tt.stamp,  sigma_y, '-', 'Color', c_sig,  'LineWidth', 1.3, ...
        'DisplayName', '\pm\sigma');
    plot(ax_y, tt.stamp, -sigma_y, '-', 'Color', c_sig,  'LineWidth', 1.3, ...
        'HandleVisibility', 'off');
    plot(ax_y, tt.stamp,  2*sigma_y, '-', 'Color', c_2sig, 'LineWidth', 1.0, ...
        'DisplayName', '\pm2\sigma');
    plot(ax_y, tt.stamp, -2*sigma_y, '-', 'Color', c_2sig, 'LineWidth', 1.0, ...
        'HandleVisibility', 'off');

    yline(ax_y, 0, '--k', 'LineWidth', 0.8, 'HandleVisibility', 'off');
    ylabel(ax_y, 'innov y  [m]', 'Interpreter', 'tex');
    xlabel(ax_y, 't  [s]');
    title(ax_y, sprintf('innov y     1\\sigma %.0f%%     2\\sigma %.0f%%     (theoretical 68%% / 95%%)', ...
        pct1y, pct2y), 'Interpreter', 'tex');
    lg = legend(ax_y, 'show', 'Location', 'northeast', 'FontSize', leg_fs, ...
        'Orientation', 'horizontal', 'NumColumns', 2, 'Interpreter', 'tex');
    try; lg.BoxFace.ColorType = 'truecoloralpha'; lg.BoxFace.ColorData = uint8([255;255;255;200]); catch; end

    sgtitle(tl, sprintf('%s — consistency check: innovations vs adaptive R bands', sens_disp{k}), ...
        'FontWeight', 'bold', 'FontSize', 12, 'Interpreter', 'none');

    linkaxes([ax_x ax_y], 'x');
    if exist('x_lim','var') && all(isfinite(x_lim)); xlim(ax_x, x_lim); end

    axes(end+1) = ax_x; %#ok<SAGROW>
    axes(end+1) = ax_y; %#ok<SAGROW>

    % stampa a console
    fprintf('\n[%s] consistency innov vs adaptive R:\n', sens_disp{k});
    fprintf('  x:  1sigma = %.1f%%   2sigma = %.1f%%   (theoretical 68%% / 95%%)\n', pct1x, pct2x);
    fprintf('  y:  1sigma = %.1f%%   2sigma = %.1f%%   (theoretical 68%% / 95%%)\n', pct1y, pct2y);
end


% ---------- FIGURE 3: Moving mean of measurement error — all sensors ----------
% Plots the local mean of the measurement error over time for all sensors
% in a single figure (2 subplots: x and y). A slowly-varying mean indicates
% a low-frequency bias that adaptive R cannot capture.

if ~exist('gt', 'var') || ~isfield(gt, 'x_map') || ~isfield(gt, 'stamp')
    warning('[R_analysis] gt not available: moving mean figure skipped.');
else

[gt_stamp_u, gt_ui] = unique(gt.stamp);
gt_xmap_u = gt.x_map(gt_ui);
gt_ymap_u = gt.y_map(gt_ui);

pos_thr  = 5.0;
v_thr    = 2.0;
win_s    = 60.0;   % moving mean window [s]

figure('Name', 'Moving mean of measurement error - all sensors', ...
    'NumberTitle', 'off', 'Color', 'w', 'Position', [100 100 1200 900]);
tl_mm = tiledlayout(3, 1, 'Padding', 'compact', 'TileSpacing', 'compact');

ax_mx = nexttile(tl_mm, 1); hold(ax_mx, 'on'); grid(ax_mx, 'on');
yline(ax_mx, 0, '--k', 'LineWidth', 0.8, 'HandleVisibility', 'off');
ylabel(ax_mx, 'mean(e_x)  [m]', 'Interpreter', 'tex');
title(ax_mx, sprintf('Local mean of x error  (win = %.0fs)', win_s), 'Interpreter', 'none');

ax_my = nexttile(tl_mm, 2); hold(ax_my, 'on'); grid(ax_my, 'on');
yline(ax_my, 0, '--k', 'LineWidth', 0.8, 'HandleVisibility', 'off');
ylabel(ax_my, 'mean(e_y)  [m]', 'Interpreter', 'tex');
title(ax_my, sprintf('Local mean of y error  (win = %.0fs)', win_s), 'Interpreter', 'none');

ax_mrd = nexttile(tl_mm, 3); hold(ax_mrd, 'on'); grid(ax_mrd, 'on');
yline(ax_mrd, 0, '--k', 'LineWidth', 0.8, 'HandleVisibility', 'off');
ylabel(ax_mrd, 'mean(e_{\rho_{dot}})  [m/s]', 'Interpreter', 'tex');
xlabel(ax_mrd, 't  [s]');
title(ax_mrd, sprintf('Local mean of \\rho_{dot} error — radar only  (win = %.0fs)', win_s), 'Interpreter', 'tex');

for k = 1:numel(sens_list)
    s_struct = sensors{k}.s;
    col_k    = sensors{k}.col;
    is_radar_k = strcmp(sensors{k}.name, 'radar');

    if ~isfield(s_struct, 'x_map') || ~isfield(s_struct, 'y_map'); continue; end
    if ~isfield(s_struct, 'sens_stamp'); continue; end

    t_s = s_struct.sens_stamp(:);
    xm  = s_struct.x_map(:, min(opp_idx, size(s_struct.x_map, 2)));
    ym  = s_struct.y_map(:, min(opp_idx, size(s_struct.y_map, 2)));
    xm(xm == 0) = NaN;
    ym(ym == 0) = NaN;

    % compute error only where sensor has a valid detection
    valid_det = isfinite(xm) & isfinite(ym) & isfinite(t_s);

    t_valid  = t_s(valid_det);
    xm_valid = xm(valid_det);
    ym_valid = ym(valid_det);
    [t_valid, ui] = unique(t_valid);
    xm_valid = xm_valid(ui);
    ym_valid = ym_valid(ui);

    % interpolate gt only at valid detection timestamps
    gt_x = interp1(gt_stamp_u, gt_xmap_u, t_valid, 'linear', NaN);
    gt_y = interp1(gt_stamp_u, gt_ymap_u, t_valid, 'linear', NaN);
    ex = xm_valid - gt_x;
    ey = ym_valid - gt_y;

    % position gating
    gate_pos = hypot(ex, ey) < pos_thr & isfinite(ex) & isfinite(ey);

    % velocity gating (radar only)
    gate_vel = true(size(t_valid));
    if is_radar_k && isfield(s_struct, 'rho_dot') && isfield(gt, 'rho_dot')
        rd_meas = s_struct.rho_dot(:, min(opp_idx, size(s_struct.rho_dot, 2)));
        rd_meas(rd_meas == 0) = NaN;
        rd_valid = rd_meas(valid_det); rd_valid = rd_valid(ui);
        gt_rd    = interp1(gt_stamp_u, gt.rho_dot(gt_ui), t_valid, 'linear', NaN);
        e_rd     = rd_valid - gt_rd;
        gate_vel = abs(e_rd) < v_thr | isnan(e_rd);
    end

    gate = gate_pos & gate_vel;
    t_g  = t_valid(gate);
    ex_g = ex(gate);
    ey_g = ey(gate);
    [t_g, ug] = unique(t_g);
    ex_g = ex_g(ug); ey_g = ey_g(ug);

    if numel(t_g) < 10; continue; end

    [t_mx, mean_x] = sliding_mean(t_g, ex_g, win_s);
    [t_my, mean_y] = sliding_mean(t_g, ey_g, win_s);

    plot(ax_mx, t_mx, mean_x, '-', 'Color', col_k, 'LineWidth', 1.6, 'DisplayName', sens_disp{k});
    plot(ax_my, t_my, mean_y, '-', 'Color', col_k, 'LineWidth', 1.6, 'DisplayName', sens_disp{k});

    % rho_dot for radar only
    if is_radar_k && isfield(s_struct, 'rho_dot') && isfield(gt, 'rho_dot')
        gate_rd = gate & isfinite(e_rd);
        t_rd_g  = t_valid(gate_rd);
        e_rd_g  = e_rd(gate_rd);
        [t_rd_g, ur] = unique(t_rd_g); e_rd_g = e_rd_g(ur);
        if numel(t_rd_g) >= 10
            [t_mrd, mean_rd] = sliding_mean(t_rd_g, e_rd_g, win_s);
            plot(ax_mrd, t_mrd, mean_rd, '-', 'Color', col_k, 'LineWidth', 1.6, 'DisplayName', 'radar');
        end
    end
end

legend(ax_mx,  'show', 'Location', 'best', 'FontSize', leg_fs, 'Interpreter', 'none');
legend(ax_my,  'show', 'Location', 'best', 'FontSize', leg_fs, 'Interpreter', 'none');
legend(ax_mrd, 'show', 'Location', 'best', 'FontSize', leg_fs, 'Interpreter', 'none');
linkaxes([ax_mx ax_my ax_mrd], 'x');

sgtitle(tl_mm, sprintf('Moving mean of measurement error (win = %.0fs) — low-frequency bias analysis', win_s), ...
    'FontWeight', 'bold', 'FontSize', 12, 'Interpreter', 'none');

end % gt guard
% ===================== local helpers =====================
function v = pick_opp(tt, field, s, opp_idx)
    d = tt.(field).(s);
    if ndims(d) == 3
        v = squeeze(d(:, opp_idx, :));
    else
        v = d(:, opp_idx);
    end
    v = mask_sentinel(v);
end

function v = mask_sentinel(v)
    v(v <= -9999) = NaN;
end

function add_comp_legend(v, comp_lab, leg_fs)
    K = size(v,2);
    if K > 1
        if nargin > 1 && numel(comp_lab) >= K
            lg = legend(comp_lab(1:K), 'Location', 'best', 'Interpreter', 'tex');
        else
            lg = legend(arrayfun(@(i) sprintf('comp %d', i), 1:K, 'uni', 0), 'Location', 'best');
        end
        if nargin >= 3 && ~isempty(leg_fs); lg.FontSize = leg_fs; end
        try; lg.BoxFace.ColorType = 'truecoloralpha'; lg.BoxFace.ColorData = uint8([255;255;255;200]); catch; end
    end
end

% =========================================================================
function [t_out, mean_out] = sliding_mean(t, x, win_s)
% Compute local mean in a sliding window of duration win_s [s].
% For each sample i, takes all samples within [t(i)-win_s/2, t(i)+win_s/2].
    n = numel(t);
    t_out    = zeros(n, 1);
    mean_out = zeros(n, 1);
    half     = win_s / 2;
    valid    = false(n, 1);
    for i = 1:n
        in_win = x(t >= t(i)-half & t <= t(i)+half);
        if numel(in_win) >= 3
            t_out(i)    = t(i);
            mean_out(i) = mean(in_win);
            valid(i)    = true;
        end
    end
    t_out    = t_out(valid);
    mean_out = mean_out(valid);
end