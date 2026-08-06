%% JERK_FILTERING - jerk estimation from the high-Q filter, compared to GT
% Called from the main script (jerk_derivation style).
% Uses: tt, gt, opp_idx, axes, f      (requires use_ref/use_sim_ref active)
%
% Methods to estimate j = d(ax)/dt from the high-Q filter:
%   1) CAUSAL Butterworth LPF on ax -> derivative (online-implementable)
%   2) ACAUSAL Wiener (offline benchmark: LTI lower bound)
%   3) CAUSAL Savitzky-Golay (endpoint) -> derivative at the last sample
%   4) ACAUSAL Savitzky-Golay (centered window, offline only)
%   5) dirty derivative s/(tau*s+1), Tustin-discretized
%   6) causal Elliptic + derivative
%   7) causal Chebyshev II + derivative
% Reference: GT (acceleration and jerk derived from GT acceleration)
% Extra figure: GT jerk derived causally vs acausally (zero-phase)
%
% NOTA sul confronto a_x: la curva "GT" del pannello accelerazione NON e' la
% GT grezza, ma la GT filtrata zero-phase a fc_gt (serve per derivare il jerk
% di riferimento senza amplificare rumore). Confrontare una stima NON filtrata
% con una GT filtrata e' asimmetrico: attiva plot_gt_raw per sovrapporre anche
% la GT grezza e capire quanta della differenza e' rumore vero e quanta e'
% smoothing introdotto da fc_gt.

%% ------------------- HELPER: compact legend outside the axes ------------
% Places the legend to the EAST (right of the axes) with small font, so it
% doesn't eat plot space. Change 'eastoutside' to 'southoutside' for below.
compactLegend = @(ax) set(legend(ax), 'Location', 'eastoutside', ...
    'FontSize', 8, 'Box', 'off');

%% ------------------- PARAMETERS -------------------
% Text interpreter -> 'tex' (MATLAB factory default): tolerates single _ and
% ^ (a_x, m/s^2, f_c). If the environment forces 'latex', those symbols
% outside $...$ throw "valid interpreter syntax" when linkaxes refreshes.
set(groot, 'defaultAxesTickLabelInterpreter', 'tex');
set(groot, 'defaultTextInterpreter', 'tex');
set(groot, 'defaultLegendInterpreter', 'tex');

fc_lpf      = 2;      % [Hz] Butterworth cutoff on estimated ax (reference band)
bw_order    = 2;      % causal Butterworth order
fc_gt       = 5;      % [Hz] cutoff (zero-phase) to derive jerk from GT
jerk_thr    = 25;     % [m/s^3] jerk trigger threshold (to tune)

mask_gt_zeros = true; % true -> gli 0 nella GT sono placeholder "no data" e
                      % diventano NaN (evita transitori finti nel filtfilt)

% Il jerk loggato si chiama ax_dot nel messaggio. mask_jerk_zeros = true
% tratta gli 0 come placeholder "no data"; se nel tuo log lo 0 e' un valore
% legittimo (jerk nullo), mettilo a false, altrimenti azzeri tutto il segnale.
mask_jerk_zeros = true;

% --- curves to PLOT (computation happens regardless) ---
plot_bw      = true;   % causal Butterworth
plot_wiener  = false;  % acausal Wiener (benchmark)
plot_sg      = false;   % causal Savitzky-Golay (endpoint)
plot_sg_ac   = false;   % acausal Savitzky-Golay (centered)
plot_dirty   = false;  % dirty derivative
plot_ellip   = false;  % Elliptic
plot_cheby2  = false;  % Chebyshev II
plot_tt_jerk = true;   % logged jerk from the filter (if present)
plot_gt_raw  = false;   % sovrappone la GT GREZZA (non filtrata) nel pannello a_x

% --- Elliptic (Cauer) ---
ell_order   = 3;      % Elliptic filter order
ell_rp      = 0.5;    % [dB] passband ripple
ell_rs      = 40;     % [dB] minimum stopband attenuation

% --- Chebyshev type II ---
cby_order   = 3;      % Chebyshev II order
cby_rs      = 40;     % [dB] minimum stopband attenuation

match_bandwidth = true;  % true -> tau_dirty derived from fc_lpf (dirty derivative)
sg_order    = 3;      % Savitzky-Golay polynomial order (causal and acausal)
sg_frame    = 11;      % SG TOTAL window in samples (odd for the acausal one)
tau_dirty   = 0.03;   % [s], used only if match_bandwidth = false

do_sg_tuning = false;  % true -> (sg_order, sg_frame) map: RMSE jerk vs GT
do_tuning    = false;  % true -> fc_lpf sweep: delay vs RMSE vs GT
do_psd       = false;  % true -> acceleration PSD figure (Welch)
do_psd_jerk  = false;   % true -> jerk PSD of the methods vs GT jerk
do_gt_causal = false;   % true -> GT jerk causal vs acausal figure
do_ff_flag   = false;   % true -> figura ff_flag vs jerk stimato/loggato

% --- figura ff_flag ---
ff_shade_color = [0.85 0.55 0.20];  % colore banda dove ff_flag = true
ff_shade_alpha = 0.18;

% --- time window(s) for PSD computation (do_psd / do_psd_jerk) -----------
% Each ROW is a window [t_start t_end], in the same time base as tt.stamp /
% t_u (i.e. what you see on the x-axis of the main plot). Use -Inf/Inf to
% leave a bound open (clamped to the actual data extent automatically).
% Default: a single window spanning the whole bag (previous behaviour).
%   Example, one restricted window:      psd_windows = [12 28];
%   Example, compare two windows:        psd_windows = [5 20; 45 70];
psd_windows = [-inf inf];

