%% JERK_FF_QMULT - jerk (ax_dot) vs ff_flag e q_mult
%
% Figura unica, due pannelli della stessa dimensione:
%   (1) jerk: ax_dot di ogni log (+ jerk della GT)
%   (2) ff_flag (asse sinistro, 0/1) e q_mult (asse destro)
%
% Serve a vedere se l'attivazione del feed-forward e l'entita' del
% moltiplicatore di process noise sono coerenti con il jerk osservato.
%
% NB: ff_flag e q_mult non sono caricati da load_tt.m, quindi vengono letti
% dai log grezzi (log / log_2 / log_3). Per ff_flag lo 0 e' un valore
% LEGITTIMO (flag basso), quindi NON viene mascherato come placeholder.
%
% Richiede in workspace: tt, log, opp_idx, f, axes, col
%                        (tt2/log_2, tt3/log_3 e gt opzionali).

%% ================= PARAMETRI =================
show_gt  = true;    % jerk della GT nel pannello superiore
fc_gt    = 7;       % [Hz] taglio zero-phase per derivare il jerk dalla GT
jerk_thr = 20;      % [m/s^3] soglia di riferimento (linea orizzontale)

ylim_pct = 99.5;    % percentile per la scala Y del jerk (ignora outlier)

% Nomi alternativi con cui cercare il moltiplicatore di process noise.
qmult_candidates = {'opponents__q_mult','opponents__q_lambda','opponents__qmult'};

%% ================= RACCOLTA LOG =================
% ogni riga: {struct tt*, log grezzo, colore, etichetta di default}
defs = {};
if exist('tt','var')
    if exist('log','var');   r1 = log;   else; r1 = []; end
    defs(end+1,:) = {tt,  r1, col.tt,  'log 1'};
end
if exist('tt2','var')
    if exist('log_2','var'); r2 = log_2; else; r2 = []; end
    defs(end+1,:) = {tt2, r2, col.tt2, 'log 2'};
end
if exist('tt3','var')
    if exist('log_3','var'); r3 = log_3; else; r3 = []; end
    defs(end+1,:) = {tt3, r3, col.tt3, 'log 3'};
end

curves = {};
for i = 1:size(defs,1)
    T      = defs{i,1};
    rawlog = defs{i,2};
    c      = defs{i,3};
    if isfield(T,'name'); nm = T.name; else; nm = defs{i,4}; end

    % ---------- jerk loggato (ax_dot) ----------
    j = []; j_src = '';
    if isfield(T, 'jerk')
        j = T.jerk;   j_src = 'tt.jerk';
    elseif isfield(T, 'ax_dot')
        j = T.ax_dot; j_src = 'tt.ax_dot';
    elseif ~isempty(rawlog) && isfield(rawlog, 'perception__opponents') && ...
            isfield(rawlog.perception__opponents, 'opponents__ax_dot')
        j = rawlog.perception__opponents.opponents__ax_dot;
        j_src = 'log.opponents__ax_dot';
    end
    if ~isempty(j)
        j = j(:, min(opp_idx, size(j,2)));
        j(j == 0) = nan;
    else
        warning('jerk_ff_qmult: ax_dot non trovato per %s.', nm);
    end

    % ---------- ff_flag ----------
    % 0 = flag basso, valore legittimo: NON mascherare a NaN
    ff = [];
    if isfield(T, 'ff_flag')
        ff = T.ff_flag;
    elseif ~isempty(rawlog) && isfield(rawlog, 'perception__opponents') && ...
            isfield(rawlog.perception__opponents, 'opponents__ff_flag')
        ff = rawlog.perception__opponents.opponents__ff_flag;
    end
    if ~isempty(ff)
        ff = double(ff(:, min(opp_idx, size(ff,2))));
    else
        warning('jerk_ff_qmult: ff_flag non trovato per %s.', nm);
    end

    % ---------- q_mult ----------
    qm = []; q_src = '';
    if isfield(T, 'q_mult')
        qm = T.q_mult;   q_src = 'tt.q_mult';
    elseif isfield(T, 'q_lambda')
        qm = T.q_lambda; q_src = 'tt.q_lambda';
    elseif ~isempty(rawlog) && isfield(rawlog, 'perception__opponents')
        for kc = 1:numel(qmult_candidates)
            if isfield(rawlog.perception__opponents, qmult_candidates{kc})
                qm = rawlog.perception__opponents.(qmult_candidates{kc});
                q_src = ['log.' qmult_candidates{kc}];
                break;
            end
        end
    end
    if ~isempty(qm)
        qm = double(qm(:, min(opp_idx, size(qm,2))));
        qm(qm == 0) = nan;   % qui lo 0 e' un placeholder (un moltiplicatore
                             % nullo azzererebbe il process noise)
    else
        warning('jerk_ff_qmult: q_mult non trovato per %s.', nm);
    end

    S.stamp = T.stamp(:);
    S.jerk = j; S.ff = ff; S.qm = qm;
    S.col = c;  S.name = nm;
    curves{end+1} = S; %#ok<SAGROW>

    fprintf('jerk_ff_qmult: %s | jerk da %s | q_mult da %s\n', ...
        nm, j_src, q_src);
