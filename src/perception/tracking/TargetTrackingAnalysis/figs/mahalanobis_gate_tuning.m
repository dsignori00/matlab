%% mahalanobis_gate_tuning.m
%
% Chi-square test per il tuning della distanza di Mahalanobis
% nel contesto del target tracking (gating misura-traccia).
%
% Prerequisiti: tt già caricato via load_tt(log)
%   tt.x_map            [T x N]  posizione x traccia
%   tt.y_map            [T x N]  posizione y traccia
%   tt.covariance       [T x N x n_state x n_state]  covarianza EKF post-update
%   tt.measures.x_map   [T x N x M]  posizione x misure associate
%   tt.measures.y_map   [T x N x M]  posizione y misure associate
%   tt.measures.source  [T x N x M]  tipo sensore
%   tt.measures.count   [T x N]      numero misure associate per traccia
%
% Assunzione: misura z = [x_map; y_map] → dim_z = 2
%             S = H * P * H' + R   con H = [I2 0 ... 0] (solo posizione)
% -------------------------------------------------------------------------

close all;

%% =========================================================
%  PARAMETRI UTENTE
% =========================================================
dim_z       = 2;          % dimensione misura: [x, y]
confidences = [0.90, 0.95, 0.99, 0.999];  % livelli da confrontare
conf_target = 0.99;       % confidenza scelta per il gate finale

% Indici stato: quale riga/colonna di P corrisponde a x_map e y_map?
% Adatta se il tuo stato EKF ha un ordine diverso
idx_x = 1;
idx_y = 2;

% Matrice H di osservazione (proietta stato → misura [x,y])
% Se lo stato è [x, y, vx, vy, ax, yaw, yaw_rate, ...] allora:
n_state = size(tt.covariance, 3);   % dimensione automatica da P
H = zeros(dim_z, n_state);
H(1, idx_x) = 1;
H(2, idx_y) = 1;

% Rumore di misura R (usa la tua R stimata per sensore)
% Esempio: lidar ~0.1m std, radar ~0.5m std, camera ~1m std
R_by_source = struct();
R_by_source.lidar  = diag([0.4, 0.4]);   % [m²]
R_by_source.radar  = diag([1.13, 0.94]);
R_by_source.camera = diag([1.0^2, 1.0^2]);
R_by_source.pp     = diag([0.27, 0.31]);   % pointpillars
R_by_source.default= diag([0.5^2, 0.5^2]);   % fallback

% Mappa source_type (intero) → nome sensore
source_map = containers.Map({1, 2, 3, 4}, ...
                             {'lidar','radar','camera','pp'});

%% =========================================================
%  SOGLIE CHI-QUADRO
% =========================================================
fprintf('\n=== SOGLIE CHI-QUADRO (dim_z = %d) ===\n', dim_z);
fprintf('%-10s  %-10s\n', 'Confidenza', 'gamma²');
fprintf('%s\n', repmat('-',1,22));
gamma2_table = zeros(size(confidences));
for k = 1:numel(confidences)
    g2 = chi2inv(confidences(k), dim_z);
    gamma2_table(k) = g2;
    marker = '';
    if confidences(k) == conf_target; marker = '  ← SCELTA'; end
    fprintf('  %5.1f%%      %7.3f%s\n', confidences(k)*100, g2, marker);
end
gamma2_target = chi2inv(conf_target, dim_z);
fprintf('\nSoglia gate al %.1f%%: gamma² = %.4f\n\n', conf_target*100, gamma2_target);

%% =========================================================
%  CALCOLO DISTANZE DI MAHALANOBIS SU TUTTE LE MISURE
% =========================================================
[T, N, M] = size(tt.measures.x_map);

d2_all    = [];   % D² di tutte le innovazioni valide
src_all   = [];   % source type corrispondente
inn_x_all = [];   % innovazione x
inn_y_all = [];   % innovazione y

