%% OUTLIER_ANALYSIS
% 4 figure che mostrano, per il solo radar, l'effetto di due gate
% annidati basati su errore di posizione (euclideo, rispetto al gt) ed
% errore di rho_dot (rispetto al gt):
%
%   GATE 1 (largo)  : errore_pos > gate1_pos_thr [m]  OPPURE  errore_rhodot > gate1_rhodot_thr [m/s]
%   GATE 2 (stretto): errore_pos > gate2_pos_thr [m]  OPPURE  errore_rhodot > gate2_rhodot_thr [m/s]
%
% Essendo il gate 2 piu' stretto del gate 1, ogni punto escluso dal
% gate 1 e' automaticamente escluso anche dal gate 2 (gate2 include
% strettamente gate1). Su questa base i punti radar vengono divisi in
% 3 categorie, con lo STESSO colore su tutte le figure:
%
%   - ROSSO  : esclusi dal gate 1 (il piu' largo)              -> col.radar_out
%   - ARANCIONE : passano il gate 1 ma sono esclusi dal gate 2  -> col.radar_gate2
%   - BLU    : passano entrambi i gate (sempre inclusi)         -> col.radar (azzurro originale)
%
% FIGURE:
%   1) Map            (spaziale, con bottone Refresh)
%   2) Range           (range + rho_dot vs tempo)
%   3) State Map        (x_map, y_map, yaw_map vs tempo)
%   4) Gating analysis (errore posizione vs errore rho_dot, con i due
%                        rettangoli di gate e i punti colorati per
%                        categoria - risponde a "punti esclusi dal
%                        primo gate / sempre inclusi / esclusi al
%                        secondo gate")
%
% Per ora viene plottato SOLO il radar (gli altri sensori sono ignorati).
%
% USO: lanciare da mainScript.m con "outlier_analysis;" nella sezione
% %% PLOTTING (prima di link_axes();). Richiede use_ref oppure
% use_sim_ref = true.
%
%#ok<*UNRCH>
%#ok<*INUSD>

% --- soglie dei due gate (MODIFICABILI) ---
gate1_pos_thr    = 5;   % [m]   gate largo - errore di posizione
gate1_rhodot_thr = 3;   % [m/s] gate largo - errore di rho_dot
gate2_pos_thr    = 5;   % [m]   gate stretto - errore di posizione
gate2_rhodot_thr = 1.5; % [m/s] gate stretto - errore di rho_dot

if ~(use_ref || use_sim_ref)
    error('outlier_anlysis: serve la ground truth (use_ref o use_sim_ref = true).');
end

%% --- isola il solo radar ---
rad_idx = find(cellfun(@(x) strcmp(x.name,'radar'), sensors));
if isempty(rad_idx)
    error('outlier_analysis: sensore "radar" non trovato in "sensors".');
end
s = sensors{rad_idx}.s;
if ~isfield(s,'rho_dot')
    error('outlier_analysis: la struttura radar non ha il campo rho_dot.');
end

s.sens_stamp = s.sens_stamp(:); % [T x 1] - un timestamp per riga
T = numel(s.sens_stamp);
if size(s.rho_dot,1) ~= T
    error(['outlier_analysis: s.rho_dot ha %d righe ma s.sens_stamp ne ha %d. ' ...
        'La struttura radar non e'' quella attesa [T x nDet].'], size(s.rho_dot,1), T);
end
nDet = size(s.rho_dot,2);

% controllo di coerenza dimensionale sulle altre matrici per-rilevamento
detFields = {'x_map','y_map','x_rel','y_rel','yaw_map'};
for kf = 1:numel(detFields)
    fld = detFields{kf};
    if isfield(s, fld) && ~isequal(size(s.(fld)), [T nDet])
        error('outlier_analysis: campo radar "%s" ha dimensione %s, attesa [%d %d].', ...
            fld, mat2str(size(s.(fld))), T, nDet);
    end
end

s.range = sqrt(s.x_rel.^2 + s.y_rel.^2); % [T x nDet]

col.radar_out   = colors.red{2};   % rosso  = escluso dal gate 1 (largo)
col.radar_gate2 = colors.orange{2}; % arancione = escluso dal gate 2 (stretto), passa il gate 1

%% --- ground truth: alias 'range' + interpolazione su sens_stamp ---
if(use_sim_ref); gt.rho = sqrt(gt.x_rel.^2 + gt.y_rel.^2); end
gt.range = gt.rho;

gt_rhodot_i = interp1(gt.stamp(:), gt.rho_dot(:), s.sens_stamp, 'linear', 'extrap'); % [T x 1]
gt_x_i      = interp1(gt.stamp(:), gt.x_map(:),   s.sens_stamp, 'linear', 'extrap'); % [T x 1]
gt_y_i      = interp1(gt.stamp(:), gt.y_map(:),   s.sens_stamp, 'linear', 'extrap'); % [T x 1]

% errori (broadcasting [T x nDet] - [T x 1])
pos_err    = sqrt((s.x_map - gt_x_i).^2 + (s.y_map - gt_y_i).^2); % [T x nDet]
rhodot_err = abs(s.rho_dot - gt_rhodot_i);                        % [T x nDet]

% --- classificazione nei 2 gate (gate2 e' sempre un sovrainsieme di gate1) ---
is_out1 = (pos_err > gate1_pos_thr) | (rhodot_err > gate1_rhodot_thr); % escluso dal gate largo
is_out2 = (pos_err > gate2_pos_thr) | (rhodot_err > gate2_rhodot_thr); % escluso dal gate stretto

cat_red   = is_out1;                 % escluso dal gate 1
cat_green = (~is_out1) & is_out2;    % passa il gate 1 ma escluso dal gate 2
cat_blue  = (~is_out1) & (~is_out2); % sempre incluso (passa entrambi)

% matrice dei t1imestamp con la stessa shape delle altre matrici radar,
% da usare per i plot vs tempo
stamp_mat = repmat(s.sens_stamp, 1, nDet); % [T x nDet]

%% --- campi derivati per tt/tt2/tt3 (serve solo 'range') ---
tt.range = sqrt(tt.x_rel.^2 + tt.y_rel.^2);
if(compare);  tt2.range = sqrt(tt2.x_rel.^2 + tt2.y_rel.^2); end
if(compare2); tt3.range = sqrt(tt3.x_rel.^2 + tt3.y_rel.^2); end

%% ============================== FIGURA 1: RANGE + RHO DOT ==============================
figRange = figure('name','Outlier Analysis - Range', 'NumberTitle','off');
tiledlayout(figRange,2,1,'Padding','compact');

ax_range = nexttile; hold(ax_range,'on'); grid(ax_range,'on');
ylabel(ax_range,'range [m]'); ylim(ax_range,[0 200]);
plotRadarSeries(ax_range, stamp_mat, s.range, cat_blue, cat_green, cat_red, col);
plot_tt(tt.stamp, tt.range, tt.max_opp, col.tt, name1);
if(compare);  plot_tt(tt2.stamp, tt2.range, tt2.max_opp, col.tt2, name2); end
if(compare2); plot_tt(tt3.stamp, tt3.range, tt3.max_opp, col.tt3, name3); end
plot(ax_range, gt.stamp, gt.range, 'Color', col.ref, 'DisplayName','gt');
legend(ax_range,'show');

ax_rhodot = nexttile; hold(ax_rhodot,'on'); grid(ax_rhodot,'on');
ylabel(ax_rhodot,'rho dot [m/s]'); xlabel(ax_rhodot,'timestamp [s]');
plotRadarSeries(ax_rhodot, stamp_mat, s.rho_dot, cat_blue, cat_green, cat_red, col);
plot_tt(tt.stamp, tt.rho_dot, tt.max_opp, col.tt, name1);
if(compare);  plot_tt(tt2.stamp, tt2.rho_dot, tt2.max_opp, col.tt2, name2); end
if(compare2); plot_tt(tt3.stamp, tt3.rho_dot, tt3.max_opp, col.tt3, name3); end
plot(ax_rhodot, gt.stamp, gt.rho_dot, 'Color', col.ref, 'DisplayName','gt');
legend(ax_rhodot,'show');

%% ============================== FIGURA 2: X / Y / YAW MAP ==============================
figState = figure('name','Outlier Analysis - State Map', 'NumberTitle','off');
tiledlayout(figState,3,1,'Padding','compact');

ax_x = nexttile; hold(ax_x,'on'); grid(ax_x,'on'); ylabel(ax_x,'x map [m]');
plotRadarSeries(ax_x, stamp_mat, s.x_map, cat_blue, cat_green, cat_red, col);
plot_tt(tt.stamp, tt.x_map, tt.max_opp, col.tt, name1);
if(compare);  plot_tt(tt2.stamp, tt2.x_map, tt2.max_opp, col.tt2, name2); end
if(compare2); plot_tt(tt3.stamp, tt3.x_map, tt3.max_opp, col.tt3, name3); end
plot(ax_x, gt.stamp, gt.x_map, 'Color', col.ref, 'DisplayName','gt');
legend(ax_x,'show');

ax_y = nexttile; hold(ax_y,'on'); grid(ax_y,'on'); ylabel(ax_y,'y map [m]');
plotRadarSeries(ax_y, stamp_mat, s.y_map, cat_blue, cat_green, cat_red, col);
plot_tt(tt.stamp, tt.y_map, tt.max_opp, col.tt, name1);
if(compare);  plot_tt(tt2.stamp, tt2.y_map, tt2.max_opp, col.tt2, name2); end
if(compare2); plot_tt(tt3.stamp, tt3.y_map, tt3.max_opp, col.tt3, name3); end
plot(ax_y, gt.stamp, gt.y_map, 'Color', col.ref, 'DisplayName','gt');
legend(ax_y,'show');

ax_yaw = nexttile; hold(ax_yaw,'on'); grid(ax_yaw,'on');
ylabel(ax_yaw,'yaw [deg]'); xlabel(ax_yaw,'timestamp [s]');
yawS = unwrap_pi(s.yaw_map);
plotRadarSeries(ax_yaw, stamp_mat, yawS, cat_blue, cat_green, cat_red, col);
plot_tt(tt.stamp, tt.yaw_map, tt.max_opp, col.tt, name1);
if(compare);  plot_tt(tt2.stamp, tt2.yaw_map, tt2.max_opp, col.tt2, name2); end
if(compare2); plot_tt(tt3.stamp, tt3.yaw_map, tt3.max_opp, col.tt3, name3); end
plot(ax_yaw, gt.stamp, gt.yaw_map, 'Color', col.ref, 'DisplayName','gt');
legend(ax_yaw,'show');

linkaxes([ax_range ax_rhodot ax_x ax_y ax_yaw],'x');

%% ============================== FIGURA 3: MAP (spaziale, con Refresh) ==============================
figMap = figure('name','Outlier Analysis - Map', 'NumberTitle','off');
tiledlayout(figMap,1,1,'Padding','compact');
ax_map = nexttile;

mapCtx = struct( ...
    'trajDatabase', trajDatabase, ...
    's',            s, ...          % s.sens_stamp [Tx1], s.x_map/y_map [T x nDet]
    'cat_blue',     cat_blue, ...   % [T x nDet]
    'cat_green',    cat_green, ...  % [T x nDet]
    'cat_red',      cat_red, ...    % [T x nDet]
    'tt',           tt, ...
    'name1',        name1, ...
    'compare',      compare, ...
    'compare2',     compare2, ...
    'use_ref',      use_ref, ...
    'use_sim_ref',  use_sim_ref, ...
    'gt',           gt, ...
    'col',          col, ...
    'timeRefAx',    ax_rhodot); % asse (nella figura Range) da cui leggere la finestra temporale al refresh
if(compare);  mapCtx.tt2 = tt2; mapCtx.name2 = name2; end
if(compare2); mapCtx.tt3 = tt3; mapCtx.name3 = name3; end

figMap.UserData.ax     = ax_map;
figMap.UserData.mapCtx = mapCtx;

drawOutlierMap(ax_map, mapCtx, [-inf inf]);

c = c + 1;
b(c) = uicontrol('Parent', figMap, 'Style','pushbutton', ...
    'String','Refresh', ...
    'Units','normalized', ...
    'Position',[0.01 0.01 0.1 0.05], ...
    'Callback',@refreshOutlierButtonPushed);

%% ============================== FIGURA 4: GATING ANALYSIS ==============================
% errore di posizione vs errore di rho_dot, con i due rettangoli di gate
% e i punti colorati per categoria: risponde a "punti esclusi dal primo
% gate / punti sempre inclusi / punti esclusi al secondo gate"
figGate = figure('name','Outlier Analysis - Gating', 'NumberTitle','off');
tiledlayout(figGate,1,1,'Padding','compact');
ax_gate = nexttile; hold(ax_gate,'on'); grid(ax_gate,'on');
xlabel(ax_gate,'errore di posizione [m]'); ylabel(ax_gate,'errore rho dot [m/s]');
title(ax_gate, sprintf(['Gate largo: %.1f m / %.1f m/s (rosso)   |   ' ...
    'Gate stretto: %.1f m / %.1f m/s (arancione)'], ...
    gate1_pos_thr, gate1_rhodot_thr, gate2_pos_thr, gate2_rhodot_thr));

% rettangolo gate 1 (largo) e gate 2 (stretto), ancorati a errore = 0
rectangle(ax_gate,'Position',[0 0 gate1_pos_thr gate1_rhodot_thr], ...
    'EdgeColor', col.radar_out, 'LineStyle','--', 'LineWidth', 1.5);
rectangle(ax_gate,'Position',[0 0 gate2_pos_thr gate2_rhodot_thr], ...
    'EdgeColor', col.radar_gate2, 'LineStyle','--', 'LineWidth', 1.5);

plot(ax_gate, pos_err(cat_blue),  rhodot_err(cat_blue),  '.', 'MarkerSize', 14, ...
    'Color', col.radar,       'DisplayName','sempre incluso (passa entrambi i gate)');
plot(ax_gate, pos_err(cat_green), rhodot_err(cat_green), '.', 'MarkerSize', 14, ...
    'Color', col.radar_gate2, 'DisplayName','escluso solo dal gate stretto');
plot(ax_gate, pos_err(cat_red),   rhodot_err(cat_red),   '.', 'MarkerSize', 14, ...
    'Color', col.radar_out,   'DisplayName','escluso dal gate largo');
legend(ax_gate,'show','Location','northeast');

n_tot   = numel(cat_blue);
n_red   = nnz(cat_red);
n_green = nnz(cat_green);
n_blue  = nnz(cat_blue);
fprintf('outlier_analysis: %d/%d punti radar esclusi dal gate largo (%.1f%%), %d/%d esclusi solo dal gate stretto (%.1f%%), %d/%d sempre inclusi (%.1f%%)\n', ...
    n_red, n_tot, 100*n_red/n_tot, n_green, n_tot, 100*n_green/n_tot, n_blue, n_tot, 100*n_blue/n_tot);

% errore medio (posizione e rho_dot) dei punti esclusi SOLO dal gate
% stretto (arancione) - passano il gate largo ma non quello stretto
if n_green > 0
    mean_pos_err_gate2    = mean(pos_err(cat_green));
    mean_rhodot_err_gate2 = mean(rhodot_err(cat_green));
else
    mean_pos_err_gate2    = NaN;
    mean_rhodot_err_gate2 = NaN;
end
fprintf('outlier_analysis: punti esclusi dal gate stretto (arancione) - errore medio posizione = %.2f m, errore medio rho_dot = %.2f m/s (n=%d)\n', ...
    mean_pos_err_gate2, mean_rhodot_err_gate2, n_green);

%% ============================== LOCAL FUNCTIONS ==============================

function plotRadarSeries(axh, stampMat, yMat, cat_blue, cat_green, cat_red, col)
    plot(axh, stampMat(cat_blue), yMat(cat_blue), '.', 'MarkerSize', 20, ...
        'Color', col.radar, 'DisplayName','radar (sempre incluso)');
    if any(cat_green(:))
        plot(axh, stampMat(cat_green), yMat(cat_green), '.', 'MarkerSize', 20, ...
            'Color', col.radar_gate2, 'DisplayName','radar (escluso dal gate stretto)');
    end
    if any(cat_red(:))
        plot(axh, stampMat(cat_red), yMat(cat_red), '.', 'MarkerSize', 20, ...
            'Color', col.radar_out, 'DisplayName','radar (escluso dal gate largo)');
    end
end

function refreshOutlierButtonPushed(src, ~)
    fig = ancestor(src,'figure');
    axm = fig.UserData.ax;
    ctx = fig.UserData.mapCtx;
    t_lim = xlim(ctx.timeRefAx); % finestra temporale letta dalla figura Range (linkata alle altre)
    drawOutlierMap(axm, ctx, t_lim);
end

function drawOutlierMap(axh, ctx, t_lim)
    set(ancestor(axh,'figure'),'CurrentAxes',axh);
    cla(axh); hold(axh,'on'); grid(axh,'on'); axis(axh,'equal');
    xlabel(axh,'x [m]'); ylabel(axh,'y [m]'); title(axh,'Map');

    col = ctx.col;
    trajDatabase = ctx.trajDatabase;
    id_left  = numel(trajDatabase) - 2;
    id_right = numel(trajDatabase) - 1;
    plot(axh, trajDatabase(id_left).x,  trajDatabase(id_left).y,  'k','LineWidth',1,'HandleVisibility','off');
    plot(axh, trajDatabase(id_right).x, trajDatabase(id_right).y, 'k','LineWidth',1,'HandleVisibility','off');

    s = ctx.s; % s.sens_stamp [Tx1], s.x_map/y_map [T x nDet]

    % finestra temporale per riga/timestep (broadcast sulle colonne)
    rows_win  = s.sens_stamp >= t_lim(1) & s.sens_stamp <= t_lim(2); % [T x 1]
    blue_win  = ctx.cat_blue  & rows_win; % [T x nDet]
    green_win = ctx.cat_green & rows_win; % [T x nDet]
    red_win   = ctx.cat_red   & rows_win; % [T x nDet]

    plot(axh, s.x_map(blue_win), s.y_map(blue_win), '.', 'MarkerSize', 20, ...
        'Color', col.radar, 'DisplayName','radar (sempre incluso)');
    if any(green_win(:))
        plot(axh, s.x_map(green_win), s.y_map(green_win), '.', 'MarkerSize', 20, ...
            'Color', col.radar_gate2, 'DisplayName','radar (escluso dal gate stretto)');
    end
    if any(red_win(:))
        plot(axh, s.x_map(red_win), s.y_map(red_win), '.', 'MarkerSize', 20, ...
            'Color', col.radar_out, 'DisplayName','radar (escluso dal gate largo)');
    end

    tt = ctx.tt;
    [t1,tend] = timeWindowIdx(tt.stamp, t_lim);
    plot(axh, tt.x_map(t1:tend,1:tt.max_opp), tt.y_map(t1:tend,1:tt.max_opp), ...
        'Color',col.tt,'HandleVisibility','off');
    plot_tt(NaN,NaN,1,col.tt,ctx.name1);

    if ctx.compare
        [t1,tend] = timeWindowIdx(ctx.tt2.stamp, t_lim);
        plot(axh, ctx.tt2.x_map(t1:tend,1:ctx.tt2.max_opp), ctx.tt2.y_map(t1:tend,1:ctx.tt2.max_opp), ...
            'Color',col.tt2,'HandleVisibility','off');
        plot_tt(NaN,NaN,1,col.tt2,ctx.name2);
    end
    if ctx.compare2
        [t1,tend] = timeWindowIdx(ctx.tt3.stamp, t_lim);
        plot(axh, ctx.tt3.x_map(t1:tend,1:ctx.tt3.max_opp), ctx.tt3.y_map(t1:tend,1:ctx.tt3.max_opp), ...
            'Color',col.tt3,'HandleVisibility','off');
        plot_tt(NaN,NaN,1,col.tt3,ctx.name3);
    end

    if ctx.use_ref || ctx.use_sim_ref
        gt = ctx.gt;
        [t1,tend] = timeWindowIdx(gt.stamp, t_lim);
        plot(axh, gt.x_map(t1:tend), gt.y_map(t1:tend), 'Color',col.ref,'DisplayName','gt');
    end

    legend(axh,'show');
end