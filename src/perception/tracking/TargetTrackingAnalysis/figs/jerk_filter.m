%% JERK_HYSTERESIS - accelerazione vs GT + confronto jerk con soglie a isteresi
%
% Figura unica, due pannelli della stessa dimensione:
%   (1) a_x stimata dal filtro vs a_x della GT
%   (2) jerk: quello loggato dal filtro, quello derivato dalla GT, e le
%       stime causali (Butterworth e/o dirty derivative), attivabili e
%       tarabili singolarmente dai parametri qui sotto.
%
% Sul pannello jerk sono disegnate le bande di soglia per una futura logica
% a ISTERESI (Schmitt trigger):
%   |jerk| > thr_on   -> trigger ATTIVO
%   |jerk| < thr_off  -> trigger torna INATTIVO
% Gli intervalli in cui il trigger risulta attivo sono evidenziati con uno
% sfondo grigio, cosi' si vede a colpo d'occhio quando scatterebbe.
%
% NOTA sul campionamento: l'isteresi NON viene valutata solo sui campioni
% originali del filtro. Il segnale pilota viene infittito (hyst_upsample) e
% i bordi delle bande sono calcolati in TEMPO CONTINUO, interpolando l'istante
% esatto di attraversamento della soglia. Cosi' un crossing che avviene tra
% due campioni viene comunque catturato, e la banda inizia esattamente dove la
% curva taglia la linea di soglia invece che al campione successivo.
%
% Richiede in workspace: tt, gt, opp_idx, f (contatore figure), axes.
% Campi usati: tt.stamp, tt.ax, tt.jerk (opzionale), gt.stamp, gt.ax.

compactLegend = @(ax) set(legend(ax), 'Location', 'eastoutside', ...
    'FontSize', 8, 'Box', 'off');

set(groot, 'defaultAxesTickLabelInterpreter', 'tex');
set(groot, 'defaultTextInterpreter', 'tex');
set(groot, 'defaultLegendInterpreter', 'tex');

%% ================= PARAMETRI =================

% --- quali curve di jerk mostrare ---
use_logged = true;    % jerk loggato dal filtro (tt.jerk, se presente)
use_gt     = true;    % jerk derivato dalla GT (riferimento acausale)
use_bw     = false;   % Butterworth causale + derivata
use_dirty  = false;    % dirty derivative s/(tau*s+1)

% --- taratura Butterworth (causale, su a_x stimata) ---
fc_bw    = 5;         % [Hz] frequenza di taglio
bw_order = 2;         % ordine del filtro

% --- taratura dirty derivative ---
tau_dirty = 0.03;     % [s] costante di tempo (banda equivalente ~ 1/(2*pi*tau))

% --- derivazione del jerk dalla GT (zero-phase, riferimento) ---
fc_gt    = 8;         % [Hz] taglio zero-phase applicato alla a_x della GT
gt_order = 2;         % ordine del filtro sulla GT

% --- soglie a isteresi ---
thr_on   = 20;        % [m/s^3] sopra questa soglia il trigger si ATTIVA
thr_off  = 10;        % [m/s^3] sotto questa soglia il trigger si DISATTIVA

% quale segnale pilota l'isteresi (e quindi lo sfondo grigio):
%   'logged' | 'bw' | 'dirty' | 'gt'
% ATTENZIONE: deve essere una curva che stai anche VISUALIZZANDO, altrimenti
% la banda grigia sembra "sfasata" rispetto alle curve a schermo perche' sta
% seguendo un segnale invisibile. Lo script avvisa e la disegna comunque.
hyst_source = 'logged';

force_show_hyst_curve = true;  % true -> se la curva pilota non e' tra quelle
                               % attive, la disegna comunque (tratteggiata)

% Fattore di infittimento per la rilevazione dei crossing. 1 = valuta solo
% sui campioni originali (comportamento vecchio, perde i crossing tra due
% campioni). 20 = risoluzione 20x piu' fine -> bordi banda praticamente
% coincidenti con l'intersezione visiva curva/soglia.
hyst_upsample = 20;

show_hyst_shading = true;   % false -> disegna solo le linee di soglia
shade_color = [0.6 0.6 0.6];
shade_alpha = 0.22;

