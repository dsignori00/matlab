%% FF_FLAG_JERK - accelerazione e jerk di piu' log, con bande ff_flag
%
% Figura unica, due pannelli della stessa dimensione:
%   (1) a_x   di ogni log (+ GT)
%   (2) jerk  di ogni log (+ GT), con bande dove ff_flag e' attivo
%
% Ogni log usa la PROPRIA accelerazione e il PROPRIO jerk: non si incrociano
% piu' sorgenti diverse. Per ciascuno si sceglie con un flag se usare i campi
% feed-forward o quelli standard:
%   use_ff_1 / use_ff_2 / use_ff_3 = true  -> ff_ax  (accelerazione)
%                                     false -> ax
% Il jerk e' sempre ax_dot (l'uscita C++), con in piu' la possibilita' di
% sovrapporre il jerk ricalcolato qui in MATLAB (Butterworth + derivata)
% sulla stessa accelerazione, per validare l'implementazione.
%
% NB: i campi ff_ax / ff_vx NON sono caricati da load_tt.m, quindi vengono
% letti dai log grezzi (log / log_2 / log_3). Gli 0 sono mascherati a NaN.
%
% Richiede in workspace: tt, log, opp_idx, f, axes, col
%                        (tt2/log_2, tt3/log_3 e gt opzionali).

%% ================= PARAMETRI =================
use_ff_1 = false;   % log 1: true -> ff_ax, false -> ax
use_ff_2 = true;    % log 2: idem
use_ff_3 = false;   % log 3: idem

show_logged = true;    % jerk loggato dal C++ (ax_dot) di ogni log
show_local  = false;    % jerk ricalcolato in MATLAB (BW + derivata) di ogni log
show_gt     = true;    % accelerazione e jerk della GT

% Butterworth per il jerk ricalcolato: DEVONO essere gli stessi del C++,
% altrimenti la differenza che vedi e' di taratura, non di implementazione.
fc_bw    = 5;          % [Hz] frequenza di taglio
bw_order = 2;          % ordine del filtro

% Ordine delle operazioni, da allineare a come e' scritto il C++.
% Sono equivalenti a meno del transitorio (operatori LTI, la convoluzione
% commuta), ma tenerli allineati elimina un dubbio in meno.
deriv_mode = 'filter_then_diff';   % 'filter_then_diff' | 'diff_then_filter'

fc_gt    = 7;          % [Hz] taglio zero-phase per derivare il jerk dalla GT
jerk_thr = 20;         % [m/s^3] soglia di riferimento (linea + statistiche)

% ff_flag: da quale log prendere le bande. 1 | 2 | 3 | 0 per nessuna.
ff_band_log = 1;
ff_shade_color = [0.85 0.55 0.20];
ff_shade_alpha = 0.18;

ylim_pct = 99.5;       % percentile per la scala Y (ignora outlier isolati)

% Fattore di scurimento per la curva tratteggiata (jerk ricalcolato in
% MATLAB): stesso colore del log moltiplicato per questo valore. 1 = identico,
% valori piu' bassi = piu' scuro.
dark_factor = 0.55;

%% ================= RACCOLTA LOG =================
% ogni riga: {struct tt*, log grezzo, flag ff, colore, etichetta di default}
defs = {};
if exist('tt','var')
    if exist('log','var');   r1 = log;   else; r1 = []; end
    defs(end+1,:) = {tt,  r1, use_ff_1, col.tt,  'log 1'};
end
if exist('tt2','var')
    if exist('log_2','var'); r2 = log_2; else; r2 = []; end
    defs(end+1,:) = {tt2, r2, use_ff_2, col.tt2, 'log 2'};
end
if exist('tt3','var')
    if exist('log_3','var'); r3 = log_3; else; r3 = []; end
    defs(end+1,:) = {tt3, r3, use_ff_3, col.tt3, 'log 3'};
end

