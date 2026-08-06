%% R_WHITE_CHECK
% Verifica che la R stimata "contenga" l'innovazione BIANCA (innov dopo
% rimozione del bias colorato). Per ogni sensore e componente:
%   - innovazione bianca vs bande +/-sigma e +/-2sigma ricavate da R (diagonale)
%   - copertura empirica 1sigma (~68%) e 2sigma (~95%)
%   - ac1 dell'innovazione standardizzata z=innov/sigma (~0 se bianca)
% R: [N x 4] (2x2 row-major) -> sigma_x=sqrt(R(:,1)), sigma_y=sqrt(R(:,4)).
% usa: tt, opp_idx, x_lim, axes
% Campi richiesti da load_tt: tt.innov_white.(s), tt.R.(s)

if ~exist('axes','var'); axes = []; end

% ground truth (frame relativo) per validare la copertura su misura-gt
has_gt = (exist('use_ref','var') && use_ref) || (exist('use_sim_ref','var') && use_sim_ref);
if has_gt && exist('gt','var')
    [gts_w, gtx_w] = mono_interp_src(gt.stamp, gt.x_rel);
    [~,     gty_w] = mono_interp_src(gt.stamp, gt.y_rel);
else
    has_gt = false;
end
sens_name_map = struct('lidar','lidar','pp','pointpillars','radar','radar','camera','camera');

sens_list = {'lidar','pp','radar','camera'};
sens_disp = {'lidar','pointpillars','radar','camera'};
comp_lab  = {'x','y'};
diag_idx  = [1 4];           % posizioni diagonale di R (xx, yy)

% colore per sensore (coerente con le altre figure: lidar verde, pp arancione,
% radar azzurro, camera giallo). Fallback se 'col' non e' definito.
sens_col = containers.Map('KeyType','char','ValueType','any');
if exist('col','var')
    sens_col('lidar')  = col.lidar;
    sens_col('pp')     = col.pp;
    sens_col('radar')  = col.radar;
    sens_col('camera') = col.camera;
else
    sens_col('lidar')  = [0.20 0.65 0.30];
    sens_col('pp')     = [0.90 0.55 0.10];
    sens_col('radar')  = [77 190 238]/255;
    sens_col('camera') = [0.95 0.80 0.15];
end

for k = 1:numel(sens_list)
    s = sens_list{k};
    if ~isfield(tt,'innov_white') || ~isfield(tt.innov_white, s); continue; end
    if ~isfield(tt,'R')           || ~isfield(tt.R, s);           continue; end

    IW = pick_opp(tt, 'innov_white', s, opp_idx);   % [N x nc]
    R  = pick_opp(tt, 'R',           s, opp_idx);   % [N x 4]
    nc = min(size(IW,2), numel(diag_idx));
    if nc < 1; continue; end

    figure('Name',['innov bianca vs R - ' sens_disp{k}],'NumberTitle','off');
    ax_pan = gobjects(1,nc);
    for c = 1:nc
        ax = subplot(nc,1,c); hold(ax,'on'); grid(ax,'on');
        ax_pan(c) = ax; axes(end+1) = ax; %#ok<SAGROW>

        iw  = IW(:,c);
        sig = sqrt(abs(R(:, diag_idx(c))));
        t   = tt.stamp(:);

        % innovazione bianca (colore del sensore)
        plot(ax, t, iw, '.', 'Color', sens_col(s), 'MarkerSize', 7, ...
             'DisplayName', sprintf('innov bianca e_{%s}', comp_lab{c}));

        % bande da R
        c_sig = [0 0 0.55]; c_2sig = [0 0.45 1];
        plot(ax, t,  sig,   '-', 'Color', c_sig,  'LineWidth', 1.2, 'DisplayName', '\pm\sigma');
        plot(ax, t, -sig,   '-', 'Color', c_sig,  'LineWidth', 1.2, 'HandleVisibility','off');
        plot(ax, t,  2*sig, '-', 'Color', c_2sig, 'LineWidth', 1.0, 'DisplayName', '\pm2\sigma');
        plot(ax, t, -2*sig, '-', 'Color', c_2sig, 'LineWidth', 1.0, 'HandleVisibility','off');

        % metriche di consistenza (su campioni validi con sigma>0)
        ok = isfinite(iw) & isfinite(sig) & sig > 0;
        n  = nnz(ok);
        cov1 = 100*nnz(abs(iw(ok)) <= 1*sig(ok))/max(n,1);
        cov2 = 100*nnz(abs(iw(ok)) <= 2*sig(ok))/max(n,1);
        z = iw(ok) ./ sig(ok); z = z(isfinite(z));
        ac1 = nan; if numel(z) > 10; ac1 = corr(z(1:end-1), z(2:end)); end
        medz2 = median(z.^2, 'omitnan');   % atteso ~1 se R ben calibrata

        % limiti y robusti
        yl = max( prctile_local(abs(iw(ok)), 99), 3*median(sig(ok),'omitnan') );
        if isfinite(yl) && yl>0; ylim(ax, [-1 1]*1.1*yl); end

        ylabel(ax, sprintf('innov_{%s}', comp_lab{c}));
        title(ax, sprintf('%s e_{%s}  1\\sigma %.0f%%  2\\sigma %.0f%%  ac1=%.2f  med(z^2)=%.2f  (n=%d)', ...
            sens_disp{k}, comp_lab{c}, cov1, cov2, ac1, medz2, n), 'Interpreter','tex');
        legend(ax, 'show', 'Location', 'best');
    end
    xlabel('t [s]');
    if all(isgraphics(ax_pan)); linkaxes(ax_pan, 'x'); end
    if exist('x_lim','var') && all(isfinite(x_lim)) && all(isgraphics(ax_pan))
        xlim(ax_pan(1), x_lim);
    end

    fprintf('[r_white_check] %s: ', sens_disp{k});
    fprintf('(1s atteso ~68%%, 2s ~95%%, ac1 ~0, med(z^2) ~1)\n');
