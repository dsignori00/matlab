%% R_TIME_ANALYSIS
% Inizializza ax se non esiste (per linkaxes nel main)
if ~exist('ax','var'); ax = gobjects(0); end
% Per ogni sensore (camera inclusa) plotta:
% - Errore istantaneo (alta frequenza) in colore chiaro
% - Media mobile (bassa frequenza) in nero
% - Linee ±sigma stimata (R baseline) tratteggiate
%
% Obiettivo: capire se la media mobile dell'errore varia nel tempo
% -> motivazione per R adattiva

% include solo camera
sensors_r = sensors(cellfun(@(s) strcmp(s.name, 'camera'), sensors));

% Finestra media mobile in secondi -> converti in campioni
window_secs = [30.0, 60.0, 120.0];  % tre finestre da confrontare

fprintf('\n===== R TIME ANALYSIS =====\n');
fprintf('%-12s  %8s  %8s  %8s  %8s\n', 'Sensor', 'sigma_x', 'sigma_y', 'R_xx', 'R_yy');
fprintf('%s\n', repmat('-', 1, 55));

for k = 1:numel(sensors_r)
    s     = sensors_r{k}.s;
    col_k = sensors_r{k}.col;
    name  = sensors_r{k}.name;

    % Calcola errore nel frame relativo (come estimate_R_baseline)
    x_map_err  = s.x_map_err;
    y_map_err  = s.y_map_err;
    n_cols     = size(x_map_err, 2);
    sens_stamp = repmat(s.sens_stamp, 1, n_cols);

    x_map_err  = x_map_err(:);
    y_map_err  = y_map_err(:);
    sens_stamp = sens_stamp(:);

    valid = ~isnan(x_map_err) & ~isnan(y_map_err) & ~isnan(sens_stamp);
    x_map_err  = x_map_err(valid);
    y_map_err  = y_map_err(valid);
    sens_stamp = sens_stamp(valid);

    psi_gt    = interp1(gt.stamp(:), gt.yaw_map(:), sens_stamp, 'linear', 'extrap');
    x_err_rel =  cos(psi_gt) .* x_map_err + sin(psi_gt) .* y_map_err;
    y_err_rel = -sin(psi_gt) .* x_map_err + cos(psi_gt) .* y_map_err;

    % Filtra outlier grossolani (err_thr)
    ass     = hypot(x_err_rel, y_err_rel) < err_thr;
    x_err_rel(~ass) = nan;
    y_err_rel(~ass) = nan;

    % Statistiche globali
    sigma_x = std(x_err_rel, 'omitnan');
    sigma_y = std(y_err_rel, 'omitnan');


    R_xx    = sigma_x^2;
    R_yy    = sigma_y^2;
    fprintf('%-12s  %8.4f  %8.4f  %8.4f  %8.4f\n', name, sigma_x, sigma_y, R_xx, R_yy);

    % Rimuovi punti senza misure (trim bordi)
    valid2      = ~isnan(x_err_rel) & ~isnan(y_err_rel);
    t_valid     = sens_stamp(valid2);
    x_err_valid = x_err_rel(valid2);
    y_err_valid = y_err_rel(valid2);

    % Rimuovi timestamp duplicati prima dell'interpolazione
    [t_valid, ui] = unique(t_valid);
    x_err_valid   = x_err_valid(ui);
    y_err_valid   = y_err_valid(ui);

    % Griglia temporale uniforme per media mobile stabile
    dt_grid = median(diff(t_valid), 'omitnan');
    t_grid  = (t_valid(1) : dt_grid : t_valid(end))';
    x_grid  = interp1(t_valid, x_err_valid, t_grid, 'linear', 'extrap');
    y_grid  = interp1(t_valid, y_err_valid, t_grid, 'linear', 'extrap');

    % Calcola media mobile per ogni finestra
    wins = max(3, round(window_secs / dt_grid));
    win  = wins(1);  % finestra principale per figura 1

    x_lfs = cell(numel(window_secs),1);
    y_lfs = cell(numel(window_secs),1);
    for wk = 1:numel(window_secs)
        % Media mobile di |e| -> stima del livello medio di R nel tempo
        x_lfs{wk} = movmean(abs(x_grid), wins(wk));
        y_lfs{wk} = movmean(abs(y_grid), wins(wk));
    end
    x_lf = x_lfs{1};
    y_lf = y_lfs{1};

    % Aggiorna sens_stamp e dati per il plot (solo punti validi)
    sens_stamp = t_valid;
    x_err_rel  = x_err_valid;
    y_err_rel  = y_err_valid;

    %% ---- Figura per sensore ----
    figure('Name', sprintf('R Time Analysis - %s', upper(name)), ...
           'Color', 'w', 'Position', [100 100 1000 500]);
    tiledlayout(1, 2, 'Padding', 'compact', 'TileSpacing', 'loose');

    dims   = {x_err_rel, y_err_rel};
    lfs    = {x_lf, y_lf};
    sigmas = {sigma_x, sigma_y};
    xlbls  = {'|errore| longitudinale x_{rel}  [m]', '|errore| laterale y_{rel}  [m]'};

    for d = 1:2
        nexttile; hold on; grid on; box on;

        % Alta frequenza: |errore| istantaneo
        plot(sens_stamp, abs(dims{d}), '.', ...
            'Color', [col_k 0.3], 'MarkerSize', 3, ...
            'HandleVisibility', 'off');

        % Bassa frequenza: tutte e tre le finestre
        lf_colors = {[0 0 0], [0.5 0 0.5], [0.8 0 0]};
        lfs_all = {x_lfs, y_lfs};
        for wk = 1:numel(window_secs)
            plot(t_grid, lfs_all{d}{wk}, '-', ...
                'Color', lf_colors{wk}, 'LineWidth', 1.8, ...
                'DisplayName', sprintf('win=%.0fs', window_secs(wk)));
        end


        % Sigma globale come riferimento
        yline(sigmas{d}, '--', 'Color', col_k, 'LineWidth', 1.5, ...
            'HandleVisibility', 'off');

        ylim([0, 3*sigmas{d}]);
        xlabel('t  [s]'); ylabel(xlbls{d}, 'Interpreter', 'tex');
        legend show;
    end

    sgtitle(sprintf('%s — Error vs time  (\\sigma_x=%.3f m,  \\sigma_y=%.3f m)', ...
        upper(name), sigma_x, sigma_y), ...
        'FontSize', 13, 'FontWeight', 'bold', 'Interpreter', 'tex');


    %% ---- Figura Range vs R stimata ----
    % x_rel e y_rel dal gt ai timestamp validi
    [gt_u, ui_gt] = unique(gt.stamp);
    x_rel_at_sens = interp1(gt_u, gt.x_rel(ui_gt), t_valid, 'linear', 'extrap');
    y_rel_at_sens = interp1(gt_u, gt.y_rel(ui_gt), t_valid, 'linear', 'extrap');

    % Interpola su t_grid
    [t_valid_u, ui_tv] = unique(t_valid);
    x_rel_grid = interp1(t_valid_u, x_rel_at_sens(ui_tv), t_grid, 'linear', 'extrap');
    y_rel_grid = interp1(t_valid_u, y_rel_at_sens(ui_tv), t_grid, 'linear', 'extrap');

    rel_grids = {abs(x_rel_grid), abs(y_rel_grid)};
    rel_lbls  = {'|x_{rel}|  [m]', '|y_{rel}|  [m]'};

    % R stimata come movmean(e^2) per la finestra intermedia
    R_x_t = movmean(x_grid.^2, wins(2));
    R_y_t = movmean(y_grid.^2, wins(2));

    figure('Name', sprintf('Range vs R - %s', upper(name)), ...
           'Color', 'w', 'Position', [200 200 1000 500]);
    tiledlayout(1, 2, 'Padding', 'compact', 'TileSpacing', 'loose');

    grids_d2 = {x_grid, y_grid};
    R_globs  = {sigma_x^2, sigma_y^2};
    R_lbls   = {'\sigma_x(t)  [m]', '\sigma_y(t)  [m]'};

    lf_colors = {[0 0 0], [0.5 0 0.5], [0.8 0 0]};

    for d = 1:2
        nexttile; hold on; grid on; box on;

        % sigma(t) per le 3 finestre
        for wk = 1:numel(window_secs)
            R_t = movmean(grids_d2{d}.^2, wins(wk));
            plot(t_grid, sqrt(R_t), '-', 'Color', lf_colors{wk}, 'LineWidth', 1.8, ...
                'DisplayName', sprintf('win = %.0f s', window_secs(wk)));
        end

        % sigma globale
        yline(sqrt(R_globs{d}), '--', 'Color', [0.4 0.4 0.4], 'LineWidth', 1.2, ...
            'HandleVisibility', 'off');

        % x_rel o y_rel su asse destro
        yyaxis right;
        plot(t_grid, rel_grids{d}, ':', 'Color', col_k, 'LineWidth', 1.5, ...
            'DisplayName', rel_lbls{d});
        ylabel(rel_lbls{d}, 'Interpreter', 'tex', 'Color', col_k);
        ylim([0 max(rel_grids{d}) * 1.1]);
        ax_cur = gca;
        ax_cur.YAxis(2).Color = col_k;

        yyaxis left;
        ylabel(R_lbls{d}, 'Interpreter', 'tex');
        xlabel('t  [s]');
        ylim([0 3*sqrt(R_globs{d})]);
        legend show;
    end

    sgtitle(sprintf('%s — sigma(t) vs x_{rel}/y_{rel}', upper(name)), ...
        'FontSize', 13, 'FontWeight', 'bold');
end

fprintf('%s\n\n', repmat('-', 1, 55));