curves = {};
for i = 1:size(defs,1)
    T      = defs{i,1};
    rawlog = defs{i,2};
    do_ff  = defs{i,3};
    c      = defs{i,4};
    if isfield(T,'name'); nm = T.name; else; nm = defs{i,5}; end

    % ---------- accelerazione ----------
    a = [];
    if do_ff
        if isfield(T, 'ff_ax')
            a = T.ff_ax;
        elseif ~isempty(rawlog) && isfield(rawlog, 'perception__opponents') && ...
                isfield(rawlog.perception__opponents, 'opponents__ff_ax')
            a = rawlog.perception__opponents.opponents__ff_ax;
        end
        tag = 'ff\_';
        if isempty(a)
            warning('ff_flag_jerk: ff_ax non trovato per %s - log saltato.', nm);
            continue;
        end
    else
        if isfield(T,'ax'); a = T.ax; end
        tag = '';
        if isempty(a)
            warning('ff_flag_jerk: ax non trovato per %s - log saltato.', nm);
            continue;
        end
    end
    a = a(:, min(opp_idx, size(a,2)));
    a(a == 0) = nan;

    % ---------- jerk loggato (ax_dot) ----------
    j = [];
    if isfield(T, 'jerk')
        j = T.jerk;
    elseif isfield(T, 'ax_dot')
        j = T.ax_dot;
    elseif ~isempty(rawlog) && isfield(rawlog, 'perception__opponents') && ...
            isfield(rawlog.perception__opponents, 'opponents__ax_dot')
        j = rawlog.perception__opponents.opponents__ax_dot;
    end
    if ~isempty(j)
        j = j(:, min(opp_idx, size(j,2)));
        j(j == 0) = nan;
    end

    % ---------- jerk ricalcolato in MATLAB sulla STESSA accelerazione ------
    jl = []; t_loc = [];
    if show_local
        tt_raw = T.stamp(:);
        vv = ~isnan(tt_raw) & ~isnan(a);
        if nnz(vv) > 10
            [t_vv, iu] = unique(tt_raw(vv));    % ordinato: interp1 vuole
            a_vv = a(vv); a_vv = a_vv(iu);      % ascisse monotone
            dt_i = median(diff(t_vv));
            t_loc = (t_vv(1):dt_i:t_vv(end)).';
            a_loc = interp1(t_vv, a_vv, t_loc, 'linear');
            [b_i, a_i] = butter(bw_order, fc_bw/((1/dt_i)/2));
            switch lower(deriv_mode)
                case 'filter_then_diff'
                    jl = [0; diff(filter(b_i, a_i, a_loc))] / dt_i;
                case 'diff_then_filter'
                    jl = filter(b_i, a_i, [0; diff(a_loc)] / dt_i);
                otherwise
                    error('deriv_mode non valido.');
            end
        end
    end

    S.stamp = T.stamp(:);
    S.ax = a; S.jerk = j; S.jerk_loc = jl; S.t_loc = t_loc;
    S.col = c; S.name = nm; S.tag = tag;
    curves{end+1} = S; %#ok<SAGROW>

    if do_ff; src_txt = 'ff_ax'; else; src_txt = 'ax'; end
    fprintf('ff_flag_jerk: %s -> accelerazione %s\n', nm, src_txt);
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
    ax_gt_f   = filtfilt(b_g, a_g, ax_gtu);
    jerk_gt_f = gradient(ax_gt_f, dt_gt);
end

%% ================= FF_FLAG (bande) =================
ff_t = []; ff_on = [];
if ff_band_log >= 1 && ff_band_log <= size(defs,1)
    Tf     = defs{ff_band_log,1};
    rawf   = defs{ff_band_log,2};
    if isfield(Tf,'name'); ff_name = Tf.name; else; ff_name = defs{ff_band_log,5}; end

    ff_all = [];
    if isfield(Tf, 'ff_flag')
        ff_all = Tf.ff_flag;
    elseif ~isempty(rawf) && isfield(rawf, 'perception__opponents') && ...
            isfield(rawf.perception__opponents, 'opponents__ff_flag')
        ff_all = rawf.perception__opponents.opponents__ff_flag;
    end

    if ~isempty(ff_all)
        % NB: 0 e' un valore LEGITTIMO (flag basso), NON un placeholder:
        % non va mascherato a NaN come gli altri campi.
        ffc = double(ff_all(:, min(opp_idx, size(ff_all,2))));
        tfr = Tf.stamp(:);
        vf  = ~isnan(tfr) & ~isnan(ffc);
        [ff_t, iff] = unique(tfr(vf));
        ffv = ffc(vf);
        ff_on = ffv(iff) > 0.5;

        d_ff     = diff([false; ff_on(:); false]);
        ff_start = find(d_ff ==  1);
        ff_stop  = find(d_ff == -1) - 1;
        n_ff     = numel(ff_start);
        fprintf('ff_flag da %s: %d attivazioni, duty %.1f%% del tempo\n', ...
            ff_name, n_ff, 100*nnz(ff_on)/numel(ff_on));
    else
        n_ff = 0;
        warning('ff_flag_jerk: ff_flag non trovato nel log %d.', ff_band_log);
    end
else
    n_ff = 0;
end

%% ================= FIGURA =================
figure('Name','Accelerazione e jerk (+ ff_flag)','NumberTitle','off'); f = f+1;
tl = tiledlayout(2,1,'TileSpacing','compact');
title(tl, sprintf('Accelerazione e jerk - opp %d', opp_idx), 'FontWeight','bold');

% ---- (1) accelerazione ----
axa = nexttile; hold on; grid on;
for i = 1:numel(curves)
    S = curves{i};
    plot(S.stamp, S.ax, '-', 'Color', S.col, 'LineWidth', 1.3, ...
        'DisplayName', sprintf('%s: %sax', S.name, S.tag));
end
if has_gt
    plot(t_gtu, ax_gt_f, '-', 'Color', col.ref, 'LineWidth', 1.5, ...
        'DisplayName', sprintf('gt (f_c=%g Hz)', fc_gt));
