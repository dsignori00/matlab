%% ACCEL_FILTERING - acceleration and jerk estimation, tt vs tt2
% Called from the main script (jerk_derivation style).
% Uses: tt, tt2, gt, opp_idx, axes, f, col      (requires compare = true)
%
% tt  = filter WITHOUT acceleration state (e.g. CTRV): a must be derived from vx
% tt2 = filter WITH    acceleration state (e.g. CCA):  a comes from the filter
%
% Methods to estimate a = d(vx)/dt from the tt log:
%   1) CAUSAL Butterworth LPF on vx -> derivative (online-implementable)
%   2) ACAUSAL Wiener (offline benchmark: LTI lower bound)
%   3) CAUSAL Savitzky-Golay (endpoint) -> derivative at the last sample
%   4) ACAUSAL Savitzky-Golay (centered window, offline only)
%   5) dirty derivative s/(tau*s+1), Tustin-discretized
%   6) causal Elliptic + derivative
%   7) causal Chebyshev II + derivative
%
% JERK SECTION: goes up one more order. It compares paths with a DIFFERENT
% number of differentiations, which is the whole point:
%   vx of tt  -> a -> j    (TWO differentiations, worst case)
%   ax of tt2 -> j         (ONE differentiation, the filter already gives a)
%   jerk of tt2            (ZERO differentiations, if the model logs it)
% Plus the second-order Savitzky-Golay, which gets j from vx with a SINGLE
% polynomial fit instead of two cascaded differentiations.
%
% References: gt.ax for acceleration (taken as-is, only band-matched with a
% zero-phase filter), its derivative for jerk.
%
% PHYSICAL GATE: samples exceeding v_max / a_max / j_max are rejected as
% non-physical before any processing. This targets the source of the outliers
% rather than the filtered outputs.
%
% COLOR SCHEME (semantic, not decorative):
%   tt color     -> everything belonging to the tt log
%   tt2 color    -> everything belonging to the tt2 log
%   black        -> everything belonging to the GT
%   method palette -> derived estimates, no overlap with the three colors
%                     above. All data lines are solid: dotted is reserved
%                     for thresholds and reference markers.

%% ------------------- HELPER: compact legend outside the axes ------------
compactLegend = @(ax) set(legend(ax), 'Location', 'eastoutside', ...
    'FontSize', 8, 'Box', 'off');

%% ------------------- PARAMETERS -------------------
set(groot, 'defaultAxesTickLabelInterpreter', 'tex');
set(groot, 'defaultTextInterpreter', 'tex');
set(groot, 'defaultLegendInterpreter', 'tex');

fc_lpf      = 3;      % [Hz] Butterworth cutoff on estimated vx (common band)
bw_order    = 2;      % causal Butterworth order
fc_gt       = 5;      % [Hz] zero-phase cutoff applied to the GT
acc_thr     = 10;     % [m/s^2] acceleration trigger threshold
max_gap     = 0.5;    % [s] gap above which interpolation is flagged as suspect

% --- physical plausibility gate (applied to RAW inputs, before processing) ---
v_max       = 70;     % [m/s]   reject |vx| above this
a_max       = 100;    % [m/s^2] reject |ax| above this
j_max       = 100;    % [m/s^3] reject |jerk| above this

% --- curves to PLOT (computation happens regardless) ---
plot_bw          = true;   % causal Butterworth
plot_wiener      = false;  % acausal Wiener (benchmark)
plot_sg          = false;  % causal Savitzky-Golay (endpoint)
plot_sg_ac       = false;  % acausal Savitzky-Golay (centered)
plot_dirty       = true;   % dirty derivative
plot_ellip       = false;  % Elliptic
plot_cheby2      = false;  % Chebyshev II
plot_tt2_acc     = true;   % acceleration state logged by tt2
plot_tt2_derived = false;  % acceleration derived from the tt2 velocity

% --- JERK SECTION ---
do_jerk         = true;   % true -> compute and plot the jerk figure
fc_jerk         = 2;      % [Hz] cutoff of the SECOND differentiation stage
jerk_thr        = 15;     % [m/s^3] jerk trigger threshold
plot_j_from_v   = true;   % j from vx of tt (two cascaded differentiations)
plot_j_dirty    = true;   % j from vx of tt, cascaded dirty derivatives
plot_j_sg2      = false;  % j from vx of tt, second-order SG (single fit)
plot_j_from_a2  = false;  % j from ax of tt2 (one differentiation)
plot_j_logged   = true;   % jerk logged by the filter, if present

% --- Elliptic (Cauer) ---
ell_order   = 3;      % order
ell_rp      = 0.5;    % [dB] passband ripple
ell_rs      = 40;     % [dB] minimum stopband attenuation

% --- Chebyshev type II ---
cby_order   = 3;      % order
cby_rs      = 40;     % [dB] minimum stopband attenuation

match_bandwidth = true;  % true -> tau_dirty derived from fc_lpf
sg_order    = 3;      % Savitzky-Golay polynomial order (causal and acausal)
sg_frame    = 11;     % SG TOTAL window in samples (odd for the acausal one)
tau_dirty   = 0.05;   % [s], used only if match_bandwidth = false

do_sg_tuning = false;  % true -> (sg_order, sg_frame) map: accel RMSE vs GT
do_tuning    = false;  % true -> fc_lpf sweep: delay vs RMSE vs GT
do_psd       = false;  % true -> velocity PSD figure (Welch)
do_psd_acc   = false;  % true -> acceleration PSD of the methods vs GT
do_psd_jerk  = false;  % true -> jerk PSD of the methods vs GT
do_gt_causal = false;  % true -> differentiation-cost figure on the GT

%% ------------------- INPUT CHECK ---------------------------------------
if ~exist('tt2','var') || ~isstruct(tt2)
    error(['accel_filtering: tt2 not found. compare = true is required in the ' ...
           'main script (tt = model without accel, tt2 = model with accel).']);
end

nm1 = 'tt';  if isfield(tt,  'name'); nm1 = tt.name;  end
nm2 = 'tt2'; if isfield(tt2, 'name'); nm2 = tt2.name; end
c1 = [0 0.447 0.741];    if isfield(tt,  'col'); c1 = tt.col;  end
c2 = [0.85 0.325 0.098]; if isfield(tt2, 'col'); c2 = tt2.col; end
c_ref = [0 0 0]; if exist('col','var') && isfield(col,'ref'); c_ref = col.ref; end

