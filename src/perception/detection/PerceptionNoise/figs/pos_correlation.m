%% === CHECK VARIABILI ===
if ~exist('sensors','var') || ~exist('err_thr','var')
    error('Servono ''sensors'' e ''err_thr'' in workspace: esegui prima lo script principale.');
end

win = 2;         % finestra della media mobile [s]
gap_thr = 0.5;   % soglia [s]: oltre questo gap tra campioni, la linea si interrompe nei plot
t_win = []; % <-- finestra temporale per le correlazioni [s]. Metti [] per usare tutto il dataset.

%% === FIG 1: CORRELAZIONE |ERRORE| vs POSIZIONE RELATIVA (con modulo) ===
figure('Name','rel_pos_correlation')
tiledlayout(numel(sensors), 3, 'Padding','compact')

results = table('Size',[numel(sensors) 4], ...
    'VariableTypes', {'string','double','double','double'}, ...
    'VariableNames', {'sensor','r_mod','r_x','r_y'});

for i = 1:numel(sensors)
    s = sensors{i}.s;
    t = s.sens_stamp(:,1);
    err_mod = hypot(s.x_map_err(:,1), s.y_map_err(:,1));
    gate = err_mod < err_thr;
    err_mod(~gate) = NaN;

    xr = s.x_rel(:,1);
    yr = s.y_rel(:,1);
    rel_mod = hypot(xr, yr);

    if ~isempty(t_win)
        in_win = t >= t_win(1) & t <= t_win(2);
        err_mod(~in_win) = NaN;
    end

    Rm = corrcoef(rel_mod, err_mod, 'rows','complete'); rm = Rm(1,2);
    Rx = corrcoef(xr, err_mod, 'rows','complete'); rx = Rx(1,2);
    Ry = corrcoef(yr, err_mod, 'rows','complete'); ry = Ry(1,2);

    results.sensor(i) = sensors{i}.name;
    results.r_mod(i) = rm;
    results.r_x(i) = rx;
    results.r_y(i) = ry;

    nexttile; hold on; grid on;
    scatter(rel_mod, err_mod, 10, sensors{i}.col, 'filled', 'HandleVisibility','off')
    xlabel('|rel pos| [m]'); ylabel('|error| [m]');
    title(sprintf('%s | r = %.2f', sensors{i}.name, rm))

    nexttile; hold on; grid on;
    scatter(xr, err_mod, 10, sensors{i}.col, 'filled', 'HandleVisibility','off')
    xlabel('x rel [m]'); ylabel('|error| [m]');
    title(sprintf('r_x = %.2f', rx))

    nexttile; hold on; grid on;
    scatter(yr, err_mod, 10, sensors{i}.col, 'filled', 'HandleVisibility','off')
    xlabel('y rel [m]'); ylabel('|error| [m]');
    title(sprintf('r_y = %.2f', ry))
end

if ~isempty(t_win)
    sgtitle(sprintf('Finestra temporale: [%.1f, %.1f] s', t_win(1), t_win(2)))
end
disp('--- Correlazione |errore| vs posizione relativa ---')
disp(results)

%% === FIG 2: CORRELAZIONE ERRORE vs POSIZIONE RELATIVA (senza modulo, x/y separati) ===
figure('Name','rel_pos_correlation_xy')
tiledlayout(numel(sensors), 2, 'Padding','compact')

results_xy = table('Size',[numel(sensors) 3], ...
    'VariableTypes', {'string','double','double'}, ...
    'VariableNames', {'sensor','r_x','r_y'});

