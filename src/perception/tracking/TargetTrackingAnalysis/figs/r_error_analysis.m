%% R_ERROR_ANALYSIS — una figura per sensore
% Per ogni sensore produce 3 figure:
%   fig A: error vs +/-sigma_R (no drift)
%   fig B: error vs drift b(t) +/- sigma_R
%   fig C: PSD dell'errore
% uses: tt, sensors, gt, opp_idx, x_lim, axes, use_ref, use_sim_ref

if ~exist('axes','var'); axes = []; end

has_gt = (exist('use_ref','var') && use_ref) || (exist('use_sim_ref','var') && use_sim_ref);
if ~has_gt
    warning('r_error_analysis: ground truth required. Skipping.');
else

r_field  = {'lidar','pp','radar','camera'};
disp_map = containers.Map( ...
    {'lidar','pp','radar','camera'}, ...
    {'lidar clustering','lidar point pillars','radar','camera'});

% Nomi esatti in sensors{}
sens_name_map = containers.Map( ...
    {'lidar clustering','lidar point pillars','radar','camera'}, ...
    {'lidar','pointpillars','radar','camera'});

% ---------- parameters ----------
smooth_win   = 15;
skip_start_s = 5;
err_outlier  = 3;
out_rd       = 3;
drift_win_s  = 20;
r_floor_eps  = 1e-4;
leg_fs       = 9;

% ---------- GT monotonic ----------
[gts, gtx] = mono_interp_src(gt.stamp, gt.x_rel);
[~,   gty] = mono_interp_src(gt.stamp, gt.y_rel);
has_rd_gt  = isfield(gt,'rho_dot');
if has_rd_gt; [grt, grv] = mono_interp_src(gt.stamp, gt.rho_dot); end

% console header
fprintf('\n');
fprintf('%-22s  %-6s  %-20s  %-20s  %-15s\n', ...
    'Sensore','comp','no-drift 1s/2s','with-drift 1s/2s','drift amp');
fprintf('%s\n', repmat('-',1,95));

% ========== LOOP SENSORI ==========
% Tabella PSD: accumulo risultati
psd_table = {};   % {sname, comp, N, f50, f90}

