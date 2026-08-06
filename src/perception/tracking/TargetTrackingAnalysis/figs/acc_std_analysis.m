%#ok<*UNRCH>
%#ok<*INUSD>

%% Acceleration vs Velocity Flag Comparison
% Compares maneuver detection based on:
%   1. std(a)  - sliding std of acceleration   (current C++ implementation)
%   2. dV      - velocity range over window     (velocity-based alternative)
%   3. curve   - map-based curve index flag

opp     = opp_idx;
col_ref = col;

% --- parameters ---
ACC_STD_THR    = 1.0;   % [m/s^2] threshold for std(a) flag
ACC_STD_WINDOW = 10;    % window for std(a) [samples]
DV_THR         = 2.0;   % [m/s] threshold for delta-v flag
DV_WINDOW      = 10;    % window for delta-v [samples]
FILTER_HZ      = 20;    % nominal filter frequency [Hz]

% Curve segments (same as ComputeLambda in C++)
CURVE_BUFFER   = 50;
TRAJ_LEN       = 5901;
curve_segments = [166, 789; 2300, 2700; 4800, 5030; 5350, 5587];

% --- extract acceleration + velocity + trajectory index ---
t_all = tt.stamp;
a_all = tt.ax(:, opp);
v_all = tt.vx(:, opp);
valid = ~isnan(a_all) & ~isnan(v_all);
t_v   = t_all(valid);
a_v   = a_all(valid);
v_v   = v_all(valid);

has_idx = isfield(tt, 'closest_idx');
if has_idx
    idx_all = tt.closest_idx(1:end, opp);
    idx_v   = idx_all(valid);
end

[t_v, uidx] = unique(t_v, 'stable');
a_v = a_v(uidx);
v_v = v_v(uidx);
if has_idx; idx_v = idx_v(uidx); end

if numel(a_v) < max(ACC_STD_WINDOW, DV_WINDOW)
    warning('[acc_std_analysis] Not enough valid samples.'); return
end

% --- resample to uniform grid ---
dt = 1 / FILTER_HZ;
[a_rs, t_rs] = resample(a_v, t_v, FILTER_HZ);
v_rs = resample(v_v, t_v, FILTER_HZ);
N = numel(a_rs);

if has_idx
    idx_rs = round(interp1(t_v, double(idx_v), t_rs, 'linear', 'extrap'));
    idx_rs = min(max(idx_rs, 1), TRAJ_LEN);
end

% --- compute indicators ---
acc_std = movstd(a_rs, ACC_STD_WINDOW, 1);   % population std of a

% delta-v: velocity range (max - min) over sliding window
acc_dv  = zeros(N, 1);
half_dv = floor(DV_WINDOW / 2);
for k = 1:N
    i1  = max(1, k - half_dv);
    i2  = min(N, k + half_dv);
    seg = v_rs(i1:i2);
    acc_dv(k) = max(seg) - min(seg);
end

% --- flags ---
flag_std = acc_std > ACC_STD_THR;
flag_dv  = acc_dv  > DV_THR;
flag_curve = false(N, 1);
if has_idx
    for s = 1:size(curve_segments,1)
        buf_start = max(1,        curve_segments(s,1) - CURVE_BUFFER);
        buf_end   = min(TRAJ_LEN, curve_segments(s,2) + CURVE_BUFFER);
        flag_curve = flag_curve | (idx_rs >= buf_start & idx_rs <= buf_end);
    end
else
    warning('[acc_std_analysis] closest_idx not in tt. Curve flag disabled.');
end

% AND flags (actual C++ logic)
flag_std_and = flag_std & flag_curve;
flag_dv_and  = flag_dv  & flag_curve;

% console stats
fprintf('\n--- Acc vs Vel Flag Comparison (Opponent %d) ---\n', opp);
fprintf('Resampled: %d Hz\n', FILTER_HZ);
fprintf('std(a)  - win=%d (%.2fs)  thr=%.2f  flag ON: %.1f%%   AND curve: %.1f%%\n', ...
    ACC_STD_WINDOW, ACC_STD_WINDOW*dt, ACC_STD_THR, 100*mean(flag_std), 100*mean(flag_std_and));
fprintf('dV      - win=%d (%.2fs)  thr=%.2f  flag ON: %.1f%%   AND curve: %.1f%%\n', ...
    DV_WINDOW, DV_WINDOW*dt, DV_THR, 100*mean(flag_dv), 100*mean(flag_dv_and));
fprintf('curve   - flag ON: %.1f%%\n', 100*mean(flag_curve));
fprintf('------------------------------------------------\n');

% =========================================================================
%  FIGURE 1 — signals with both indicators
% =========================================================================
figure('Name', 'Acc vs Vel - Signals', 'NumberTitle', 'off');
tiledlayout(4, 1, 'Padding', 'compact');

% --- velocity ---
ax_v = nexttile; hold on; grid on;
plot(t_rs, v_rs, 'Color', col_ref.tt, 'LineWidth', 1.5, 'DisplayName', 'vx');
if exist('gt','var') && (use_ref || use_sim_ref)
    plot(gt.stamp, gt.vx, 'Color', col_ref.ref, 'DisplayName', 'gt');
