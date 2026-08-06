%% COVARIANCE_STD_ANALYSIS
% Compares the filter's estimated standard deviation (sqrt(P)) for velocity
% and acceleration between tt (baseline) and tt2 (e.g. higher Q), plus the
% real logged Kalman gain on acceleration (tt.K_a) if available.
%
% Diagonal indices in the tt.covariance tensor [N x n_opp x 36] (6x6 state,
% order [x, y, v, yaw, yaw_rate, a] confirmed by covariance.m):
%   15 -> P_vv   (velocity)
%   36 -> P_aa   (acceleration)
%
% FIGURE 1: rho_dot (context) + std(v) + std(a) over time, with the
%           maneuver window [WIN_T0, WIN_T1] highlighted.
% FIGURE 2: K_a (real Kalman gain on acceleration, from the log), same
%           maneuver window highlighted. Requires tt.K_a (opponents__k_a);
%           skipped otherwise.
%
% Both figures are added to the shared "axes" array (same convention used
% across the project, e.g. r_bias_cross_correlation.m, latency_delay.m) so
% that the final linkaxes(axes,'x') in the main script keeps them in sync
% with every other time plot.
%
% uses: tt, tt2, opp_idx, col, name1, name2, compare, gt, use_ref,
%       use_sim_ref, axes (optional)

if ~exist('axes','var'); axes = []; end %#ok<*NASGU>

legend_fontsize = 20; % legend font size (both figures) - raise/lower to taste

opp = opp_idx;

% --- parameters ---
WIN_T0 = 1042.0;   % [s] start of the window of interest
WIN_T1 = 1043.5;   % [s] end of the window of interest
IDX_V  = 15;        % P_vv diagonal index
IDX_A  = 36;        % P_aa diagonal index

if ~isfield(tt, 'covariance')
    warning('[covariance_std_analysis] tt.covariance not available. Requires a log with opponents__ekf_p.');
    return
end
if opp > tt.max_opp
    warning('[covariance_std_analysis] opp_idx (%d) > tt.max_opp (%d). Using opponent 1.', opp, tt.max_opp);
    opp = 1;
end

% --- P extraction (baseline) ---
std_v_tt = sqrt(max(tt.covariance(:, opp, IDX_V), 0));
std_a_tt = sqrt(max(tt.covariance(:, opp, IDX_A), 0));

has_tt2 = exist('tt2', 'var') && exist('compare', 'var') && compare && ...
          isfield(tt2, 'covariance');
if has_tt2
    opp2 = min(opp, tt2.max_opp);
    std_v_tt2 = sqrt(max(tt2.covariance(:, opp2, IDX_V), 0));
    std_a_tt2 = sqrt(max(tt2.covariance(:, opp2, IDX_A), 0));
end

% --- real Kalman gain on acceleration (K_a), only if logged ---
has_gain = isfield(tt, 'K_a');
if has_gain
    K_a_tt = tt.K_a(:, opp);
    gain_source = 'real (log: opponents__k_a)';
else
    K_a_tt = [];
    gain_source = 'not available (log missing opponents__k_a)';
end

has_gain2 = has_tt2 && isfield(tt2, 'K_a');
if has_gain2
    K_a_tt2 = tt2.K_a(:, opp2);
else
    K_a_tt2 = [];
end

fprintf('[covariance_std_analysis] Gain K_a: %s\n', gain_source);

% =========================================================================
% FIGURE 1 - std(v) and std(a) over time, with highlighted window
% =========================================================================
fig1 = figure('Name', 'Covariance Std - v & a', 'NumberTitle', 'off', 'Color', 'w');
tl1 = tiledlayout(fig1, 3, 1, 'TileSpacing', 'compact', 'Padding', 'compact');

% --- rho_dot for context (baseline, tt2, gt) ---
ax_rd = nexttile(tl1, 1); hold(ax_rd, 'on'); grid(ax_rd, 'on');
patch(ax_rd, [WIN_T0 WIN_T1 WIN_T1 WIN_T0], ...
    [min(ylim(ax_rd)) min(ylim(ax_rd)) max(ylim(ax_rd)) max(ylim(ax_rd))], ...
    [0.92 0.92 0.92], 'EdgeColor', 'none', 'HandleVisibility', 'off');