% Palette for the DERIVATIVE METHODS. Chosen not to clash with c1 (tt),
% c2 (tt2) or black (GT): no oranges, no blacks, no saturated blue.
cm.bw     = c1;                    % primary method inherits the tt identity
cm.dirty  = [0.494 0.184 0.556];   % purple
cm.wiener = [0.466 0.674 0.188];   % green
cm.sg     = [0.301 0.745 0.933];   % cyan
cm.sg_ac  = [0.100 0.520 0.520];   % teal
cm.ellip  = [0.635 0.408 0.196];   % brown
cm.cheby  = [0.800 0.690 0.100];   % gold
cm.tt2der = c2*0.55 + 0.45;        % tt2 family, light shade

%% ------------------- EXTRACTION: tt (velocity) -------------------------
[v_gated1, nrj_v1] = local_gate(local_speed(tt, opp_idx), v_max);
[t1_c, v1_c] = local_clean(tt.stamp(:), v_gated1);

dt = median(diff(t1_c));
fs = 1/dt;

%% ------------------- EXTRACTION: tt2 (velocity + accel + jerk) ---------
[v_gated2, nrj_v2] = local_gate(local_speed(tt2, opp_idx), v_max);
[t2_c, v2_c] = local_clean(tt2.stamp(:), v_gated2);

% load_tt always populates .ax: in the log without an acceleration state the
% field is all zeros, hence all NaN after masking. isfield alone is not enough.
has_tt2_acc = local_hasdata(tt2, 'ax', opp_idx);
nrj_a2 = 0;
if has_tt2_acc
    [a_gated2, nrj_a2] = local_gate(tt2.ax(:, min(opp_idx, size(tt2.ax,2))), a_max);
    [t2_a, a2_c] = local_clean(tt2.stamp(:), a_gated2);
else
    warning(['accel_filtering: %s carries no valid acceleration (.ax all NaN). ' ...
             'Did you swap log and log_2?'], nm2);
end

% Jerk logged by the filter: load_tt looks for opponents__jerk / __jx /
% __ax_dot / __jerk_x. Present only if the model has jerk as a state.
% tt2 is preferred, but tt is also checked in case the higher-order model
% happens to be the one loaded first.
jsrc = ''; nrj_j = 0;
if local_hasdata(tt2, 'jerk', opp_idx)
    jsrc = nm2;
    [j_gated, nrj_j] = local_gate(tt2.jerk(:, min(opp_idx, size(tt2.jerk,2))), j_max);
    [tj_c, j_c] = local_clean(tt2.stamp(:), j_gated);
elseif local_hasdata(tt, 'jerk', opp_idx)
    jsrc = nm1;
    [j_gated, nrj_j] = local_gate(tt.jerk(:, min(opp_idx, size(tt.jerk,2))), j_max);
    [tj_c, j_c] = local_clean(tt.stamp(:), j_gated);
end
has_log_jerk = ~isempty(jsrc);
if do_jerk
    if has_log_jerk
        fprintf('Logged jerk found in the %s log.\n', jsrc);
    else
        fprintf(['No logged jerk in either log (fields searched by load_tt: ' ...
                 'opponents__jerk / __jx / __ax_dot / __jerk_x): the comparison ' ...
                 'uses derived estimates only.\n']);
    end
end

%% ------------------- COMMON TIME GRID (overlap of both logs) -----------
t_start = max(t1_c(1),   t2_c(1));
t_end   = min(t1_c(end), t2_c(end));
if t_end <= t_start
    error('accel_filtering: %s and %s do not overlap in time.', nm1, nm2);
end
t_u = (t_start:dt:t_end).';

v_u  = interp1(t1_c, v1_c, t_u, 'linear');
v2_u = interp1(t2_c, v2_c, t_u, 'linear');
if has_tt2_acc
    a2_u = interp1(t2_a, a2_c, t_u, 'linear');
end
if has_log_jerk
    j_log_u = interp1(tj_c, j_c, t_u, 'linear');
end

fprintf('accel_filtering: %s vs %s | fs = %.1f Hz, N = %d, overlap %.2f s\n', ...
    nm1, nm2, fs, numel(t_u), t_end - t_start);
fprintf(['Physical gate (|v|>%g, |a|>%g, |j|>%g): rejected %d v_x %s, ' ...
         '%d v_x %s, %d a_x %s, %d jerk\n'], v_max, a_max, j_max, ...
         nrj_v1, nm1, nrj_v2, nm2, nrj_a2, nm2, nrj_j);

% Gap diagnostics: load_tt NaNs out unpopulated opponent slots, so a tracking
% dropout becomes a hole that interp1 fills smoothly -> artificially low
% derived acceleration over that stretch.
gap1 = max(diff(t1_c));
gap2 = max(diff(t2_c));
if gap1 > max_gap || gap2 > max_gap
    fprintf(['  WARNING: largest gap %s %.2f s, %s %.2f s (> %.2f s). ' ...
             'Check tt.count over those intervals.\n'], ...
             nm1, gap1, nm2, gap2, max_gap);
end

%% ------------------- BANDWIDTH MATCH (dirty derivative) -----------------
if match_bandwidth
    tau_dirty = 1/(2*pi*fc_lpf);
end
tau_jerk = 1/(2*pi*fc_jerk);
fprintf(['Common band fc = %g Hz -> tau_dirty = %.3f s | ' ...
         'jerk fc = %g Hz -> tau_jerk = %.3f s | SG: order %d, frame %d (%.2f s)\n'], ...
    fc_lpf, tau_dirty, fc_jerk, tau_jerk, sg_order, sg_frame, sg_frame*dt);