% Scala Y del pannello jerk: 'percentile' ignora i picchi isolati (utile
% quando un singolo outlier schiaccia tutto il grafico), 'max' usa il massimo
% assoluto come prima.
ylim_mode = 'percentile';
ylim_pct  = 99.5;      % percentile usato se ylim_mode = 'percentile'

%% ================= ESTRAZIONE E RICAMPIONAMENTO (filtro) =================
t_raw  = tt.stamp(:);
ax_raw = tt.ax(:, min(opp_idx, size(tt.ax,2)));

valid = ~isnan(t_raw) & ~isnan(ax_raw);
% NB: unique() ORDINATO (non 'stable'): interp1 richiede ascisse monotone,
% e gli stamp possono arrivare fuori ordine.
[t_v, iu] = unique(t_raw(valid));
ax_valid = ax_raw(valid);
ax_v = ax_valid(iu);

dt = median(diff(t_v));
fs = 1/dt;
t_u  = (t_v(1):dt:t_v(end)).';
ax_u = interp1(t_v, ax_v, t_u, 'linear');

fprintf('jerk_hysteresis: fs = %.1f Hz, N = %d campioni\n', fs, numel(t_u));

%% ================= GT: accelerazione e jerk =================
has_gt = exist('gt','var') && isstruct(gt) && isfield(gt,'stamp') && isfield(gt,'ax');
if has_gt
    t_gt_raw  = gt.stamp(:);
    ax_gt_raw = gt.ax(:, min(opp_idx, size(gt.ax,2)));
    ax_gt_raw(ax_gt_raw == 0) = nan;

    v_gt = ~isnan(t_gt_raw) & ~isnan(ax_gt_raw);
    [t_gt, ig] = unique(t_gt_raw(v_gt));
    ax_gt_valid = ax_gt_raw(v_gt);
    ax_gt = ax_gt_valid(ig);

    dt_gt  = median(diff(t_gt));
    t_gtu  = (t_gt(1):dt_gt:t_gt(end)).';
    ax_gtu = interp1(t_gt, ax_gt, t_gtu, 'linear');

    [b_g, a_g] = butter(gt_order, min(fc_gt/(1/dt_gt/2), 0.99));
    ax_gtu_f = filtfilt(b_g, a_g, ax_gtu);        % zero-phase
    jerk_gt  = gradient(ax_gtu_f, dt_gt);         % jerk di riferimento

    jerk_gt_on_tu = interp1(t_gtu, jerk_gt, t_u, 'linear');
else
    warning('jerk_hysteresis: GT non disponibile (use_ref?).');
    jerk_gt_on_tu = nan(size(t_u));
end

%% ================= JERK LOGGATO DAL FILTRO =================
has_logged = isfield(tt, 'jerk');
if has_logged
    j_raw = tt.jerk(:, min(opp_idx, size(tt.jerk,2)));
    vj = ~isnan(t_raw) & ~isnan(j_raw);
    [tj, ij] = unique(t_raw(vj));
    j_valid = j_raw(vj);
    j_v = j_valid(ij);
    jerk_logged = interp1(tj, j_v, t_u, 'linear');
else
    jerk_logged = nan(size(t_u));
    if use_logged
        warning('jerk_hysteresis: tt.jerk non presente nel log.');
    end
end

%% ================= JERK: BUTTERWORTH CAUSALE + DERIVATA =================
[b_bw, a_bw] = butter(bw_order, fc_bw/(fs/2));
ax_bw   = filter(b_bw, a_bw, ax_u);
jerk_bw = [0; diff(ax_bw)] / dt;

%% ================= JERK: DIRTY DERIVATIVE (Tustin) =================
b_dd = [2, -2] / (2*tau_dirty + dt);
a_dd = [1, (dt - 2*tau_dirty)/(2*tau_dirty + dt)];
jerk_dd = filter(b_dd, a_dd, ax_u);

