%% FREQUENCY_ANALYSIS
%
% Frequency analysis of measurement error for each sensor.
% Produces TWO figures per sensor:
%   Fig A) Welch PSD  [unit^2/Hz]
%   Fig B) FFT magnitude (octave smoothed)
%
% Split frequencies:
%   T = 10 s -> f = 0.100 Hz
%   T = 20 s -> f = 0.050 Hz
%   T = 30 s -> f = 0.033 Hz
%
% - RADAR   (rad_clust): x_rel_err, y_rel_err, rho_dot_err  -> 3 subplots
% - LIDAR   (lid_clust): x_rel_err, y_rel_err               -> 2 subplots
% - PILLARS (lid_pp)   : x_rel_err, y_rel_err               -> 2 subplots

pos_thr = 5.0;    % [m]    position gating threshold
v_thr   = 2.0;   % [m/s]  velocity gating (rho_dot_err only)

T_wins   = [10, 20, 30];
f_splits = 1 ./ T_wins;

split_colors = {[0.85 0.33 0.10], [0.49 0.18 0.56], [0.13 0.55 0.13]};

% ----------------------------------------------------------------
% Sensor configuration
% ----------------------------------------------------------------
cfg = {
    struct('id', 'rad_clust', 'name', 'RADAR', ...
           'channels',   {{'x_rel_err', 'y_rel_err', 'rho_dot_err'}}, ...
           'psd_labels', {{'PSD  [m^2/Hz]', 'PSD  [m^2/Hz]', 'PSD  [(m/s)^2/Hz]'}}, ...
           'fft_labels', {{'|E_x(f)|  [m]', '|E_y(f)|  [m]', '|E_{dot rho}(f)|  [m/s]'}}), ...
    struct('id', 'lid_clust', 'name', 'LIDAR  (clustering)', ...
           'channels',   {{'x_rel_err', 'y_rel_err'}}, ...
           'psd_labels', {{'PSD  [m^2/Hz]', 'PSD  [m^2/Hz]'}}, ...
           'fft_labels', {{'|E_x(f)|  [m]', '|E_y(f)|  [m]'}}), ...
    struct('id', 'lid_pp', 'name', 'LIDAR  (PointPillars)', ...
           'channels',   {{'x_rel_err', 'y_rel_err'}}, ...
           'psd_labels', {{'PSD  [m^2/Hz]', 'PSD  [m^2/Hz]'}}, ...
           'fft_labels', {{'|E_x(f)|  [m]', '|E_y(f)|  [m]'}}) ...
};

% ----------------------------------------------------------------
% Tabella riepilogativa: accumula dati da tutti i sensori
% ----------------------------------------------------------------
% Colonne: sensor | channel | fs | N | LF@T=10 | HF@T=10 | LF@T=20 | HF@T=20 | LF@T=30 | HF@T=30
summary = {};

