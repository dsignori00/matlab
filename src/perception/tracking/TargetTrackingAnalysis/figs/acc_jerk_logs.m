%% ACC_JERK_LOGS - plot accelerazione e jerk dei log caricati
% Da chiamare dallo script principale (stile jerk_derivation), DOPO il
% blocco PARSING (usa tt, tt2, tt3, gt, opp_idx, axes, f, compare, compare2,
% use_ref/use_sim_ref, name1/name2/name3, col.tt/tt2/tt3).
%
% Subplot 1: ax di ogni log attivo (sul proprio asse tempi originale,
%            nessun ricampionamento) + GT (smoothato, stesso trattamento
%            usato per derivarne il jerk, cosi' le due curve sono coerenti).
% Subplot 2 (se disponibile almeno un jerk): jerk loggato di ogni log che
%            ha il campo tt.jerk (vedi load_tt.m), + jerk GT ottenuto
%            derivando l'accelerazione GT (stesso metodo di jerk_filtering.m:
%            smoothing zero-phase leggero + derivata numerica, offline).

%% ------------------- HELPER: compact legend outside the axes ------------
% Places the legend to the EAST (right of the axes) with small font, so it
% doesn't eat plot space. Change 'eastoutside' to 'southoutside' for below.
compactLegend = @(ax) set(legend(ax), 'Location', 'eastoutside', ...
    'FontSize', 8, 'Box', 'off');

%% ------------------- RACCOLTA LOG ATTIVI -------------------
logs = struct('tt', {}, 'name', {}, 'col', {});

logs(end+1) = struct('tt', tt, 'name', name1, 'col', col.tt);
if exist('compare','var') && compare && exist('tt2','var') && isstruct(tt2)
    logs(end+1) = struct('tt', tt2, 'name', name2, 'col', col.tt2);
end
if exist('compare2','var') && compare2 && exist('tt3','var') && isstruct(tt3)
    logs(end+1) = struct('tt', tt3, 'name', name3, 'col', col.tt3);
end
n_logs = numel(logs);

%% ------------------- GT: ACCELERAZIONE (smoothata) E JERK DERIVATO ------
% Stesso procedimento di jerk_filtering.m: smoothing zero-phase leggero
% (offline, niente ritardo) + derivata numerica sull'ax GT.
fc_gt_deriv = 5;   % [Hz] cutoff zero-phase per lo smoothing/derivata del GT

has_gt = (exist('use_ref','var') && use_ref) || (exist('use_sim_ref','var') && use_sim_ref);
has_gt = has_gt && exist('gt','var') && isstruct(gt) && isfield(gt,'stamp') && isfield(gt,'ax');

has_gt_jerk_deriv = false;
if has_gt
    t_gt_raw  = gt.stamp(:);
    ax_gt_raw = gt.ax;
    if size(ax_gt_raw, 2) > 1
        ax_gt_raw = ax_gt_raw(:, min(opp_idx, size(ax_gt_raw,2)));
    end
    ax_gt_raw = ax_gt_raw(:);

    v_gt = ~isnan(t_gt_raw) & ~isnan(ax_gt_raw);
    [t_gt, ig] = unique(t_gt_raw(v_gt), 'stable');
    ax_gt_v = ax_gt_raw(v_gt); ax_gt_v = ax_gt_v(ig);

    if numel(t_gt) > 4
        dt_gt = median(diff(t_gt));
        t_gtu  = (t_gt(1):dt_gt:t_gt(end)).';
        ax_gtu = interp1(t_gt, ax_gt_v, t_gtu, 'linear');

        [b_gt, a_gt] = butter(2, min(fc_gt_deriv/(1/dt_gt/2), 0.99));
        ax_gtu_f      = filtfilt(b_gt, a_gt, ax_gtu);
        jerk_gt_deriv = gradient(ax_gtu_f, dt_gt);
        has_gt_jerk_deriv = true;
    end
end

has_any_jerk = any(arrayfun(@(L) isfield(L.tt, 'jerk'), logs)) || has_gt_jerk_deriv;

%% ------------------- PLOT -------------------
n_rows = 1 + double(has_any_jerk);
figure('Name','Acceleration & Jerk log','NumberTitle','off'); f = f+1;
tl = tiledlayout(n_rows,1,'TileSpacing','compact');

% --- acceleration ---
nexttile; hold on; grid on;
for k = 1:n_logs
    L = logs(k);
    plot(L.tt.stamp, L.tt.ax(:,opp_idx), 'Color', L.col, 'LineWidth', 1.0, ...
        'DisplayName', L.name);
end
if has_gt_jerk_deriv
    plot(t_gtu, ax_gtu_f, 'k', 'LineWidth', 1.3, 'DisplayName', 'GT');
end
ylabel('a_x [m/s^2]'); compactLegend(gca);
title(tl, sprintf('Acceleration and jerk - opp %d', opp_idx), 'FontWeight', 'bold');
if n_rows == 1; xlabel('t [s]'); end
axes = [axes, gca]; %#ok<AGROW>

% --- jerk ---
if has_any_jerk
    nexttile; hold on; grid on;
    for k = 1:n_logs
        L = logs(k);
        if isfield(L.tt, 'jerk')
            plot(L.tt.stamp, L.tt.jerk(:,opp_idx), 'Color', L.col, 'LineWidth', 1.0, ...
                'DisplayName', [L.name ' (jerk)']);
        end
    end
    if has_gt_jerk_deriv
        plot(t_gtu, jerk_gt_deriv, 'k', 'LineWidth', 1.3, 'DisplayName', 'GT jerk (derived)');
    end
    ylabel('jerk [m/s^3]'); xlabel('t [s]'); compactLegend(gca);
    axes = [axes, gca]; %#ok<AGROW>
else
    warning('acc_jerk_logs: no jerk available (neither logged nor derivable from GT) - only ax plotted.');
end

clearvars logs n_logs has_gt has_gt_jerk_deriv has_any_jerk n_rows k L ...
    t_gt_raw ax_gt_raw v_gt ig t_gt ax_gt_v dt_gt t_gtu ax_gtu b_gt a_gt ...
    ax_gtu_f jerk_gt_deriv fc_gt_deriv compactLegend