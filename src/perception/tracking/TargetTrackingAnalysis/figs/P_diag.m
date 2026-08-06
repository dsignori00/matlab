%% COVARIANCE_DIAG - diagonale della matrice di covarianza P (ekf_p)
%
% Un pannello per ogni elemento diagonale P_ii, cioe' la varianza dello
% stato i-esimo. Tutti i log disponibili sono sovrapposti sullo stesso
% pannello, con il colore e il nome gia' assegnati dal main script.
%
% ekf_p e' float32[36] = matrice 6x6 serializzata. Gli indici della diagonale
% sono (k-1)*n + k, che coincidono sia in row-major sia in column-major
% (la diagonale e' invariante rispetto alla trasposizione).
%
% Richiede in workspace: tt, log, opp_idx, f, axes, col
%                        (tt2/log_2, tt3/log_3 opzionali).

%% ================= PARAMETRI =================
plot_log_1 = true;    % includi log 1
plot_log_2 = true;    % includi log 2
plot_log_3 = true;    % includi log 3

plot_sigma = true;    % true  -> sqrt(P_ii), stesse unita' dello stato
                      % false -> P_ii (varianza)
log_scale  = true;    % asse Y logaritmico (le varianze coprono ordini di
                      % grandezza diversi tra loro)

% Etichette degli stati, nell'ordine in cui compaiono nella matrice P.
% Se il numero non corrisponde alla dimensione trovata, si ricade su
% 'stato 1', 'stato 2', ...
state_labels = {'x','y','vx','psi','psi\_dot','ax'};

% Unita' di misura corrispondenti (solo per l'etichetta dell'asse Y).
% Lasciare vuoto {} per non mostrarle.
state_units = {'m','m','m/s','rad','rad/s','m/s^2'};

%% ================= RACCOLTA LOG =================
curves = {};
for kl = 1:3
    switch kl
        case 1
            if ~plot_log_1 || ~exist('tt','var'); continue; end
            T = tt;  cc = col.tt;
            if exist('name1','var'); nm = name1; else; nm = 'log 1'; end
            if exist('log','var');   RL = log;   else; RL = []; end
        case 2
            if ~plot_log_2 || ~exist('tt2','var'); continue; end
            T = tt2; cc = col.tt2;
            if exist('name2','var'); nm = name2; else; nm = 'log 2'; end
            if exist('log_2','var'); RL = log_2; else; RL = []; end
        case 3
            if ~plot_log_3 || ~exist('tt3','var'); continue; end
            T = tt3; cc = col.tt3;
            if exist('name3','var'); nm = name3; else; nm = 'log 3'; end
            if exist('log_3','var'); RL = log_3; else; RL = []; end
    end

    % ---- ekf_p: struct tt* se caricata, altrimenti log grezzo ----
    P = [];
    if isfield(T, 'ekf_p')
        P = T.ekf_p;
    elseif isfield(T, 'covariance')
        P = T.covariance;
    elseif ~isempty(RL) && isfield(RL, 'perception__opponents') && ...
            isfield(RL.perception__opponents, 'opponents__ekf_p')
        P = RL.perception__opponents.opponents__ekf_p;
    end
    if isempty(P)
        warning('covariance_diag: ekf_p non trovato per %s - log saltato.', nm);
        continue;
    end

    % ---- dimensione della matrice dal numero di elementi serializzati ----
    n_el = size(P, ndims(P));
    n_st = round(sqrt(n_el));
    if n_st^2 ~= n_el
        warning(['covariance_diag: %s -> ekf_p ha %d elementi, che non e'' un ' ...
                 'quadrato perfetto: impossibile ricavare la diagonale di una ' ...
                 'matrice n x n. Log saltato.'], nm, n_el);
        continue;
    end

    oi = min(opp_idx, size(P,2));
    dg = ((1:n_st)-1)*n_st + (1:n_st);   % indici diagonale
    Pd = squeeze(P(:, oi, dg));          % [N x n_st]
    Pd(Pd == 0) = nan;                   % placeholder "no data"

    % una varianza negativa non ha senso fisico: segnala perdita di
    % definita positivita' del filtro, vale la pena saperlo
    n_neg = nnz(Pd < 0);
    if n_neg > 0
        warning('covariance_diag: %s -> %d valori diagonali NEGATIVI (P non definita positiva).', ...
            nm, n_neg);
    end

    S.stamp = T.stamp(:);
    S.Pd = Pd; S.n_st = n_st; S.col = cc; S.name = nm;
    curves{end+1} = S; %#ok<SAGROW>
    fprintf('covariance_diag: %s -> ekf_p %dx%d\n', nm, n_st, n_st);
end

if isempty(curves)
    warning('covariance_diag: nessun log con ekf_p - figura non creata.');
else

%% ================= FIGURA =================
n_max = 0;
for i = 1:numel(curves); n_max = max(n_max, curves{i}.n_st); end

if numel(state_labels) == n_max
    lbl = state_labels;
else
    lbl = arrayfun(@(k) sprintf('stato %d', k), 1:n_max, 'UniformOutput', false);
end
if numel(state_units) == n_max
    unt = state_units;
else
    unt = repmat({''}, 1, n_max);
end

figure('name','Filter - covarianza P (diagonale)','NumberTitle','off'); f = f+1;
tlp = tiledlayout(n_max, 1, 'TileSpacing','compact');
if plot_sigma
    title(tlp, sprintf('ekf\\_p: \\sigma_i = sqrt(P_{ii}) - opp %d', opp_idx), ...
        'FontWeight','bold');
else
    title(tlp, sprintf('ekf\\_p: varianze P_{ii} - opp %d', opp_idx), ...
        'FontWeight','bold');
end

for k = 1:n_max
    axes(f) = nexttile; f=f+1; hold on; grid on;
    for i = 1:numel(curves)
        S = curves{i};
        if k > S.n_st; continue; end
        y = S.Pd(:,k);
        if plot_sigma; y = sqrt(abs(y)); end
        plot(S.stamp, y, '-', 'Color', S.col, 'LineWidth', 1.2, ...
            'DisplayName', S.name);
    end
    if log_scale; set(gca, 'YScale', 'log'); end

    if plot_sigma
        if isempty(unt{k})
            ylabel(sprintf('\\sigma_{%s}', lbl{k}));
        else
            ylabel(sprintf('\\sigma_{%s} [%s]', lbl{k}, unt{k}));
        end
    else
        if isempty(unt{k})
            ylabel(sprintf('P_{%s}', lbl{k}));
        else
            ylabel(sprintf('P_{%s} [(%s)^2]', lbl{k}, unt{k}));
        end
    end

    if k == 1;     legend('Location','eastoutside','FontSize',8,'Box','off'); end
    if k == n_max; xlabel('timestamp [s]'); end
end

end

clearvars kl T cc nm RL P n_el n_st oi dg Pd n_neg S curves i k y ...
    n_max lbl unt tlp state_labels state_units