for t = 1:T
    for n = 1:N
        n_meas = tt.measures.count(t, n);
        if n_meas == 0 || isnan(tt.x_map(t,n)); continue; end

        % Predizione della traccia (usiamo stato post-update come proxy)
        x_pred = tt.x_map(t, n);
        y_pred = tt.y_map(t, n);

        % Covarianza EKF (post-update): shape [n_state x n_state]
        P = squeeze(tt.covariance(t, n, :, :));
        if any(isnan(P(:))); continue; end

        for m = 1:n_meas
            z_x = tt.measures.x_map(t, n, m);
            z_y = tt.measures.y_map(t, n, m);
            src = tt.measures.source(t, n, m);

            if isnan(z_x) || isnan(z_y); continue; end

            % Seleziona R per questo sensore
            if isKey(source_map, src)
                src_name = source_map(src);
                if isfield(R_by_source, src_name)
                    R = R_by_source.(src_name);
                else
                    R = R_by_source.default;
                end
            else
                R = R_by_source.default;
                src_name = 'unknown';
            end

            % Innovazione
            inn = [z_x - x_pred; z_y - y_pred];

            % Matrice di innovazione S = H*P*H' + R
            S = H * P * H' + R;

            % Distanza di Mahalanobis al quadrato
            d2 = inn' / S * inn;

            d2_all    = [d2_all;    d2];   %#ok<AGROW>
            src_all   = [src_all;   src];  %#ok<AGROW>
            inn_x_all = [inn_x_all; inn(1)]; %#ok<AGROW>
            inn_y_all = [inn_y_all; inn(2)]; %#ok<AGROW>
        end
    end
end

fprintf('Totale innovazioni valide: %d\n', numel(d2_all));

%% =========================================================
%  NIS (Normalized Innovation Squared) — CONSISTENCY CHECK
% =========================================================
% Se il filtro è consistente: E[D²] ≈ dim_z = 2
nis_mean = mean(d2_all, 'omitnan');
fprintf('\n=== NIS CONSISTENCY CHECK ===\n');
fprintf('NIS medio osservato : %.4f\n', nis_mean);
fprintf('NIS atteso (dim_z)  : %.4f\n', dim_z);
if nis_mean > dim_z * 1.5
    fprintf('⚠️  NIS >> dim_z: P e/o R probabilmente SOTTOSTIMATE\n');
elseif nis_mean < dim_z * 0.5
    fprintf('⚠️  NIS << dim_z: P e/o R probabilmente SOVRASTIMATE\n');
else
    fprintf('✅ Filtro consistente\n');
end

%% =========================================================
%  TEST CHI-QUADRO — PERCENTUALE DI OUTLIER PER OGNI SOGLIA
% =========================================================
fprintf('\n=== TEST CHI-QUADRO: OUTLIER REJECTION ===\n');
fprintf('%-10s  %-10s  %-15s  %-15s\n', ...
    'Confidenza','gamma²','Outlier (#)','Outlier (%)');
fprintf('%s\n', repmat('-',1,55));
for k = 1:numel(confidences)
    n_out   = sum(d2_all > gamma2_table(k));
    pct_out = 100 * n_out / numel(d2_all);
    marker  = '';
    if confidences(k) == conf_target; marker = '  ← SCELTA'; end
    fprintf('  %5.1f%%      %7.3f    %6d          %6.2f%%%s\n', ...
        confidences(k)*100, gamma2_table(k), n_out, pct_out, marker);
end

%% =========================================================
%  PLOT 1: Distribuzione D² vs chi-quadro teorica
% =========================================================
figure('Name','Chi-square Gate Tuning','NumberTitle','off');

% Istogramma D² osservato
subplot(2,2,1);
edges = linspace(0, min(max(d2_all), chi2inv(0.9999, dim_z)*2), 80);
histogram(d2_all, edges, 'Normalization','pdf', ...
    'FaceColor',[0.2 0.5 0.8], 'FaceAlpha',0.6);
hold on;
x_chi2 = linspace(0, edges(end), 300);
plot(x_chi2, chi2pdf(x_chi2, dim_z), 'r-', 'LineWidth', 2);
% Soglie verticali
cols_conf = lines(numel(confidences));
for k = 1:numel(confidences)
    xline(gamma2_table(k), '--', ...
        sprintf('%.0f%%', confidences(k)*100), ...
        'Color', cols_conf(k,:), 'LineWidth', 1.5, ...
        'LabelVerticalAlignment','bottom');
end
xlabel('D² (Mahalanobis²)');
ylabel('PDF');
title('Distribuzione D² vs \chi^2 teorica');
legend('D² osservato', sprintf('\\chi^2_{%d} teorica', dim_z));
grid on;