end
ylabel('a_x [m/s^2]');
legend('Location','eastoutside','FontSize',8,'Box','off');
axes = [axes, axa]; %#ok<AGROW>

% ---- (2) jerk ----
axj = nexttile; hold on; grid on;

% scala Y decisa prima delle patch (servono per l'altezza)
jall = [];
for i = 1:numel(curves)
    if show_logged && ~isempty(curves{i}.jerk);     jall = [jall; curves{i}.jerk(:)];     end %#ok<AGROW>
    if show_local  && ~isempty(curves{i}.jerk_loc); jall = [jall; curves{i}.jerk_loc(:)]; end %#ok<AGROW>
end
if has_gt; jall = [jall; jerk_gt_f(:)]; end
jall = abs(jall(~isnan(jall)));
if isempty(jall)
    yf = max(jerk_thr, 1);
else
    yf = max(prctile(jall, ylim_pct), 1.5*jerk_thr);
end
ylim([-yf yf]);

% bande ff_flag (disegnate per prime -> restano sullo sfondo)
for k = 1:n_ff
    patch('XData', [ff_t(ff_start(k)) ff_t(ff_stop(k)) ...
                    ff_t(ff_stop(k))  ff_t(ff_start(k))], ...
          'YData', [-yf -yf yf yf], ...
          'FaceColor', ff_shade_color, 'FaceAlpha', ff_shade_alpha, ...
          'EdgeColor', 'none', 'HandleVisibility', 'off');
end
if n_ff > 0
    patch('XData', nan(1,4), 'YData', nan(1,4), ...
          'FaceColor', ff_shade_color, 'FaceAlpha', ff_shade_alpha, ...
          'EdgeColor', 'none', 'DisplayName', sprintf('ff\\_flag ON (%s)', ff_name));
end

for i = 1:numel(curves)
    S = curves{i};
    if show_logged && ~isempty(S.jerk)
        plot(S.stamp, S.jerk, '-', 'Color', S.col, 'LineWidth', 1.3, ...
            'DisplayName', sprintf('%s: ax\\_dot', S.name));
    end
    if show_local && ~isempty(S.jerk_loc)
        % stesso colore del log ma piu' scuro: migliora la leggibilita'
        % quando continua (ax_dot) e tratteggiata (BW locale) si sovrappongono
        col_dark = S.col * dark_factor;
        plot(S.t_loc, S.jerk_loc, '--', 'Color', col_dark, 'LineWidth', 1.0, ...
            'DisplayName', sprintf('%s: BW ord %d, f_c=%g Hz', S.name, bw_order, fc_bw));
    end
end
if has_gt
    plot(t_gtu, jerk_gt_f, '-', 'Color', col.ref, 'LineWidth', 1.5, ...
        'DisplayName', 'gt jerk');
end
yline( jerk_thr, 'r--', 'HandleVisibility','off');
yline(-jerk_thr, 'r--', 'DisplayName', sprintf('soglia %g', jerk_thr));
ylabel('jerk [m/s^3]'); xlabel('t [s]');
legend('Location','eastoutside','FontSize',8,'Box','off');
axes = [axes, axj]; %#ok<AGROW>

%% ---- verifica C++ vs MATLAB, per ogni log ----
if show_logged && show_local
    for i = 1:numel(curves)
        S = curves{i};
        if isempty(S.jerk) || isempty(S.jerk_loc); continue; end
        % il jerk loggato sta su S.stamp, quello locale su S.t_loc:
        % riporto il primo sulla griglia del secondo
        vv = ~isnan(S.stamp) & ~isnan(S.jerk);
        if nnz(vv) < 10; continue; end
        [ts, iu2] = unique(S.stamp(vv));
        js = S.jerk(vv); js = js(iu2);
        j_on = interp1(ts, js, S.t_loc, 'linear');

        m = ~isnan(j_on) & ~isnan(S.jerk_loc);
        n_sk = min(round(2/median(diff(S.t_loc))), nnz(m)-1);
        idx = find(m); idx = idx(n_sk+1:end);
        if numel(idx) < 10; continue; end

        er = j_on(idx) - S.jerk_loc(idx);
        cc = corrcoef(S.jerk_loc(idx), j_on(idx));
        fprintf(['%s | C++ vs MATLAB: RMSE %.3f | max %.3f | bias %+.3f | ' ...
                 'corr %.4f\n'], S.name, sqrt(mean(er.^2)), max(abs(er)), ...
                 mean(er), cc(1,2));
    end
end

clearvars defs r1 r2 r3 curves i T rawlog do_ff c nm a j jl t_loc tag S src_txt ...
    tt_raw vv t_vv iu a_vv dt_i a_loc b_i a_i ...
    tg_raw ag_raw vg t_gt ig ag_v dt_gt ax_gtu b_g a_g has_gt ...
    Tf rawf ff_all ffc tfr vf iff ffv d_ff ff_start ff_stop ff_t ff_on ...
    tl axa axj jall yf k ts iu2 js j_on m n_sk idx er cc col_dark dark_factor