for k = 1:numel(r_field)
    rf    = r_field{k};
    sname = disp_map(rf);

    % trova indice in sensors{}
    bk = [];
    target_name = sens_name_map(sname);
    for ki = 1:numel(sensors)
        if strcmpi(sensors{ki}.name, target_name)
            bk = ki; break;
        end
    end
    if isempty(bk)
        fprintf('[r_error_analysis] "%s" non trovato in sensors{}. Skip.\n', sname);
        continue;
    end

    s    = sensors{bk}.s;
    scol = sensors{bk}.col;
    st_s = s.sens_stamp(:);
    t0   = min(gts);

    % R adattiva disponibile?
    has_R = isfield(tt,'R') && isfield(tt.R, rf);
    if has_R
        sig_x_tt = sqrt(comp_from_R(tt, rf, opp_idx, 1));
        sig_y_tt = sqrt(comp_from_R(tt, rf, opp_idx, 4));
        if smooth_win > 1
            sig_x_tt = movmedian(sig_x_tt, smooth_win, 'omitnan');
            sig_y_tt = movmedian(sig_y_tt, smooth_win, 'omitnan');
        end
        has_rd_sens = strcmp(rf,'radar') && isfield(tt,'R_rhodot') && has_rd_gt;
        if has_rd_sens
            sig_rd_tt = sqrt(mask_sentinel(tt.R_rhodot(:, opp_idx)));
            if smooth_win > 1; sig_rd_tt = movmedian(sig_rd_tt, smooth_win, 'omitnan'); end
        end
    else
        has_rd_sens = false;
    end

    % numero pannelli
    npan_k   = 2 + (strcmp(rf,'radar') && has_rd_gt && isfield(s,'rho_dot'));
    labels_k = {'x','y','\rho_{dot}'};
    units_k  = {'m','m','m/s'};
    outl_k   = [err_outlier, err_outlier, out_rd];

    % --- Pre-calcola xlim dai campioni validi di x_rel (componente x) ---
    % Primo calcola e_series per x per trovare t_start/t_end con base valida
    meas_tmp = s.x_rel;
    if size(meas_tmp,2) >= opp_idx; meas_tmp = meas_tmp(:, opp_idx); else; meas_tmp = meas_tmp(:,1); end
    mk_tmp   = mask_sentinel(meas_tmp);
    gt_tmp   = interp1(gts, gtx, st_s, 'linear', nan);
    e_tmp    = mk_tmp - gt_tmp;
    base_tmp = isfinite(st_s) & isfinite(e_tmp) & ...
               (st_s - t0 >= skip_start_s) & (abs(e_tmp) <= err_outlier);
    if any(base_tmp)
        t_xlim = [st_s(find(base_tmp,1,'first')), st_s(find(base_tmp,1,'last'))];
    else
        t_xlim = [nan nan];
    end

    % crea 3 figure per questo sensore
    fA = figure('Name', sprintf('Error vs sigma_R (no drift) — %s', sname), 'NumberTitle','off');
    fB = figure('Name', sprintf('Error vs drift b(t) — %s',         sname), 'NumberTitle','off');
    fC = figure('Name', sprintf('PSD errore — %s',                  sname), 'NumberTitle','off');

    axA = gobjects(1, npan_k);
    axB = gobjects(1, npan_k);
    axC = gobjects(1, npan_k);

    % ---- per-componente ----
    for cidx = 1:npan_k
        if cidx == 1
            meas = s.x_rel;   gtt = gts; gtv = gtx;
            if has_R; sig_tt = sig_x_tt; else; sig_tt = []; end
        elseif cidx == 2
            meas = s.y_rel;   gtt = gts; gtv = gty;
            if has_R; sig_tt = sig_y_tt; else; sig_tt = []; end
        else
            meas = s.rho_dot; gtt = grt; gtv = grv;
            if has_rd_sens; sig_tt = sig_rd_tt; else; sig_tt = []; end
        end

        if size(meas,1) ~= numel(st_s) && size(meas,2) == numel(st_s); meas = meas.'; end
        mk       = mask_sentinel(meas(:,1));
        gt_on    = interp1(gtt, gtv, st_s, 'linear', nan);
        e_series = mk - gt_on;

        % sigma interpolata
        if ~isempty(sig_tt) && has_R
            [tt_u, iu2] = unique(tt.stamp(:),'stable');
            sig_u = sig_tt(iu2);
            gsel  = isfinite(tt_u) & isfinite(sig_u);
            if sum(gsel) >= 2
                sig_series = interp1(tt_u(gsel), sig_u(gsel), st_s, 'linear', nan);
            else
                sig_series = nan(size(st_s));
            end
        else
            sig_series = nan(size(st_s));
        end

        outl     = outl_k(cidx);
        is_floor = isfinite(sig_series) & (sig_series <= sqrt(r_floor_eps));
        base     = isfinite(st_s) & isfinite(e_series) & ...
                   (st_s - t0 >= skip_start_s) & (abs(e_series) <= outl) & ...
                   (~isfinite(sig_series) | (sig_series > 0 & ~is_floor));
        excl     = isfinite(st_s) & isfinite(e_series) & ...
                   ~((st_s - t0 >= skip_start_s) & (abs(e_series) <= outl));

        % drift
        dt_med = median(diff(st_s(isfinite(st_s))),'omitnan');
        win_n  = max(3, round(drift_win_s / max(dt_med, eps)));
        e_fd   = e_series; e_fd(~base) = nan;
        b_t    = movmean(e_fd, win_n, 'omitnan');

        % metriche
        kk     = base & isfinite(b_t);
        n_used = nnz(kk);
        cov1=NaN; cov2=NaN; covd1=NaN; covd2=NaN; amp_dr=NaN;
        if n_used > 0
            amp_dr = std(b_t(kk), 'omitnan');
            if has_R && any(isfinite(sig_series(kk)))
                e  = e_series(kk); sg = sig_series(kk); bt = b_t(kk);
                cov1  = 100*nnz(abs(e)    <= 1*sg)/n_used;
                cov2  = 100*nnz(abs(e)    <= 2*sg)/n_used;
                ed    = e - bt;
                covd1 = 100*nnz(abs(ed)   <= 1*sg)/n_used;
                covd2 = 100*nnz(abs(ed)   <= 2*sg)/n_used;
            end
        end
        fprintf('%-22s  e_%-8s  %5.1f%% / %5.1f%%       %5.1f%% / %5.1f%%       amp=%.3f\n', ...
            sname, labels_k{cidx}, cov1, cov2, covd1, covd2, amp_dr);

        % ylabel corti: solo unità, no formula lunga
        ylab_e   = sprintf('[%s]', units_k{cidx});
        ylab_psd = 'PSD [dB/Hz]';

        c_sig  = [0 0 0.55];
        c_2sig = [0 0.45 1];
        c_org  = [0.85 0.33 0.10];

        % ---- FIGURA A: no drift ----
        figure(fA);
        axA(cidx) = subplot(npan_k, 1, cidx); hold on; grid on;
        plot(st_s(base), e_series(base), '.', 'Color', scol, 'MarkerSize', 6, ...
             'DisplayName', sprintf('e_{%s}', labels_k{cidx}));
        if any(excl)
            plot(st_s(excl), e_series(excl), 'x', 'Color',[0.6 0.6 0.6], ...
                 'MarkerSize',4, 'DisplayName','discarded');
        end
        if has_R && any(isfinite(sig_series))
            plot(st_s,  sig_series,   '-', 'Color',c_sig,  'LineWidth',1.3,'DisplayName','\pm\sigma');
            plot(st_s, -sig_series,   '-', 'Color',c_sig,  'LineWidth',1.3,'HandleVisibility','off');
            plot(st_s,  2*sig_series, '-', 'Color',c_2sig, 'LineWidth',1.0,'DisplayName','\pm2\sigma');
            plot(st_s, -2*sig_series, '-', 'Color',c_2sig, 'LineWidth',1.0,'HandleVisibility','off');
            if n_used > 0
                yl = max(max(abs(e_series(base))), 3*median(sig_series(kk),'omitnan'));
                if isfinite(yl) && yl>0; ylim([-1 1]*1.1*yl); end
            end
        end
        ylabel(ylab_e, 'Interpreter','tex', 'FontSize',10);
        % titolo con solo componente e copertura
        title(sprintf('e_{%s}   1\\sigma %.0f%%   2\\sigma %.0f%%', ...
              labels_k{cidx}, cov1, cov2), 'Interpreter','tex', 'FontSize',10);
        legend('show','Location','northeast','FontSize',leg_fs,'NumColumns',2);
        axes(end+1) = axA(cidx); %#ok<SAGROW>

        % ---- FIGURA B: con drift ----
        figure(fB);
        axB(cidx) = subplot(npan_k, 1, cidx); hold on; grid on;
        plot(st_s(base), e_series(base), '.', 'Color', scol, 'MarkerSize', 6, ...
             'DisplayName', sprintf('e_{%s}', labels_k{cidx}));
        if any(excl)
            plot(st_s(excl), e_series(excl), 'x', 'Color',[0.6 0.6 0.6], ...
                 'MarkerSize',4, 'DisplayName','discarded');
        end
        plot(st_s, b_t, '-', 'Color', c_org, 'LineWidth', 1.8, ...
             'DisplayName', sprintf('drift (%gs)', drift_win_s));
        if has_R && any(isfinite(sig_series))
            plot(st_s, b_t+sig_series,   '-', 'Color',c_sig,  'LineWidth',1.3,'DisplayName','b\pm\sigma');
            plot(st_s, b_t-sig_series,   '-', 'Color',c_sig,  'LineWidth',1.3,'HandleVisibility','off');
            plot(st_s, b_t+2*sig_series, '-', 'Color',c_2sig, 'LineWidth',1.0,'DisplayName','b\pm2\sigma');
            plot(st_s, b_t-2*sig_series, '-', 'Color',c_2sig, 'LineWidth',1.0,'HandleVisibility','off');
            if n_used > 0
                yl = max(max(abs(e_series(base))), 3*median(sig_series(kk),'omitnan'));
                if isfinite(yl) && yl>0; ylim([-1 1]*1.1*yl); end
            end
        end
        ylabel(ylab_e, 'Interpreter','tex', 'FontSize',10);
        title(sprintf('e_{%s}   1\\sigma %.0f%%   2\\sigma %.0f%%  (with drift)', ...
              labels_k{cidx}, covd1, covd2), 'Interpreter','tex', 'FontSize',10);
        legend('show','Location','northeast','FontSize',leg_fs,'NumColumns',2);
        axes(end+1) = axB(cidx); %#ok<SAGROW>

        % ---- FIGURA C: PSD ----
        figure(fC);
        axC(cidx) = subplot(npan_k, 1, cidx); hold on; grid on;
        ok = base & isfinite(e_series);
        ts = st_s(ok); es = e_series(ok);
        [ts, iu] = unique(ts,'stable'); es = es(iu);
        [ts, is] = sort(ts);           es = es(is);
        if numel(ts) >= 32
            % PSD diretta sulla sequenza di campioni validi (no interpolazione sui gap)
            fs_s = 1 / median(diff(ts),'omitnan');
            eu   = es - mean(es,'omitnan');
            [pxx, fv] = welch_psd(eu, fs_s);
            if ~isempty(pxx)
                f50    = freq_cumpow(fv, pxx, 0.5);
                f90    = freq_cumpow(fv, pxx, 0.9);
                % accumula per tabella
                psd_table{end+1} = {sname, labels_k{cidx}, numel(eu), f50, f90};

                semilogx(fv(2:end), 10*log10(pxx(2:end)), '-', 'Color', scol, ...
                         'LineWidth', 1.6, 'DisplayName', sprintf('e_{%s}', labels_k{cidx}));
                yl = ylim;
                xline(f50, ':', sprintf('f_{50}=%.3gHz', f50), ...
                      'Color',[0 0 0.55], 'LineWidth',1.2, ...
                      'LabelHorizontalAlignment','right', 'FontSize', 8);
                xline(f90, ':', sprintf('f_{90}=%.3gHz', f90), ...
                      'Color',[0 0.45 1], 'LineWidth',1.0, ...
                      'LabelHorizontalAlignment','right', 'FontSize', 8);
                ylim(yl);
                title(sprintf('e_{%s}   f_{50}=%.3gHz   f_{90}=%.3gHz', ...
                      labels_k{cidx}, f50, f90), 'Interpreter','tex', 'FontSize',10);
            end
        end
        set(axC(cidx), 'XScale','log');
        xlim(axC(cidx), [1e-3, 10]);
        ylabel(ylab_psd, 'FontSize',10);
        legend('show','Location','northeast','FontSize',leg_fs);
        xlabel('f [Hz]');
    end % cidx

    % link assi temporali + xlim sui dati validi
    figure(fA); xlabel('t [s]');
    linkaxes(axA,'x');
    if all(isfinite(t_xlim)); xlim(axA(1), t_xlim); end

    figure(fB); xlabel('t [s]');
    linkaxes(axB,'x');
    if all(isfinite(t_xlim)); xlim(axB(1), t_xlim); end

    % x_lim del main script ha la precedenza
    if exist('x_lim','var') && all(isfinite(x_lim))
        xlim(axA(1), x_lim); xlim(axB(1), x_lim);
    end

    % sgtitle con nome sensore
    figure(fA); sgtitle(sname, 'FontSize',13, 'FontWeight','bold');
    figure(fB); sgtitle(sname, 'FontSize',13, 'FontWeight','bold');
    figure(fC); sgtitle(sname, 'FontSize',13, 'FontWeight','bold');

