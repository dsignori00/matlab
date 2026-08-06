%% R_DRIFT_COMPARE
% Carica un drift salvato da una bag precedente (file .mat) e lo confronta
% con il drift stimato sulla bag CORRENTE: testa se la struttura del drift
% (ampiezza, costante di tempo, distribuzione) generalizza tra bag diverse.
% Le due curve sono allineate sul PRIMO CAMPIONE VALIDO di ciascuna bag
% (non sull'inizio bag in senso assoluto), per un confronto onesto.
% usa: tt, sensors, gt, opp_idx; chiede il file con uigetfile.

[file, path] = uigetfile('drift_*.mat', 'Seleziona il drift salvato (bag precedente)');
if isequal(file,0)
    disp('Nessun file selezionato, salto il confronto.');
else
    old = load(fullfile(path,file));
    drift_old = old.drift_data;
    band_sensor_save = drift_old.sensor;
    drift_win_s = drift_old.drift_win_s;
    comps_save = intersect(fieldnames(drift_old), {'x','y'});

    r_field = {'lidar','pp','radar','camera'};
    bk = find(strcmp(r_field, band_sensor_save), 1);

    [gts, gtx] = mono_interp_src(gt.stamp, gt.x_rel);
    [~,   gty] = mono_interp_src(gt.stamp, gt.y_rel);

    if isempty(bk)
        warning('r_drift_compare: sensore %s non trovato nella bag corrente.', band_sensor_save);
    else
        s  = sensors{bk}.s;
        st = s.sens_stamp(:);
        t0 = min(gts);

        figure('name', ['Drift generalization: ' band_sensor_save], 'NumberTitle','off');
        np = numel(comps_save);

        fprintf('\n[r_drift_compare] === %s vs bag salvata (%s) ===\n', band_sensor_save, drift_old.created);

        for ci = 1:np
            comp = comps_save{ci};
            if strcmp(comp,'x'); meas = s.x_rel; gtt=gts; gtv=gtx;
            else;                meas = s.y_rel; gtt=gts; gtv=gty;
            end
            if size(meas,1) ~= numel(st) && size(meas,2) == numel(st); meas = meas.'; end
            mk = meas(:,1);
            gt_on = interp1(gtt, gtv, st, 'linear', nan);
            e_series = mk - gt_on;

            base = isfinite(st) & isfinite(e_series) & (st - t0 >= 5) & (abs(e_series) <= 5);
            dt_med = median(diff(st(isfinite(st))), 'omitnan');
            win_n  = max(3, round(drift_win_s / max(dt_med, eps)));
            e_for_drift = e_series; e_for_drift(~base) = nan;
            b_new = movmean(e_for_drift, win_n, 'omitnan');

            sigma_new = std(b_new, 'omitnan');
            tau_new   = drift_timeconst(st(base & isfinite(b_new)), b_new(base & isfinite(b_new)));

            old_c = drift_old.(comp);

            % --- allinea sul PRIMO CAMPIONE VALIDO di ciascuna bag (non su t0 assoluto) ---
            t0_old_valid = min(old_c.t(old_c.base & isfinite(old_c.b)));
            if isempty(t0_old_valid) || ~isfinite(t0_old_valid)
                t0_old_valid = min(old_c.t(isfinite(old_c.t)));
            end
            t_old_rel = old_c.t - t0_old_valid;

            t0_new_valid = min(st(base & isfinite(b_new)));
            if isempty(t0_new_valid) || ~isfinite(t0_new_valid)
                t0_new_valid = t0;
            end
            t_new_rel = st - t0_new_valid;

            % --- plot affiancato: drift vecchio vs nuovo, allineati a t=0 ---
            ax = subplot(np,1,ci); hold(ax,'on'); grid(ax,'on');
            plot(ax, t_old_rel, old_c.b, '-', 'Color', [0.5 0.5 0.5], 'LineWidth', 1.3, ...
                 'DisplayName', sprintf('bag precedente (\\sigma=%.2f \\tau=%.0fs)', old_c.sigma_b, old_c.tau_b));
            plot(ax, t_new_rel, b_new,  '-', 'Color', [0.85 0.33 0.10], 'LineWidth', 1.3, ...
                 'DisplayName', sprintf('bag corrente  (\\sigma=%.2f \\tau=%.0fs)', sigma_new, tau_new));
            yline(ax, 0, 'k:', 'HandleVisibility','off');
            ylabel(ax, sprintf('b_%s [m]', comp));
            title(ax, sprintf('drift %s - %s: \\sigma %.2f vs %.2f   \\tau %.0fs vs %.0fs', ...
                comp, band_sensor_save, old_c.sigma_b, sigma_new, old_c.tau_b, tau_new), 'Interpreter','tex');
            legend(ax, 'show', 'Location','best');
            if ci == np; xlabel(ax, 't relativo [s] (da primo campione valido)'); end

            % --- verdetto numerico di generalizzazione ---
            ratio_sigma = sigma_new / max(old_c.sigma_b, eps);
            ratio_tau   = tau_new   / max(old_c.tau_b, eps);
            fprintf('  %s: sigma_b  %.3f -> %.3f  (rapporto %.2f)\n', comp, old_c.sigma_b, sigma_new, ratio_sigma);
            fprintf('  %s: tau_b    %.1fs -> %.1fs  (rapporto %.2f)\n', comp, old_c.tau_b, tau_new, ratio_tau);
            if ratio_sigma > 0.5 && ratio_sigma < 2 && ratio_tau > 0.5 && ratio_tau < 2
                fprintf('  %s: GENERALIZZA (stessa scala ampiezza/tempo) -> Q_b fisso plausibile\n', comp);
            else
                fprintf('  %s: NON generalizza bene -> serve Q_b adattivo per bag, non un valore fisso\n', comp);
            end
        end
        fprintf('\n');
    end
end

% ===================== helper locali =====================
function tau = drift_timeconst(t, b)
    b = b(:); t = t(:);
    ok = isfinite(b) & isfinite(t);
    b = b(ok) - mean(b(ok),'omitnan'); t = t(ok);
    if numel(b) < 20; tau = nan; return; end
    maxlag = min(numel(b)-1, 2000);
    c = xcorr(b, maxlag, 'normalized');
    c = c(maxlag+1:end);
    idx = find(c < exp(-1), 1, 'first');
    dt = median(diff(t),'omitnan');
    if isempty(idx) || ~isfinite(dt); tau = nan; else; tau = (idx-1)*dt; end
end

function [ts, vs] = mono_interp_src(t, v)
    ts = t(:); vs = v(:);
    good = isfinite(ts) & isfinite(vs);
    ts = ts(good); vs = vs(good);
    [ts, iu] = unique(ts, 'stable'); vs = vs(iu);
    [ts, is] = sort(ts);             vs = vs(is);
end