%% ------------------- GT: VELOCITY, ACCELERATION, JERK ------------------
% The GT already carries .ax: the acceleration reference is NOT differentiated,
% only zero-phase filtered to match the band of the methods. The GT jerk, on
% the other hand, must be differentiated - but from a clean signal, acausally.
has_gt = exist('gt','var') && isstruct(gt) && isfield(gt,'stamp') && isfield(gt,'ax');
if has_gt
    a_gt_col = local_gate(gt.ax(:, min(opp_idx, size(gt.ax,2))), a_max);
    [t_gt, a_gt_c] = local_clean(gt.stamp(:), a_gt_col);

    dt_gt  = median(diff(t_gt));
    t_gtu  = (t_gt(1):dt_gt:t_gt(end)).';
    a_gtu  = interp1(t_gt, a_gt_c, t_gtu, 'linear');

    [b_gt, a_gt] = butter(2, min(fc_gt/(1/dt_gt/2), 0.99));
    acc_gt = filtfilt(b_gt, a_gt, a_gtu);              % ACCELERATION REFERENCE
    acc_gt_on_tu = interp1(t_gtu, acc_gt, t_u, 'linear');

    % JERK REFERENCE: acausal derivative of the GT acceleration, re-filtered
    % zero-phase so the quantization noise of the difference is not left in.
    jerk_gt = filtfilt(b_gt, a_gt, gradient(acc_gt, dt_gt));
    jerk_gt_on_tu = interp1(t_gtu, jerk_gt, t_u, 'linear');

    % GT velocity on the same grid
    v_gt_gated = local_gate(local_speed(gt, opp_idx), v_max);
    [t_gv, v_gt_c] = local_clean(gt.stamp(:), v_gt_gated);
    v_gtu   = interp1(t_gv, v_gt_c, t_gtu, 'linear');
    v_gtu_f = filtfilt(b_gt, a_gt, v_gtu);
    v_gt_on_tu = interp1(t_gtu, v_gtu_f, t_u, 'linear');

    % Cost of differentiation measured on a CLEAN signal: same pipeline applied
    % to the GT velocity. The gap against acc_gt is the lower bound for any
    % method that differentiates velocity.
    acc_gt_fromv      = gradient(v_gtu_f, dt_gt);                     % acausal
    acc_gt_fromv_caus = [0; diff(filter(b_gt, a_gt, v_gtu))] / dt_gt; % causal
else
    warning('accel_filtering: gt unavailable or without .ax - plotting without reference');
end

%% ------------------- 1) CAUSAL BUTTERWORTH + DERIVATIVE ----------------
[b_bw, a_bw] = butter(bw_order, fc_lpf/(fs/2));
v_bw_causal   = filter(b_bw, a_bw, v_u);
acc_bw_causal = [0; diff(v_bw_causal)] / dt;

%% ------------------- 2) ACAUSAL WIENER (offline benchmark) -------------
% LTI lower bound: S_true from the GT velocity PSD, S_noise as the spectral
% excess of the estimate over the GT (robust to time misalignment).
if has_gt
    v_c  = v_u - mean(v_u,'omitnan'); v_c(isnan(v_c)) = 0;
    vg_c = v_gt_on_tu - mean(v_gt_on_tu,'omitnan'); vg_c(isnan(vg_c)) = 0;
    Nw = numel(v_c);
    Vx = fft(v_c); Vg = fft(vg_c);

    sm = @(P) real(ifft(fft(P) .* fft(ones(min(15,Nw),1)/min(15,Nw), Nw)));
    Svx   = sm(abs(Vx).^2);
    Strue = sm(abs(Vg).^2);
    Snoise = max(Svx - Strue, 0);
    Wgain = Strue ./ max(Strue + Snoise, eps);

    kfreq = [0:floor(Nw/2), -(ceil(Nw/2)-1):-1].';
    jw = 1i * 2*pi * (kfreq / (Nw*dt));
    acc_wiener = real(ifft(jw .* Wgain .* Vx));
else
    acc_wiener = nan(size(v_u));
    warning('accel_filtering: Wiener requires GT - benchmark not computed.');
end

%% ------------------- 3) CAUSAL SAVITZKY-GOLAY (endpoint) ---------------
% Polynomial fit over the LAST sg_frame samples, derivative at the endpoint:
% FIR on past samples only, online-implementable.
xw   = (-(sg_frame-1):0).';
A_sg = xw .^ (0:sg_order);
W_sg = pinv(A_sg);
w_d1 = W_sg(2, :);
acc_sg = filter(fliplr(w_d1), 1, v_u) / dt;

% SECOND derivative from the same fit: the x^2 coefficient equals j/2, so
% jerk = 2*c3/dt^2. This gets jerk from vx with a SINGLE fit instead of two
% cascaded differentiations - less noise amplification at equal bandwidth.
w_d2 = 2 * W_sg(3, :);
jerk_sg2 = filter(fliplr(w_d2), 1, v_u) / dt^2;

%% ------------------- 4) ACAUSAL SAVITZKY-GOLAY (centered) --------------
sg_frame_ac = sg_frame; if mod(sg_frame_ac,2)==0; sg_frame_ac = sg_frame_ac+1; end
[~, g_sgac] = sgolay(sg_order, sg_frame_ac);
acc_sg_ac = conv(v_u, factorial(1)/(-dt)^1 * g_sgac(:,2), 'same');

%% ------------------- 5) DIRTY DERIVATIVE (Tustin) ----------------------
b_dd = [2, -2] / (2*tau_dirty + dt);
a_dd = [1, (dt - 2*tau_dirty)/(2*tau_dirty + dt)];
acc_dirty = filter(b_dd, a_dd, v_u);

%% ------------------- 6) CAUSAL ELLIPTIC + DERIVATIVE -------------------
[b_el, a_el] = ellip(ell_order, ell_rp, ell_rs, fc_lpf/(fs/2));
v_el_causal = filter(b_el, a_el, v_u);
acc_ellip   = [0; diff(v_el_causal)] / dt;

%% ------------------- 7) CAUSAL CHEBYSHEV II + DERIVATIVE ---------------
% Aligned to -3 dB at fc_lpf via bisection on the stopband edge.
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
v_cb_causal = filter(b_cb, a_cb, v_u);
acc_cheby2  = [0; diff(v_cb_causal)] / dt;
fprintf('Cheby II: -3 dB at %.2f Hz (stopband edge %.2f Hz)\n', fc_lpf, Ws*(fs/2));