for i = 1:numel(sensors)
    s = sensors{i}.s;
    t = s.sens_stamp(:,1);
    err_mod = hypot(s.x_map_err(:,1), s.y_map_err(:,1));
    gate = err_mod < err_thr;

    ex = s.x_map_err(:,1); ex(~gate) = NaN;
    ey = s.y_map_err(:,1); ey(~gate) = NaN;
    xr = s.x_rel(:,1);
    yr = s.y_rel(:,1);

    if ~isempty(t_win)
        in_win = t >= t_win(1) & t <= t_win(2);
        ex(~in_win) = NaN;
        ey(~in_win) = NaN;
    end

    Rx = corrcoef(xr, ex, 'rows','complete'); rx = Rx(1,2);
    Ry = corrcoef(yr, ey, 'rows','complete'); ry = Ry(1,2);

    results_xy.sensor(i) = sensors{i}.name;
    results_xy.r_x(i) = rx;
    results_xy.r_y(i) = ry;

    nexttile; hold on; grid on;
    scatter(xr, ex, 10, sensors{i}.col, 'filled', 'HandleVisibility','off')
    xlabel('x rel [m]'); ylabel('x error [m]');
    title(sprintf('%s | r_x = %.2f', sensors{i}.name, rx))

    nexttile; hold on; grid on;
    scatter(yr, ey, 10, sensors{i}.col, 'filled', 'HandleVisibility','off')
    xlabel('y rel [m]'); ylabel('y error [m]');
    title(sprintf('r_y = %.2f', ry))
end

if ~isempty(t_win)
    sgtitle(sprintf('Finestra temporale: [%.1f, %.1f] s', t_win(1), t_win(2)))
end
disp('--- Correlazione errore vs posizione relativa (senza modulo) ---')
disp(results_xy)

%% === FIG 3: MOVING AVERAGE ERRORI (con segno) PER SENSORE, con finestra evidenziata ===
figure('Name','error_moving_average')
tiledlayout(2,1,'Padding','compact')

ax1 = nexttile; hold on; grid on;
title('x error - moving average'); ylabel('x error [m]');

ax2 = nexttile; hold on; grid on;
title('y error - moving average'); ylabel('y error [m]');
xlabel('timestamp [s]');

for i = 1:numel(sensors)
    s = sensors{i}.s;
    t = s.sens_stamp(:,1);

    err_mod = hypot(s.x_map_err(:,1), s.y_map_err(:,1));
    gate = err_mod < err_thr;

    ex = s.x_map_err(:,1); ex(~gate) = NaN;
    ey = s.y_map_err(:,1); ey(~gate) = NaN;

    valid_t = ~isnan(t);
    t = t(valid_t); ex = ex(valid_t); ey = ey(valid_t);
    [t_sorted, idx] = sort(t);
    ex_sorted = ex(idx);
    ey_sorted = ey(idx);

    [t_unique, ~, ic] = unique(t_sorted);
    ex_unique = accumarray(ic, ex_sorted, [], @(v) mean(v,'omitnan'));
    ey_unique = accumarray(ic, ey_sorted, [], @(v) mean(v,'omitnan'));

    ex_ma = movmean(ex_unique, win, 'omitnan', 'SamplePoints', t_unique);
    ey_ma = movmean(ey_unique, win, 'omitnan', 'SamplePoints', t_unique);

    gaps = diff(t_unique) > gap_thr;
    ex_ma(gaps) = NaN;
    ey_ma(gaps) = NaN;

    plot(ax1, t_unique, ex_ma, '-', 'Color', sensors{i}.col, 'LineWidth', 1.5, 'DisplayName', sensors{i}.name)
    plot(ax2, t_unique, ey_ma, '-', 'Color', sensors{i}.col, 'LineWidth', 1.5, 'DisplayName', sensors{i}.name)
end

plot(ax1, xlim(ax1), [0 0], '--k', 'LineWidth', 0.3, 'HandleVisibility','off')
plot(ax2, xlim(ax2), [0 0], '--k', 'LineWidth', 0.3, 'HandleVisibility','off')

if ~isempty(t_win)
    yl1 = ylim(ax1);
    patch(ax1, [t_win(1) t_win(2) t_win(2) t_win(1)], [yl1(1) yl1(1) yl1(2) yl1(2)], ...
        [0.9 0.9 0.2], 'FaceAlpha', 0.15, 'EdgeColor','none', 'HandleVisibility','off')
    ylim(ax1, yl1);

    yl2 = ylim(ax2);
    patch(ax2, [t_win(1) t_win(2) t_win(2) t_win(1)], [yl2(1) yl2(1) yl2(2) yl2(2)], ...
        [0.9 0.9 0.2], 'FaceAlpha', 0.15, 'EdgeColor','none', 'HandleVisibility','off')
    ylim(ax2, yl2);
end