end
ylabel('vx [m/s]', 'Interpreter', 'none');
title(sprintf('Velocity  (Opponent %d)', opp), 'Interpreter', 'none');
legend('show', 'Interpreter', 'none', 'Location', 'northeast');

% --- acceleration ---
ax_a = nexttile; hold on; grid on;
plot(t_rs, a_rs, 'Color', col_ref.tt, 'LineWidth', 1.5, 'DisplayName', 'ax');
if exist('gt','var') && (use_ref || use_sim_ref)
    plot(gt.stamp, gt.ax, 'Color', col_ref.ref, 'DisplayName', 'gt');
end
ylabel('ax [m/s^2]', 'Interpreter', 'none');
title('Acceleration', 'Interpreter', 'none');
legend('show', 'Interpreter', 'none', 'Location', 'northeast');

% --- std(a) ---
ax_std = nexttile; hold on; grid on;
plot(t_rs, acc_std, 'Color', col_ref.tt2, 'LineWidth', 1.5, ...
    'DisplayName', sprintf('std(a) win=%d', ACC_STD_WINDOW));
yline(ACC_STD_THR, '--k', 'LineWidth', 1.2, 'HandleVisibility', 'off');
text(t_rs(round(end*0.98)), ACC_STD_THR*1.08, sprintf('thr=%.2f', ACC_STD_THR), ...
    'Interpreter', 'none', 'FontSize', 8, 'HorizontalAlignment', 'right');
ylabel('std(a) [m/s^2]', 'Interpreter', 'none');
title('Sliding std of acceleration', 'Interpreter', 'none');
legend('show', 'Interpreter', 'none', 'Location', 'northeast');

% --- delta-v ---
ax_dv = nexttile; hold on; grid on;
plot(t_rs, acc_dv, 'Color', col_ref.tt3, 'LineWidth', 1.5, ...
    'DisplayName', sprintf('dV win=%d', DV_WINDOW));
yline(DV_THR, '--k', 'LineWidth', 1.2, 'HandleVisibility', 'off');
text(t_rs(round(end*0.98)), DV_THR*1.08, sprintf('thr=%.2f', DV_THR), ...
    'Interpreter', 'none', 'FontSize', 8, 'HorizontalAlignment', 'right');
ylabel('dV [m/s]', 'Interpreter', 'none');
xlabel('Time [s]', 'Interpreter', 'none');
title('Velocity range over window', 'Interpreter', 'none');
legend('show', 'Interpreter', 'none', 'Location', 'northeast');

linkaxes([ax_v, ax_a, ax_std, ax_dv], 'x');
axes = [axes, ax_v, ax_a, ax_std, ax_dv]; %#ok<AGROW>

% =========================================================================
%  FIGURE 2 — flag comparison (one row per flag)
% =========================================================================
figure('Name', 'Acc vs Vel - Flag Comparison', 'NumberTitle', 'off');
ax_flag = gca;
hold on; grid on;

flags      = {flag_std,    flag_dv,     flag_curve,      flag_std_and,    flag_dv_and};
flag_cols  = {col_ref.tt2, col_ref.tt3, [0.85 0.1 0.1],  [0.4 0.0 0.6],   [0.0 0.4 0.4]};
flag_names = {sprintf('std(a) (thr=%.2f)', ACC_STD_THR), ...
              sprintf('dV (thr=%.2f)', DV_THR), ...
              'curve index', ...
              'std AND curve', ...
              'dV AND curve'};
y_pos = [1, 2, 3, 4, 5];

for f = 1:5
    flg   = flags{f};
    col_f = flag_cols{f};
    yp    = y_pos(f);

    patch(ax_flag, [t_rs(1) t_rs(end) t_rs(end) t_rs(1)], ...
        [yp-0.4 yp-0.4 yp+0.4 yp+0.4], ...
        [0.92 0.92 0.92], 'EdgeColor','none', 'HandleVisibility','off');

    d      = diff([0; flg(:); 0]);
    starts = find(d ==  1);
    ends   = find(d == -1) - 1;
    for k = 1:numel(starts)
        t_s = t_rs(starts(k));
        t_e = t_rs(min(ends(k), numel(t_rs)));
        patch(ax_flag, [t_s t_e t_e t_s], [yp-0.4 yp-0.4 yp+0.4 yp+0.4], ...
            col_f, 'FaceAlpha', 0.85, 'EdgeColor','none', 'HandleVisibility','off');
    end

    fill(ax_flag, NaN, NaN, col_f, 'FaceAlpha', 0.85, 'EdgeColor','none', ...
        'DisplayName', flag_names{f});
end

ylim([0.4 5.6]);
yticks(y_pos);
yticklabels(flag_names);
xlabel('Time [s]', 'Interpreter','none');
title('Flag comparison  |  std(a)  vs  dV', 'Interpreter','none');
legend('show', 'Interpreter','none', 'Location','northeast');

axes = [axes, ax_flag]; %#ok<AGROW>