%% ================= ISTERESI (Schmitt trigger, tempo continuo) ============
switch lower(hyst_source)
    case 'logged'; j_hyst = jerk_logged;   hyst_name = 'filter jerk';   hyst_shown = use_logged && has_logged;
    case 'bw';     j_hyst = jerk_bw;       hyst_name = sprintf('BW %g Hz', fc_bw);              hyst_shown = use_bw;
    case 'dirty';  j_hyst = jerk_dd;       hyst_name = sprintf('dirty \\tau=%.2fs', tau_dirty); hyst_shown = use_dirty;
    case 'gt';     j_hyst = jerk_gt_on_tu; hyst_name = 'GT jerk';       hyst_shown = use_gt && has_gt;
    otherwise
        error('hyst_source non valido: usa ''logged'', ''bw'', ''dirty'' o ''gt''.');
end

if ~hyst_shown
    warning(['jerk_hysteresis: la curva che pilota l''isteresi (%s) NON e'' tra ' ...
             'quelle attive: la banda grigia seguira'' un segnale non visibile. ' ...
             'Attiva la use_* corrispondente o cambia hyst_source.'], hyst_source);
end

% --- griglia infittita: cattura i crossing che cadono TRA due campioni -----
% Il segnale viene interpolato linearmente (stessa retta che vedi tracciata
% tra due marker nel plot), quindi il crossing trovato sulla griglia fine
% coincide con l'intersezione visiva curva/soglia.
n_up = max(1, round(hyst_upsample));
if n_up > 1
    t_h = linspace(t_u(1), t_u(end), (numel(t_u)-1)*n_up + 1).';
    j_h = interp1(t_u, j_hyst, t_h, 'linear');
else
    t_h = t_u;
    j_h = j_hyst;
end

a_h   = abs(j_h);
state = false;
t_on_list  = [];
t_off_list = [];

for k = 1:numel(a_h)
    a = a_h(k);
    if isnan(a); continue; end

    if ~state && a > thr_on
        % istante ESATTO di attraversamento della soglia ON: interpolo tra il
        % campione precedente (sotto soglia) e questo (sopra soglia)
        t_cross = t_h(k);
        if k > 1 && ~isnan(a_h(k-1)) && a_h(k-1) <= thr_on && a > a_h(k-1)
            w = (thr_on - a_h(k-1)) / (a - a_h(k-1));
            t_cross = t_h(k-1) + w*(t_h(k) - t_h(k-1));
        end
        t_on_list(end+1) = t_cross; %#ok<SAGROW>
        state = true;

    elseif state && a < thr_off
        t_cross = t_h(k);
        if k > 1 && ~isnan(a_h(k-1)) && a_h(k-1) >= thr_off && a < a_h(k-1)
            w = (a_h(k-1) - thr_off) / (a_h(k-1) - a);
            t_cross = t_h(k-1) + w*(t_h(k) - t_h(k-1));
        end
        t_off_list(end+1) = t_cross; %#ok<SAGROW>
        state = false;
    end
end

% se il trigger e' ancora attivo a fine log, chiudo l'ultimo intervallo
if state
    t_off_list(end+1) = t_h(end);
end

n_act = numel(t_on_list);
if n_act > 0
    dur_tot = sum(t_off_list(:) - t_on_list(:));
else
    dur_tot = 0;
end
fprintf(['Isteresi su %s (on %g / off %g, upsample %dx): %d attivazioni, ' ...
         '%.2f s totali (%.1f%%)\n'], ...
    hyst_name, thr_on, thr_off, n_up, n_act, dur_tot, ...
    100*dur_tot/(t_u(end)-t_u(1)));

%% ================= FIGURA =================
figure('Name','Jerk & hysteresis','NumberTitle','off'); f = f+1;
tl = tiledlayout(2,1,'TileSpacing','compact');
title(tl, sprintf('Accelerazione e jerk vs GT - opp %d', opp_idx), 'FontWeight','bold');

% ---------- (1) accelerazione vs GT ----------
ax1 = nexttile; hold on; grid on;
plot(t_u, ax_u, 'LineWidth', 1.0, 'DisplayName', 'a_x filtro');
if has_gt
    plot(t_gtu, ax_gtu_f, 'k', 'LineWidth', 1.4, 'DisplayName', 'a_x GT');
end
ylabel('a_x [m/s^2]');
compactLegend(ax1);
axes = [axes, ax1]; %#ok<AGROW>

% ---------- (2) jerk + soglie a isteresi ----------
ax2 = nexttile; hold on; grid on;

