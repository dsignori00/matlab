%% GT vx vs uscita filtro (tt / tt2 / tt3) + misure radar (stile latency_delay)
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
% Ogni misura radar e' disegnata DUE volte (come in latency_delay):
%   o  cerchio -> ascissa = sens_stamp  (istante di acquisizione del sensore)
%   x  croce   -> ascissa = stamp       (istante di arrivo al filtro, in ritardo)
% Lo shift orizzontale cerchio->x e' la latenza. Il VALORE e' identico:
% la vx si calcola una volta sola con l'ego interpolato su sens_stamp.
%
% Plotta tt (sempre), tt2 e tt3 se esistono (compare/compare2 = true nello
% script principale). La GT non va ruotata: gt.vx e' gia' la vx vera, a
% linea continua. Le misure radar restano quelle del log primario (rad_clust).
%
% Si appoggia alle variabili di workspace: rad_clust, gt, col, opp_idx, tt,
% (tt2, tt3 se presenti), e ai contatori f / axes usati dal linkaxes finale.

% ---------- knobs ----------
cos_min     = 0.15;   % |cos(aspect)| minimo: sotto -> misura scartata
rho_sign    = +1;     % se le misure risultano "riflesse" nei sorpassi -> -1
mk_o        = 4;      % size marker cerchio (sens_stamp)
mk_x        = 5;      % size marker croce (filter stamp)
show_aspect = false;  % true -> aggiunge pannello debug dell'angolo di aspetto

% ---------- velocita' ego (per ri-comporre la vx ASSOLUTA) ----------
% Se log.estimation manca o e' vuoto non c'e' modo di ricomporre la vx
% assoluta dal rho_dot relativo: le misure radar vengono semplicemente
% saltate (niente errore), il resto della figura (tt, gt) viene plottato lo stesso.
has_radar_meas = true;
if ~exist('ego','var') || ~isfield(ego,'stamp') || ~isfield(ego,'vx')
    if ~isfield(log,'estimation') || isempty(log.estimation) ...
            || ~isfield(log.estimation,'stamp__tot') || ~isfield(log.estimation,'vx') ...
            || isempty(log.estimation.stamp__tot) || isempty(log.estimation.vx)
        has_radar_meas = false;
        warning('vx_gt_radar: log.estimation vuoto/mancante, misure radar non plottate.');
    else
        te_raw    = log.estimation.stamp__tot(:);
        ego.stamp = te_raw - te_raw(1);
        ego.vx    = log.estimation.vx(:);
    end
end

if has_radar_meas
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

    vego_i   = interp1(ego.stamp(:), ego.vx(:), s.sens_stamp(:), 'linear', 'extrap'); % [N x 1]
    vego_los = vego_i .* cos(beta);      % [N x n_det]

    vx_meas = (rho_sign*rd + vego_los) ./ c;   % [N x n_det]

    ncol   = size(vx_meas, 2);
    t_sens = repmat(s.sens_stamp(:), 1, ncol);
    t_arr  = repmat(s.stamp(:),      1, ncol);
    good   = isfinite(vx_meas) & isfinite(t_sens) & isfinite(t_arr);
    vv = vx_meas(good);
    ts = t_sens(good);      % ascissa cerchi
    ta = t_arr(good);       % ascissa croci
end

% ---------- GT (colonna avversario opp_idx) ----------
gt_vx  = gt.vx;  gt_vx(gt_vx==0) = nan;
oi_g   = min(opp_idx, size(gt_vx,2));  vx_gt = gt_vx(:,oi_g);

% ---------- lista delle stime filtro da plottare ----------
plot_list = {tt};
if exist('tt2','var'); plot_list{end+1} = tt2; end
if exist('tt3','var'); plot_list{end+1} = tt3; end

% ---------- figura ----------
figure('name', 'GT vs filtro: v_x + misure radar', 'NumberTitle','off');
ntile = 2 + (show_aspect && has_radar_meas);
tiledlayout(ntile,1,'Padding','compact');

% (1) vx: stime dei log + GT + misure (cerchio @ sens_stamp, x @ stamp)
ax_main = nexttile([2 1]); axes(f) = ax_main; f=f+1; hold on; grid on; %#ok<*SAGROW>
h_leg = gobjects(0); lbl = {};
for i = 1:numel(plot_list)
    T  = plot_list{i};
    oi = min(opp_idx, size(T.vx,2));
    hi = plot(T.stamp, T.vx(:,oi), '-', 'Color', T.col, 'LineWidth', 1.4);
    h_leg(end+1) = hi; lbl{end+1} = T.name; %#ok<*SAGROW>
end
% GT a linea continua
h_gt = plot(gt.stamp, vx_gt, '-', 'Color', col.ref, 'LineWidth', 1.8);
h_leg(end+1) = h_gt; lbl{end+1} = 'gt';
% marker misure radar (sopra le linee), stile latency_delay -- solo se disponibili
if has_radar_meas
    h_o = plot(ts, vv, 'o', 'MarkerEdgeColor', col.radar, 'MarkerSize', mk_o, ...
               'LineWidth', 0.5, 'LineStyle', 'none');
    h_x = plot(ta, vv, 'x', 'Color', col.radar, 'MarkerSize', mk_x, ...
               'LineWidth', 0.8, 'LineStyle', 'none');
    h_all = [h_o h_x h_leg];
    l_all = [{'radar (sens stamp)','radar (filter stamp)'}, lbl];
else
    h_all = h_leg;
    l_all = lbl;
end
ylabel('v_x [m/s]');
if ~show_aspect || ~has_radar_meas; xlabel('timestamp [s]'); end
% legenda orizzontale in basso: cerchio, x (se presenti), <log...>, gt
lgd = legend(h_all, l_all, 'Orientation','horizontal', 'NumColumns', numel(l_all));
lgd.Layout.Tile = 'south';

% (2) aspect angle: debug del mascheramento (opzionale, solo se ci sono misure radar)
if show_aspect && has_radar_meas
    ax_asp = nexttile; axes(f) = ax_asp; f=f+1; hold on; grid on;
    asp_deg = rad2deg(wrapToPi(aspect));
    scatter(t_sens(:), asp_deg(:), 6, [0.6 0.6 0.6], 'filled', ...
            'MarkerFaceAlpha', 0.25, 'MarkerEdgeColor','none');
    thr = acosd(cos_min);
    yline( thr, 'r--'); yline(-thr, 'r--');
    yline( 180-thr, 'r--'); yline(-(180-thr), 'r--');
    ylabel('aspect [deg]'); xlabel('timestamp [s]'); ylim([-180 180]);
end