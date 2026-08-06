%#ok<*UNRCH>
%#ok<*INUSD>

%% Q FEEDFORWARD MAP
figure('Name', 'Q Feedforward - Mappa', 'NumberTitle', 'off');

% Button
c = c + 1;
b(c) = uicontrol('Style', 'pushbutton', ...
    'String', 'Refresh', ...
    'Units', 'normalized', ...
    'Position', [0.01 0.01 0.1 0.05], ...
    'Callback', @refreshQMapButtonPushed);

function refreshQMapButtonPushed(~, ~)

    % --- fetch from base ---
    ax       = evalin('base', 'axes');
    traj_db  = evalin('base', 'trajDatabase');
    col      = evalin('base', 'col');
    tt       = evalin('base', 'tt');
    opp      = evalin('base', 'opp_idx');
    use_ref      = evalin('base', 'use_ref');
    use_sim_ref  = evalin('base', 'use_sim_ref');
    compare      = evalin('base', 'compare');
    compare2     = evalin('base', 'compare2');

    if compare;  tt2 = evalin('base', 'tt2'); end
    if compare2; tt3 = evalin('base', 'tt3'); end
    if use_ref || use_sim_ref; gt = evalin('base', 'gt'); end

    % --- controllo campi Q ---
    if ~isfield(tt, 'Q_aa') || ~isfield(tt, 'q_lambda')
        title('Campi Q non disponibili nel log', 'Interpreter', 'none');
        return
    end

    % --- time window dall'asse condiviso ---
    t_lim = xlim(ax(1));
    [t1_tt, tend_tt] = timeWindowIdx(tt.stamp, t_lim);

    % --- reset asse corrente ---
    cla reset; hold on; grid on; axis equal;
    xlabel('x [m]', 'Interpreter', 'none');
    ylabel('y [m]', 'Interpreter', 'none');
    title(sprintf('Qaa map - Opponent %d', opp), 'Interpreter', 'none');

    % --- track boundaries ---
    id_left  = numel(traj_db) - 2;
    id_right = numel(traj_db) - 1;
    plot(traj_db(id_left).X,  traj_db(id_left).Y,  'k', 'LineWidth', 1, 'HandleVisibility', 'off');
    plot(traj_db(id_right).X, traj_db(id_right).Y, 'k', 'LineWidth', 1, 'HandleVisibility', 'off');

    % --- dati nell'intervallo temporale selezionato ---
    q_aa   = tt.Q_aa(t1_tt:tend_tt, opp);
    lambda = tt.q_lambda(t1_tt:tend_tt, opp);
    x_map  = tt.x_map(t1_tt:tend_tt, opp);
    y_map  = tt.y_map(t1_tt:tend_tt, opp);

    valid = ~isnan(q_aa) & ~isnan(x_map) & ~isnan(y_map);
    x_v   = x_map(valid);
    y_v   = y_map(valid);
    q_v   = q_aa(valid);
    lam_v = lambda(valid);

    % --- scatter colorato per Qaa ---
    if ~isempty(q_v)
        q_norm = (q_v - min(q_v)) / (max(q_v) - min(q_v) + eps);
        scatter(x_v, y_v, 20, q_norm, 'filled', 'DisplayName', 'Qaa');
        cb = colorbar;
        cb.Label.String = 'Qaa normalizzato [0=min, 1=max]';
        cb.Label.Interpreter = 'none';
        colormap(gca, 'turbo');
    end

    % --- evidenzia punti in curva (lambda > 1) ---
    in_c = ~isnan(lam_v) & lam_v > 1.0;
    if any(in_c)
        scatter(x_v(in_c), y_v(in_c), 50, 'r', 'o', ...
            'LineWidth', 1.5, 'DisplayName', 'lambda > 1 ');
    end
    % --- ground truth ---
    if use_ref || use_sim_ref
        [t1_gt, tend_gt] = timeWindowIdx(gt.stamp, t_lim);
        plot(gt.x_map(t1_gt:tend_gt), gt.y_map(t1_gt:tend_gt), ...
            'Color', col.ref, 'LineWidth', 1.5, 'DisplayName', 'gt');
    end

    % --- altri tt per confronto (traccia semplice, senza Q) ---
    if compare
        [t1_tt2, tend_tt2] = timeWindowIdx(tt2.stamp, t_lim);
        plot(tt2.x_map(t1_tt2:tend_tt2, opp), tt2.y_map(t1_tt2:tend_tt2, opp), ...
            'Color', col.tt2, 'LineWidth', 1, 'DisplayName', tt2.name);
    end
    if compare2
        [t1_tt3, tend_tt3] = timeWindowIdx(tt3.stamp, t_lim);
        plot(tt3.x_map(t1_tt3:tend_tt3, opp), tt3.y_map(t1_tt3:tend_tt3, opp), ...
            'Color', col.tt3, 'LineWidth', 1, 'DisplayName', tt3.name);
    end

    legend('show', 'Interpreter', 'none');
end