%% ------------------- tt2 SELF-CONSISTENCY -----------------------------
% Same causal Butterworth pipeline applied to the tt2 velocity: if the filter
% is internally consistent, this should track its own acceleration state.
acc_tt2_derived = [0; diff(filter(b_bw, a_bw, v2_u))] / dt;

%% ------------------- SECOND STAGE: JERK --------------------------------
% Second filtering stage with its own band: the second derivative amplifies
% noise by a further factor of f, hence fc_jerk <= fc_lpf.
[b_j, a_j] = butter(bw_order, fc_jerk/(fs/2));
b_dj = [2, -2] / (2*tau_jerk + dt);
a_dj = [1, (dt - 2*tau_jerk)/(2*tau_jerk + dt)];

% (a) from vx of tt: TWO cascaded differentiations - the worst case
jerk_from_v     = [0; diff(filter(b_j, a_j, acc_bw_causal))] / dt;
jerk_dirty_v    = filter(b_dj, a_dj, acc_dirty);

% (b) from ax of tt2: ONE differentiation, the filter already provides a
if has_tt2_acc
    jerk_from_a2 = [0; diff(filter(b_j, a_j, a2_u))] / dt;
else
    jerk_from_a2 = nan(size(t_u));
end

%% ------------------- MAIN FIGURE ---------------------------------------
figure('Name','Accel filtering','NumberTitle','off'); f = f+1;
tl = tiledlayout(2,1,'TileSpacing','compact');

% --- velocity
ax1 = nexttile; hold on; grid on;
plot(t_u, v_u,  'Color', c1, 'LineWidth', 1.0, 'DisplayName', sprintf('v_x %s', nm1));
plot(t_u, v2_u, 'Color', c2, 'LineWidth', 1.0, 'DisplayName', sprintf('v_x %s', nm2));
if has_gt
    plot(t_gtu, v_gtu_f, 'Color', c_ref, 'LineWidth', 1.6, 'DisplayName', 'v_x GT');
end
ylabel('v_x [m/s]'); compactLegend(ax1);
title(tl, sprintf('Acceleration: derived from %s vs state of %s - opp %d', ...
    nm1, nm2, opp_idx), 'FontWeight', 'bold');
axes = [axes, ax1]; %#ok<AGROW>

% --- acceleration (curves selectable via the plot_* flags)
ax2 = nexttile; hold on; grid on;
if plot_bw
    plot(t_u, acc_bw_causal, 'Color', cm.bw, 'LineWidth', 1.0, ...
        'DisplayName', sprintf('causal BW ord %d (from v_x %s)', bw_order, nm1));
end
if plot_wiener
    plot(t_u, acc_wiener, 'Color', cm.wiener, 'LineWidth', 1.0, ...
        'DisplayName', 'Wiener (benchmark)');
end
if plot_sg
    plot(t_u, acc_sg, 'Color', cm.sg, 'LineWidth', 1.0, ...
        'DisplayName', sprintf('causal SG (ord %d, frame %d)', sg_order, sg_frame));
end
if plot_sg_ac
    plot(t_u, acc_sg_ac, 'Color', cm.sg_ac, 'LineWidth', 1.0, ...
        'DisplayName', sprintf('acausal SG (ord %d, frame %d)', sg_order, sg_frame_ac));
end
if plot_dirty
    plot(t_u, acc_dirty, 'Color', cm.dirty, 'LineWidth', 1.0, ...
        'DisplayName', sprintf('dirty deriv. \\tau=%.2fs', tau_dirty));
end
if plot_ellip
    plot(t_u, acc_ellip, 'Color', cm.ellip, 'LineWidth', 1.0, ...
        'DisplayName', sprintf('Elliptic ord %d (rp %.1f dB)', ell_order, ell_rp));
end
if plot_cheby2
    plot(t_u, acc_cheby2, 'Color', cm.cheby, 'LineWidth', 1.0, ...
        'DisplayName', sprintf('Cheby II ord %d (rs %d dB)', cby_order, cby_rs));
end
if plot_tt2_derived
    plot(t_u, acc_tt2_derived, 'Color', cm.tt2der, 'LineWidth', 1.0, ...
        'DisplayName', sprintf('causal BW (from v_x %s)', nm2));
end
if plot_tt2_acc && has_tt2_acc
    plot(t_u, a2_u, 'Color', c2, 'LineWidth', 1.3, ...
        'DisplayName', sprintf('a_x %s (filter state)', nm2));
end
if has_gt
    plot(t_gtu, acc_gt, 'Color', c_ref, 'LineWidth', 1.6, 'DisplayName', 'a_x GT');
end
yline( acc_thr, ':', 'Color', [0.7 0.7 0.7], 'HandleVisibility','off');
yline(-acc_thr, ':', 'Color', [0.7 0.7 0.7], 'DisplayName', 'accel threshold');
ylabel('a_x [m/s^2]'); xlabel('t [s]'); compactLegend(ax2);
ylim([-1 1]*max(2*acc_thr, 1.2*max(abs(acc_bw_causal),[],'omitnan')));
axes = [axes, ax2]; %#ok<AGROW>