end

% ===================== FIGURE EXTRA (solo lidar e pp): innov grezza + PSD =====================
extra_sens = {'lidar','pp'};
for kk = 1:numel(extra_sens)
    s = extra_sens{kk};
    si = find(strcmp(sens_list, s), 1);
    has_raw   = isfield(tt,'innov')       && isfield(tt.innov, s);
    has_white = isfield(tt,'innov_white') && isfield(tt.innov_white, s);
    if ~has_raw && ~has_white; continue; end
    if ~isfield(tt,'R') || ~isfield(tt.R, s); continue; end

    IR = []; if has_raw;   IR = pick_opp(tt,'innov',       s, opp_idx); end
    IW = []; if has_white; IW = pick_opp(tt,'innov_white', s, opp_idx); end
    R  = pick_opp(tt,'R', s, opp_idx);
    ncs = max([size(IR,2) size(IW,2)]);
    nc  = min(ncs, numel(diag_idx));
    t   = tt.stamp(:);

    % ---------- FIG A: innovazione GREZZA vs bande R ----------
    if has_raw
        figure('Name',['innov GREZZA vs R - ' sens_disp{si}],'NumberTitle','off');
        axg = gobjects(1,nc);
        for c = 1:nc
            ax = subplot(nc,1,c); hold(ax,'on'); grid(ax,'on');
            axg(c) = ax; axes(end+1) = ax; %#ok<SAGROW>
            ir  = IR(:,c);
            sig = sqrt(abs(R(:, diag_idx(c))));
            plot(ax, t, ir, '.', 'Color', sens_col(s), 'MarkerSize', 7, ...
                 'DisplayName', sprintf('innov grezza e_{%s}', comp_lab{c}));
            c_sig = [0 0 0.55]; c_2sig = [0 0.45 1];
            plot(ax, t,  sig,   '-', 'Color', c_sig,  'LineWidth', 1.2, 'DisplayName', '\pm\sigma');
            plot(ax, t, -sig,   '-', 'Color', c_sig,  'LineWidth', 1.2, 'HandleVisibility','off');
            plot(ax, t,  2*sig, '-', 'Color', c_2sig, 'LineWidth', 1.0, 'DisplayName', '\pm2\sigma');
            plot(ax, t, -2*sig, '-', 'Color', c_2sig, 'LineWidth', 1.0, 'HandleVisibility','off');
            ok = isfinite(ir) & isfinite(sig) & sig>0; n = nnz(ok);
            cov1 = 100*nnz(abs(ir(ok))<=1*sig(ok))/max(n,1);
            cov2 = 100*nnz(abs(ir(ok))<=2*sig(ok))/max(n,1);
            z = ir(ok)./sig(ok); z = z(isfinite(z));
            ac1 = nan; if numel(z)>10; ac1 = corr(z(1:end-1), z(2:end)); end
            yl = max( prctile_local(abs(ir(ok)),99), 3*median(sig(ok),'omitnan') );
            if isfinite(yl) && yl>0; ylim(ax,[-1 1]*1.1*yl); end
            ylabel(ax, sprintf('innov_{%s}', comp_lab{c}));
            title(ax, sprintf('%s e_{%s} GREZZA  1\\sigma %.0f%%  2\\sigma %.0f%%  ac1=%.2f  (n=%d)', ...
                sens_disp{si}, comp_lab{c}, cov1, cov2, ac1, n), 'Interpreter','tex');
            legend(ax,'show','Location','best');
        end
        xlabel('t [s]');
        if all(isgraphics(axg)); linkaxes(axg,'x'); end
        if exist('x_lim','var') && all(isfinite(x_lim)) && all(isgraphics(axg)); xlim(axg(1), x_lim); end
    end

    % ---------- FIG B: PSD innovazione grezza vs bianca ----------
    figure('Name',['PSD innov (grezza vs bianca) - ' sens_disp{si}],'NumberTitle','off');
    axp = gobjects(1,nc);
    for c = 1:nc
        ax = subplot(nc,1,c); hold(ax,'on'); grid(ax,'on');
        axp(c) = ax;   % asse in frequenza -> NON aggiunto a 'axes'
        leg = {};
        if has_raw
            [fvr, pr] = psd_of_series(t, IR(:,c));
            if ~isempty(pr)
                semilogx(ax, fvr(2:end), 10*log10(pr(2:end)), '-', 'Color', [0.6 0.6 0.6], ...
                         'LineWidth', 1.3); leg{end+1} = 'grezza'; %#ok<SAGROW>
            end
        end
        if has_white
            [fvw, pw] = psd_of_series(t, IW(:,c));
            if ~isempty(pw)
                semilogx(ax, fvw(2:end), 10*log10(pw(2:end)), '-', 'Color', sens_col(s), ...
                         'LineWidth', 1.6); leg{end+1} = 'bianca'; %#ok<SAGROW>
            end
        end
        grid(ax,'on'); set(ax,'XScale','log');
        ylabel(ax, sprintf('PSD innov_{%s} [dB/Hz]', comp_lab{c}));
        title(ax, sprintf('%s e_{%s}: PSD innovazione (grezza vs bianca)', sens_disp{si}, comp_lab{c}));
        if ~isempty(leg); legend(ax, leg, 'Location','best'); end
    end
    xlabel('f [Hz]');
    if all(isgraphics(axp)); linkaxes(axp,'x'); end

    % ---------- FIG C: validazione su ERRORE MISURA-GT centrato su b(t) ----------
    % b(t)=innov-innov_white e' la media rimossa dal passa-alto a 0.5 Hz.
    % Validiamo R sull'errore INDIPENDENTE misura-gt (non sull'innovazione usata per
    % stimarla). Residuo = (misura-gt) - b(t); copertura entro +/-sigma, +/-2sigma da R.
    % Se manca il gt -> fallback su innovazione grezza (residuo = innov_white).
    if has_raw && has_white
        figure('Name',['R su errore misura-gt centrata su b(t) - ' sens_disp{si}],'NumberTitle','off');
        axb = gobjects(1,nc);

        % errore misura-gt riportato su tt.stamp, per ogni componente
        sname = sens_name_map.(s);
        sidx  = find(cellfun(@(z) strcmp(z.name, sname), sensors), 1);
        e_gt = nan(numel(t), nc);
        err_outlier = 3;     % [m] scarta |misura-gt| oltre questa soglia
        gap_factor  = 3;     % buco se dt tra campioni > gap_factor * dt mediano sensore
        if has_gt && ~isempty(sidx)
            sd = sensors{sidx}.s; stps = sd.sens_stamp(:);
            for c = 1:nc
                if c==1; meas = sd.x_rel; gtv = gtx_w; else; meas = sd.y_rel; gtv = gty_w; end
                if size(meas,1)~=numel(stps) && size(meas,2)==numel(stps); meas = meas.'; end
                mk = meas(:,1); mk(mk<=-9999)=nan;
                gon = interp1(gts_w, gtv, stps, 'linear', nan);
                em  = mk - gon;                                  % errore sui tempi sensore
                em(abs(em) > err_outlier) = nan;                 % scarta outlier > 3 m
                gg = isfinite(stps) & isfinite(em);
                if nnz(gg) > 2
                    [su, eu_] = mono_interp_src(stps(gg), em(gg));   % unici e ordinati
                    if numel(su) > 2
                        eint = interp1(su, eu_, t, 'linear', nan);
                        % NON interpolare attraverso i buchi: NaN se il campione e'
                        % troppo lontano dal piu' vicino stamp valido del sensore.
                        dt_s   = median(diff(su), 'omitnan');
                        maxgap = gap_factor * dt_s;
                        % distanza dal piu' vicino stamp del sensore (memory-safe)
                        idxn   = interp1(su, 1:numel(su), t, 'nearest', 'extrap');
                        dnear  = abs(t - su(idxn));
                        eint(dnear > maxgap) = nan;                  % apri i buchi
                        e_gt(:,c) = eint;
                    end
                end
            end
        end

        for c = 1:nc
            ax = subplot(nc,1,c); hold(ax,'on'); grid(ax,'on');
            axb(c) = ax; axes(end+1) = ax; %#ok<SAGROW>

            ir  = IR(:,c); iw = IW(:,c);
            b   = ir - iw;                                  % media rimossa
            sig = sqrt(abs(R(:, diag_idx(c))));

            use_gt = has_gt && any(isfinite(e_gt(:,c)));
            if use_gt
                eref = e_gt(:,c); ref_name = 'errore misura-gt';
            else
                eref = ir;        ref_name = 'innov grezza (no gt)';
            end

            % errore di riferimento (punti) e media b(t)
            plot(ax, t, eref, '.', 'Color', sens_col(s), 'MarkerSize', 6, 'DisplayName', ref_name);
            plot(ax, t, b, '-', 'Color', [0.85 0.33 0.10], 'LineWidth', 1.6, ...
                 'DisplayName', 'b(t)=innov-innov\_white');

            % bande centrate su b(t)
            cb = [0 0 0.55]; c2b = [0 0.45 1];
            plot(ax, t, b+sig,   '-', 'Color', cb,  'LineWidth', 1.3, 'DisplayName', 'b\pm\sigma');
            plot(ax, t, b-sig,   '-', 'Color', cb,  'LineWidth', 1.3, 'HandleVisibility','off');
            plot(ax, t, b+2*sig, '-', 'Color', c2b, 'LineWidth', 1.0, 'DisplayName', 'b\pm2\sigma');
            plot(ax, t, b-2*sig, '-', 'Color', c2b, 'LineWidth', 1.0, 'HandleVisibility','off');

            % bande centrate a 0 (contrasto)
            plot(ax, t,  sig, '--', 'Color', [0.5 0.5 0.5], 'LineWidth', 1.0, 'DisplayName', '\pm\sigma (su 0)');
            plot(ax, t, -sig, '--', 'Color', [0.5 0.5 0.5], 'LineWidth', 1.0, 'HandleVisibility','off');

            % copertura: residuo centrato b = eref-b  vs  residuo su 0 = eref
            ok = isfinite(eref) & isfinite(b) & isfinite(sig) & sig>0; n = nnz(ok);
            rb = eref(ok) - b(ok);
            covb1 = 100*nnz(abs(rb)        <= 1*sig(ok))/max(n,1);
            covb2 = 100*nnz(abs(rb)        <= 2*sig(ok))/max(n,1);
            cov01 = 100*nnz(abs(eref(ok))  <= 1*sig(ok))/max(n,1);
            cov02 = 100*nnz(abs(eref(ok))  <= 2*sig(ok))/max(n,1);

            yl = max( prctile_local(abs(eref(ok)),99), 3*median(sig(ok),'omitnan') );
            if isfinite(yl) && yl>0; ylim(ax,[-1 1]*1.1*yl); end

            ylabel(ax, sprintf('e_{%s}', comp_lab{c}));
            title(ax, sprintf(['%s e_{%s} [%s]  centrata b: 1\\sigma %.0f%% 2\\sigma %.0f%%   ' ...
                               'su 0: 1\\sigma %.0f%% 2\\sigma %.0f%%  (n=%d)'], ...
                sens_disp{si}, comp_lab{c}, ternary(use_gt,'gt','innov'), ...
                covb1, covb2, cov01, cov02, n), 'Interpreter','tex');
            legend(ax,'show','Location','best');
        end
        xlabel('t [s]');
        if all(isgraphics(axb)); linkaxes(axb,'x'); end
        if exist('x_lim','var') && all(isfinite(x_lim)) && all(isgraphics(axb)); xlim(axb(1), x_lim); end

        fprintf('[r_white_check] %s: validazione R su errore %s, centrata su b(t).\n', ...
            sens_disp{si}, ternary(has_gt,'misura-gt','innov (no gt)'));
        fprintf('   "su 0" sfora ma "centrata b" ~68/95%% -> R giusta, solo scentrata dal drift.\n');
        fprintf('   "centrata b" >95%% -> R sovrastimata; <68%% (1s) -> R sottostimata (taglio 0.5Hz toglie troppo).\n');

        % ---------- FIG D: Bode innovazione grezza / errore misura-gt ----------
        % Stima H(f)=innov/errore: guadagno [dB] + fase [deg] + coerenza.
        % Fase ~0 -> in fase; ~+/-180 -> controfase (il "180" che sospettavi).
        if has_gt
            figure('Name',['Bode innov/errore (gt) - ' sens_disp{si}],'NumberTitle','off');
            for c = 1:nc
                xin = e_gt(:,c);   % ingresso: errore misura-gt
                yout= IR(:,c);     % uscita: innovazione grezza
                ok2 = isfinite(xin) & isfinite(yout);
                tk = t(ok2); xk = xin(ok2); yk = yout(ok2);
                [tk,iu] = unique(tk,'stable'); xk=xk(iu); yk=yk(iu);
                [tk,is] = sort(tk);            xk=xk(is); yk=yk(is);
                if numel(tk) < 32; continue; end
                dt = median(diff(tk),'omitnan'); fs = 1/dt;
                tu = (tk(1):dt:tk(end)).';
                xu = interp1(tk,xk,tu,'linear'); xu = xu-mean(xu,'omitnan');
                yu = interp1(tk,yk,tu,'linear'); yu = yu-mean(yu,'omitnan');
                [fv, Hmag, Hph, g2] = welch_tf(xu, yu, fs);
                if isempty(fv); continue; end

                % guadagno + coerenza
                axm = subplot(2*nc, 1, 2*c-1); hold(axm,'on'); grid(axm,'on');
                yyaxis(axm,'left');
                semilogx(axm, fv(2:end), Hmag(2:end), '-', 'Color', sens_col(s), 'LineWidth', 1.4);
                ylabel(axm,'|H| [dB]');
                yyaxis(axm,'right');
                semilogx(axm, fv(2:end), g2(2:end), '-', 'Color', [0.75 0.2 0.2], 'LineWidth', 1.0);
                ylim(axm,[0 1]); ylabel(axm,'\gamma^2');
                set(axm,'XScale','log'); xlim(axm,[max(1e-3,fv(2)) fv(end)]);
                title(axm, sprintf('%s e_{%s}: guadagno |innov/errore| + coerenza', sens_disp{si}, comp_lab{c}));

                % fase
                axp2 = subplot(2*nc, 1, 2*c); hold(axp2,'on'); grid(axp2,'on');
                semilogx(axp2, fv(2:end), Hph(2:end), '-', 'Color', [0.2 0.2 0.2], 'LineWidth', 1.2);
                yline(axp2, 0, 'k:'); yline(axp2, 180, 'r:'); yline(axp2, -180, 'r:');
                ylim(axp2,[-200 200]); set(axp2,'YTick',-180:90:180);
                set(axp2,'XScale','log'); xlim(axp2,[max(1e-3,fv(2)) fv(end)]);
                ylabel(axp2,'fase [deg]');
                title(axp2, sprintf('%s e_{%s}: fase innov/errore', sens_disp{si}, comp_lab{c}));
            end
            xlabel('f [Hz]');
        end
    end