% =========================================================
%  PLOT 2: Q-Q plot
% =========================================================
subplot(2,2,2);
d2_sorted = sort(d2_all(~isnan(d2_all)));
n_valid   = numel(d2_sorted);
probs     = ((1:n_valid) - 0.5) / n_valid;
q_teorici = chi2inv(probs, dim_z);
scatter(q_teorici, d2_sorted, 3, 'filled', ...
    'MarkerFaceColor',[0.2 0.5 0.8], 'MarkerFaceAlpha', 0.4);
hold on;
q_max = chi2inv(0.995, dim_z);
plot([0 q_max],[0 q_max],'r--','LineWidth',2);
xlabel('Quantili teorici \chi^2');
ylabel('D² osservati');
title('Q-Q Plot (consistenza filtro)');
grid on;
xlim([0 q_max]); ylim([0 q_max]);
legend('Dati osservati','Linea teorica','Location','northwest');

% =========================================================
%  PLOT 3: Percentuale outlier vs confidenza
% =========================================================
subplot(2,2,3);
conf_fine = 0.80:0.001:0.999;
pct_out_fine = zeros(size(conf_fine));
for k = 1:numel(conf_fine)
    g2 = chi2inv(conf_fine(k), dim_z);
    pct_out_fine(k) = 100 * sum(d2_all > g2) / numel(d2_all);
end
plot(conf_fine*100, pct_out_fine, 'b-', 'LineWidth', 2);
hold on;
% Teorica (dovrebbe essere 100*(1-conf) se filtro consistente)
plot(conf_fine*100, 100*(1-conf_fine), 'r--', 'LineWidth', 1.5);
xline(conf_target*100, 'k--', sprintf('%.0f%% target', conf_target*100), ...
    'LineWidth', 1.5, 'LabelVerticalAlignment', 'bottom');
xlabel('Confidenza (%)');
ylabel('Outlier rigettati (%)');
title('% Outlier vs Soglia di confidenza');
legend('Osservato','Teorico (filtro ideale)','Location','northeast');
grid on;

% =========================================================
%  PLOT 4: D² per source type
% =========================================================
subplot(2,2,4);
src_unique = unique(src_all(~isnan(src_all)));
colors_src = lines(numel(src_unique));
hold on;
legend_entries = {};
for k = 1:numel(src_unique)
    s   = src_unique(k);
    d2s = d2_all(src_all == s);
    if numel(d2s) < 2; continue; end
    histogram(d2s, edges, 'Normalization','pdf', ...
        'FaceAlpha', 0.5, 'FaceColor', colors_src(k,:));
    if isKey(source_map, s)
        legend_entries{end+1} = source_map(s); %#ok<AGROW>
    else
        legend_entries{end+1} = sprintf('src %d', s); %#ok<AGROW>
    end
end
plot(x_chi2, chi2pdf(x_chi2, dim_z), 'k-', 'LineWidth', 2);
legend_entries{end+1} = sprintf('\\chi^2_{%d} teorica', dim_z);
xline(gamma2_target, 'r--', sprintf('Gate %.0f%%=%.2f', ...
    conf_target*100, gamma2_target), 'LineWidth',1.5);
xlabel('D²'); ylabel('PDF');
title('D² per tipo di sensore');
legend(legend_entries, 'Location','northeast');
grid on;

sgtitle(sprintf('Mahalanobis Gate Tuning — Soglia al %.0f%%: \\gamma^2 = %.3f', ...
    conf_target*100, gamma2_target));

%% =========================================================
%  RIEPILOGO FINALE
% =========================================================
fprintf('\n=== PARAMETRI CONSIGLIATI PER IL GATE ===\n');
fprintf('  dim_z          = %d   (misura: [x_map, y_map])\n', dim_z);
fprintf('  confidenza     = %.1f%%\n', conf_target*100);
fprintf('  gamma²         = %.4f\n', gamma2_target);
fprintf('  gamma (std)    = %.4f\n', sqrt(gamma2_target));
fprintf('\nUso nel tracker:\n');
fprintf('  S    = H * P * H'' + R;\n');
fprintf('  inn  = z - H * x_pred;\n');
fprintf('  d2   = inn'' / S * inn;\n');
fprintf('  gate = d2 <= %.4f;  %% TRUE = misura accettata\n', gamma2_target);