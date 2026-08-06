%% JERK_ANALYSIS
%
% Computes the a-posteriori residual (innovation proxy) between
% sensor measurements and EKF estimated state, and uses it to
% trigger a Q boost flag.
%
% Residual: e = z - x_hat  (measurement - corrected state)
% Flag:     ||e|| > n_sigma * sigma_res  ->  Q boost
%
% Layout (4 stacked subplots, linked x-axis):
%   1) EKF state x_rel vs measurements
%   2) Residual norm ||e|| + threshold + flag regions
%   3) Decay multiplier m_flag
%   4) Opponent GT: vx and ax

% ----------------------------------------------------------------
% Parameters
% ----------------------------------------------------------------
opp_col     = 1;      % column index for main opponent
n_sigma     = 3.0;    % flag threshold in sigma units
alpha_decay = 0.90;   % exponential decay per sample
smooth_win  = 5;      % smoothing window for residual [samples]
pos_thr_res = 30.0;   % loose position gate to remove garbage [m]

% ----------------------------------------------------------------
% EKF estimated state
% ----------------------------------------------------------------
t_ekf   = log.perception__opponents.stamp__tot(:);
x_rel_h = log.perception__opponents.opponents__x_rel(:, opp_col);
y_rel_h = log.perception__opponents.opponents__y_rel(:, opp_col);

valid_ekf = ~isnan(x_rel_h) & ~isnan(y_rel_h) & ~isnan(t_ekf) & ...
            (x_rel_h ~= 0 | y_rel_h ~= 0);

t_ekf   = t_ekf(valid_ekf);
x_rel_h = x_rel_h(valid_ekf);
y_rel_h = y_rel_h(valid_ekf);

[t_ekf, ui_e] = unique(t_ekf);
x_rel_h = x_rel_h(ui_e);
y_rel_h = y_rel_h(ui_e);

% ----------------------------------------------------------------
% Measurements — pick sensor with most valid samples
% ----------------------------------------------------------------
best_n   = 0;
best_sid = 0;
for kk = 1:numel(sensors)
    if strcmp(sensors{kk}.name, 'camera'); continue; end
    ss   = sensors{kk}.s;
    n_ok = sum(~isnan(ss.x_rel(:,1)) & ...
               hypot(ss.x_rel(:,1), ss.y_rel(:,1)) < pos_thr_res & ...
               hypot(ss.x_rel(:,1), ss.y_rel(:,1)) > 0);
    if n_ok > best_n
        best_n   = n_ok;
        best_sid = kk;
    end
end

fprintf('Using sensor: %s  (%d valid samples)\n', sensors{best_sid}.name, best_n);

ss_meas = sensors{best_sid}.s;
t_meas  = ss_meas.sens_stamp(:);
x_meas  = ss_meas.x_rel(:, 1);
y_meas  = ss_meas.y_rel(:, 1);

valid_m = ~isnan(x_meas) & ~isnan(y_meas) & ~isnan(t_meas) & ...
          hypot(x_meas, y_meas) < pos_thr_res & ...
          hypot(x_meas, y_meas) > 0;

t_meas = t_meas(valid_m);
x_meas = x_meas(valid_m);
y_meas = y_meas(valid_m);

[t_meas, ui_m] = unique(t_meas);
x_meas = x_meas(ui_m);
y_meas = y_meas(ui_m);

% ----------------------------------------------------------------
% Interpolate EKF state at measurement timestamps
% ----------------------------------------------------------------
in_range = t_meas >= t_ekf(1) & t_meas <= t_ekf(end);
t_meas   = t_meas(in_range);
x_meas   = x_meas(in_range);
y_meas   = y_meas(in_range);

x_hat_at_meas = interp1(t_ekf, x_rel_h, t_meas, 'linear', nan);
y_hat_at_meas = interp1(t_ekf, y_rel_h, t_meas, 'linear', nan);

% ----------------------------------------------------------------
% Residual norm
% ----------------------------------------------------------------
res_x    = x_meas - x_hat_at_meas;
res_y    = y_meas - y_hat_at_meas;
res_norm = hypot(res_x, res_y);

