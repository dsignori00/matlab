%% Tuning della soglia sulla rolling-std (curve vs non-curve)
% Calcola la deviazione standard mobile (finestra N campioni) di accelerazione
% e jerk per l'opponent scelto, separa i campioni IN-curve da quelli OUT-curve
% e ne mostra percentili / istogrammi, per scegliere acc_std.
% La soglia "giusta" e' quella che separa le due popolazioni: sopra la coda
% out-curve (reietta gli outlier) ma sotto la massa in-curve (cattura l'onset).

opp = opp_idx;       % opponent da analizzare
N   = 25;            % finestra campioni (deve coincidere con quella del flag)

t = tt.stamp(:);
a = tt.ax(:, opp);

% --- maschera curve: map-based se disponibile, altrimenti da q_lambda ---
if isfield(tt, 'in_curve')
    ic = tt.in_curve;
    if size(ic, 2) >= opp, in_curve = ic(:, opp) > 0.5; else, in_curve = ic(:, 1) > 0.5; end
else
    in_curve = tt.q_lambda(:, opp) > 1.0 & ~isnan(tt.q_lambda(:, opp));
end

% --- jerk = derivata dell'accelerazione ---
dt_v = [median(diff(t), 'omitnan'); diff(t)];
dt_v(dt_v <= 0) = NaN;                       % protegge da timestamp duplicati/non monotoni
j = [0; diff(a)] ./ dt_v;

% --- rolling std (finestra centrata su N campioni) ---
sa = movstd(a, N, 'omitnan');                % std accelerazione [m/s^2]
sj = movstd(j, N, 'omitnan');                % std jerk          [m/s^3]

% --- separazione in / out curva ---
valid = ~isnan(a);
in_c  = in_curve  & valid;
out_c = ~in_curve & valid;

% =========================================================================
% Report a terminale + soglie candidate
% =========================================================================
fprintf('\n===== Rolling-std tuning - Opponent %d, N = %d =====\n', opp, N);
thr_a = report_std('acc  std [m/s^2]', sa, in_c, out_c);
thr_j = report_std('jerk std [m/s^3]', sj, in_c, out_c);

% =========================================================================
% FIGURA 1 - serie temporale della rolling-std + bande curva + soglia
% =========================================================================
figure('Name', 'Rolling-std vs time', 'NumberTitle', 'off');
ax1 = subplot(2,1,1); hold on; grid on;
plot(ax1, t(valid), sa(valid), 'b', 'LineWidth', 1.2);
yline(ax1, thr_a, '--r', sprintf('thr = %.3f', thr_a), 'LineWidth', 1.0);
ylabel(ax1, 'acc std [m/s^2]', 'Interpreter', 'none');
title(ax1, 'Rolling std - acceleration', 'Interpreter', 'none');
shade_curves(ax1, t, in_curve);

ax2 = subplot(2,1,2); hold on; grid on;
plot(ax2, t(valid), sj(valid), 'b', 'LineWidth', 1.2);
yline(ax2, thr_j, '--r', sprintf('thr = %.3f', thr_j), 'LineWidth', 1.0);
ylabel(ax2, 'jerk std [m/s^3]', 'Interpreter', 'none');
xlabel(ax2, 'Time [s]', 'Interpreter', 'none');
title(ax2, 'Rolling std - jerk', 'Interpreter', 'none');
shade_curves(ax2, t, in_curve);
linkaxes([ax1, ax2], 'x');

% =========================================================================
% FIGURA 2 - istogrammi in-curve vs out-curve
% =========================================================================
figure('Name', 'Rolling-std distributions', 'NumberTitle', 'off');
subplot(1,2,1);
hist_in_out(sa, in_c, out_c, thr_a, 'acc std [m/s^2]');
subplot(1,2,2);
hist_in_out(sj, in_c, out_c, thr_j, 'jerk std [m/s^3]');

% =========================================================================
function thr = report_std(name, s, in_c, out_c)
    si = s(in_c);  si = si(~isnan(si));
    so = s(out_c); so = so(~isnan(so));
    fprintf('\n--- %s ---\n', name);
    fprintf('            p50      p75      p90      p95      max     (n)\n');
    fprintf('in-curve : %8.3f %8.3f %8.3f %8.3f %8.3f  %6d\n', ...
        my_prctile(si,50), my_prctile(si,75), my_prctile(si,90), my_prctile(si,95), nanmax_(si), numel(si));
    fprintf('out-curve: %8.3f %8.3f %8.3f %8.3f %8.3f  %6d\n', ...
        my_prctile(so,50), my_prctile(so,75), my_prctile(so,90), my_prctile(so,95), nanmax_(so), numel(so));
    % soglia candidata: a meta' strada tra la coda out-curve (p90) e la massa in-curve (p50)
    thr = 0.5 * (my_prctile(so,90) + my_prctile(si,50));
    fprintf('-> soglia suggerita ~ %.3f  (meta'' tra p90 out e p50 in)\n', thr);
end

% =========================================================================
function hist_in_out(s, in_c, out_c, thr, name)
    si = s(in_c);  si = si(~isnan(si));
    so = s(out_c); so = so(~isnan(so));
    hold on; grid on;
    histogram(so, 'Normalization', 'probability', 'FaceColor', [0.4 0.4 0.4], 'EdgeColor', 'none', 'DisplayName', 'out-curve');
    histogram(si, 'Normalization', 'probability', 'FaceColor', [0.85 0.33 0.10], 'EdgeColor', 'none', 'DisplayName', 'in-curve');
    xline(thr, '--k', sprintf('thr = %.3f', thr), 'LineWidth', 1.0, 'HandleVisibility', 'off');
    xlabel(name, 'Interpreter', 'none'); ylabel('prob');
    legend('show', 'Interpreter', 'none');
end

% =========================================================================
function shade_curves(ax, t, mask)
    if ~any(mask), return; end
    yl = ylim(ax);
    d = diff([0; mask(:); 0]);
    starts = find(d ==  1);
    ends   = find(d == -1) - 1;
    for k = 1:numel(starts)
        t_s = t(starts(k));
        t_e = t(min(ends(k), numel(t)));
        patch(ax, [t_s t_e t_e t_s], [yl(1) yl(1) yl(2) yl(2)], [0.8 0.8 0.8], ...
            'FaceAlpha', 0.3, 'EdgeColor', 'none', 'HandleVisibility', 'off');
    end
end

% =========================================================================
function p = my_prctile(x, q)
% Percentile con interpolazione lineare (no Statistics Toolbox richiesto).
    x = x(~isnan(x));
    if isempty(x), p = NaN; return; end
    x = sort(x(:));
    n = numel(x);
    if n == 1, p = x; return; end
    pos  = (q/100) * (n - 1) + 1;
    lo   = floor(pos); hi = ceil(pos);
    frac = pos - lo;
    p = x(lo) * (1 - frac) + x(hi) * frac;
end

% =========================================================================
function m = nanmax_(x)
    x = x(~isnan(x));
    if isempty(x), m = NaN; else, m = max(x); end
end