end % k sensori

fprintf('%s\n', repmat('-',1,95));

% ========== TABELLA PSD ==========
fprintf('\n');
fprintf('╔══════════════════════╦══════════╦══════════╦══════════╦══════════╗\n');
fprintf('║ Sensore              ║  comp    ║    N     ║  f50 Hz  ║  f90 Hz  ║\n');
fprintf('╠══════════════════════╬══════════╬══════════╬══════════╬══════════╣\n');
for ri = 1:numel(psd_table)
    row = psd_table{ri};
    fprintf('║ %-20s ║  %-6s  ║  %6d  ║  %6.4f  ║  %6.4f  ║\n', ...
        row{1}, row{2}, row{3}, row{4}, row{5});
end
fprintf('╚══════════════════════╩══════════╩══════════╩══════════╩══════════╝\n');

end % has_gt

% ===================== local helpers =====================
function c = comp_from_R(tt, s, opp_idx, idx)
    R = pick_opp(tt, 'R', s, opp_idx);
    c = R(:, idx);
end

function [ts, vs] = mono_interp_src(t, v)
    ts = t(:); vs = v(:);
    good = isfinite(ts) & isfinite(vs);
    ts = ts(good); vs = vs(good);
    [ts, iu] = unique(ts,'stable'); vs = vs(iu);
    [ts, is] = sort(ts);           vs = vs(is);