end

% ===================== helper locali =====================
function [ts, vs] = mono_interp_src(t, v)
    ts = t(:); vs = v(:);
    good = isfinite(ts) & isfinite(vs);
    ts = ts(good); vs = vs(good);
    [ts, iu] = unique(ts, 'stable'); vs = vs(iu);
    [ts, is] = sort(ts);             vs = vs(is);
end

function out = ternary(cond, a, b)
    if cond; out = a; else; out = b; end
end

function v = pick_opp(tt, field, s, opp_idx)
    d = tt.(field).(s);
    if ndims(d) == 3
        v = squeeze(d(:, opp_idx, :));
    else
        v = d(:, opp_idx);
    end
    v(v <= -9999) = NaN;   % sentinella "no data"
end

% percentile senza Statistics Toolbox
function p = prctile_local(x, q)
    x = x(:); x = x(isfinite(x));
    if isempty(x); p = nan; return; end
    x = sort(x);
    if numel(x) == 1; p = x; return; end
    idx = (q/100)*(numel(x)-1) + 1;
    lo = floor(idx); hi = ceil(idx); fr = idx - lo;
    p = x(lo)*(1-fr) + x(hi)*fr;
end

% PSD di una serie (t,x) non uniforme: ricampiona su griglia uniforme e Welch
function [fv, pxx] = psd_of_series(t, x)
    t = t(:); x = x(:);
    ok = isfinite(t) & isfinite(x);
    t = t(ok); x = x(ok);
    [t, iu] = unique(t,'stable'); x = x(iu);
    [t, is] = sort(t);            x = x(is);
    if numel(t) < 32; fv = []; pxx = []; return; end
    dt = median(diff(t),'omitnan'); fs = 1/dt;
    tu = (t(1):dt:t(end)).';
    xu = interp1(t, x, tu, 'linear');
    xu = xu - mean(xu,'omitnan');
    [pxx, fv] = welch_psd(xu, fs);