%% ------------------- JERK FIGURE ---------------------------------------
% The comparison is between paths with a DIFFERENT number of differentiations.
% That is the point: every differentiation costs bandwidth and delay, so having
% the state inside the filter is worth more than any choice of filter.
if do_jerk
    figure('Name','Jerk estimation','NumberTitle','off'); f = f+1;
    tlj = tiledlayout(2,1,'TileSpacing','compact');

    % --- acceleration (context)
    axj1 = nexttile; hold on; grid on;
    plot(t_u, acc_bw_causal, 'Color', cm.bw, 'LineWidth', 1.0, ...
        'DisplayName', sprintf('a_x from v_x %s', nm1));
    if has_tt2_acc
        plot(t_u, a2_u, 'Color', c2, 'LineWidth', 1.3, ...
            'DisplayName', sprintf('a_x %s (filter state)', nm2));
    end
    if has_gt
        plot(t_gtu, acc_gt, 'Color', c_ref, 'LineWidth', 1.6, 'DisplayName', 'a_x GT');
    end
    ylabel('a_x [m/s^2]'); compactLegend(axj1);
    ylim([-1 1]*max(2*acc_thr, 1.2*max(abs(acc_bw_causal),[],'omitnan')));
    title(tlj, sprintf('Jerk: cost of successive differentiations - opp %d', opp_idx), ...
        'FontWeight', 'bold');
    axes = [axes, axj1]; %#ok<AGROW>

    % --- jerk
    axj2 = nexttile; hold on; grid on;
    if plot_j_from_v
        plot(t_u, jerk_from_v, 'Color', cm.bw, 'LineWidth', 1.0, ...
            'DisplayName', sprintf('from v_x %s: 2 BW differentiations (f_c=%g, %g Hz)', ...
            nm1, fc_lpf, fc_jerk));
    end
    if plot_j_dirty
        plot(t_u, jerk_dirty_v, 'Color', cm.dirty, 'LineWidth', 1.0, ...
            'DisplayName', sprintf('from v_x %s: 2 dirty derivs (\\tau=%.2f, %.2f s)', ...
            nm1, tau_dirty, tau_jerk));
    end
    if plot_j_sg2
        plot(t_u, jerk_sg2, 'Color', cm.sg, 'LineWidth', 1.0, ...
            'DisplayName', sprintf('from v_x %s: SG 2nd derivative (ord %d, frame %d)', ...
            nm1, sg_order, sg_frame));
    end
    if plot_j_from_a2 && has_tt2_acc
        plot(t_u, jerk_from_a2, 'Color', cm.tt2der, 'LineWidth', 1.0, ...
            'DisplayName', sprintf('from a_x %s: 1 BW differentiation (f_c=%g Hz)', nm2, fc_jerk));
    end
    if plot_j_logged && has_log_jerk
        plot(t_u, j_log_u, 'Color', c2, 'LineWidth', 1.3, ...
            'DisplayName', sprintf('jerk %s (filter state)', jsrc));
    end
    if has_gt
        plot(t_gtu, jerk_gt, 'Color', c_ref, 'LineWidth', 1.6, 'DisplayName', 'jerk GT');
    end
    yline( jerk_thr, ':', 'Color', [0.7 0.7 0.7], 'HandleVisibility','off');
    yline(-jerk_thr, ':', 'Color', [0.7 0.7 0.7], 'DisplayName', 'jerk threshold');
    ylabel('jerk [m/s^3]'); xlabel('t [s]'); compactLegend(axj2);
    ylim([-1 1]*max(3*jerk_thr, 1.2*max(abs(jerk_from_v),[],'omitnan')));
    axes = [axes, axj2]; %#ok<AGROW>
end

%% ------------------- FIGURE: DIFFERENTIATION COST ON THE GT ------------
% The GT carries both vx and ax: differentiating ITS velocity isolates the
% error introduced by differentiation alone, with no tracker noise. The gap
% against gt.ax is the lower bound for any derivative-based method.
if do_gt_causal && has_gt
    figure('Name','Differentiation cost (GT)','NumberTitle','off'); f = f+1;
    axg = gca; hold on; grid on;
    plot(t_gtu, acc_gt,            'Color', c_ref,     'LineWidth', 1.6, 'DisplayName', 'a_x GT (reference)');
    plot(t_gtu, acc_gt_fromv,      'Color', cm.wiener, 'LineWidth', 1.0, 'DisplayName', 'from v_x GT, acausal (filtfilt)');
    plot(t_gtu, acc_gt_fromv_caus, 'Color', cm.dirty,  'LineWidth', 1.0, 'DisplayName', 'from v_x GT, causal (filter)');
    ylabel('a_x [m/s^2]'); xlabel('t [s]');
    title(sprintf('Differentiating v_x instead of using a_x: intrinsic cost (butter ord 2, f_c = %g Hz)', fc_gt), ...
        'FontWeight', 'bold');
    compactLegend(axg);
    axes = [axes, axg]; %#ok<AGROW>

    r_ac = sqrt(mean((acc_gt_fromv      - acc_gt).^2, 'omitnan'));
    r_ca = sqrt(mean((acc_gt_fromv_caus - acc_gt).^2, 'omitnan'));
    agc = acc_gt_fromv_caus - mean(acc_gt_fromv_caus,'omitnan');
    aga = acc_gt            - mean(acc_gt,'omitnan');
    [xcg, lgg] = xcorr(agc, aga, round(1/dt_gt));
    [~, igx] = max(xcg);
    fprintf(['Differentiation cost on GT: RMSE acausal %.2f, causal %.2f [m/s^2] | ' ...
             'causal delay %.0f ms\n'], r_ac, r_ca, lgg(igx)*dt_gt*1e3);
end

%% ------------------- VELOCITY PSD (Welch) ------------------------------
if do_psd
    nwin = min(2^nextpow2(round(8*fs)), floor(numel(v_u)/2));
    figure('Name','Velocity PSD','NumberTitle','off'); f = f+1;
    axp = gca; hold on; grid on;
    [pxx, fxx] = local_psd(v_u, nwin, fs);
    semilogx(fxx, 10*log10(pxx), 'Color', c1, 'LineWidth', 1.2, ...
        'DisplayName', sprintf('v_x %s', nm1));
    [pcc, fcc] = local_psd(v2_u, nwin, fs);
    semilogx(fcc, 10*log10(pcc), 'Color', c2, 'LineWidth', 1.2, ...
        'DisplayName', sprintf('v_x %s', nm2));
    if has_gt
        nwin_gt = min(2^nextpow2(round(8/dt_gt)), floor(numel(v_gtu)/2));
        [pgt, fgt] = local_psd(v_gtu, nwin_gt, 1/dt_gt);
        semilogx(fgt, 10*log10(pgt), 'Color', c_ref, 'LineWidth', 1.6, ...
            'DisplayName', 'v_x GT');
    end
    set(gca,'XScale','log');
    xline(fc_lpf, ':', 'Color', [0.7 0.7 0.7], 'DisplayName', sprintf('f_c = %g Hz', fc_lpf));
    xlabel('f [Hz]'); ylabel('PSD [dB/Hz]');
    title('v_x PSD (Welch)', 'FontWeight', 'bold'); compactLegend(axp);
    xlim([max(1/(nwin*dt),0.05) fs/2]);
