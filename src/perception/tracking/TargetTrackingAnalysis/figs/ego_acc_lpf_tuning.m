%% ego_acc_lpf_tuning.m
% Tuning del passabasso del primo ordine su |ax| dell'EGO (proxy per
% pilotare un gonfiamento adattivo della Q in feed-forward sull'EKF opponent).
%
% Il LPF del primo ordine su |ax| E' gia' la media mobile esponenziale:
%   ax_f[k] = a*|ax[k]| + (1-a)*ax_f[k-1],   a = dt/(tau+dt)
% a regime converge alla media di |ax| con memoria ~tau. Niente media mobile
% separata: tau piccolo -> reattivo ma rumoroso, tau grande -> liscio/ritardato.
%
% Sorgente ego: log.estimation (campo estimations.ax / estimation__ax).
% Lancialo come gli altri blocchi di plotting.

% --- parametri ---
taus = [0.05 0.15 0.20 0.50 1.00];   % costanti di tempo da confrontare [s]

% --- estrazione ego ax da log.estimation (gestisce nomi possibili) ---
est = log.estimation;
if isfield(est, 'estimation__ax')
    ax_ego = double(est.estimation__ax(:));
elseif isfield(est, 'ax')
    ax_ego = double(est.ax(:));
elseif isfield(est, 'estimations__ax')
    ax_ego = double(est.estimations__ax(:));
else
    fn = fieldnames(est);
    hit = fn(contains(fn, 'ax', 'IgnoreCase', true));
    if isempty(hit)
        error('Campo ax non trovato in log.estimation. Campi: %s', strjoin(fn, ', '));
    end
    warning('Uso il campo "%s" da log.estimation', hit{1});
    ax_ego = double(est.(hit{1})(:));
end

% --- timestamp ego ---
if isfield(est, 'stamp__tot')
    t = double(est.stamp__tot(:));
elseif isfield(est, 'stamp')
    t = double(est.stamp(:));
else
    fn = fieldnames(est);
    hit = fn(contains(fn, 'stamp', 'IgnoreCase', true));
    t = double(est.(hit{1})(:));
end

% allinea lunghezze per sicurezza
n = min(numel(t), numel(ax_ego));
t = t(1:n); ax_ego = ax_ego(1:n);

% asse temporale relativo
t0 = t(find(isfinite(ax_ego), 1, 'first'));
trel = t - t0;

% segnale di lavoro: valore assoluto
abs_ax = abs(ax_ego);

% --- dt mediano ---
dt_vec = diff(t);
dt = median(dt_vec(dt_vec > 0 & isfinite(dt_vec)), 'omitnan');

% --- filtraggio per ogni tau ---
nT = numel(taus);
ax_f     = nan(numel(abs_ax), nT);   % |ax| filtrato -> media / trigger
ax_f_sgn = nan(numel(ax_ego), nT);   % ax con segno filtrato -> confronto subplot 1
for j = 1:nT
    ax_f(:, j)     = lpf_first_order_nan(abs_ax, dt, taus(j));
    ax_f_sgn(:, j) = lpf_first_order_nan(ax_ego, dt, taus(j));
end

% =====================================================================
f = f + 1;
figure(f); clf;
set(gcf, 'Name', 'Ego |a_x| LPF tuning');
cmap = lines(nT);

% --- (1) ax CON SEGNO grezza vs ax CON SEGNO filtrata: seguo le manovre? ---
% Confronto a parita' di segno: ax di partenza e ax filtrata con gli stessi
% tau. Se la filtrata segue accelerate/frenate senza ritardo eccessivo ->
% tau ok; se appiattisce o ritarda i picchi -> tau troppo grande.
axh1 = subplot(3,1,1); hold on; grid on;
plot(trel, ax_ego, '-', 'Color', [0.55 0.55 0.55], 'DisplayName', 'a_x raw');
for j = 1:nT
    plot(trel, ax_f_sgn(:, j), '-', 'LineWidth', 1.4, 'Color', cmap(j,:), ...
        'DisplayName', sprintf('\tau=%.2fs', taus(j)));
end
yline(0, '-k', 'HandleVisibility', 'off');
ylabel('a_x  [m/s^2]', 'Interpreter', 'tex');
title('a_x grezza vs filtrata (con segno)', 'FontSize', 10);
legend('show', 'Location', 'northeast', 'FontSize', 7, 'Box', 'on', ...
    'Color', 'w', 'EdgeColor', [0.4 0.4 0.4], ...
    'Orientation', 'horizontal', 'NumColumns', 3);

% --- (2) |ax| grezza vs media esponenziale (=LPF) ---
axh2 = subplot(3,1,2); hold on; grid on;
plot(trel, abs_ax, '-', 'Color', [0.7 0.7 0.7], 'DisplayName', '|a_x| raw');
for j = 1:nT
    plot(trel, ax_f(:, j), '-', 'LineWidth', 1.4, 'Color', cmap(j,:), ...
        'DisplayName', sprintf('\tau=%.2fs', taus(j)));
end
ylabel('|a_x|  [m/s^2]', 'Interpreter', 'tex');
title('|a_x| grezza vs media filtrata (LPF 1° ordine)', 'FontSize', 10);

% --- (3) solo le medie + soglia di esempio per il trigger Q ---
axh3 = subplot(3,1,3); hold on; grid on;
for j = 1:nT
    plot(trel, ax_f(:, j), '-', 'LineWidth', 1.2, 'Color', cmap(j,:), ...
        'DisplayName', sprintf('\tau=%.2fs', taus(j)));
end
ref_col = ceil(nT/2);
thr = median(ax_f(:, ref_col), 'omitnan') + std(ax_f(:, ref_col), 'omitnan');
yline(thr, '--k', sprintf('soglia ~ %.2f', thr), 'HandleVisibility', 'off');
ylabel('media |a_x|  [m/s^2]', 'Interpreter', 'tex');
xlabel('t  [s]');
title('Trigger per Q feed-forward adattiva', 'FontSize', 10);

linkaxes([axh1 axh2 axh3], 'x');
if exist('x_lim','var') && isfinite(x_lim(2)); xlim(x_lim); end
if exist('axes','var'); axes = [axes axh1 axh2 axh3]; end %#ok<AGROW>

% --- diagnostica ---
fprintf('\n[ego_acc_lpf_tuning] dt mediano = %.4f s (fs ~ %.1f Hz)\n', dt, 1/dt);
fprintf('  media globale |a_x| = %.3f m/s^2 | max = %.3f\n', ...
    mean(abs_ax,'omitnan'), max(abs_ax,[],'omitnan'));
for j = 1:nT
    fprintf('  tau=%.2f s -> alpha=%.3f, ritardo di gruppo ~ %.2f s\n', ...
        taus(j), dt/(taus(j)+dt), taus(j));
end

% =====================================================================
function y = lpf_first_order_nan(x, dt, tau)
% Passabasso del primo ordine robusto ai NaN (propaga lo stato sui buchi).
    a = dt / (tau + dt);
    y = nan(size(x));
    s = NaN;
    for k = 1:numel(x)
        xk = x(k);
        if isnan(xk)
            y(k) = s; continue;
        end
        if isnan(s), s = xk; else, s = a*xk + (1-a)*s; end
        y(k) = s;
    end
end