%% R_DRIFT_SAVE
% Calcola il drift b(t) per il sensore/componente scelti sulla bag corrente
% e lo salva su disco per confrontarlo in un run successivo con un'altra bag.
% usa: tt, sensors, gt, opp_idx, drift_win_s (se non definita, default sotto)

if ~exist('drift_win_s','var'); drift_win_s = 20; end
band_sensor_save = 'pp';     % sensore da salvare
comps_save = {'x','y'};      % componenti da salvare

r_field = {'lidar','pp','radar','camera'};
bk = find(strcmp(r_field, band_sensor_save), 1);

[gts, gtx] = mono_interp_src(gt.stamp, gt.x_rel);
[~,   gty] = mono_interp_src(gt.stamp, gt.y_rel);

drift_data = struct();
drift_data.bag_name   = '';   % compilala sotto se vuoi taggare la bag
drift_data.sensor     = band_sensor_save;
drift_data.drift_win_s = drift_win_s;
drift_data.created    = datestr(now);

if isempty(bk)
    warning('r_drift_save: sensore %s non trovato in sensors.', band_sensor_save);
else
    s  = sensors{bk}.s;
    st = s.sens_stamp(:);
    t0 = min(gts);

    for ci = 1:numel(comps_save)
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
        b_t = movmean(e_for_drift, win_n, 'omitnan');

        drift_data.(comp).t    = st;
        drift_data.(comp).b    = b_t;
        drift_data.(comp).e    = e_series;
        drift_data.(comp).base = base;
        drift_data.(comp).sigma_b = std(b_t, 'omitnan');
        drift_data.(comp).tau_b   = drift_timeconst(st(base & isfinite(b_t)), b_t(base & isfinite(b_t)));
    end

    save_path = fullfile(pwd, sprintf('drift_%s_%s.mat', band_sensor_save, datestr(now,'yyyymmdd_HHMMSS')));
    save(save_path, 'drift_data');
    fprintf('[r_drift_save] Salvato: %s\n', save_path);
    fprintf('  Per confrontarlo con la prossima bag, esegui r_drift_compare con questo file.\n');
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