end

% PSD di Welch one-sided (Hann, ~8 segmenti, 50% overlap). Self-contained.
function [pxx, fv] = welch_psd(x, fs)
    x = x(:); x = x(isfinite(x));
    n = numel(x);
    if n < 16; pxx = []; fv = []; return; end
    nseg = 2^floor(log2(max(16, n/8)));
    nseg = min(nseg, n);
    nov  = floor(nseg/2);
    step = nseg - nov;
    w = 0.5 - 0.5*cos(2*pi*(0:nseg-1).'/(nseg-1));   % Hann
    U = sum(w.^2);
    nfft = nseg; nb = floor(nfft/2)+1;
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

% Funzione di trasferimento di Welch H = Sxy/Sxx tra ingresso x e uscita y.
% Ritorna fv, |H| in dB, fase [deg], coerenza gamma^2 in [0,1].
function [fv, Hmag, Hph, g2] = welch_tf(x, y, fs)
    x = x(:); y = y(:);
    m = isfinite(x) & isfinite(y); x = x(m); y = y(m);
    n = numel(x);
    if n < 16; fv=[]; Hmag=[]; Hph=[]; g2=[]; return; end
    nseg = 2^floor(log2(max(16, n/8))); nseg = min(nseg, n);
    nov  = floor(nseg/2); step = nseg - nov;
    w = 0.5 - 0.5*cos(2*pi*(0:nseg-1).'/(nseg-1));
    nfft = nseg; nb = floor(nfft/2)+1;
    Sxx = zeros(nb,1); Syy = zeros(nb,1); Sxy = complex(zeros(nb,1)); cnt = 0;
    for st = 1:step:(n-nseg+1)
        xs = x(st:st+nseg-1); xs = (xs-mean(xs)).*w;
        ys = y(st:st+nseg-1); ys = (ys-mean(ys)).*w;
        X = fft(xs,nfft); Y = fft(ys,nfft);
        X = X(1:nb); Y = Y(1:nb);
        Sxx = Sxx + (abs(X).^2); Syy = Syy + (abs(Y).^2);
        Sxy = Sxy + (conj(X).*Y);          % ingresso x -> uscita y
        cnt = cnt + 1;
    end
    if cnt == 0; fv=[]; Hmag=[]; Hph=[]; g2=[]; return; end
    H   = Sxy ./ max(Sxx, eps);
    Hmag= 20*log10(abs(H) + eps);
    Hph = angle(H) * 180/pi;
    g2  = (abs(Sxy).^2) ./ max(Sxx.*Syy, eps);
    fv  = (0:nfft/2).' * (fs/nfft);
end