for c = 1:numel(cfg)

    sen_id     = cfg{c}.id;
    sen_name   = cfg{c}.name;
    channels   = cfg{c}.channels;
    psd_labels = cfg{c}.psd_labels;
    fft_labels = cfg{c}.fft_labels;
    n_ch       = numel(channels);

    idx = find(cellfun(@(s) strcmp(s.id, sen_id), sensors), 1);
    if isempty(idx)
        warning('frequency_analysis: sensor %s not found. Skip.', sen_id);
        continue;
    end

    s     = sensors{idx}.s;
    col_k = sensors{idx}.col;

    % Position gating mask
    if isfield(s, 'x_rel_err') && isfield(s, 'y_rel_err')
        dist_pos = hypot(s.x_rel_err(:, 1), s.y_rel_err(:, 1));
    else
        dist_pos = zeros(numel(s.sens_stamp), 1);
    end
    gate_mask = dist_pos < pos_thr & ~isnan(dist_pos);

    % Figures
    scr   = get(0, 'ScreenSize');
    fig_w = min(420 * n_ch, scr(3) - 100);
    fig_h = 480;

    fig_psd = figure('Name', sprintf('PSD - %s', sen_name), ...
        'Color', 'w', ...
        'Position', [(scr(3)-fig_w)/2  (scr(4)-fig_h)/2+60  fig_w  fig_h]);
    tl_psd = tiledlayout(fig_psd, 1, n_ch, 'Padding', 'compact', 'TileSpacing', 'loose');

    fig_fft = figure('Name', sprintf('FFT - %s', sen_name), ...
        'Color', 'w', ...
        'Position', [(scr(3)-fig_w)/2  (scr(4)-fig_h)/2-60  fig_w  fig_h]);
    tl_fft = tiledlayout(fig_fft, 1, n_ch, 'Padding', 'compact', 'TileSpacing', 'loose');

    for ch = 1:n_ch

        chan = channels{ch};

        if ~isfield(s, chan)
            warning('frequency_analysis: field %s not found for %s. Skip.', chan, sen_name);
            continue;
        end

        raw    = s.(chan);
        t_sens = s.sens_stamp(:);

        if size(raw, 2) > 1
            raw = raw(:, 1);
        end

        % rho_dot_err: double gating
        if strcmp(chan, 'rho_dot_err') && isfield(s, 'rho_dot') && isfield(s, 'rho_dot_gt')
            gt_val = s.rho_dot_gt(:, 1);
            rd_val = s.rho_dot(:, 1);
            gt_ok  = gt_val ~= 0 & ~isnan(gt_val) & ~isnan(rd_val);
            raw    = rd_val - gt_val;
            in_vel = abs(raw) < v_thr;
            valid  = gt_ok & ~isnan(t_sens) & gate_mask & in_vel;
        else
            valid  = ~isnan(raw) & ~isnan(t_sens) & gate_mask;
        end

        e_ch = raw(valid);
        t_ch = t_sens(valid);

        if numel(t_ch) < 64
            warning('frequency_analysis: %s/%s too few samples. Skip.', sen_name, chan);
            continue;
        end

        % Uniform time grid
        [t_ch, ui] = unique(t_ch);
        e_ch       = e_ch(ui);

        dt_grid = median(diff(t_ch), 'omitnan');
        fs      = 1 / dt_grid;
        t_grid  = (t_ch(1) : dt_grid : t_ch(end))';
        e_grid  = interp1(t_ch, e_ch, t_grid, 'linear', nan);
        e_grid(isnan(e_grid)) = 0;
        e_grid  = e_grid - mean(e_grid);
        N       = numel(e_grid);

        % Welch PSD
        % Finestra lunga per risolvere le basse frequenze di split (min 1/f_split_min)
        % df = fs / win_samples -> win_samples = fs / df_target
        df_target   = min(f_splits) / 4;          % risolve split piu' bassa con 4 punti
        win_samples = min(round(fs / df_target), floor(N / 2));
        win_samples = max(win_samples, 256);
        [pxx, f_w]  = pwelch(e_grid, hann(win_samples), floor(win_samples/2), [], fs);

        mask_dc = f_w > 0;
        f_w = f_w(mask_dc);
        pxx = pxx(mask_dc);
        df  = f_w(2) - f_w(1);

        % LF/HF percentages for each split
        E_lf = zeros(1, numel(f_splits));
        E_hf = zeros(1, numel(f_splits));
        for ti = 1:numel(f_splits)
            E_lf(ti) = sum(pxx(f_w <= f_splits(ti))) * df / (sum(pxx)*df) * 100;
            E_hf(ti) = 100 - E_lf(ti);
        end

        % Accumulate summary row
        row = {sen_name, chan, fs, N};
        for ti = 1:numel(f_splits)
            row{end+1} = E_lf(ti); %#ok<AGROW>
            row{end+1} = E_hf(ti); %#ok<AGROW>
        end
        summary{end+1} = row; %#ok<AGROW>

        % FFT magnitude (octave smoothed)
        E_fft = abs(fft(e_grid)) / N;
        f_fft = (0 : N-1)' * fs / N;
        idx_h = 1 : floor(N/2) + 1;
        f_fft = f_fft(idx_h);
        E_fft = E_fft(idx_h);
        E_fft(2:end-1) = 2 * E_fft(2:end-1);
        mask_dc2 = f_fft > 0;
        f_fft    = f_fft(mask_dc2);
        E_fft    = E_fft(mask_dc2);
        E_fft_smooth = octave_smooth(f_fft, E_fft, 1/3);

        % ============================================================
        % Fig A — Welch PSD
        % ============================================================
        ax_psd = nexttile(tl_psd);
        hold(ax_psd, 'on'); grid(ax_psd, 'on'); box(ax_psd, 'on');

        plot(ax_psd, f_w, pxx, '-', 'Color', col_k, ...
            'LineWidth', 1.8, 'HandleVisibility', 'off');
        fill(ax_psd, [f_w; flipud(f_w)], [pxx; zeros(numel(pxx),1)], ...
            col_k, 'FaceAlpha', 0.15, 'EdgeColor', 'none', 'HandleVisibility', 'off');

        % Split lines with legend entries
        for ti = 1:numel(f_splits)
            sc = split_colors{ti};
            xline(ax_psd, f_splits(ti), '--', ...
                'Color', sc, 'LineWidth', 1.5, ...
                'HandleVisibility', 'off');
            % Dummy plot for legend
            plot(ax_psd, nan, nan, '--', 'Color', sc, 'LineWidth', 1.5, ...
                'DisplayName', sprintf('T = %d s', T_wins(ti)));
        end

        set(ax_psd, 'XScale', 'log', 'YScale', 'log');
        xlim(ax_psd, [min(f_splits)*0.4, fs/2]);
        ylim(ax_psd, [min(pxx(pxx>0))*0.5, max(pxx)*2]);
        xlabel(ax_psd, 'f  [Hz]', 'FontSize', 10);
        ylabel(ax_psd, psd_labels{ch}, 'Interpreter', 'none', 'FontSize', 10);
        title(ax_psd, strrep(chan, '_', '\_'), 'Interpreter', 'tex', 'FontSize', 11);
        legend(ax_psd, 'show', 'Location', 'southwest', 'FontSize', 8, 'Box', 'on');

        % ============================================================
        % Fig B — FFT magnitude
        % ============================================================
        ax_fft = nexttile(tl_fft);
        hold(ax_fft, 'on'); grid(ax_fft, 'on'); box(ax_fft, 'on');

        plot(ax_fft, f_fft, E_fft, '-', 'Color', [0.82 0.82 0.82], ...
            'LineWidth', 0.6, 'DisplayName', 'Raw FFT');
        plot(ax_fft, f_fft, E_fft_smooth, '-', 'Color', col_k, ...
            'LineWidth', 2.0, 'DisplayName', 'Smoothed FFT');

        % Split lines with legend entries
        for ti = 1:numel(f_splits)
            sc = split_colors{ti};
            xline(ax_fft, f_splits(ti), '--', ...
                'Color', sc, 'LineWidth', 1.5, 'HandleVisibility', 'off');
            plot(ax_fft, nan, nan, '--', 'Color', sc, 'LineWidth', 1.5, ...
                'DisplayName', sprintf('T = %d s', T_wins(ti)));
        end

        set(ax_fft, 'XScale', 'log', 'YScale', 'log');
        xlim(ax_fft, [min(f_splits)*0.4, fs/2]);
        ylim(ax_fft, [min(E_fft_smooth(E_fft_smooth>0))*0.5, max(E_fft_smooth)*2]);
        xlabel(ax_fft, 'f  [Hz]', 'FontSize', 10);
        ylabel(ax_fft, fft_labels{ch}, 'Interpreter', 'none', 'FontSize', 10);
        title(ax_fft, strrep(chan, '_', '\_'), 'Interpreter', 'tex', 'FontSize', 11);
        legend(ax_fft, 'show', 'Location', 'southwest', 'FontSize', 8, 'Box', 'on');

    end

    % Titoli puliti senza parametri
    sgtitle(tl_psd, sprintf('%s  —  Welch PSD', sen_name), ...
        'FontSize', 12, 'FontWeight', 'bold', 'Interpreter', 'none');
    sgtitle(tl_fft, sprintf('%s  —  FFT magnitude', sen_name), ...
        'FontSize', 12, 'FontWeight', 'bold', 'Interpreter', 'none');