if isfield(tt, 'rho_dot')
    plot(ax_rd, tt.stamp, tt.rho_dot(:, opp), 'Color', col.tt, 'LineWidth', 1.3, ...
        'DisplayName', name1);
end
if has_tt2 && isfield(tt2, 'rho_dot')
    plot(ax_rd, tt2.stamp, tt2.rho_dot(:, opp2), 'Color', col.tt2, 'LineWidth', 1.3, ...
        'DisplayName', name2);
end
if exist('gt', 'var') && (use_ref || use_sim_ref) && isfield(gt, 'rho_dot')
    plot(ax_rd, gt.stamp, gt.rho_dot, 'Color', col.ref, 'LineWidth', 1.3, 'DisplayName', 'gt');
end
ylabel(ax_rd, 'rho dot [m/s]', 'Interpreter', 'none');
title(ax_rd, sprintf('Context: rho dot (Opponent %d)', opp), 'Interpreter', 'none');

% --- std(v) ---
ax_v = nexttile(tl1, 2); hold(ax_v, 'on'); grid(ax_v, 'on');
plot(ax_v, tt.stamp, std_v_tt, 'Color', col.tt, 'LineWidth', 1.3, 'DisplayName', name1);
if has_tt2
    plot(ax_v, tt2.stamp, std_v_tt2, 'Color', col.tt2, 'LineWidth', 1.3, 'DisplayName', name2);
end
yl = ylim(ax_v);
patch(ax_v, [WIN_T0 WIN_T1 WIN_T1 WIN_T0], [yl(1) yl(1) yl(2) yl(2)], ...
    [0.92 0.92 0.92], 'FaceAlpha', 0.5, 'EdgeColor', 'none', 'HandleVisibility', 'off');
uistack(findobj(ax_v, 'Type', 'patch'), 'bottom');
ylabel(ax_v, 'std(v) [m/s]', 'Interpreter', 'none');
title(ax_v, 'Estimated standard deviation on velocity (sqrt(P_{vv}))', 'Interpreter', 'none');

% --- std(a) ---
ax_a = nexttile(tl1, 3); hold(ax_a, 'on'); grid(ax_a, 'on');
plot(ax_a, tt.stamp, std_a_tt, 'Color', col.tt, 'LineWidth', 1.3, 'DisplayName', name1);
if has_tt2
    plot(ax_a, tt2.stamp, std_a_tt2, 'Color', col.tt2, 'LineWidth', 1.3, 'DisplayName', name2);
end
yl = ylim(ax_a);
patch(ax_a, [WIN_T0 WIN_T1 WIN_T1 WIN_T0], [yl(1) yl(1) yl(2) yl(2)], ...
    [0.92 0.92 0.92], 'FaceAlpha', 0.5, 'EdgeColor', 'none', 'HandleVisibility', 'off');
uistack(findobj(ax_a, 'Type', 'patch'), 'bottom');
ylabel(ax_a, 'std(a) [m/s^2]', 'Interpreter', 'none');
xlabel(ax_a, 'timestamp [s]', 'Interpreter', 'none');
title(ax_a, 'Estimated standard deviation on acceleration (sqrt(P_{aa}))', 'Interpreter', 'none');

% single shared legend, bottom of the tile layout (same style as
% r_bias_cross_correlation.m), instead of one legend per subplot
lg1 = legend(ax_rd, 'Orientation', 'horizontal', 'NumColumns', 3, 'FontSize', legend_fontsize);
lg1.Layout.Tile = 'south';

linkaxes([ax_rd, ax_v, ax_a], 'x');
xlim(ax_rd, [tt.stamp(1), tt.stamp(end)]);

% add to the shared time-axes list so it stays linked with every other
% figure in the pipeline (TargetTrackingAnalysis.m does linkaxes(axes,'x'))
axes(end+1) = ax_rd; %#ok<SAGROW>
axes(end+1) = ax_v;  %#ok<SAGROW>
axes(end+1) = ax_a;  %#ok<SAGROW>

