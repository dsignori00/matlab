%% INNOVATION FLAG
% FIGURE 1 - subplot 1: acceleration - GT a_x vs filter a_x (tt.ax)
%          - subplot 2: raw vs filtered rho_dot innovation (logged directly
%                        by the filter, opponents__innovation_rho_dot_meas
%                        and opponents__innovation_rho_dot_filtered)
%
% Requires in workspace: tt, gt, log, col (opt.), opp_idx (opt.)
% (no log.estimation needed - no radar measurement reconstruction here)

plot_col = 1;
if exist('opp_idx', 'var'); plot_col = opp_idx; end

po = log.perception__opponents;

%% ===================================================================
%% Raw vs filtered rho_dot innovation (logged directly by the filter)
%% ===================================================================
innov_raw = [];
innov_filt = [];

if isfield(po, 'opponents__innovation_rho_dot_meas')
    innov_raw = mask_sentinel(po.opponents__innovation_rho_dot_meas(:,plot_col));
    fprintf('DEBUG: innovation_rho_dot_meas -> %d non-NaN\n', nnz(~isnan(innov_raw)));
else
    warning('innovation_flag: opponents__innovation_rho_dot_meas not found.');
end

if isfield(po, 'opponents__innovation_rho_dot_filtered')
    innov_filt = mask_sentinel(po.opponents__innovation_rho_dot_filtered(:,plot_col));
    fprintf('DEBUG: innovation_rho_dot_filtered -> %d non-NaN\n', nnz(~isnan(innov_filt)));
else
    warning('innovation_flag: opponents__innovation_rho_dot_filtered not found.');
end

%% ===================================================================
%% FIGURE 1: acceleration + rho_dot innovation
%% ===================================================================
figure('Name', 'Acceleration + rho_dot innovation (raw vs filtered)', 'NumberTitle', 'off', 'Position', [80 80 1400 900]);
tl1 = tiledlayout(2,1, 'TileSpacing', 'compact', 'Padding', 'compact');

ax1 = nexttile(tl1); hold on; grid on; box on;
plot(gt.stamp, gt.ax, 'k-', 'LineWidth', 1.5, 'DisplayName', 'GT a_x');
plot(tt.stamp, tt.ax(:,plot_col), '-', 'Color', [0.2 0.4 0.8], 'LineWidth', 1.2, 'DisplayName', 'filter a_x');
xlabel('time [s]', 'Interpreter', 'tex', 'FontSize', 8);
ylabel('a_x [m/s^2]', 'Interpreter', 'tex');
title('Acceleration: GT vs filter', 'Interpreter', 'tex');
legend('show', 'Location', 'southoutside', 'Orientation', 'horizontal', 'Box', 'off', 'FontSize', 10, 'Interpreter', 'tex');

ax2 = nexttile(tl1); hold on; grid on; box on;
if ~isempty(innov_raw)
    plot(tt.stamp, innov_raw, '.', 'MarkerSize', 5, 'Color', [0.85 0.10 0.10], 'DisplayName', 'innovation (raw)');
end
if ~isempty(innov_filt)
    plot(tt.stamp, innov_filt, '.', 'MarkerSize', 5, 'Color', [0.10 0.45 0.85], 'DisplayName', 'innovation (filtered)');
end
yline(0, 'k:', 'HandleVisibility', 'off');
yline(0.2, '--', 'Color', [0.4 0.4 0.4], 'LineWidth', 1.2, 'DisplayName', 'fixed level 0.2');
xlabel('time [s]', 'Interpreter', 'tex', 'FontSize', 8);
ylabel('rho_{dot} innovation', 'Interpreter', 'tex');
title('rho_{dot} innovation: raw vs filtered', 'Interpreter', 'tex');
legend('show', 'Location', 'southoutside', 'Orientation', 'horizontal', 'Box', 'off', 'FontSize', 10, 'Interpreter', 'tex');

linkaxes([ax1, ax2], 'x');

%% ===================== local functions =====================
function v = mask_sentinel(v)
% MASK_SENTINEL  Zeroes out "no data" placeholders (0 and sentinel <=
% -9999), replacing them with NaN, same convention used across the pipeline.
    v = double(v);
    v(v == 0) = nan;
    v(v <= -9999) = nan;
end