valid_r  = ~isnan(res_norm);
t_res    = t_meas(valid_r);
res_norm = res_norm(valid_r);

res_sm    = movmean(res_norm, smooth_win);
sigma_res = std(res_norm, 'omitnan');
thr_res   = n_sigma * sigma_res;

fprintf('Residual sigma = %.3f m,  threshold = %.3f m  (%.0f sigma)\n', ...
    sigma_res, thr_res, n_sigma);

% ----------------------------------------------------------------
% Exponential decay flag
% ----------------------------------------------------------------
n_res  = numel(t_res);
m_flag = zeros(n_res, 1);

for i = 2:n_res
    trigger   = res_sm(i) / thr_res;
    m_flag(i) = min(1, max(trigger, alpha_decay * m_flag(i-1)));
end

flag_on = m_flag > 0.5;

fprintf('Flag ON: %d / %d samples  (%.1f%%)\n', ...
    sum(flag_on), n_res, sum(flag_on)/n_res*100);

% ----------------------------------------------------------------
% GT opponent
% ----------------------------------------------------------------
t_gt  = gt.stamp(:);
vx_gt = gt.vx(:);
ax_gt = gt.ax(:);

valid_g      = ~isnan(vx_gt) & ~isnan(t_gt);
t_gt         = t_gt(valid_g);
vx_gt        = vx_gt(valid_g);
ax_gt        = ax_gt(valid_g);
[t_gt, ui_g] = unique(t_gt);
vx_gt        = vx_gt(ui_g);
ax_gt        = ax_gt(ui_g);

% ----------------------------------------------------------------
% Figure
% ----------------------------------------------------------------
scr   = get(0, 'ScreenSize');
fig_w = min(1200, scr(3) - 80);
fig_h = 800;

figure('Name', 'Innovation-based Q boost flag', ...
       'Color', 'w', ...
       'Position', [(scr(3)-fig_w)/2  (scr(4)-fig_h)/2  fig_w  fig_h]);

tl = tiledlayout(4, 1, 'Padding', 'compact', 'TileSpacing', 'tight');

col_state = [0.0  0.45 0.74];
col_meas  = [0.93 0.50 0.19];
col_res   = [0.85 0.33 0.10];
col_flag  = [0.93 0.69 0.13];
col_opp   = [0.47 0.67 0.19];
col_ax    = [0.64 0.08 0.18];
col_pflag = [0.5  0.0  0.5 ];

t_min = max(t_res(1),   t_gt(1));
t_max = min(t_res(end), t_gt(end));

%% ---- Subplot 1: EKF state vs measurements ----
ax1 = nexttile;
hold(ax1,'on'); grid(ax1,'on'); box(ax1,'on');

ja_fill(ax1, t_res, flag_on, col_flag, 0.20);

plot(ax1, t_ekf, x_rel_h, '-', 'Color', col_state, 'LineWidth', 1.4, ...
    'DisplayName', 'x_{rel}  EKF');
plot(ax1, t_meas, x_meas, '.', 'Color', col_meas, 'MarkerSize', 4, ...
    'DisplayName', 'x_{rel}  meas');

ylabel(ax1, 'x_{rel}  [m]', 'Interpreter','tex', 'FontSize', 10);
legend(ax1, 'show', 'Location','best', 'Interpreter','tex', 'FontSize', 8);
xlim(ax1, [t_min, t_max]);
xticklabels(ax1, {});

%% ---- Subplot 2: Residual norm ----
ax2 = nexttile;
hold(ax2,'on'); grid(ax2,'on'); box(ax2,'on');

ja_fill(ax2, t_res, flag_on, col_flag, 0.20);

plot(ax2, t_res, res_norm, '.', 'Color', [col_res 0.25], ...
    'MarkerSize', 3, 'HandleVisibility','off');
plot(ax2, t_res, res_sm, '-', 'Color', col_res, 'LineWidth', 1.8, ...
    'DisplayName', '||e||  smoothed');

yline(ax2, thr_res, '--', 'Color', [0.2 0.2 0.2], 'LineWidth', 1.3, ...
    'Label', sprintf('%.0f\\sigma = %.2f m', n_sigma, thr_res), ...
    'Interpreter','tex', 'LabelVerticalAlignment','bottom', ...
    'HandleVisibility','off');