% =========================================================================
% FIGURE 2 - Kalman gain on acceleration (K_a), separate figure
% =========================================================================
if has_gain
    fig2 = figure('Name', 'Covariance Std - Gain', 'NumberTitle', 'off', 'Color', 'w');
    tl2 = tiledlayout(fig2, 1, 1, 'TileSpacing', 'compact', 'Padding', 'compact');

    ax_ka = nexttile(tl2, 1); hold(ax_ka, 'on'); grid(ax_ka, 'on');
    plot(ax_ka, tt.stamp, K_a_tt, 'Color', col.tt, 'LineWidth', 1.3, 'DisplayName', name1);
    if has_gain2
        plot(ax_ka, tt2.stamp, K_a_tt2, 'Color', col.tt2, 'LineWidth', 1.3, 'DisplayName', name2);
    end
    yl = ylim(ax_ka);
    patch(ax_ka, [WIN_T0 WIN_T1 WIN_T1 WIN_T0], [yl(1) yl(1) yl(2) yl(2)], ...
        [0.92 0.92 0.92], 'FaceAlpha', 0.5, 'EdgeColor', 'none', 'HandleVisibility', 'off');
    uistack(findobj(ax_ka, 'Type', 'patch'), 'bottom');
    ylabel(ax_ka, 'K_a  [-]', 'Interpreter', 'tex');
    xlabel(ax_ka, 'timestamp [s]', 'Interpreter', 'none');
    title(ax_ka, 'Kalman gain on acceleration (how much each velocity innovation corrects the acceleration estimate)', ...
        'Interpreter', 'none');

    lg2 = legend(ax_ka, 'Orientation', 'horizontal', 'NumColumns', 2, 'FontSize', legend_fontsize);
    lg2.Layout.Tile = 'south';

    linkaxes([ax_rd, ax_ka], 'x');
    axes(end+1) = ax_ka; %#ok<SAGROW>
end

% =========================================================================
% TERMINAL STATISTICS - inside vs outside the window of interest
% =========================================================================
mask_win = tt.stamp >= WIN_T0 & tt.stamp <= WIN_T1;
mask_out = ~mask_win;

fprintf('\n--- Covariance Std Analysis (Opponent %d) ---\n', opp);
fprintf('Window of interest: [%.2f, %.2f] s\n', WIN_T0, WIN_T1);
fprintf('%-12s | %-10s %-10s | %-10s %-10s\n', 'log', 'std(v) win', 'std(v) out', 'std(a) win', 'std(a) out');
fprintf('%-12s | %-10.3f %-10.3f | %-10.3f %-10.3f\n', name1, ...
    mean(std_v_tt(mask_win), 'omitnan'), mean(std_v_tt(mask_out), 'omitnan'), ...
    mean(std_a_tt(mask_win), 'omitnan'), mean(std_a_tt(mask_out), 'omitnan'));
if has_tt2
    mask_win2 = tt2.stamp >= WIN_T0 & tt2.stamp <= WIN_T1;
    mask_out2 = ~mask_win2;
    fprintf('%-12s | %-10.3f %-10.3f | %-10.3f %-10.3f\n', name2, ...
        mean(std_v_tt2(mask_win2), 'omitnan'), mean(std_v_tt2(mask_out2), 'omitnan'), ...
        mean(std_a_tt2(mask_win2), 'omitnan'), mean(std_a_tt2(mask_out2), 'omitnan'));

    ratio_v = mean(std_v_tt2(mask_win2), 'omitnan') / mean(std_v_tt(mask_win), 'omitnan');
    ratio_a = mean(std_a_tt2(mask_win2), 'omitnan') / mean(std_a_tt(mask_win), 'omitnan');
    fprintf('\nStd ratio in the window (tt2 / tt): v = %.2fx | a = %.2fx\n', ratio_v, ratio_a);
end

if has_gain
    fprintf('\n--- Gain K_a (real, from log) ---\n');
    fprintf('%-12s | K_a mean (window) | K_a mean (outside)\n', 'log');
    fprintf('%-12s | %-18.3f | %-.3f\n', name1, ...
        mean(K_a_tt(mask_win), 'omitnan'), mean(K_a_tt(mask_out), 'omitnan'));
    if has_gain2
        fprintf('%-12s | %-18.3f | %-.3f\n', name2, ...
            mean(K_a_tt2(mask_win2), 'omitnan'), mean(K_a_tt2(mask_out2), 'omitnan'));
        fprintf('K_a ratio in the window (tt2/tt): %.2fx\n', ...
            mean(K_a_tt2(mask_win2), 'omitnan') / mean(K_a_tt(mask_win), 'omitnan'));
    end
else
    fprintf('\nK_a not available (log missing opponents__k_a).\n');
end
fprintf('-----------------------------------------------\n');