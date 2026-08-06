%#ok<*UNRCH>
%#ok<*INUSD>

%% GATING HISTOGRAM
figure('Name', 'Gating - Mahalanobis Distribution', 'NumberTitle', 'off');

c = c + 1;
b(c) = uicontrol('Style', 'pushbutton', ...
    'String', 'Refresh', ...
    'Units', 'normalized', ...
    'Position', [0.01 0.01 0.1 0.05], ...
    'Callback', @refreshGatingHistButtonPushed);

function refreshGatingHistButtonPushed(~, ~)

    % --- fetch from base ---
    ax  = evalin('base', 'axes');
    tt  = evalin('base', 'tt');
    opp = evalin('base', 'opp_idx');
    col = evalin('base', 'col');
    log = evalin('base', 'log');

    MAH_DIST_THR = 9.21;  % chi2(2, 0.99)

    % Varianze sensori [sx2, sy2] — source_type 0-based
    sensor_var = containers.Map(...
        {0, 1, 2, 3, 4, 5, 6}, ...
        {[0.63^2, 0.63^2], ...   % LIDAR_CLUSTERING
         [0.52^2, 0.56^2], ...   % LIDAR_POINTPILLARS
         [1.60^2, 0.97^2], ...   % RADAR_CLUSTERING
         [4.00^2, 4.00^2], ...   % CAMERA_YOLO
         [2.50^2, 2.50^2], ...   % CAMERA_YOLO_ENHANCED
         [0.60^2, 0.60^2], ...   % V2V
         [0.60^2, 0.60^2]});     % GHOSTCAR

    % --- time window ---
    t_lim = xlim(ax(1));
    [t1, tend] = timeWindowIdx(tt.stamp, t_lim);

    % --- dati track nell'intervallo ---
    t_track = tt.stamp(t1:tend);
    x_tr    = tt.x_map(t1:tend, opp);
    y_tr    = tt.y_map(t1:tend, opp);
    psi_tr  = deg2rad(tt.yaw_map(t1:tend, opp));

    % --- misure associate ---
    mx  = squeeze(tt.measures.x_map(t1:tend, opp, :));   % [N x 5]
    my  = squeeze(tt.measures.y_map(t1:tend, opp, :));
    src = squeeze(tt.measures.source(t1:tend, opp, :));
    % converti stamp misure in secondi relativi
    t_meas = squeeze(tt.measures.stamp(t1:tend, opp, :));
    t_meas = (t_meas - log.time_offset_nsec) * 1e-9;     % [N x 5] in secondi

    % --- ricalcola d^2 interpolando la posizione del track al tempo della misura ---
    mah_d2     = [];
    mah_d2_src = [];

    % indici validi del track (non nan) per interpolazione
    valid_tr = ~isnan(x_tr) & ~isnan(psi_tr);

    N = size(mx, 1);
    for k = 1:N
        if ~valid_tr(k), continue; end

        for m = 1:size(mx, 2)
            if isnan(mx(k,m)) || isnan(my(k,m)) || isnan(t_meas(k,m)), continue; end

            % interpola posizione e heading del track al timestamp della misura
            t_m = t_meas(k, m);
            if t_m < t_track(1) || t_m > t_track(end), continue; end

            x0  = interp1(t_track(valid_tr), x_tr(valid_tr),   t_m, 'linear', 'extrap');
            y0  = interp1(t_track(valid_tr), y_tr(valid_tr),   t_m, 'linear', 'extrap');
            psi = interp1(t_track(valid_tr), psi_tr(valid_tr), t_m, 'linear', 'extrap');

            % R nel frame world
            Rot     = [cos(psi), -sin(psi); sin(psi), cos(psi)];
            s_type  = src(k, m);
            if isKey(sensor_var, double(s_type))
                sv = sensor_var(double(s_type));
            else
                sv = [1.0, 1.0];
            end
            R_rel   = diag(sv);
            R_world = Rot * R_rel * Rot';

            e  = [mx(k,m) - x0; my(k,m) - y0];
            d2 = e' * (R_world \ e);

            if d2 > 0 && isfinite(d2)
                mah_d2(end+1)     = d2;      %#ok<AGROW>
                mah_d2_src(end+1) = s_type;  %#ok<AGROW>
            end
        end
    end

    % --- plot ---
    cla reset; hold on; grid on;

    if isempty(mah_d2)
        text(0.5, 0.5, 'Nessuna misura nel range selezionato', ...
            'Units', 'normalized', 'HorizontalAlignment', 'center', ...
            'Interpreter', 'none');
        return
    end

    % istogramma totale
    histogram(mah_d2, 40, ...
        'Normalization', 'pdf', ...
        'FaceColor', col.tt, ...
        'EdgeColor', 'none', ...
        'FaceAlpha', 0.6, ...
        'DisplayName', sprintf('d^2 totale (N=%d)', numel(mah_d2)));

    % istogrammi per sorgente
    src_labels = {0,'lidar',col.lidar; 1,'pp',col.pp; 2,'radar',col.radar; ...
                  3,'camera',col.camera; 5,'v2v',col.tt2};
    for i = 1:size(src_labels,1)
        s_type = src_labels{i,1};
        mask   = mah_d2_src == s_type;
        if sum(mask) < 5, continue; end
        histogram(mah_d2(mask), 40, ...
            'Normalization', 'pdf', ...
            'EdgeColor', src_labels{i,3}, ...
            'FaceColor', 'none', ...
            'LineWidth', 1.5, ...
            'DisplayName', sprintf('%s (N=%d)', src_labels{i,2}, sum(mask)));
    end

    % pdf teorica chi2(2)
    x_vec = linspace(0, min(max(mah_d2)*1.1, MAH_DIST_THR*3), 300);
    plot(x_vec, 0.5*exp(-x_vec/2), 'r-', 'LineWidth', 2, 'DisplayName', 'chi2(2) teorico');

    % soglia
    xline(MAH_DIST_THR, '--k', 'LineWidth', 1.5, 'HandleVisibility', 'off');
    text(MAH_DIST_THR + 0.1, 0.02, sprintf('soglia=%.2f', MAH_DIST_THR), ...
        'Interpreter', 'none', 'FontSize', 9);

    xlabel('d^2 Mahalanobis', 'Interpreter', 'none');
    ylabel('PDF', 'Interpreter', 'none');
    title(sprintf('Distribuzione Mahalanobis misure associate - Opponent %d', opp), ...
        'Interpreter', 'none');
    legend('show', 'Interpreter', 'none', 'Location', 'northeast');

    % statistiche in console
    fprintf('\n--- Gating Stats (Opponent %d, t=[%.1f, %.1f]s) ---\n', opp, t_lim(1), t_lim(2));
    fprintf('N misure totali:      %d\n',   numel(mah_d2));
    fprintf('d^2 medio:            %.3f  (atteso ~2 per chi2(2))\n', mean(mah_d2));
    fprintf('d^2 mediano:          %.3f\n', median(mah_d2));
    fprintf('d^2 max:              %.3f\n', max(mah_d2));
    fprintf('Entro soglia (%.2f): %.1f%%\n', MAH_DIST_THR, 100*mean(mah_d2 < MAH_DIST_THR));
    for i = 1:size(src_labels,1)
        mask = mah_d2_src == src_labels{i,1};
        if sum(mask) < 1, continue; end
        fprintf('  %-8s N=%4d  mean=%.2f  entro soglia=%.1f%%\n', ...
            src_labels{i,2}, sum(mask), mean(mah_d2(mask)), ...
            100*mean(mah_d2(mask) < MAH_DIST_THR));
    end
    fprintf('---------------------------------------------------\n');
end