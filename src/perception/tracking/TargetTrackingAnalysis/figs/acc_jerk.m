%% ACC_JERK - accelerazione e jerk di piu' log a confronto
%
% Figura unica, due pannelli della stessa dimensione:
%   (1) a_x   di ogni log (+ GT)
%   (2) jerk  di ogni log (+ GT)
%
% I log vengono presi da tt, tt2, tt3 (quelli che esistono in workspace),
% usando il colore T.col e il nome T.name gia' impostati dal main script.
%
% Richiede in workspace: tt, opp_idx, f, axes (tt2/tt3 e gt opzionali).

%% ================= PARAMETRI =================
show_gt = true;    % sovrappone la ground truth
fc_gt   = 7;       % [Hz] taglio zero-phase per derivare il jerk dalla GT

%% ================= LOG DISPONIBILI =================
logs = {tt};
if exist('tt2','var'); logs{end+1} = tt2; end
if exist('tt3','var'); logs{end+1} = tt3; end

%% ================= FIGURA =================
figure('Name','Accelerazione e jerk','NumberTitle','off'); f = f+1;
tl = tiledlayout(2,1,'TileSpacing','compact');
title(tl, sprintf('Accelerazione e jerk - opp %d', opp_idx), 'FontWeight','bold');

% ---- (1) accelerazione ----
ax1 = nexttile; hold on; grid on;
for i = 1:numel(logs)
    T  = logs{i};
    oi = min(opp_idx, size(T.ax,2));
    plot(T.stamp, T.ax(:,oi), '-', 'Color', T.col, 'LineWidth', 1.2, ...
        'DisplayName', T.name);
end

% ---- GT: accelerazione filtrata e jerk derivato ----
has_gt = show_gt && exist('gt','var') && isstruct(gt) && ...
         isfield(gt,'stamp') && isfield(gt,'ax');
if has_gt
    tg = gt.stamp(:);
    ag = gt.ax(:, min(opp_idx, size(gt.ax,2)));
    ag(ag == 0) = nan;
    vg = ~isnan(tg) & ~isnan(ag);
    [t_gt, ig] = unique(tg(vg));
    ag_v = ag(vg); ag_v = ag_v(ig);

    dt_gt  = median(diff(t_gt));
    t_gtu  = (t_gt(1):dt_gt:t_gt(end)).';
    ax_gtu = interp1(t_gt, ag_v, t_gtu, 'linear');
    [b_g, a_g] = butter(2, min(fc_gt/(1/dt_gt/2), 0.99));
    ax_gt_f   = filtfilt(b_g, a_g, ax_gtu);
    jerk_gt_f = gradient(ax_gt_f, dt_gt);

    plot(t_gtu, ax_gt_f, '-', 'Color', col.ref, 'LineWidth', 1.4, ...
        'DisplayName', 'gt');
end
ylabel('a_x [m/s^2]');
legend('Location','eastoutside','FontSize',8,'Box','off');
axes = [axes, ax1]; %#ok<AGROW>

% ---- (2) jerk ----
ax2 = nexttile; hold on; grid on;
for i = 1:numel(logs)
    T = logs{i};
    if isfield(T, 'jerk')
        j = T.jerk;
    elseif isfield(T, 'ax_dot')
        j = T.ax_dot;
    else
        warning('acc_jerk: jerk non trovato in %s - saltato.', T.name);
        continue;
    end
    oi = min(opp_idx, size(j,2));
    plot(T.stamp, j(:,oi), '-', 'Color', T.col, 'LineWidth', 1.2, ...
        'DisplayName', T.name);
end
if has_gt
    plot(t_gtu, jerk_gt_f, '-', 'Color', col.ref, 'LineWidth', 1.4, ...
        'DisplayName', 'gt');
end
ylabel('jerk [m/s^3]'); xlabel('t [s]');
legend('Location','eastoutside','FontSize',8,'Box','off');
axes = [axes, ax2]; %#ok<AGROW>

clearvars logs i T oi j tg ag vg t_gt ig ag_v dt_gt ax_gtu b_g a_g ...
    tl ax1 ax2 has_gt