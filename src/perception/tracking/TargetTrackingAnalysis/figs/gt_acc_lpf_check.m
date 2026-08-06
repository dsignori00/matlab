%% gt_acc_lpf_check.m
% Validazione del passabasso su |ax| del GROUND TRUTH dell'avversario.
% Serve a verificare se il tau tunato sull'ego (proxy) ha senso anche sul
% segnale che l'EKF deve davvero inseguire: l'accelerazione vera dell'opponent.
%
% Confronta ax grezza vs filtrata (con segno), per piu' tau.
% Il tau scelto (tau_sel) viene evidenziato.
%
% Sorgente: struct gt (da load_ref / log_ref).

% --- parametri (modificabili) ---
taus    = [0.10 0.15 0.20 0.50 1.00];   % tau da confrontare [s]
tau_sel = 0.05;                          % il tau che hai scelto -> evidenziato

% --- estrazione ax dal GT (fallback sui nomi possibili) ---
cand_ax = {'ax','a_x','acc','accel','acceleration','ax_map','long_acc'};
ax_gt = [];
for c = 1:numel(cand_ax)
    if isfield(gt, cand_ax{c})
        ax_gt = double(gt.(cand_ax{c})(:));
        fprintf('[gt_acc_lpf_check] uso gt.%s come accelerazione\n', cand_ax{c});
        break;
    end
end
if isempty(ax_gt)
    fn = fieldnames(gt);
    hit = fn(contains(fn, 'a', 'IgnoreCase', true) & ...
              (contains(fn, 'acc', 'IgnoreCase', true) | strcmpi(fn,'ax')));
    if isempty(hit)
        error('Campo accelerazione non trovato in gt. Campi disponibili: %s', ...
            strjoin(fieldnames(gt), ', '));
    end
    warning('Uso il campo gt.%s', hit{1});
    ax_gt = double(gt.(hit{1})(:));
end

% --- timestamp GT (fallback) ---
cand_t = {'stamp','stamp__tot','time','t'};
t = [];
for c = 1:numel(cand_t)
    if isfield(gt, cand_t{c}); t = double(gt.(cand_t{c})(:)); break; end
end
if isempty(t)
    fn = fieldnames(gt);
    hit = fn(contains(fn, 'stamp', 'IgnoreCase', true) | contains(fn,'time','IgnoreCase',true));
    t = double(gt.(hit{1})(:));
end

% allinea lunghezze
n = min(numel(t), numel(ax_gt));
t = t(1:n); ax_gt = ax_gt(1:n);
ax_gt(ax_gt == 0) = nan;   % coerente con la convenzione del log

t0 = t(find(isfinite(ax_gt), 1, 'first'));
trel = t - t0;

% --- dt mediano ---
dt_vec = diff(t);
dt = median(dt_vec(dt_vec > 0 & isfinite(dt_vec)), 'omitnan');

% --- filtraggio ---
nT = numel(taus);
ax_f_sgn = nan(numel(ax_gt), nT);
for j = 1:nT
    ax_f_sgn(:, j) = lpf_first_order_nan(ax_gt, dt, taus(j));
end
% tau selezionato
ax_sel_sgn = lpf_first_order_nan(ax_gt, dt, tau_sel);

% =====================================================================
f = f + 1;
figure(f); clf;
set(gcf, 'Name', 'GT opponent a_x LPF check');
cmap = lines(nT);

% --- ax grezza vs filtrata (con segno), tau_sel evidenziato ---
axh1 = gca; hold on; grid on;
plot(trel, ax_gt, '-', 'Color', [0 0 0], 'LineWidth', 1.3, 'DisplayName', 'a_x GT raw');
for j = 1:nT
    plot(trel, ax_f_sgn(:, j), '--', 'LineWidth', 1.0, 'Color', cmap(j,:), ...
        'DisplayName', sprintf('\\tau=%.2fs', taus(j)));
end
plot(trel, ax_sel_sgn, '-', 'LineWidth', 1.3, 'Color', [1 0 0], ...
    'DisplayName', sprintf('\\tau_{sel}=%.2fs', tau_sel));
yline(0, '-k', 'HandleVisibility', 'off');
ylabel('a_x  [m/s^2]', 'Interpreter', 'tex');
xlabel('t  [s]');
title('Opponent GT acceleration vs low-pass filtered opponent GT acceleration', 'FontSize', 15 , 'FontWeight', 'bold');
legend('show', 'Location', 'northeast', 'FontSize', 7, 'Box', 'on', ...
    'Color', 'w', 'EdgeColor', [0.4 0.4 0.4], ...
    'Orientation', 'horizontal', 'NumColumns', 3);

if exist('x_lim','var') && isfinite(x_lim(2)); xlim(x_lim); end
if exist('axes','var'); axes = [axes axh1]; end %#ok<AGROW>

% --- diagnostica: ritardo del tau_sel sui picchi (cross-correlation) ---
v = isfinite(ax_gt) & isfinite(ax_sel_sgn);
if nnz(v) > 10
    a = ax_gt(v) - mean(ax_gt(v));
    b = ax_sel_sgn(v) - mean(ax_sel_sgn(v));
    [xc, lags] = xcorr(b, a, round(3/dt), 'normalized');
    [~, im] = max(xc);
    fprintf('[gt_acc_lpf_check] dt=%.4fs | tau_sel=%.2fs | ritardo stimato ~ %.2fs\n', ...
        dt, tau_sel, lags(im)*dt);
end

% =====================================================================
function y = lpf_first_order_nan(x, dt, tau)
    a = dt / (tau + dt);
    y = nan(size(x));
    s = NaN;
    for k = 1:numel(x)
        xk = x(k);
        if isnan(xk), y(k) = s; continue; end
        if isnan(s), s = xk; else, s = a*xk + (1-a)*s; end
        y(k) = s;
    end
end