end

%% ------------------- ACCELERATION PSD: METHODS vs GT -------------------
if do_psd_acc
    nwj = min(2^nextpow2(round(8*fs)), floor(numel(t_u)/2));

    acc_list = {};
    if plot_bw;      acc_list(end+1,:) = {acc_bw_causal, sprintf('causal BW (from v_x %s)', nm1), cm.bw, 1.0}; end
    if plot_wiener;  acc_list(end+1,:) = {acc_wiener, 'Wiener (benchmark)', cm.wiener, 1.0}; end
    if plot_sg;      acc_list(end+1,:) = {acc_sg, 'causal SG', cm.sg, 1.0}; end
    if plot_sg_ac;   acc_list(end+1,:) = {acc_sg_ac, 'acausal SG', cm.sg_ac, 1.0}; end
    if plot_dirty;   acc_list(end+1,:) = {acc_dirty, 'dirty deriv.', cm.dirty, 1.0}; end
    if plot_ellip;   acc_list(end+1,:) = {acc_ellip, sprintf('Elliptic ord %d', ell_order), cm.ellip, 1.0}; end
    if plot_cheby2;  acc_list(end+1,:) = {acc_cheby2, sprintf('Cheby II ord %d', cby_order), cm.cheby, 1.0}; end
    if plot_tt2_derived
        acc_list(end+1,:) = {acc_tt2_derived, sprintf('causal BW (from v_x %s)', nm2), cm.tt2der, 1.0};
    end
    if plot_tt2_acc && has_tt2_acc
        acc_list(end+1,:) = {a2_u, sprintf('a_x %s (filter state)', nm2), c2, 1.3};
    end

    figure('Name','Accel PSD','NumberTitle','off'); f = f+1;
    axpj = gca; hold on; grid on;
    for k = 1:size(acc_list,1)
        [pj, fj] = local_psd(acc_list{k,1}, nwj, fs);
        semilogx(fj, 10*log10(pj), 'Color', acc_list{k,3}, ...
            'LineWidth', acc_list{k,4}, 'DisplayName', acc_list{k,2});
    end
    if has_gt
        nwjg = min(2^nextpow2(round(8/dt_gt)), floor(numel(acc_gt)/2));
        [pjg, fjg] = local_psd(acc_gt, nwjg, 1/dt_gt);
        semilogx(fjg, 10*log10(pjg), 'Color', c_ref, 'LineWidth', 1.6, 'DisplayName', 'a_x GT');

        cumP = cumsum(pjg) / sum(pjg);
        f50 = fjg(find(cumP >= 0.50, 1));
        f90 = fjg(find(cumP >= 0.90, 1));
        yl = ylim;
        plot([f50 f50], yl, ':',  'Color', [0.3 0.3 0.3], 'LineWidth', 1.2, ...
            'DisplayName', sprintf('50%% GT power (%.2f Hz)', f50));
        plot([f90 f90], yl, '-.', 'Color', [0.3 0.3 0.3], 'LineWidth', 1.2, ...
            'DisplayName', sprintf('90%% GT power (%.2f Hz)', f90));
        fprintf('GT accel power: 50%% within %.2f Hz | 90%% within %.2f Hz\n', f50, f90);
    end
    set(gca,'XScale','log');
    xline(fc_lpf, ':', 'Color', [0.7 0.7 0.7], 'HandleVisibility','off');
    xlabel('f [Hz]'); ylabel('PSD [dB/Hz]');
    title('Acceleration PSD (Welch) - selected methods vs GT', 'FontWeight', 'bold');
    compactLegend(axpj);
    xlim([max(1/(nwj*dt), 0.05) fs/2]);
end

%% ------------------- JERK PSD: METHODS vs GT ---------------------------
if do_psd_jerk && do_jerk
    nwjk = min(2^nextpow2(round(8*fs)), floor(numel(t_u)/2));

    jrk_list = {};
    if plot_j_from_v;  jrk_list(end+1,:) = {jerk_from_v, sprintf('2 BW derivs (from v_x %s)', nm1), cm.bw, 1.0}; end
    if plot_j_dirty;   jrk_list(end+1,:) = {jerk_dirty_v, sprintf('2 dirty derivs (from v_x %s)', nm1), cm.dirty, 1.0}; end
    if plot_j_sg2;     jrk_list(end+1,:) = {jerk_sg2, sprintf('SG 2nd deriv. (from v_x %s)', nm1), cm.sg, 1.0}; end
    if plot_j_from_a2 && has_tt2_acc
        jrk_list(end+1,:) = {jerk_from_a2, sprintf('1 BW deriv. (from a_x %s)', nm2), cm.tt2der, 1.0};
    end
    if plot_j_logged && has_log_jerk
        jrk_list(end+1,:) = {j_log_u, sprintf('jerk %s (filter state)', jsrc), c2, 1.3};
    end

    figure('Name','Jerk PSD','NumberTitle','off'); f = f+1;
    axpk = gca; hold on; grid on;
    for k = 1:size(jrk_list,1)
        [pk, fk] = local_psd(jrk_list{k,1}, nwjk, fs);
        semilogx(fk, 10*log10(pk), 'Color', jrk_list{k,3}, ...
            'LineWidth', jrk_list{k,4}, 'DisplayName', jrk_list{k,2});
    end
    if has_gt
        nwkg = min(2^nextpow2(round(8/dt_gt)), floor(numel(jerk_gt)/2));
        [pkg, fkg] = local_psd(jerk_gt, nwkg, 1/dt_gt);
        semilogx(fkg, 10*log10(pkg), 'Color', c_ref, 'LineWidth', 1.6, 'DisplayName', 'jerk GT');

        cumK = cumsum(pkg) / sum(pkg);
        k50 = fkg(find(cumK >= 0.50, 1));
        k90 = fkg(find(cumK >= 0.90, 1));
        fprintf('GT jerk power: 50%% within %.2f Hz | 90%% within %.2f Hz\n', k50, k90);
    end
    set(gca,'XScale','log');
    xline(fc_jerk, ':', 'Color', [0.7 0.7 0.7], 'HandleVisibility','off');
    xlabel('f [Hz]'); ylabel('PSD [dB/Hz]');
    title('Jerk PSD (Welch) - selected methods vs GT', 'FontWeight', 'bold');
    compactLegend(axpk);
    xlim([max(1/(nwjk*dt), 0.05) fs/2]);