%% ------------------- EXTRACTION AND RESAMPLING (high-Q) -----------------
t_raw  = tt.stamp(:);
ax_raw = log.perception__opponents.opponents__ff_ax(:, opp_idx);

valid = ~isnan(t_raw) & ~isnan(ax_raw);
t_valid  = t_raw(valid);
ax_valid = ax_raw(valid);

% NB: unique() ORDINATO (non 'stable'): interp1 richiede ascisse monotone e
% gli stamp possono arrivare fuori ordine -> con 'stable' i risultati sono
% silenziosamente sbagliati.
[t_v, iu] = unique(t_valid);
ax_v = ax_valid(iu);

dt = median(diff(t_v));
fs = 1/dt;
t_u  = (t_v(1):dt:t_v(end)).';
ax_u = interp1(t_v, ax_v, t_u, 'linear');

fprintf('jerk_filtering: mean fs = %.1f Hz, N = %d samples\n', fs, numel(t_u));

%% ------------------- BANDWIDTH MATCH (dirty derivative) -----------------
if match_bandwidth
    tau_dirty = 1/(2*pi*fc_lpf);
end
fprintf(['Common band fc = %g Hz  ->  tau_dirty = %.3f s | ' ...
         'SG: order %d, frame %d (%.2f s)\n'], ...
    fc_lpf, tau_dirty, sg_order, sg_frame, sg_frame*dt);

%% ------------------- GT: ACCELERATION AND JERK -------------------------
has_gt = exist('gt','var') && isstruct(gt) && isfield(gt,'stamp') && isfield(gt,'ax');
if has_gt
    t_gt_raw  = gt.stamp(:);
    ax_gt_raw = gt.ax;
    if size(ax_gt_raw, 2) > 1
        ax_gt_raw = ax_gt_raw(:, min(opp_idx, size(ax_gt_raw,2)));
    end
    ax_gt_raw = ax_gt_raw(:);

    % gli 0 sono placeholder "no data" (stessa convenzione di load_tt): se
    % restano, entrano nel filtfilt come valori veri e creano gradini finti
    if mask_gt_zeros
        n_zero_gt = nnz(ax_gt_raw == 0);
        ax_gt_raw(ax_gt_raw == 0) = nan;
        if n_zero_gt > 0
            fprintf('GT a_x: %d campioni a zero mascherati come NaN\n', n_zero_gt);
        end
    end

    v_gt = ~isnan(t_gt_raw) & ~isnan(ax_gt_raw);
    t_gt_valid  = t_gt_raw(v_gt);
    ax_gt_valid = ax_gt_raw(v_gt);
    [t_gt, ig] = unique(t_gt_valid);
    ax_gt = ax_gt_valid(ig);

    dt_gt = median(diff(t_gt));
    t_gtu  = (t_gt(1):dt_gt:t_gt(end)).';
    ax_gtu = interp1(t_gt, ax_gt, t_gtu, 'linear');

    [b_gt, a_gt] = butter(2, min(fc_gt/(1/dt_gt/2), 0.99));
    ax_gtu_f  = filtfilt(b_gt, a_gt, ax_gtu);
    jerk_gt   = gradient(ax_gtu_f, dt_gt);          % ACAUSAL (reference)

    % CAUSAL version of the same procedure (same filter, filter + backward
    % difference): shows how much delay/attenuation causality alone adds,
    % all else being equal
    ax_gtu_c     = filter(b_gt, a_gt, ax_gtu);
    jerk_gt_caus = [0; diff(ax_gtu_c)] / dt_gt;

    ax_gt_on_tu   = interp1(t_gtu, ax_gtu_f, t_u, 'linear');
    jerk_gt_on_tu = interp1(t_gtu, jerk_gt,  t_u, 'linear');

    % quanto smoothing introduce fc_gt sulla GT (std del residuo grezzo-filtrato)
    fprintf('GT a_x: std grezza %.3f | std filtrata %.3f | std residuo %.3f m/s^2\n', ...
        std(ax_gtu,'omitnan'), std(ax_gtu_f,'omitnan'), std(ax_gtu - ax_gtu_f,'omitnan'));
else
    warning('jerk_filtering: gt unavailable (use_ref?) - plotting without reference');
end

%% ------------------- LOGGED JERK: ax_dot -------------------------------
% Il jerk loggato si chiama ax_dot nel messaggio ([m/s^3] X jerk). Lo leggo
% con questa priorita':
%   1) direttamente da log.perception__opponents.opponents__ax_dot (sorgente
%      esplicita: nessun dubbio su cosa load_tt abbia mappato)
%   2) tt.ax_dot        (se load_tt viene esteso in futuro)
%   3) tt.jerk          (load_tt attuale rimappa ax_dot qui, ma prova prima
%                        altri nomi: se nel log esistesse opponents__jerk,
%                        tt.jerk conterrebbe QUELLO, non ax_dot)
jerk_tt_all   = [];
jerk_src_name = '';
if exist('log','var') && isfield(log, 'perception__opponents') && ...
        isfield(log.perception__opponents, 'opponents__ax_dot')
    jerk_tt_all   = log.perception__opponents.opponents__ax_dot;
    jerk_src_name = 'log.perception__opponents.opponents__ax_dot';
elseif isfield(tt, 'ax_dot')
    jerk_tt_all   = tt.ax_dot;
    jerk_src_name = 'tt.ax_dot';
elseif isfield(tt, 'jerk')
    jerk_tt_all   = tt.jerk;
    jerk_src_name = 'tt.jerk';
end

