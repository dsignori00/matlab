%% RADAR rho_dot -> vx : misure (sens_stamp vs filter stamp) vs stime vs GT
%
% Il radar misura rho_dot = range-rate RELATIVO ego<->avversario (closing
% speed), NON la velocita' assoluta. Per ottenere la vx assoluta si ricompone
% il moto ego proiettato sulla LOS e si "ruota" per l'angolo di aspetto,
% assumendo no-slip (vy_body = 0):
%       beta   = atan2(y_rel, x_rel)               % bearing avversario (frame ego)
%       aspect = yaw_rel - beta                    % angolo di aspetto
%       vx     = ( rho_dot + vx_ego*cos(beta) ) / cos(aspect)
% Vicino ad aspect = +/-90 deg -> cos->0 -> vx esplode: la misura si scarta.
%
% Ogni misura e' disegnata DUE volte:
%   o  cerchio -> ascissa = sens_stamp  (istante di acquisizione del sensore)
%   x  croce   -> ascissa = stamp       (istante di arrivo al filtro, in ritardo)
% Lo shift orizzontale cerchio->x e' la latenza. Il VALORE e' identico:
% la vx si calcola una volta sola con l'ego interpolato su sens_stamp.
%
% Vengono create FINO A TRE figure (cumulative, una per ogni log aggiuntivo
% disponibile in workspace):
%   fig 1 -> solo primo log (tt)
%   fig 2 -> primo + secondo log (tt, tt2)         [solo se tt2 esiste]
%   fig 3 -> primo + secondo + terzo (tt, tt2, tt3) [solo se tt3 esiste;
%            se tt2 non esiste ma tt3 si', fig 3 diventa (tt, tt3)]
% La GT non va ruotata: gt.vx e' gia' la vx vera, a linea continua.
% Le misure radar restano quelle del log primario (rad_clust).
% Ogni figura ha anche un subplot con l'accelerazione (a_x) stimata dai
% log e la GT, senza marker di misura (il radar non misura ax direttamente).
% Si appoggia alle variabili di workspace: rad_clust, tt, gt, col, opp_idx,
% e ai contatori f / axes usati dal linkaxes finale.

% ---------- knobs ----------
cos_min    = 0.15;   % |cos(aspect)| minimo: sotto -> misura scartata
rho_sign   = +1;     % se le misure risultano "riflesse" nei sorpassi -> -1
mk_o       = 4;      % size marker cerchio (sens_stamp)
mk_x       = 5;      % size marker croce (filter stamp)
show_aspect = false; % true -> aggiunge pannello debug dell'angolo di aspetto

% ---------- velocita' ego (per ri-comporre la vx ASSOLUTA) ----------
% rho_dot loggato = range-rate RELATIVO: serve ri-aggiungere la velocita' ego
% proiettata sulla LOS -> vx_ego*cos(beta). Stato ego: log.estimation.vx.
% NB: estimation.stamp__tot NON e' sulla stessa base di stamp__tot del tracking:
% lo riporto a zero sul proprio istante iniziale (durata coerente col radar).
if ~exist('ego','var') || ~isfield(ego,'stamp') || ~isfield(ego,'vx')
    te_raw    = log.estimation.stamp__tot(:);
    ego.stamp = te_raw - te_raw(1);
    ego.vx    = log.estimation.vx(:);
end
assert(isfield(ego,'stamp') && isfield(ego,'vx'), ...
    'Serve la velocita'' ego: definisci ego.stamp [s] e ego.vx [m/s].');

% ---------- sorgente radar (log primario) ----------
if exist('rad_clust','var')
    s = rad_clust;
else
    ridx = find(cellfun(@(c) strcmpi(c.name,'radar'), sensors), 1);
    assert(~isempty(ridx), 'radar non trovato in sensors');
    s = sensors{ridx}.s;
end

% ---------- misure: rho_dot -> vx ----------
rd   = s.rho_dot;  rd(rd==0) = nan;
xr   = s.x_rel;    xr(xr==0) = nan;
yr   = s.y_rel;    yr(yr==0) = nan;
yawr = s.yaw_rel;
if max(abs(yawr(:)), [], 'omitnan') > 2*pi     % autodetect deg vs rad
    yawr = deg2rad(yawr);
end

beta    = atan2(yr, xr);              % bearing avversario nel frame ego
aspect  = yawr - beta;               % angolo di aspetto
c       = cos(aspect);
c(abs(c) < cos_min) = nan;           % scarta vicino alla singolarita'

% ego proiettato sulla LOS, interpolato all'istante di ACQUISIZIONE (sens_stamp)
vego_i   = interp1(ego.stamp(:), ego.vx(:), s.sens_stamp(:), 'linear', 'extrap'); % [N x 1]
vego_los = vego_i .* cos(beta);      % [N x n_det]

% range-rate relativo -> vx assoluta avversario (calcolata UNA volta)
vx_meas = (rho_sign*rd + vego_los) ./ c;   % [N x n_det]

% doppia ascissa: acquisizione (sens_stamp) e arrivo al filtro (stamp)
ncol   = size(vx_meas, 2);
t_sens = repmat(s.sens_stamp(:), 1, ncol);
t_arr  = repmat(s.stamp(:),      1, ncol);
good   = isfinite(vx_meas) & isfinite(t_sens) & isfinite(t_arr);
vv = vx_meas(good);
ts = t_sens(good);      % ascissa cerchi
ta = t_arr(good);       % ascissa croci

% ---------- GT (colonna avversario opp_idx) ----------
gt_vx  = gt.vx;  gt_vx(gt_vx==0) = nan;
oi_g   = min(opp_idx, size(gt_vx,2));  vx_gt = gt_vx(:,oi_g);

gt_ax  = gt.ax;  gt_ax(gt_ax==0) = nan;
oi_ga  = min(opp_idx, size(gt_ax,2));  ax_gt = gt_ax(:,oi_ga);

% ---------- configurazioni delle figure ----------
% fig 1: solo log1 ; fig 2: log1+log2 (se disponibile) ; fig 3: += log3 (se
% disponibile). Costruzione cumulativa: ogni figura riparte dall'insieme
% della precedente e aggiunge il log successivo, se presente in workspace.
fig_sets = { {tt} };
if exist('tt2','var'); fig_sets{end+1} = [fig_sets{end}, {tt2}]; end
if exist('tt3','var'); fig_sets{end+1} = [fig_sets{end}, {tt3}]; end

vx_axes  = gobjects(0);   % pannelli vx (per link Y tra le figure)
acc_axes = gobjects(0);   % pannelli a_x (per link Y tra le figure)
asp_axes = gobjects(0);   % pannelli aspect (per link Y tra loro)

for kf = 1:numel(fig_sets)
    tt_list = fig_sets{kf};
    names   = cellfun(@(T) T.name, tt_list, 'UniformOutput', false);

    figure('name', ['Radar rho_dot -> vx | ' strjoin(names,' + ')], 'NumberTitle','off');
    ntile = 2 + show_aspect;
    tiledlayout(ntile,1,'Padding','compact');

    % (1) vx: stime dei log (loop) + GT + misure (cerchio @ sens_stamp, x @ stamp)
    % stessa dimensione del pannello accelerazione (nessuno spanning multi-riga)
    ax_main = nexttile; axes(f) = ax_main; f=f+1; hold on; grid on; %#ok<*SAGROW>
    vx_axes(end+1) = ax_main;
    h_leg = gobjects(0); lbl = {};
    for i = 1:numel(tt_list)
        T  = tt_list{i};
        oi = min(opp_idx, size(T.vx,2));
        hi = plot(T.stamp, T.vx(:,oi), '-', 'Color', T.col, 'LineWidth', 1.4);
        h_leg(end+1) = hi; lbl{end+1} = T.name;
    end
    % GT a linea continua
    h_gt = plot(gt.stamp, vx_gt, '-', 'Color', col.ref, 'LineWidth', 1.8);
    h_leg(end+1) = h_gt; lbl{end+1} = 'gt';
    % marker misure (sopra le linee)
    h_o = plot(ts, vv, 'o', 'MarkerEdgeColor', col.radar, 'MarkerSize', mk_o, ...
               'LineWidth', 0.5, 'LineStyle', 'none');
    h_x = plot(ta, vv, 'x', 'Color', col.radar, 'MarkerSize', mk_x, ...
               'LineWidth', 0.8, 'LineStyle', 'none');
    ylabel('v_x [m/s]');
    % legenda orizzontale in basso: cerchio, x, <log...>, gt
    h_all = [h_o h_x h_leg];
    l_all = [{'radar (sens stamp)','radar (filter stamp)'}, lbl];
    lgd = legend(h_all, l_all, 'Orientation','horizontal', 'NumColumns', numel(l_all));
    lgd.Layout.Tile = 'south';

    % (2) acceleration: stime dei log (loop) + GT (nessun marker: il radar
    % non misura ax direttamente, e' un derivato del modello del filtro)
    ax_acc = nexttile; axes(f) = ax_acc; f=f+1; hold on; grid on;
    acc_axes(end+1) = ax_acc;
    for i = 1:numel(tt_list)
        T  = tt_list{i};
        oi = min(opp_idx, size(T.ax,2));
        plot(T.stamp, T.ax(:,oi), '-', 'Color', T.col, 'LineWidth', 1.4);
    end
    plot(gt.stamp, ax_gt, '-', 'Color', col.ref, 'LineWidth', 1.8);
    ylabel('a_x [m/s^2]');
    if ~show_aspect; xlabel('timestamp [s]'); end

    % (3) aspect angle: debug del mascheramento (opzionale)
    if show_aspect
        ax_asp = nexttile; axes(f) = ax_asp; f=f+1; hold on; grid on;
        asp_axes(end+1) = ax_asp;
        asp_deg = rad2deg(wrapToPi(aspect));
        scatter(t_sens(:), asp_deg(:), 6, [0.6 0.6 0.6], 'filled', ...
                'MarkerFaceAlpha', 0.25, 'MarkerEdgeColor','none');
        thr = acosd(cos_min);
        yline( thr, 'r--'); yline(-thr, 'r--');
        yline( 180-thr, 'r--'); yline(-(180-thr), 'r--');
        ylabel('aspect [deg]'); xlabel('timestamp [s]'); ylim([-180 180]);
    end
end

% ---------- sincronizzazione assi ----------
% La X e' gia' legata globalmente dal linkaxes(axes,'x') in fondo al main.
% Qui aggiungo la Y con linkprop (non toccato dal linkaxes 'x'): i pannelli vx
% condividono YLim tra loro, gli a_x tra loro, gli aspect tra loro. Le
% variabili linkprop vanno tenute vive in workspace, altrimenti il legame si
% rompe.
if numel(vx_axes) >= 2
    radar_vx_ylink = linkprop(vx_axes, 'YLim'); %#ok<NASGU>
end
if numel(acc_axes) >= 2
    radar_acc_ylink = linkprop(acc_axes, 'YLim'); %#ok<NASGU>
end
if numel(asp_axes) >= 2
    radar_asp_ylink = linkprop(asp_axes, 'YLim'); %#ok<NASGU>
end