end

%% ------------------- METRICS vs GT -------------------------------------
if has_gt
    m = ~isnan(acc_gt_on_tu);
    ag = acc_gt_on_tu(m) - mean(acc_gt_on_tu(m));

    delay_of = @(x) local_delay(x, m, ag, fs, dt);
    rmse     = @(x) sqrt(mean((x(m) - acc_gt_on_tu(m)).^2, 'omitnan'));

    fprintf('causal BW vs GT a_x: delay %.0f ms\n', delay_of(acc_bw_causal));

    fprintf(['Accel RMSE vs GT [m/s^2]: BW caus %.2f | Wiener %.2f | ' ...
             'SG caus %.2f | SG acaus %.2f | dirty %.2f | ellip %.2f | cheby2 %.2f'], ...
        rmse(acc_bw_causal), rmse(acc_wiener), rmse(acc_sg), rmse(acc_sg_ac), ...
        rmse(acc_dirty), rmse(acc_ellip), rmse(acc_cheby2));

    if has_tt2_acc
        fprintf(' | %s state %.2f\n', nm2, rmse(a2_u));
        fprintf('%s accel state vs GT a_x: delay %.0f ms\n', nm2, delay_of(a2_u));

        mm = m & ~isnan(a2_u);
        d_bw  = acc_bw_causal(mm) - acc_gt_on_tu(mm);
        d_tt2 = a2_u(mm)          - acc_gt_on_tu(mm);
        fprintf(['Head-to-head vs GT: bias %s-derived %.2f, %s %.2f | ' ...
                 'std %.2f vs %.2f [m/s^2]\n'], ...
            nm1, mean(d_bw,'omitnan'), nm2, mean(d_tt2,'omitnan'), ...
            std(d_bw,'omitnan'),  std(d_tt2,'omitnan'));
    else
        fprintf('\n');
    end

    % --- jerk metrics
    if do_jerk
        mj = ~isnan(jerk_gt_on_tu);
        jg = jerk_gt_on_tu(mj) - mean(jerk_gt_on_tu(mj));
        delay_j = @(x) local_delay(x, mj, jg, fs, dt);
        rmse_j  = @(x) sqrt(mean((x(mj) - jerk_gt_on_tu(mj)).^2, 'omitnan'));

        fprintf('\n--- JERK vs GT ---\n');
        fprintf(['RMSE [m/s^3]: 2xBW from v_x %s %.2f | 2x dirty %.2f | ' ...
                 'SG 2nd deriv. %.2f'], nm1, rmse_j(jerk_from_v), ...
                 rmse_j(jerk_dirty_v), rmse_j(jerk_sg2));
        if has_tt2_acc
            fprintf(' | 1xBW from a_x %s %.2f', nm2, rmse_j(jerk_from_a2));
        end
        if has_log_jerk
            fprintf(' | %s state %.2f', jsrc, rmse_j(j_log_u));
        end
        fprintf('\n');

        fprintf('Delay [ms]: 2xBW %.0f | 2x dirty %.0f | SG 2nd deriv. %.0f', ...
            delay_j(jerk_from_v), delay_j(jerk_dirty_v), delay_j(jerk_sg2));
        if has_tt2_acc
            fprintf(' | 1xBW from a_x %s %.0f', nm2, delay_j(jerk_from_a2));
        end
        if has_log_jerk
            fprintf(' | %s state %.0f', jsrc, delay_j(j_log_u));
        end
        fprintf('\n');

        if has_tt2_acc
            fprintf(['Gain of one differentiation less: RMSE %.2f -> %.2f ' ...
                     '(%.0f%%), delay %.0f -> %.0f ms\n'], ...
                rmse_j(jerk_from_v), rmse_j(jerk_from_a2), ...
                100*(1 - rmse_j(jerk_from_a2)/max(rmse_j(jerk_from_v),eps)), ...
                delay_j(jerk_from_v), delay_j(jerk_from_a2));
        end
    end
else
    fprintf('Accel std: BW caus %.1f | SG caus %.1f | SG acaus %.1f | dirty %.1f [m/s^2]\n', ...
        std(acc_bw_causal,'omitnan'), std(acc_sg,'omitnan'), ...
        std(acc_sg_ac,'omitnan'), std(acc_dirty,'omitnan'));
    if do_jerk
        fprintf('Jerk std: 2xBW %.1f | 2x dirty %.1f | SG 2nd deriv. %.1f [m/s^3]\n', ...
            std(jerk_from_v,'omitnan'), std(jerk_dirty_v,'omitnan'), std(jerk_sg2,'omitnan'));
    end
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
            a_t  = filter(fliplr(W_t(2,:)), 1, v_u) / dt;
            S_rms(io,ifr) = sqrt(mean((a_t(m) - acc_gt_on_tu(m)).^2, 'omitnan'));
            S_del(io,ifr) = local_delay(a_t, m, ag, fs, dt);
        end
    end
    figure('Name','Causal SG tuning','NumberTitle','off'); f = f+1;
    tls = tiledlayout(1,2,'TileSpacing','compact');
    nexttile; imagesc(frame_list_s, ord_list, S_rms); colorbar; axis xy;
    xlabel('window [s]'); ylabel('order'); title('Accel RMSE vs GT [m/s^2]');
    nexttile; imagesc(frame_list_s, ord_list, S_del); colorbar; axis xy;
    xlabel('window [s]'); ylabel('order'); title('delay vs GT [ms]');
    title(tls, 'Causal SG tuning (endpoint)', 'FontWeight', 'bold');
    fprintf('\nCausal SG tuning (rows = order, cols = window [s]):\n');
    fprintf('Accel RMSE vs GT:\n'); disp(array2table(S_rms, ...
        'RowNames', compose('ord%d',ord_list), 'VariableNames', compose('w%.2fs',frame_list_s)));
    fprintf('Delay [ms]:\n'); disp(array2table(S_del, ...
        'RowNames', compose('ord%d',ord_list), 'VariableNames', compose('w%.2fs',frame_list_s)));