has_tt_jerk = false;
if ~isempty(jerk_tt_all)
    jerk_tt_raw = jerk_tt_all(:, min(opp_idx, size(jerk_tt_all,2)));
    n_nz = nnz(jerk_tt_raw ~= 0 & ~isnan(jerk_tt_raw));
    if mask_jerk_zeros
        jerk_tt_raw(jerk_tt_raw == 0) = nan;
    end

    vj = ~isnan(t_raw) & ~isnan(jerk_tt_raw);
    % servono almeno 2 nodi distinti, altrimenti interp1 va in errore
    if nnz(vj) >= 2
        tj_valid  = t_raw(vj);
        jt_valid  = jerk_tt_raw(vj);
        [tj, ij]  = unique(tj_valid);
        jerk_tt_v = jt_valid(ij);
        if numel(tj) >= 2
            jerk_tt_u   = interp1(tj, jerk_tt_v, t_u, 'linear');
            has_tt_jerk = true;
            fprintf('Logged jerk (ax_dot) da %s: %d campioni validi su %d\n', ...
                jerk_src_name, nnz(vj), numel(jerk_tt_raw));
        end
    end

    if ~has_tt_jerk
        warning(['jerk_filtering: %s esiste ma non ha campioni utilizzabili ' ...
                 '(%d valori non nulli su %d). Il jerk loggato non viene usato. ' ...
                 'Se lo zero e'' un valore legittimo, metti mask_jerk_zeros = false.'], ...
                 jerk_src_name, n_nz, numel(jerk_tt_raw));
    end
else
    warning('jerk_filtering: ax_dot non trovato (ne'' nel log, ne'' in tt).');
end
if ~has_tt_jerk
    jerk_tt_u = nan(size(t_u));
end

%% ------------------- FF_FLAG (process noise feed-forward) ---------------
% bool per-avversario: indica se il feed-forward sul process noise e' attivo.
% NB: 0 e' un valore LEGITTIMO (flag basso), quindi NON va mascherato come
% placeholder. Ricampionamento 'previous' (zero-order hold): e' uno stato
% discreto, non un segnale continuo da interpolare linearmente.
ff_all = [];
if isfield(tt, 'ff_flag')
    ff_all = tt.ff_flag;
elseif exist('log','var') && isfield(log, 'perception__opponents') && ...
        isfield(log.perception__opponents, 'opponents__ff_flag')
    ff_all = log.perception__opponents.opponents__ff_flag;
end

has_ff = false;
if ~isempty(ff_all)
    ff_col = double(ff_all(:, min(opp_idx, size(ff_all,2))));
    vf = ~isnan(t_raw) & ~isnan(ff_col);
    if nnz(vf) >= 2
        tf_valid = t_raw(vf);
        ff_valid = ff_col(vf);
        [tf, iff] = unique(tf_valid);
        ff_v = ff_valid(iff);
        if numel(tf) >= 2
            ff_u = interp1(tf, ff_v, t_u, 'previous', 'extrap') > 0.5;
            has_ff = true;
        end
    end
end

if has_ff
    d_ff     = diff([false; ff_u(:); false]);
    ff_start = find(d_ff ==  1);
    ff_stop  = find(d_ff == -1) - 1;
    n_ff     = numel(ff_start);
    ff_duty  = 100 * nnz(ff_u) / numel(ff_u);
    fprintf('ff_flag: %d attivazioni, duty %.1f%% del tempo\n', n_ff, ff_duty);
else
    ff_u = false(size(t_u));
    n_ff = 0;
    if do_ff_flag
        warning('jerk_filtering: ff_flag non utilizzabile - figura saltata.');
    end
end

%% ------------------- 1) CAUSAL BUTTERWORTH + DERIVATIVE -----------------
[b_bw, a_bw] = butter(bw_order, fc_lpf/(fs/2));
ax_bw_causal = filter(b_bw, a_bw, ax_u);
jerk_bw_causal = [0; diff(ax_bw_causal)] / dt;

%% ------------------- 2) ACAUSAL WIENER (offline benchmark) --------------
% LTI lower bound: S_true from GT PSD, S_noise as spectral excess of the
% estimate over GT (robust to time misalignment).
if has_gt
    ax_c = ax_u - mean(ax_u,'omitnan'); ax_c(isnan(ax_c)) = 0;
    ag_c = ax_gt_on_tu - mean(ax_gt_on_tu,'omitnan'); ag_c(isnan(ag_c)) = 0;
    Nw = numel(ax_c);
    Ax = fft(ax_c); Ag = fft(ag_c);

    sm = @(P) real(ifft(fft(P) .* fft(ones(min(15,Nw),1)/min(15,Nw), Nw)));
    Sax   = sm(abs(Ax).^2);
    Strue = sm(abs(Ag).^2);
    Snoise = max(Sax - Strue, 0);
    Wgain = Strue ./ max(Strue + Snoise, eps);

    kfreq = [0:floor(Nw/2), -(ceil(Nw/2)-1):-1].';
    jw = 1i * 2*pi * (kfreq / (Nw*dt));
    jerk_wiener = real(ifft(jw .* Wgain .* Ax));
else
    jerk_wiener = nan(size(ax_u));
    warning('jerk_filtering: Wiener requires GT - benchmark not computed.');
end

%% ------------------- 3) CAUSAL SAVITZKY-GOLAY (endpoint) ----------------
% Polynomial fit over the LAST sg_frame samples, derivative at the endpoint:
% FIR on past samples only, online-implementable.
xw   = (-(sg_frame-1):0).';
A_sg = xw .^ (0:sg_order);
W_sg = pinv(A_sg);
w_d1 = W_sg(2, :);
jerk_sg = filter(fliplr(w_d1), 1, ax_u) / dt;

