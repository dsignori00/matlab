%% SPEED_ACC_FF - velocita' e accelerazione di piu' log, ff_* o standard
%
% Figura unica, due pannelli della stessa dimensione:
%   (1) v_x  di ogni log (+ GT)
%   (2) a_x  di ogni log (+ GT)
%
% Per OGNI log si sceglie con un flag se plottare i campi feed-forward
% (ff_vx / ff_ax) oppure quelli standard (vx / ax):
%   use_ff_1 / use_ff_2 / use_ff_3 = true  -> ff_vx  e ff_ax
%                                     false -> vx     e ax
%
% NB: i campi ff_vx / ff_ax NON sono caricati da load_tt.m, quindi vengono
% letti direttamente dai log grezzi (log / log_2 / log_3), campi
% perception__opponents.opponents__ff_vx / __ff_ax, usando tt*.stamp come
% base tempo (stesso stamp__tot del messaggio, indici allineati riga per
% riga). Gli 0 sono mascherati a NaN, come fa load_tt per gli altri campi.
%
% Richiede in workspace: tt, log, opp_idx, f, axes, col
%                        (tt2/log_2, tt3/log_3 e gt opzionali).

%% ================= PARAMETRI =================
use_ff_1 = false;    % log 1: true -> ff_vx/ff_ax, false -> vx/ax
use_ff_2 = true;    % log 2: idem
use_ff_3 = true;   % log 3: idem

show_gt = true;     % sovrappone la ground truth

%% ================= RACCOLTA LOG =================
% ogni riga: {struct tt*, log grezzo, flag ff, colore, etichetta di default}
defs = {};
if exist('tt','var')
    if exist('log','var');   r1 = log;   else; r1 = []; end
    defs(end+1,:) = {tt,  r1, use_ff_1, col.tt,  'log 1'};
end
if exist('tt2','var')
    if exist('log_2','var'); r2 = log_2; else; r2 = []; end
    defs(end+1,:) = {tt2, r2, use_ff_2, col.tt2, 'log 2'};
end
if exist('tt3','var')
    if exist('log_3','var'); r3 = log_3; else; r3 = []; end
    defs(end+1,:) = {tt3, r3, use_ff_3, col.tt3, 'log 3'};
end

curves = {};   % struct con stamp, vx, ax, col, name, tag
for i = 1:size(defs,1)
    T      = defs{i,1};
    rawlog = defs{i,2};
    do_ff  = defs{i,3};
    c      = defs{i,4};
    if isfield(T,'name'); nm = T.name; else; nm = defs{i,5}; end

    v = []; a = [];
    if do_ff
        % ---- campi feed-forward: struct tt* se estesa, altrimenti log grezzo
        if isfield(T, 'ff_vx')
            v = T.ff_vx;
        elseif ~isempty(rawlog) && isfield(rawlog, 'perception__opponents') && ...
                isfield(rawlog.perception__opponents, 'opponents__ff_vx')
            v = rawlog.perception__opponents.opponents__ff_vx;
        end
        if isfield(T, 'ff_ax')
            a = T.ff_ax;
        elseif ~isempty(rawlog) && isfield(rawlog, 'perception__opponents') && ...
                isfield(rawlog.perception__opponents, 'opponents__ff_ax')
            a = rawlog.perception__opponents.opponents__ff_ax;
        end
        tag = 'ff\_';
        if isempty(v) && isempty(a)
            warning('speed_acc_ff: ff_vx/ff_ax non trovati per %s - log saltato.', nm);
            continue;
        end
    else
        % ---- campi standard, gia' caricati da load_tt
        if isfield(T,'vx'); v = T.vx; end
        if isfield(T,'ax'); a = T.ax; end
        tag = '';
        if isempty(v) && isempty(a)
            warning('speed_acc_ff: vx/ax non trovati per %s - log saltato.', nm);
            continue;
        end
    end

    if ~isempty(v); v = v(:, min(opp_idx, size(v,2))); v(v == 0) = nan; end
    if ~isempty(a); a = a(:, min(opp_idx, size(a,2))); a(a == 0) = nan; end

    S.stamp = T.stamp(:);
    S.vx = v; S.ax = a; S.col = c; S.name = nm; S.tag = tag;
    curves{end+1} = S; %#ok<SAGROW>

    if do_ff; src_txt = 'ff_vx/ff_ax'; else; src_txt = 'vx/ax'; end
    fprintf('speed_acc_ff: %s -> %s\n', nm, src_txt);
end

%% ================= GT =================
has_gt = show_gt && exist('gt','var') && isstruct(gt) && isfield(gt,'stamp');
if has_gt
    t_gt = gt.stamp(:);
    if isfield(gt,'vx')
        vx_gt = gt.vx(:, min(opp_idx, size(gt.vx,2)));
        vx_gt(vx_gt == 0) = nan;
    else
        vx_gt = [];
    end
    if isfield(gt,'ax')
        ax_gt = gt.ax(:, min(opp_idx, size(gt.ax,2)));
        ax_gt(ax_gt == 0) = nan;
    else
        ax_gt = [];
    end
end

%% ================= FIGURA =================
figure('Name','Speed & acc','NumberTitle','off'); f = f+1;
tl = tiledlayout(2,1,'TileSpacing','compact');
title(tl, sprintf('Velocita'' e accelerazione - opp %d', opp_idx), 'FontWeight','bold');

% ---- (1) velocita' ----
axv = nexttile; hold on; grid on;
for i = 1:numel(curves)
    S = curves{i};
    if ~isempty(S.vx)
        plot(S.stamp, S.vx, '-', 'Color', S.col, 'LineWidth', 1.3, ...
            'DisplayName', sprintf('%s: %svx', S.name, S.tag));
    end
end
if has_gt && ~isempty(vx_gt)
    plot(t_gt, vx_gt, '-', 'Color', col.ref, 'LineWidth', 1.5, 'DisplayName', 'gt');
end
ylabel('v_x [m/s]');
legend('Location','eastoutside','FontSize',8,'Box','off');
axes = [axes, axv]; %#ok<AGROW>

% ---- (2) accelerazione ----
axa = nexttile; hold on; grid on;
for i = 1:numel(curves)
    S = curves{i};
    if ~isempty(S.ax)
        plot(S.stamp, S.ax, '-', 'Color', S.col, 'LineWidth', 1.3, ...
            'DisplayName', sprintf('%s: %sax', S.name, S.tag));
    end
end
if has_gt && ~isempty(ax_gt)
    plot(t_gt, ax_gt, '-', 'Color', col.ref, 'LineWidth', 1.5, 'DisplayName', 'gt');
end
ylabel('a_x [m/s^2]'); xlabel('t [s]');
legend('Location','eastoutside','FontSize',8,'Box','off');
axes = [axes, axa]; %#ok<AGROW>

clearvars defs r1 r2 r3 curves i T rawlog do_ff c nm v a tag S src_txt ...
    t_gt vx_gt ax_gt has_gt tl axv axa