% limiti Y decisi PRIMA di disegnare le bande (servono per l'altezza patch)
j_all = [];
if use_logged && has_logged; j_all = [j_all; jerk_logged(:)]; end
if use_gt     && has_gt;     j_all = [j_all; jerk_gt(:)];     end
if use_bw;                   j_all = [j_all; jerk_bw(:)];     end
if use_dirty;                j_all = [j_all; jerk_dd(:)];     end
j_abs = abs(j_all(~isnan(j_all)));
if isempty(j_abs)
    y_ref = thr_on;
elseif strcmpi(ylim_mode, 'percentile')
    y_ref = prctile(j_abs, ylim_pct);
else
    y_ref = max(j_abs);
end
y_max = max(1.2*y_ref, 1.5*thr_on);
ylim([-y_max y_max]);

% sfondo grigio dove il trigger e' attivo (disegnato per primo -> resta dietro)
if show_hyst_shading && n_act > 0
    for k = 1:n_act
        patch('XData', [t_on_list(k) t_off_list(k) t_off_list(k) t_on_list(k)], ...
              'YData', [-y_max -y_max y_max y_max], ...
              'FaceColor', shade_color, 'FaceAlpha', shade_alpha, ...
              'EdgeColor', 'none', 'HandleVisibility', 'off');
    end
    % elemento fittizio solo per la voce di legenda
    patch('XData', nan(1,4), 'YData', nan(1,4), ...
          'FaceColor', shade_color, 'FaceAlpha', shade_alpha, 'EdgeColor', 'none', ...
          'DisplayName', sprintf('trigger ON (%s)', hyst_name));
end

% curve di jerk
if use_logged && has_logged
    plot(t_u, jerk_logged, 'LineWidth', 1.2, 'DisplayName', 'jerk filtro (loggato)');
end
if use_bw
    plot(t_u, jerk_bw, 'LineWidth', 1.0, ...
        'DisplayName', sprintf('BW ord %d, f_c=%g Hz', bw_order, fc_bw));
end
if use_dirty
    plot(t_u, jerk_dd, 'LineWidth', 1.0, ...
        'DisplayName', sprintf('dirty der. \\tau=%.2f s', tau_dirty));
end
if use_gt && has_gt
    plot(t_gtu, jerk_gt, 'k', 'LineWidth', 1.4, ...
        'DisplayName', sprintf('jerk GT (f_c=%g Hz)', fc_gt));
end

% se la curva pilota dell'isteresi non e' tra quelle attive, la disegno
% comunque tratteggiata: altrimenti la banda grigia sembra scollegata
if force_show_hyst_curve && ~hyst_shown
    if strcmpi(hyst_source, 'gt') && has_gt
        plot(t_gtu, jerk_gt, '--', 'Color', [0.4 0.4 0.4], 'LineWidth', 1.2, ...
            'DisplayName', sprintf('%s (pilota isteresi)', hyst_name));
    else
        plot(t_u, j_hyst, '--', 'Color', [0.4 0.4 0.4], 'LineWidth', 1.2, ...
            'DisplayName', sprintf('%s (pilota isteresi)', hyst_name));
    end
end

% linee di soglia
yline( thr_on,  'r--', 'LineWidth', 1.2, 'DisplayName', sprintf('soglia ON = %g', thr_on));
yline(-thr_on,  'r--', 'LineWidth', 1.2, 'HandleVisibility', 'off');
yline( thr_off, 'b:',  'LineWidth', 1.2, 'DisplayName', sprintf('soglia OFF = %g', thr_off));
yline(-thr_off, 'b:',  'LineWidth', 1.2, 'HandleVisibility', 'off');

ylabel('jerk [m/s^3]'); xlabel('t [s]');
compactLegend(ax2);
axes = [axes, ax2]; %#ok<AGROW>

clearvars compactLegend t_raw ax_raw valid iu t_v ax_v ax_valid ...
    t_gt_raw ax_gt_raw v_gt ig t_gt ax_gt ax_gt_valid b_g a_g ...
    j_raw vj tj ij j_v j_valid b_bw a_bw ax_bw b_dd a_dd ...
    j_hyst state k a d_act n_up t_h j_h a_h t_cross w ...
    n_act dur_tot j_all j_abs y_ref y_max ...
    ax1 ax2 tl has_gt has_logged hyst_shown