%% ------------------- 4) ACAUSAL SAVITZKY-GOLAY (centered) ---------------
% Same (order, window) but CENTERED window: derivative at the center, uses
% future samples too -> zero phase delay but offline only. Comparing it to
% the causal one shows the cost of causality at equal smoothing.
sg_frame_ac = sg_frame; if mod(sg_frame_ac,2)==0; sg_frame_ac = sg_frame_ac+1; end
[~, g_sgac] = sgolay(sg_order, sg_frame_ac);
jerk_sg_ac = conv(ax_u, factorial(1)/(-dt)^1 * g_sgac(:,2), 'same');

%% ------------------- 5) DIRTY DERIVATIVE (Tustin) -----------------------
b_dd = [2, -2] / (2*tau_dirty + dt);
a_dd = [1, (dt - 2*tau_dirty)/(2*tau_dirty + dt)];
jerk_dirty = filter(b_dd, a_dd, ax_u);

%% ------------------- 6) CAUSAL ELLIPTIC + DERIVATIVE --------------------
% fc_lpf = PASSBAND edge (end of ripple): the filter "starts filtering" at
% fc by construction.
[b_el, a_el] = ellip(ell_order, ell_rp, ell_rs, fc_lpf/(fs/2));
ax_el_causal = filter(b_el, a_el, ax_u);
jerk_ellip = [0; diff(ax_el_causal)] / dt;

%% ------------------- 7) CAUSAL CHEBYSHEV II + DERIVATIVE ----------------
% Aligned to -3 dB at fc_lpf via bisection on the stopband edge (valid:
% monotone passband response).
w_target = fc_lpf/(fs/2);
g3 = 1/sqrt(2);
Ws_lo = w_target; Ws_hi = min(0.999, w_target*4);
for it = 1:40
    Ws = 0.5*(Ws_lo + Ws_hi);
    [bt, at] = cheby2(cby_order, cby_rs, Ws);
    hh = freqz(bt, at, [w_target*pi, w_target*pi]);
    g = abs(hh(1));
    if g > g3
        Ws_hi = Ws;
    else
        Ws_lo = Ws;
    end
end
[b_cb, a_cb] = cheby2(cby_order, cby_rs, Ws);
ax_cb_causal = filter(b_cb, a_cb, ax_u);
jerk_cheby2 = [0; diff(ax_cb_causal)] / dt;
fprintf('Cheby II: -3 dB at %.2f Hz (stopband edge %.2f Hz)\n', fc_lpf, Ws*(fs/2));

