%% correlation_analysis.m
% Analizza la correlazione tra errori di stima (x_map_err, y_map_err)
% e posizione relativa (x_rel, y_rel) per ciascun sensore.
%
% Richiede in workspace:
%   sensors  - cell array di struct con campo .s (dati) e .col/.name
%   err_thr  - soglia di gating sull'errore

clear ax f
if ~exist('sensors','var') || ~exist('err_thr','var')
    error('correlation_analysis:missingVars', ...
        'Servono le variabili ''sensors'' e ''err_thr'' in workspace. Esegui prima lo script principale.');
end

% ---------------- REL POS CORRELATION ----------------
figure('Name','rel_pos_correlation')
tiledlayout(numel(sensors), 2, 'Padding','compact')

results = table('Size',[numel(sensors) 3], ...
    'VariableTypes', {'string','double','double'}, ...
    'VariableNames', {'sensor','r_x','r_y'});

for i = 1:numel(sensors)
    s = sensors{i}.s;
    ex = gated_error(s, 'x_map_err', err_thr);
    ey = gated_error(s, 'y_map_err', err_thr);
    xr = s.x_rel(:,1);
    yr = s.y_rel(:,1);

    rx = safe_corr(xr, ex);
    ry = safe_corr(yr, ey);
    results.sensor(i) = sensors{i}.name;
    results.r_x(i) = rx;
    results.r_y(i) = ry;

    nexttile; hold on; grid on;
    scatter(xr, ex, 10, sensors{i}.col, 'filled', 'HandleVisibility','off')
    xlabel('x rel [m]'); ylabel('x error [m]');
    title(sprintf('%s | r = %.2f', sensors{i}.name, rx))

    nexttile; hold on; grid on;
    scatter(yr, ey, 10, sensors{i}.col, 'filled', 'HandleVisibility','off')
    xlabel('y rel [m]'); ylabel('y error [m]');
    title(sprintf('%s | r = %.2f', sensors{i}.name, ry))
end

disp('--- Correlazione errore vs posizione relativa ---')
disp(results)

% ---------------- LOCAL FUNCTIONS ----------------
function err = gated_error(sensor, field, err_thr)
gate = hypot(sensor.x_map_err(:,1), sensor.y_map_err(:,1)) < err_thr;
err = sensor.(field)(:,1);
err(~gate) = NaN;
end

function r = safe_corr(a, b)
valid = ~isnan(a) & ~isnan(b);
if nnz(valid) > 1
    R = corrcoef(a(valid), b(valid));
    r = R(1,2);
else
    r = NaN;
end
end