end

%% ------------------- fc SWEEP (optional) -------------------------------
if do_tuning && has_gt
    fc_list = [0.5 1 1.5 2 3 4 5 7 10];
    n_fc = numel(fc_list);
    tune = nan(n_fc, 2);
    for k = 1:n_fc
        [bk, ak] = butter(bw_order, fc_list(k)/(fs/2));
        akk = [0; diff(filter(bk, ak, v_u))] / dt;
        tune(k,1) = local_delay(akk, m, ag, fs, dt);
        tune(k,2) = sqrt(mean((akk(m) - acc_gt_on_tu(m)).^2, 'omitnan'));
    end
    figure('Name','fc accel tuning','NumberTitle','off'); f = f+1;
    yyaxis left;  plot(fc_list, tune(:,1), '-o'); ylabel('delay vs GT [ms]');
    yyaxis right; plot(fc_list, tune(:,2), '-s'); ylabel('accel RMSE vs GT [m/s^2]');
    xlabel('f_c [Hz]'); grid on;
    title(sprintf('Delay / noise trade-off (causal BW on v_x %s)', nm1), ...
        'FontWeight', 'bold');
    if has_tt2_acc
        yline(rmse(a2_u), ':', sprintf('%s (filter state)', nm2), 'Color', c2, 'LineWidth', 1.3);
    end
    disp(array2table([fc_list(:) tune], 'VariableNames', {'fc_Hz','delay_ms','rmse_acc'}));
end

clearvars t1_c v1_c t2_c v2_c t2_a a2_c tj_c j_c jsrc t_start t_end gap1 gap2 max_gap ...
    v_gated1 v_gated2 a_gated2 j_gated v_gt_gated nrj_v1 nrj_v2 nrj_a2 nrj_j ...
    v_max a_max j_max ...
    nm1 nm2 c1 c2 c_ref cm a_gt_col a_gt_c a_gtu t_gv v_gt_c ...
    b_bw a_bw b_dd a_dd b_el a_el v_el_causal b_cb a_cb v_cb_causal ...
    b_j a_j b_dj a_dj tau_jerk ...
    w_target g3 Ws_lo Ws_hi Ws bt at hh g it v_bw_causal ...
    t_gt b_gt a_gt acc_gt_fromv acc_gt_fromv_caus r_ac r_ca agc aga xcg lgg igx ...
    compactLegend ax1 ax2 axg axp axpj axpk axj1 axj2 tlj ...
    m ag rmse delay_of mj jg rmse_j delay_j has_gt ...
    mm d_bw d_tt2 has_tt2_acc has_log_jerk ...
    v_c vg_c Nw Vx Vg Svx Strue Snoise sm Wgain kfreq jw ...
    xw A_sg W_sg w_d1 w_d2 sg_frame_ac g_sgac ...
    ord_list frame_list_s no nf S_rms S_del io ifr fr_k xw_t W_t a_t tls ...
    nwin pxx fxx pcc fcc nwin_gt pgt fgt ...
    nwj acc_list pj fj nwjg pjg fjg cumP f50 f90 yl ...
    nwjk jrk_list pk fk nwkg pkg fkg cumK k50 k90 ...
    fc_list n_fc tune bk ak akk

%% ======================= LOCAL FUNCTIONS ===============================
function [x_out, n_rej] = local_gate(x, lim)
% Physical plausibility gate: samples with |x| > lim are rejected as NaN.
% Applied to RAW inputs, before any filtering: the goal is to remove the
% source of the outliers, not to clip the filtered outputs (which would hide
% the problem while still letting it corrupt the estimates upstream).
    x_out = x(:);
    bad = abs(x_out) > lim;
    x_out(bad) = NaN;
    n_rej = nnz(bad);
end

function [t_c, x_c] = local_clean(t_in, x_in)
% Drop NaNs, enforce strictly increasing unique timestamps.
    v = ~isnan(t_in) & ~isnan(x_in);
    t_c = t_in(v); x_c = x_in(v);
    [t_c, iu] = unique(t_c, 'stable');
    x_c = x_c(iu);
end

function tf = local_hasdata(S, fld, idx)
% True if the field exists AND holds at least one non-NaN value for this
% opponent. load_tt populates some fields even when the model does not produce
% them: after zero-masking they come out all NaN, so isfield is not enough.
    tf = isfield(S, fld) && ~isempty(S.(fld)) && ...
         any(~isnan(S.(fld)(:, min(idx, size(S.(fld),2)))));
end

function s = local_speed(S, idx)
% Tangential velocity. In this log format the field is .vx (opponents__vx):
% it is already the target longitudinal speed, not a Cartesian component, so
% it is the correct signal to differentiate to obtain tangential acceleration,
% consistently with .ax (opponents__ax).
    if isfield(S, 'vx')
        s = S.vx(:, min(idx, size(S.vx, 2)));
    elseif isfield(S, 'v')
        s = S.v(:, min(idx, size(S.v, 2)));
    elseif isfield(S, 'speed')
        s = S.speed(:, min(idx, size(S.speed, 2)));
    else
        error('local_speed: no velocity field found (.vx, .v, .speed).');
    end
    s = s(:);
end

function [p, fq] = local_psd(x, nwin, fsr)
% Welch PSD: removes the mean, zeroes NaNs, Hamming window.
    x = x(:); x = x - mean(x,'omitnan'); x(isnan(x)) = 0;
    nwin = min(nwin, floor(numel(x)/2));
    [p, fq] = pwelch(x, hamming(nwin), round(nwin/2), [], fsr);
end

function d_ms = local_delay(x, m, ref_centered, fs, dt)
% Delay of x w.r.t. the centered reference, via cross-correlation peak [ms].
    xm = x(m);
    good = ~isnan(xm);
    if nnz(good) < 10
        d_ms = NaN; return;
    end
    xc_in = xm; xc_in(~good) = 0;
    xc_in = xc_in - mean(xc_in(good));
    [xc, lags] = xcorr(xc_in, ref_centered, round(1*fs));
    [~, imax] = max(xc);
    d_ms = lags(imax) * dt * 1e3;
end