end

%% ================= GT =================
has_gt = show_gt && exist('gt','var') && isstruct(gt) && ...
         isfield(gt,'stamp') && isfield(gt,'ax');
if has_gt
    tg_raw = gt.stamp(:);
    ag_raw = gt.ax(:, min(opp_idx, size(gt.ax,2)));
    ag_raw(ag_raw == 0) = nan;
    vg = ~isnan(tg_raw) & ~isnan(ag_raw);
    [t_gt, ig] = unique(tg_raw(vg));
    ag_v = ag_raw(vg); ag_v = ag_v(ig);

    dt_gt  = median(diff(t_gt));
    t_gtu  = (t_gt(1):dt_gt:t_gt(end)).';
    ax_gtu = interp1(t_gt, ag_v, t_gtu, 'linear');
    [b_g, a_g] = butter(2, min(fc_gt/(1/dt_gt/2), 0.99));
    jerk_gt_f = gradient(filtfilt(b_g, a_g, ax_gtu), dt_gt);
end

%% ================= FIGURA =================
figure('Name','Jerk vs ff_flag / q_mult','NumberTitle','off'); f = f+1;
tl = tiledlayout(2,1,'TileSpacing','compact');
title(tl, sprintf('Jerk, ff\\_flag e q\\_mult - opp %d', opp_idx), 'FontWeight','bold');

% ---- (1) jerk ----
axj = nexttile; hold on; grid on;
for i = 1:numel(curves)
    S = curves{i};
    if ~isempty(S.jerk)
        plot(S.stamp, S.jerk, '-', 'Color', S.col, 'LineWidth', 1.3, ...
            'DisplayName', sprintf('%s: ax\\_dot', S.name));
    end
end
if has_gt
    plot(t_gtu, jerk_gt_f, '-', 'Color', col.ref, 'LineWidth', 1.5, ...
        'DisplayName', sprintf('gt jerk (f_c=%g Hz)', fc_gt));
end
yline( jerk_thr, 'r--', 'HandleVisibility','off');
yline(-jerk_thr, 'r--', 'DisplayName', sprintf('soglia %g', jerk_thr));

jall = [];
for i = 1:numel(curves)
    if ~isempty(curves{i}.jerk); jall = [jall; curves{i}.jerk(:)]; end %#ok<AGROW>
end
if has_gt; jall = [jall; jerk_gt_f(:)]; end
jall = abs(jall(~isnan(jall)));
if ~isempty(jall)
    ylim([-1 1] * max(prctile(jall, ylim_pct), 1.5*jerk_thr));
end
ylabel('jerk [m/s^3]');
legend('Location','eastoutside','FontSize',8,'Box','off');
axes = [axes, axj]; %#ok<AGROW>

% ---- (2) ff_flag (sinistra) e q_mult (destra) ----
% due assi Y: ff_flag e' binario, q_mult puo' valere ordini di grandezza in
% piu' - su un asse solo uno dei due sarebbe illeggibile
axq = nexttile; hold on; grid on;

yyaxis left
for i = 1:numel(curves)
    S = curves{i};
    if ~isempty(S.ff)
        stairs(S.stamp, S.ff > 0.5, '-', 'Color', S.col, 'LineWidth', 1.4, ...
            'DisplayName', sprintf('%s: ff\\_flag', S.name));
    end
end
ylim([-0.15 1.15]); yticks([0 1]); yticklabels({'OFF','ON'});
ylabel('ff\_flag');
set(gca,'YColor',[0.25 0.25 0.25]);

yyaxis right
for i = 1:numel(curves)
    S = curves{i};
    if ~isempty(S.qm)
        plot(S.stamp, S.qm, '--', 'Color', S.col, 'LineWidth', 1.2, ...
            'DisplayName', sprintf('%s: q\\_mult', S.name));
    end
end
ylabel('q\_mult [-]');
set(gca,'YColor',[0.25 0.25 0.25]);

xlabel('t [s]');
legend('Location','eastoutside','FontSize',8,'Box','off');
axes = [axes, axq]; %#ok<AGROW>

clearvars defs r1 r2 r3 curves i T rawlog c nm j j_src ff qm q_src kc S ...
    qmult_candidates tg_raw ag_raw vg t_gt ig ag_v dt_gt ax_gtu b_g a_g ...
    has_gt tl axj axq jall