ylabel(ax2, '||e||  [m]', 'Interpreter','tex', 'FontSize', 10);
legend(ax2, 'show', 'Location','best', 'Interpreter','tex', 'FontSize', 8);
xlim(ax2, [t_min, t_max]);
ylim(ax2, [0, max(thr_res*3, max(res_sm)*1.1)]);
xticklabels(ax2, {});

%% ---- Subplot 3: Decay multiplier ----
ax3 = nexttile;
hold(ax3,'on'); grid(ax3,'on'); box(ax3,'on');

ja_fill(ax3, t_res, flag_on, col_flag, 0.20);

plot(ax3, t_res, m_flag, '-', 'Color', col_pflag, 'LineWidth', 1.8, ...
    'DisplayName', 'm_{flag}');
yline(ax3, 0.5, '--', 'Color', [0.3 0.3 0.3], 'LineWidth', 1.1, ...
    'Label', 'flag thr', 'Interpreter','none', ...
    'LabelVerticalAlignment','bottom', 'HandleVisibility','off');

ylabel(ax3, 'm_{flag}  [-]', 'Interpreter','tex', 'FontSize', 10);
legend(ax3, 'show', 'Location','best', 'Interpreter','tex', 'FontSize', 8);
xlim(ax3, [t_min, t_max]);
ylim(ax3, [0, 1.15]);
xticklabels(ax3, {});

%% ---- Subplot 4: GT opponent vx and ax ----
ax4 = nexttile;
hold(ax4,'on'); grid(ax4,'on'); box(ax4,'on');

flag_on_gt = interp1(t_res, double(flag_on), t_gt, 'nearest', 0) > 0.5;
ja_fill(ax4, t_gt, flag_on_gt, col_flag, 0.20);

plot(ax4, t_gt, vx_gt, '-', 'Color', col_opp, 'LineWidth', 1.6, ...
    'DisplayName', 'v_{opp}  (GT)');

yyaxis(ax4, 'right');
plot(ax4, t_gt, ax_gt, '-', 'Color', col_ax, 'LineWidth', 1.2, ...
    'DisplayName', 'a_{opp}  (GT)');
yline(ax4, 0, '-', 'Color', [0.6 0.6 0.6], 'LineWidth', 0.8, ...
    'HandleVisibility','off');
ylabel(ax4, 'a_{opp}  [m/s^2]', 'Interpreter','tex', 'FontSize', 10, ...
    'Color', col_ax);
ax4.YAxis(2).Color = col_ax;

yyaxis(ax4, 'left');
ylabel(ax4, 'v_{opp}  [m/s]', 'Interpreter','tex', 'FontSize', 10);
xlabel(ax4, 't  [s]', 'FontSize', 10);
legend(ax4, 'show', 'Location','best', 'Interpreter','tex', 'FontSize', 8);
xlim(ax4, [t_min, t_max]);

linkaxes([ax1, ax2, ax3, ax4], 'x');

sgtitle(tl, sprintf('Innovation-based Q boost  —  thr = %.0f\\sigma = %.2f m,  decay = %.2f', ...
    n_sigma, thr_res, alpha_decay), ...
    'FontSize', 12, 'FontWeight', 'bold', 'Interpreter', 'tex');


%% ================================================================
function ja_fill(ax, t, flag, col, alpha_val)
% JA_FILL  Fills background where flag == true.
    if ~any(flag); return; end
    yl   = ylim(ax);
    span = abs(yl(2) - yl(1));
    y_lo = yl(1) - span;
    y_hi = yl(2) + span;
    d      = diff([0; flag(:); 0]);
    starts = find(d ==  1);
    ends   = find(d == -1) - 1;
    for i = 1:numel(starts)
        t0 = t(starts(i));
        t1 = t(min(ends(i), numel(t)));
        fill(ax, [t0 t1 t1 t0], [y_lo y_lo y_hi y_hi], col, ...
            'FaceAlpha', alpha_val, 'EdgeColor', 'none', ...
            'HandleVisibility', 'off');
    end
end