%% ------------------- PSD TIME WINDOWS ------------------------------------
% Resolve psd_windows (which may contain -Inf/Inf) to concrete bounds
% clamped to the actual extent of t_u, and build a display label per window.
n_psd_win = size(psd_windows, 1);
psd_win_bounds = psd_windows;
psd_win_bounds(isinf(psd_win_bounds(:,1)), 1) = t_u(1);
psd_win_bounds(isinf(psd_win_bounds(:,2)), 2) = t_u(end);
psd_win_bounds(:,1) = max(psd_win_bounds(:,1), t_u(1));
psd_win_bounds(:,2) = min(psd_win_bounds(:,2), t_u(end));
psd_win_labels = arrayfun(@(k) sprintf('[%.1f-%.1f]s', psd_win_bounds(k,1), psd_win_bounds(k,2)), ...
    (1:n_psd_win)', 'UniformOutput', false);

%% ------------------- MAIN PLOT -------------------
figure('Name','Jerk filtering','NumberTitle','off'); f = f+1;
tl = tiledlayout(2,1,'TileSpacing','compact');

% --- ax
ax1 = nexttile; hold on; grid on;
plot(t_u, ax_u, 'LineWidth', 0.9, 'DisplayName', 'a_x high-Q');
if has_gt
    % GT grezza (non filtrata): mostra quanto pesa fc_gt sul confronto
    if plot_gt_raw
        plot(t_gtu, ax_gtu, '-', 'Color', [0.55 0.55 0.55], 'LineWidth', 0.8, ...
            'DisplayName', 'GT raw (no filter)');
    end
    plot(t_gtu, ax_gtu_f, 'k', 'LineWidth', 1.2, ...
        'DisplayName', sprintf('GT filtered (f_c=%g Hz)', fc_gt));
end
ylabel('a_x [m/s^2]'); compactLegend(ax1);
title(tl, sprintf('Jerk from high-Q filter vs GT - opp %d', opp_idx), ...
    'FontWeight', 'bold');
axes = [axes, ax1]; %#ok<AGROW>

% --- jerk (curves selectable via plot_* flags)
ax2 = nexttile; hold on; grid on;
if plot_bw
    plot(t_u, jerk_bw_causal, 'LineWidth', 1.0, 'DisplayName', sprintf('BW causal ord %d + diff', bw_order));
end
if plot_wiener
    plot(t_u, jerk_wiener, 'LineWidth', 1.0, 'DisplayName', 'Wiener (benchmark)');
end
if plot_sg
    plot(t_u, jerk_sg, 'LineWidth', 0.8, 'DisplayName', sprintf('SG causal (ord %d, frame %d)', sg_order, sg_frame));
end
if plot_sg_ac
    plot(t_u, jerk_sg_ac, 'LineWidth', 0.8, 'DisplayName', sprintf('SG acausal (ord %d, frame %d)', sg_order, sg_frame_ac));
end
if plot_dirty
    plot(t_u, jerk_dirty, 'LineWidth', 0.8, 'DisplayName', sprintf('dirty der. \\tau=%.2fs', tau_dirty));
end
if plot_ellip
    plot(t_u, jerk_ellip, 'LineWidth', 0.8, 'DisplayName', sprintf('Elliptic ord %d (rp %.1f dB)', ell_order, ell_rp));
end
if plot_cheby2
    plot(t_u, jerk_cheby2, 'LineWidth', 0.8, 'DisplayName', sprintf('Cheby II ord %d (rs %d dB)', cby_order, cby_rs));
end
if plot_tt_jerk && has_tt_jerk
    plot(t_u, jerk_tt_u, 'k--', 'LineWidth', 1.2, 'DisplayName', 'filter jerk (ax\_dot)');
end
if has_gt
    plot(t_gtu, jerk_gt, 'k', 'LineWidth', 1.2, 'DisplayName', 'GT jerk');
end
yline( jerk_thr, 'r--', 'HandleVisibility','off');
yline(-jerk_thr, 'r--', 'DisplayName', 'jerk threshold');
ylabel('jerk [m/s^3]'); xlabel('t [s]'); compactLegend(ax2);
ylim([-1 1]*max(4*jerk_thr, 1.2*max(abs(jerk_bw_causal),[],'omitnan')));
axes = [axes, ax2]; %#ok<AGROW>

%% ------------------- FIGURE: FF_FLAG vs JERK ----------------------------
% Confronto tra l'attivazione del feed-forward sul process noise (ff_flag,
% deciso a bordo) e il jerk: quello che ricostruisco qui offline dalla a_x
% stimata, e quello loggato dal filtro (ax_dot). Serve a capire se il
% trigger di bordo e' consistente con l'entita' del jerk osservato.
if do_ff_flag && has_ff
    figure('Name','ff_flag vs jerk','NumberTitle','off'); f = f+1;
    tlf = tiledlayout(2,1,'TileSpacing','compact');
    title(tlf, sprintf('ff\\_flag vs jerk - opp %d', opp_idx), 'FontWeight','bold');

    % ---- (1) jerk, con banda dove ff_flag e' attivo ----
    axf1 = nexttile; hold on; grid on;

    % scala Y decisa prima delle patch (servono per l'altezza)
    jf_all = [];
    if plot_bw;                   jf_all = [jf_all; jerk_bw_causal(:)]; end
    if plot_dirty;                jf_all = [jf_all; jerk_dirty(:)];     end
    if has_tt_jerk;               jf_all = [jf_all; jerk_tt_u(:)];      end
    if has_gt;                    jf_all = [jf_all; jerk_gt(:)];        end
    jf_abs = abs(jf_all(~isnan(jf_all)));
    if isempty(jf_abs)
        yf = max(jerk_thr, 1);
    else
        yf = max(prctile(jf_abs, 99.5), 1.5*jerk_thr);
    end
    ylim([-yf yf]);

    % bande dove ff_flag = true: UNA sola patch con n_ff facce (X e Y sono
    % matrici 4 x n_ff). Con centinaia di attivazioni, creare una patch per
    % intervallo + uistack rende il plot lentissimo.
    if n_ff > 0
        Xff = [t_u(ff_start), t_u(ff_stop), t_u(ff_stop), t_u(ff_start)].';
        Yff = repmat([-yf; -yf; yf; yf], 1, n_ff);
        patch(Xff, Yff, ff_shade_color, 'FaceAlpha', ff_shade_alpha, ...
              'EdgeColor', 'none', 'DisplayName', 'ff\_flag ON');
    end

    % jerk ricostruito qui (locale)
    if plot_bw
        plot(t_u, jerk_bw_causal, 'LineWidth', 1.0, ...
            'DisplayName', sprintf('locale: BW ord %d, f_c=%g Hz', bw_order, fc_lpf));
    end
    if plot_dirty
        plot(t_u, jerk_dirty, 'LineWidth', 0.9, ...
            'DisplayName', sprintf('locale: dirty der. \\tau=%.2fs', tau_dirty));
    end
    % jerk loggato dal filtro (ax_dot)
    if has_tt_jerk
        plot(t_u, jerk_tt_u, '--', 'Color', [0.2 0.2 0.2], 'LineWidth', 1.2, ...
            'DisplayName', 'log: ax\_dot');
    end
    if has_gt
        plot(t_gtu, jerk_gt, 'k', 'LineWidth', 1.2, 'DisplayName', 'GT jerk');
    end
    yline( jerk_thr, 'r--', 'HandleVisibility','off');
    yline(-jerk_thr, 'r--', 'DisplayName', sprintf('soglia %g', jerk_thr));
    ylim([-yf yf]);
    ylabel('jerk [m/s^3]'); compactLegend(axf1);
    axes = [axes, axf1]; %#ok<AGROW>

    % ---- (2) stato ff_flag ----
    axf2 = nexttile; hold on; grid on;
    stairs(t_u, double(ff_u), 'LineWidth', 1.4, 'Color', ff_shade_color, ...
        'DisplayName', 'ff\_flag');
    ylim([-0.15 1.15]); yticks([0 1]); yticklabels({'OFF','ON'});
    ylabel('ff\_flag'); xlabel('t [s]'); compactLegend(axf2);
    axes = [axes, axf2]; %#ok<AGROW>

    % ---- consistenza: jerk medio/max dentro e fuori le finestre ff ----
    if has_tt_jerk
        j_ref = jerk_tt_u; j_ref_name = 'ax_dot (log)';
    else
        j_ref = jerk_bw_causal; j_ref_name = 'BW causale (locale)';
    end
    in_ff  = ff_u & ~isnan(j_ref);
    out_ff = ~ff_u & ~isnan(j_ref);
    if any(in_ff) || any(out_ff)
        fprintf(['ff_flag vs %s: |jerk| medio ON %.2f / OFF %.2f | ' ...
                 'max ON %.2f / OFF %.2f [m/s^3]\n'], j_ref_name, ...
            mean(abs(j_ref(in_ff)),'omitnan'),  mean(abs(j_ref(out_ff)),'omitnan'), ...
            max(abs(j_ref(in_ff)),[],'omitnan'), max(abs(j_ref(out_ff)),[],'omitnan'));
    end
    if any(in_ff)
        fprintf('   campioni con ff ON e |jerk| < soglia (%g): %.1f%%\n', jerk_thr, ...
            100*nnz(abs(j_ref(in_ff)) < jerk_thr) / nnz(in_ff));
    end
    if any(out_ff)
        fprintf('   campioni con ff OFF e |jerk| > soglia (%g): %.1f%%\n', jerk_thr, ...
            100*nnz(abs(j_ref(out_ff)) > jerk_thr) / nnz(out_ff));
    end
end

%% ------------------- FIGURE: GT JERK CAUSAL vs ACAUSAL ------------------
% Same filter (butter ord 2, fc_gt) applied to GT two ways:
%   acausal = filtfilt + gradient  (zero-phase, the reference used everywhere)
%   causal  = filter  + backward diff (online-implementable)
% The gap between the two IS the intrinsic cost of causality (delay + slight
% attenuation) at equal band: no causal method can beat the causal curve
% below relative to the acausal one.
if do_gt_causal && has_gt
    figure('Name','GT jerk causal vs acausal','NumberTitle','off'); f = f+1;
    axg = gca; hold on; grid on;
    plot(t_gtu, jerk_gt,      'k', 'LineWidth', 1.2, 'DisplayName', 'GT jerk acausal (filtfilt)');
    plot(t_gtu, jerk_gt_caus, 'r', 'LineWidth', 1.0, 'DisplayName', 'GT jerk causal (filter)');
    ylabel('jerk [m/s^3]'); xlabel('t [s]');
    title(sprintf('GT jerk: causal vs acausal (butter ord 2, f_c = %g Hz)', fc_gt), ...
        'FontWeight', 'bold');
    compactLegend(axg);
    axes = [axes, axg]; %#ok<AGROW>

    % delay between the two versions (cross-correlation)
    jgc = jerk_gt_caus - mean(jerk_gt_caus,'omitnan');
    jga = jerk_gt      - mean(jerk_gt,'omitnan');
    [xcg, lgg] = xcorr(jgc, jga, round(1/dt_gt));
    [~, igx] = max(xcg);
    fprintf('GT jerk: causal vs acausal delay = %.0f ms\n', lgg(igx)*dt_gt*1e3);
end

%% ------------------- ACCELERATION PSD (Welch) --------------------------
% Computed separately per row of psd_windows (default: whole bag).
if do_psd
    figure('Name','Acceleration PSD','NumberTitle','off'); f = f+1;
    axp = gca; hold on; grid on;
    f_min = inf;
    for kw = 1:n_psd_win
        idx_w = t_u >= psd_win_bounds(kw,1) & t_u <= psd_win_bounds(kw,2);
        ax_w = ax_u(idx_w);
        if numel(ax_w) < 16
            warning('jerk_filtering: PSD window %s too short (%d samples), skipped.', ...
                psd_win_labels{kw}, numel(ax_w));
            continue;
        end
        nwin  = 2^nextpow2(round(8*fs));
        nwin  = min(nwin, floor(numel(ax_w)/2));
        ax_d  = ax_w - mean(ax_w, 'omitnan'); ax_d(isnan(ax_d)) = 0;
        [pxx, fxx] = pwelch(ax_d, hamming(nwin), round(nwin/2), [], fs);
        semilogx(fxx, 10*log10(pxx), 'LineWidth', 1.0, ...
            'DisplayName', sprintf('a_x high-Q %s', psd_win_labels{kw}));
        f_min = min(f_min, fxx(2));
    end
    if has_gt
        for kw = 1:n_psd_win
            idx_wg = t_gtu >= psd_win_bounds(kw,1) & t_gtu <= psd_win_bounds(kw,2);
            gt_w = ax_gtu(idx_wg);
            if numel(gt_w) < 16
                continue;
            end
            nwin_gt = min(2^nextpow2(round(8/dt_gt)), floor(numel(gt_w)/2));
            gt_d = gt_w - mean(gt_w, 'omitnan'); gt_d(isnan(gt_d)) = 0;
            [pgt, fgt] = pwelch(gt_d, hamming(nwin_gt), round(nwin_gt/2), [], 1/dt_gt);
            semilogx(fgt, 10*log10(pgt), '--', 'LineWidth', 1.2, ...
                'DisplayName', sprintf('GT %s', psd_win_labels{kw}));
            f_min = min(f_min, fgt(2));
        end
    end
    xline(fc_lpf, 'r--', sprintf('f_c = %g Hz', fc_lpf), 'HandleVisibility','off');
    xlabel('f [Hz]'); ylabel('PSD [dB/Hz]');
    title('a_x PSD (Welch)', 'FontWeight', 'bold'); compactLegend(axp);
    if isfinite(f_min); xlim([f_min fs/2]); end
end

%% ------------------- JERK PSD: SELECTED METHODS vs GT -------------------
% Computed separately per row of psd_windows (default: whole bag).
if do_psd_jerk
    jerk_list = {};
    if plot_bw;     jerk_list(end+1,:) = {jerk_bw_causal, 'BW causal'}; end
    if plot_wiener; jerk_list(end+1,:) = {jerk_wiener, 'Wiener (benchmark)'}; end
    if plot_sg;     jerk_list(end+1,:) = {jerk_sg, 'SG causal'}; end
    if plot_sg_ac;  jerk_list(end+1,:) = {jerk_sg_ac, 'SG acausal'}; end
    if plot_dirty;  jerk_list(end+1,:) = {jerk_dirty, 'dirty der.'}; end
    if plot_ellip;  jerk_list(end+1,:) = {jerk_ellip, sprintf('Elliptic ord %d', ell_order)}; end
    if plot_cheby2; jerk_list(end+1,:) = {jerk_cheby2, sprintf('Cheby II ord %d', cby_order)}; end
    if plot_tt_jerk && has_tt_jerk
        jerk_list(end+1,:) = {jerk_tt_u, 'filter jerk (ax_dot)'};
    end

    figure('Name','Jerk PSD','NumberTitle','off'); f = f+1;
    axpj = gca; hold on; grid on;
    f_min_j = inf;
    for kw = 1:n_psd_win
        idx_w = t_u >= psd_win_bounds(kw,1) & t_u <= psd_win_bounds(kw,2);
        nsamp_w = nnz(idx_w);
        if nsamp_w < 16
            warning('jerk_filtering: jerk PSD window %s too short (%d samples), skipped.', ...
                psd_win_labels{kw}, nsamp_w);
            continue;
        end
        nwj = 2^nextpow2(round(8*fs));
        nwj = min(nwj, floor(nsamp_w/2));
        for k = 1:size(jerk_list,1)
            xk = jerk_list{k,1}(idx_w);
            xk = xk - mean(xk,'omitnan'); xk(isnan(xk)) = 0;
            [pj, fj] = pwelch(xk, hamming(nwj), round(nwj/2), [], fs);
            semilogx(fj, 10*log10(pj), 'LineWidth', 1.0, ...
                'DisplayName', sprintf('%s %s', jerk_list{k,2}, psd_win_labels{kw}));
            f_min_j = min(f_min_j, fj(2));
        end
    end
    if has_gt
        for kw = 1:n_psd_win
            idx_wg = t_gtu >= psd_win_bounds(kw,1) & t_gtu <= psd_win_bounds(kw,2);
            jg_w = jerk_gt(idx_wg);
            if numel(jg_w) < 16
                continue;
            end
            nwjg = min(2^nextpow2(round(8/dt_gt)), floor(numel(jg_w)/2));
            jg_d = jg_w - mean(jg_w,'omitnan'); jg_d(isnan(jg_d)) = 0;
            [pjg, fjg] = pwelch(jg_d, hamming(nwjg), round(nwjg/2), [], 1/dt_gt);
            semilogx(fjg, 10*log10(pjg), 'k', 'LineWidth', 1.4, ...
                'DisplayName', sprintf('GT jerk %s', psd_win_labels{kw}));
            f_min_j = min(f_min_j, fjg(2));

            % cumulative-power frequencies of GT jerk (markers drawn once,
            % on the first window, to avoid cluttering the plot)
            if kw == 1
                cumP = cumsum(pjg) / sum(pjg);
                f50 = fjg(find(cumP >= 0.50, 1));
                f90 = fjg(find(cumP >= 0.90, 1));
                f95 = fjg(find(cumP >= 0.95, 1));
                yl = ylim;
                plot([f50 f50], yl, ':',  'Color', [0 0.5 0], 'LineWidth', 1.3, ...
                    'DisplayName', sprintf('50%% GT power (%.2f Hz)', f50));
                plot([f90 f90], yl, '-.', 'Color', [0 0.5 0], 'LineWidth', 1.3, ...
                    'DisplayName', sprintf('90%% GT power (%.2f Hz)', f90));
                fprintf(['GT jerk power %s: 50%% within %.2f Hz | 90%% within %.2f Hz | ' ...
                         '95%% within %.2f Hz\n'], psd_win_labels{kw}, f50, f90, f95);
            end
        end
    end
    set(gca,'XScale','log');
    xline(fc_lpf, 'r--', sprintf('f_c = %g Hz', fc_lpf), 'HandleVisibility','off');
    xlabel('f [Hz]'); ylabel('PSD [dB/Hz]');
    title('Jerk PSD (Welch) - selected methods vs GT', 'FontWeight', 'bold');
    compactLegend(axpj);
    if isfinite(f_min_j); xlim([f_min_j fs/2]); end
end

%% ------------------- METRICS vs GT -------------------
if has_gt
    m = ~isnan(jerk_gt_on_tu);
    jg = jerk_gt_on_tu(m) - mean(jerk_gt_on_tu(m));

    jc = jerk_bw_causal(m) - mean(jerk_bw_causal(m));
    [xc, lags] = xcorr(jc, jg, round(1*fs));
    [~, imax] = max(xc);
    fprintf('BW causal vs GT jerk delay: %.0f ms\n', lags(imax)*dt*1e3);

    rmse = @(x) sqrt(mean((x(m) - jerk_gt_on_tu(m)).^2, 'omitnan'));
    fprintf(['RMSE jerk vs GT [m/s^3]: BW caus %.2f | Wiener %.2f | ' ...
             'SG caus %.2f | SG acaus %.2f | dirty %.2f | ellip %.2f | cheby2 %.2f'], ...
        rmse(jerk_bw_causal), rmse(jerk_wiener), rmse(jerk_sg), rmse(jerk_sg_ac), ...
        rmse(jerk_dirty), rmse(jerk_ellip), rmse(jerk_cheby2));
    if has_tt_jerk
        mt = m & ~isnan(jerk_tt_u);
        if nnz(mt) > 10
            jt = jerk_tt_u(mt) - mean(jerk_tt_u(mt));
            jgt = jerk_gt_on_tu(mt) - mean(jerk_gt_on_tu(mt));
            [xct, lagt] = xcorr(jt, jgt, round(1*fs));
            [~, imt] = max(xct);
            fprintf(' | ax_dot %.2f\n', rmse(jerk_tt_u));
            fprintf('ax_dot vs GT jerk delay: %.0f ms\n', lagt(imt)*dt*1e3);
        else
            fprintf('\n');
        end
    else
        fprintf('\n');
    end
else
    fprintf('Jerk std: BW caus %.1f | SG caus %.1f | SG acaus %.1f | dirty %.1f [m/s^3]\n', ...
        std(jerk_bw_causal,'omitnan'), std(jerk_sg,'omitnan'), ...
        std(jerk_sg_ac,'omitnan'), std(jerk_dirty,'omitnan'));
end

%% ------------------- CAUSAL SG TUNING (optional) -----------------------
if do_sg_tuning && has_gt
    ord_list     = [1 2 3 4];
    frame_list_s = [0.10 0.15 0.20 0.30 0.45 0.65];
    no = numel(ord_list); nf = numel(frame_list_s);
    S_rms = nan(no, nf); S_del = nan(no, nf);
    for io = 1:no
        for ifr = 1:nf
            fr_k = round(frame_list_s(ifr)*fs);
            if mod(fr_k,2) == 0; fr_k = fr_k + 1; end
            if fr_k < ord_list(io) + 2; continue; end
            xw_t = (-(fr_k-1):0).';
            W_t  = pinv(xw_t .^ (0:ord_list(io)));
            j_t  = filter(fliplr(W_t(2,:)), 1, ax_u) / dt;
            S_rms(io,ifr) = sqrt(mean((j_t(m) - jerk_gt_on_tu(m)).^2, 'omitnan'));
            jtc = j_t(m) - mean(j_t(m));
            [xcs, lgs] = xcorr(jtc, jg, round(1*fs));
            [~, iks] = max(xcs);
            S_del(io,ifr) = lgs(iks)*dt*1e3;
        end
    end
    figure('Name','Causal SG tuning','NumberTitle','off'); f = f+1;
    tls = tiledlayout(1,2,'TileSpacing','compact');
    nexttile; imagesc(frame_list_s, ord_list, S_rms); colorbar; axis xy;
    xlabel('window [s]'); ylabel('order'); title('RMSE jerk vs GT [m/s^3]');
    nexttile; imagesc(frame_list_s, ord_list, S_del); colorbar; axis xy;
    xlabel('window [s]'); ylabel('order'); title('delay vs GT [ms]');
    title(tls, 'Causal SG tuning (endpoint)', 'FontWeight', 'bold');
    fprintf('\nCausal SG tuning (rows=order, cols=window [s]):\n');
    fprintf('RMSE jerk vs GT:\n'); disp(array2table(S_rms, ...
        'RowNames', compose('ord%d',ord_list), 'VariableNames', compose('w%.2fs',frame_list_s)));
    fprintf('Delay [ms]:\n'); disp(array2table(S_del, ...
        'RowNames', compose('ord%d',ord_list), 'VariableNames', compose('w%.2fs',frame_list_s)));
end

%% ------------------- fc SWEEP TUNING (optional) ------------------------
if do_tuning && has_gt
    fc_list = [0.5 1 1.5 2 3 4 5 7 10];
    n_fc = numel(fc_list);
    tune = nan(n_fc, 2);
    for k = 1:n_fc
        [bk, ak] = butter(bw_order, fc_list(k)/(fs/2));
        jk = [0; diff(filter(bk, ak, ax_u))] / dt;
        jkc = jk(m) - mean(jk(m));
        [xck, lgk] = xcorr(jkc, jg, round(1*fs));
        [~, ik] = max(xck);
        tune(k,1) = lgk(ik)*dt*1e3;
        tune(k,2) = sqrt(mean((jk(m) - jerk_gt_on_tu(m)).^2, 'omitnan'));
    end
    figure('Name','fc jerk tuning','NumberTitle','off'); f = f+1;
    yyaxis left;  plot(fc_list, tune(:,1), '-o'); ylabel('delay vs GT [ms]');
    yyaxis right; plot(fc_list, tune(:,2), '-s'); ylabel('RMSE jerk vs GT [m/s^3]');
    xlabel('f_c [Hz]'); grid on;
    title('Delay / noise trade-off (BW causal)', 'FontWeight', 'bold');
    disp(array2table([fc_list(:) tune], 'VariableNames', {'fc_Hz','delay_ms','rmse_jerk'}));
end

clearvars t_raw ax_raw valid iu t_v ax_v t_valid ax_valid b_bw a_bw b_dd a_dd b_el a_el ax_el_causal ...
    b_cb a_cb ax_cb_causal w_target g3 Ws_lo Ws_hi Ws bt at hh g it ...
    t_gt_raw ax_gt_raw v_gt ig t_gt ax_gt t_gt_valid ax_gt_valid n_zero_gt b_gt a_gt ax_gtu_c jerk_gt_caus ...
    jgc jga xcg lgg igx compactLegend ax1 ax2 axg axp axpj ...
    xc lags imax jc jg m rmse has_gt ...
    jerk_tt_raw vj tj ij jerk_tt_v tj_valid jt_valid mt jt jgt xct lagt imt n_nz ...
    jerk_tt_all jerk_src_name ...
    ff_all ff_col vf tf_valid ff_valid tf iff ff_v d_ff ff_duty ...
    has_ff n_ff ff_start ff_stop Xff Yff ...
    tlf axf1 axf2 jf_all jf_abs yf j_ref j_ref_name in_ff out_ff ...
    ax_c ag_c Nw Ax Ag Sax Strue Snoise sm Wgain kfreq jw ...
    xw A_sg W_sg w_d1 sg_frame_ac g_sgac ...
    ord_list frame_list_s no nf S_rms S_del io ifr fr_k xw_t W_t j_t jtc xcs lgs iks tls ...
    n_psd_win psd_win_bounds psd_win_labels kw idx_w idx_wg ax_w gt_w nsamp_w jg_w f_min f_min_j ...
    nwin ax_d pxx fxx nwin_gt gt_d pgt fgt ...
    nwj jerk_list xk pj fj nwjg jg_d pjg fjg cumP f50 f90 f95 yl ...
    fc_list n_fc tune bk ak jk jkc xck lgk ik