end

% ----------------------------------------------------------------
% Tabella riepilogativa a command window
% ----------------------------------------------------------------
fprintf('\n');
fprintf('===== FREQUENCY ANALYSIS SUMMARY =====\n');
sep = repmat('=', 1, 94);
fprintf('%s\n', sep);

% Header
fprintf('%-22s  %-20s', 'Sensor', 'Channel');
for ti = 1:numel(T_wins)
    fprintf('  LF@%ds[%%]  HF@%ds[%%]', T_wins(ti), T_wins(ti));
end
fprintf('\n%s\n', repmat('-', 1, 94));

% Righe
prev_sensor = '';
for r = 1:numel(summary)
    row = summary{r};
    sensor_name = row{1};
    chan_name   = row{2};

    % Separatore tra sensori
    if ~strcmp(sensor_name, prev_sensor) && ~isempty(prev_sensor)
        fprintf('%s\n', repmat('-', 1, 94));
    end
    prev_sensor = sensor_name;

    fprintf('%-22s  %-20s', sensor_name, chan_name);
    col_idx = 5;
    for ti = 1:numel(T_wins)
        fprintf('  %9.1f  %9.1f', row{col_idx}, row{col_idx+1});
        col_idx = col_idx + 2;
    end
    fprintf('\n');
end
fprintf('%s\n\n', sep);


%% ================================================================
function E_smooth = octave_smooth(f, E, frac)
    n         = numel(f);
    E_smooth  = zeros(n, 1);
    f_lo_mult = 2^(-frac/2);
    f_hi_mult = 2^(+frac/2);
    for i = 1:n
        mask = f >= f(i)*f_lo_mult & f <= f(i)*f_hi_mult;
        if any(mask)
            E_smooth(i) = mean(E(mask));
        else
            E_smooth(i) = E(i);
        end
    end
end