legend(ax1, 'show'); legend(ax2, 'show');
linkaxes([ax1 ax2], 'x');

%% === FIG 4: CORRELAZIONE TRA GLI ERRORI DEI VARI SENSORI (su moving average, finestra) ===
n = numel(sensors);
sensor_names = cellfun(@(s) s.name, sensors, 'UniformOutput', false);

ma_x = cell(n,1); ma_y = cell(n,1); ma_t = cell(n,1);
t_max = -inf;

for i = 1:n
    s = sensors{i}.s;
    t = s.sens_stamp(:,1);
    err_mod = hypot(s.x_map_err(:,1), s.y_map_err(:,1));
    gate = err_mod < err_thr;
    ex = s.x_map_err(:,1); ex(~gate) = NaN;
    ey = s.y_map_err(:,1); ey(~gate) = NaN;

    valid_t = ~isnan(t);
    t = t(valid_t); ex = ex(valid_t); ey = ey(valid_t);
    [t_sorted, idx] = sort(t);
    ex_sorted = ex(idx); ey_sorted = ey(idx);

    [t_unique, ~, ic] = unique(t_sorted);
    ex_unique = accumarray(ic, ex_sorted, [], @(v) mean(v,'omitnan'));
    ey_unique = accumarray(ic, ey_sorted, [], @(v) mean(v,'omitnan'));

    ma_x{i} = movmean(ex_unique, win, 'omitnan', 'SamplePoints', t_unique);
    ma_y{i} = movmean(ey_unique, win, 'omitnan', 'SamplePoints', t_unique);
    ma_t{i} = t_unique;

    if ~isempty(t_unique)
        t_max = max(t_max, max(t_unique));
    end
end

if ~isempty(t_win)
    t_common = linspace(t_win(1), t_win(2), 500)';
else
    t_common = linspace(0, t_max, 500)';
end

X = nan(numel(t_common), n);
Y = nan(numel(t_common), n);
for i = 1:n
    if numel(ma_t{i}) > 1
        X(:,i) = interp1(ma_t{i}, ma_x{i}, t_common, 'linear');
        Y(:,i) = interp1(ma_t{i}, ma_y{i}, t_common, 'linear');
    end
end

R_x = corrcoef(X, 'rows','complete');
R_y = corrcoef(Y, 'rows','complete');

disp('--- Pearson r tra sensori (x error, moving average) ---')
disp(array2table(R_x, 'VariableNames', sensor_names, 'RowNames', sensor_names))
disp('--- Pearson r tra sensori (y error, moving average) ---')
disp(array2table(R_y, 'VariableNames', sensor_names, 'RowNames', sensor_names))

figure('Name','sensor_error_correlation')
tiledlayout(1,2,'Padding','compact')

nexttile; imagesc(R_x, [-1 1]); axis square; colorbar; colormap(gca,'jet');
set(gca,'XTick',1:n,'XTickLabel',sensor_names,'YTick',1:n,'YTickLabel',sensor_names,'XTickLabelRotation',45)
title('Pearson r - x error'); add_labels(R_x)

nexttile; imagesc(R_y, [-1 1]); axis square; colorbar; colormap(gca,'jet');
set(gca,'XTick',1:n,'XTickLabel',sensor_names,'YTick',1:n,'YTickLabel',sensor_names,'XTickLabelRotation',45)
title('Pearson r - y error'); add_labels(R_y)

if ~isempty(t_win)
    sgtitle(sprintf('Finestra temporale: [%.1f, %.1f] s', t_win(1), t_win(2)))
end

%% === CLEANUP ===
clear s t err_mod gate ex ey xr yr rel_mod Rm Rx Ry rm rx ry i j in_win
clear valid_t t_sorted idx ex_sorted ey_sorted t_unique ic ex_unique ey_unique
clear ex_ma ey_ma gaps ax1 ax2 n sensor_names ma_x ma_y ma_t t_max t_common
clear X Y R_x R_y win gap_thr yl1 yl2

%% === LOCAL FUNCTIONS ===
function add_labels(M)
    n = size(M,1);
    for i = 1:n
        for j = 1:n
            text(j, i, sprintf('%.2f', M(i,j)), 'HorizontalAlignment','center', 'Color','k')
        end
    end
end