end

function v = pick_opp(tt, field, s, opp_idx)
    d = tt.(field).(s);
    if ndims(d) == 3
        v = squeeze(d(:, opp_idx, :));
    else
        v = d(:, opp_idx);
    end
    v = mask_sentinel(v);
end

function v = mask_sentinel(v)
    v(v <= -9999) = NaN;
end

function [pxx, fv] = welch_psd(x, fs)
    x = x(:); x = x(isfinite(x));
    n = numel(x);
    nseg = 512;   % finestra fissa per confronto omogeneo tra bag/sensori
    if n < nseg
        fprintf('  [welch_psd] N=%d < nseg=%d, stima inaffidabile.\n', n, nseg);
        pxx = []; fv = []; return;
    end
    n_win = floor((n - nseg) / (nseg/2)) + 1;
    if n_win < 6
        fprintf('  [welch_psd] solo %d finestre disponibili, stima poco stabile.\n', n_win);
    end
    nov  = floor(nseg/2);
    step = nseg - nov;
    w = 0.5 - 0.5*cos(2*pi*(0:nseg-1).'/(nseg-1));
    U = sum(w.^2);
    nfft = nseg;
    nb = floor(nfft/2)+1;
    acc = zeros(nb,1); cnt = 0;
    for start = 1:step:(n-nseg+1)
        seg = x(start:start+nseg-1);
        seg = seg - mean(seg);
        seg = seg .* w;
        X = fft(seg, nfft);
        P = (abs(X(1:nb)).^2) / (fs*U);
        P(2:end-1) = 2*P(2:end-1);
        acc = acc + P; cnt = cnt + 1;
    end
    if cnt == 0; pxx = []; fv = []; return; end
    pxx = acc / cnt;
    fv  = (0:nfft/2).' * (fs/nfft);
end

function fc = freq_cumpow(fv, pxx, frac)
    if isempty(pxx); fc = nan; return; end
    p = pxx(:); p(1) = 0;
    c = cumsum(p);
    if c(end) <= 0; fc = nan; return; end
    c = c / c(end);
    idx = find(c >= frac, 1, 'first');
    if isempty(idx); fc = nan; else; fc = fv(idx); end
end