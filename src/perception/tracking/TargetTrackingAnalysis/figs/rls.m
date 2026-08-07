function rls(varargin)
% RLS
% Viewer interattivo per verificare a occhio la continuita' del "ponte"
% RTS-smoother -> predict cinematico nel buffer storico di
% OpponentHistory, per una grandezza SCALARE (default: ax).
%
% Opponent SEMPRE fissato allo slot posizionale 1 (nessun filtro per
% obs_id). Per ciascun frame mostra SOLO gli step storici indicati in
% 'Steps' (default [0 3] = adesso e 3 campioni fa), con un gradiente di
% colore che indica quanto e' recente ciascun punto: GIALLO = lo step
% piu' recente tra quelli scelti, ROSSO = il piu' vecchio. Il frame
% corrente e' disegnato a piena opacita' e tratto spesso; i frame gia'
% visti restano come scia trasparente con lo stesso gradiente, cosi'
% puoi vedere se il nuovo frame "si aggancia" bene alla scia o salta.
% Navigazione:
%
%   SPAZIO o FRECCIA DESTRA : avanza di un frame
%   FRECCIA SINISTRA        : torna indietro di un frame
%   P                       : play/pausa (evoluzione temporale automatica)
%   + / -                   : velocizza / rallenta la riproduzione
%   HOME                    : salta al primo frame valido
%   q / ESC                 : chiude la figura
%
% Chiamata senza argomenti (rls, o rls()), va a prendere da sola la
% variabile 'log' dal workspace di chi la chiama (o dal base workspace
% se chiamata da riga di comando), e usa log.perception__opponents_history.
% In alternativa puoi passare esplicitamente la struct come primo
% argomento: rls(oh) oppure rls(log).
%
% CAMPI ATTESI nella struct (n = numero frame):
%   opponents__obs_id : [n x 10]      int
%   opponents__ax     : [n x 10 x 150] single (o vx, s, x_geom, y_geom)
%   opponents__steps  : [n x 10]      int, step validi per slot (opzionale)
%   'timestamp[]__tot': [n x 150]     double, tempo assoluto di ciascun
%                                      indice storico (opzionale: se
%                                      presente l'asse x e' il tempo
%                                      assoluto, altrimenti l'indice
%                                      storico)
%
% OPZIONI (Name-Value)
%   'Field'    : campo scalare da analizzare, default 'ax' ('vx','s',...)
%   'Steps'    : vettore di indici storici 0-based da mostrare per ogni
%                frame (0 = adesso), default [0 3]. Puoi passarne
%                quanti vuoi, es. [0 1 2 3 4 5].
%   'Slot'     : slot posizionale (1-10) dell'opponent, default 1
%   'MaxTrail' : quanti frame precedenti tenere a video (come scia) prima
%                di iniziare a cancellare i piu' vecchi (per performance),
%                default 150
%   'Period'   : secondi reali tra un frame e il successivo in modalita'
%                play automatico, default 0.05 (20 frame/s)
%
% USO
%   rls                       % legge 'log' dal workspace, slot 1, step [0 3]
%   rls('Field', 'vx')
%   rls('Steps', [0 1 2 3 4 5])   % torna al comportamento "6 step consecutivi"
%   rls(oh)
%   rls(oh, 'Field','vx')

%% -1. Se il primo argomento non e' la struct dati, vai a prenderla da sola
if nargin >= 1 && isstruct(varargin{1})
    oh = varargin{1};
    varargin(1) = [];
else
    oh = [];
    try
        oh = evalin('caller', 'log');
    catch
    end
    if isempty(oh)
        try
            oh = evalin('base', 'log');
        catch
        end
    end
    if isempty(oh)
        error(['Nessuna variabile "log" trovata nel workspace del chiamante ne'' ' ...
            'nel base workspace. Assicurati che il main abbia una variabile ' ...
            '"log" (con log.perception__opponents_history), oppure chiama ' ...
            'esplicitamente rls(oh) passando la struct.']);
    end
end

p = inputParser;
addParameter(p, 'Field', 'ax', @ischar);
addParameter(p, 'Steps', [0 3], @isnumeric);
addParameter(p, 'Slot', 1, @isscalar);
addParameter(p, 'MaxTrail', 150, @isscalar);
addParameter(p, 'Period', 0.05, @isscalar);
parse(p, varargin{:});
fieldName = p.Results.Field;
steps = sort(p.Results.Steps(:))';   % indici 0-based, ordinati crescenti (recente -> vecchio)
slot = p.Results.Slot;
maxTrail = max(1, p.Results.MaxTrail);
period0 = max(0.005, p.Results.Period);
nSteps = numel(steps);

%% 0. Normalizza input
if isfield(oh, 'perception__opponents_history')
    oh = oh.perception__opponents_history;
end
assert(isfield(oh, 'opponents__obs_id'), ...
    'Struct non riconosciuta: manca opponents__obs_id.');

fullFieldName = ['opponents__' fieldName];
assert(isfield(oh, fullFieldName), 'Campo non trovato: %s', fullFieldName);

ids = oh.opponents__obs_id;         % n x 10
n   = size(ids, 1);
frameFound = true(n, 1);

idsSlot = ids(:, slot);
nChanges = sum(diff(idsSlot) ~= 0 & ~isnan(diff(idsSlot)));
fprintf(['Uso sempre lo slot posizionale %d (nessun filtro per obs_id).\n' ...
    'L''obs_id in quello slot cambia %d volte su %d frame -> se e'' spesso, ' ...
    'i "salti" nel plot possono essere dovuti al cambio di veicolo tracciato, ' ...
    'non al bridge smoother->predict.\n'], slot, nChanges, n);

nBufSteps = size(oh.(fullFieldName), 3);   % di norma 150
assert(all(steps >= 0 & steps < nBufSteps), ...
    'Steps deve contenere indici tra 0 e %d.', nBufSteps-1);
data3d = oh.(fullFieldName);

Vfull = squeeze(data3d(:, slot, :));   % n x nBufSteps

if isfield(oh, 'opponents__steps')
    validSteps = oh.opponents__steps;  % n x 10
    for r = 1:n
        nv = double(validSteps(r, slot));
        if nv < nBufSteps && nv >= 0
            Vfull(r, nv+1:end) = NaN;
        end
    end
end

V = Vfull(:, steps + 1);   % n x nSteps, solo gli step scelti

hasTime = isfield(oh, 'timestamp[]__tot');
if hasTime
    Tfull = oh.('timestamp[]__tot');   % n x 150
    T = Tfull(:, steps + 1);           % n x nSteps
else
    T = repmat(steps, n, 1);           % fallback: asse x = indice step
end

%% 2. Figura interattiva
fig = figure('Color','w', ...
    'Name', sprintf('OpponentHistory bridge viewer [%s] - slot#%d, step %s', ...
        fieldName, slot, mat2str(steps)), ...
    'KeyPressFcn', @rls_keypress, ...
    'CloseRequestFcn', @rls_close);
ax = axes('Parent', fig); hold(ax, 'on'); grid(ax, 'on');
if hasTime
    xlabel(ax, 'tempo assoluto [s]');
else
    xlabel(ax, 'indice step storico');
end
ylabel(ax, fieldName);

tmr = timer('ExecutionMode', 'fixedRate', 'Period', period0, ...
    'TimerFcn', @(~,~) rls_timer_tick(fig));

state = struct();
state.V = V;
state.T = T;
state.steps = steps;
state.frameFound = frameFound;
state.n = n;
state.idsSlot = idsSlot;
state.slot = slot;
state.fieldName = fieldName;
state.nSteps = nSteps;
state.hasTime = hasTime;
state.ax = ax;
state.i = find(frameFound, 1, 'first');
state.currHandles = gobjects(0);
state.trailFrames = {};
state.maxTrail = maxTrail;
state.timer = tmr;
state.playing = false;
state.period = period0;
guidata(fig, state);

rls_draw_frame(fig);

fprintf(['Viewer aperto. SPAZIO/-> avanza, <- indietro, P play/pausa, ' ...
    '+/- velocita'', HOME primo frame, q/ESC chiude.\n']);

end

function rls_close(src, ~)
state = guidata(src);
if isfield(state, 'timer') && isvalid(state.timer)
    stop(state.timer);
    delete(state.timer);
end
delete(src);
end

function rls_timer_tick(fig)
if ~isvalid(fig)
    return;
end
state = guidata(fig);
newI = state.i + 1;
while newI <= state.n && ~state.frameFound(newI)
    newI = newI + 1;
end
if newI > state.n
    stop(state.timer);
    state.playing = false;
    guidata(fig, state);
    return;
end
state.i = newI;
guidata(fig, state);
rls_draw_frame(fig);
end

function rls_keypress(src, evt)
state = guidata(src);
switch evt.Key
    case {'space', 'rightarrow'}
        step = 1;
    case 'leftarrow'
        step = -1;
    case 'home'
        if state.playing
            stop(state.timer);
            state.playing = false;
        end
        state.i = find(state.frameFound, 1, 'first');
        guidata(src, state);
        rls_draw_frame(src);
        return;
    case 'p'
        if state.playing
            stop(state.timer);
            state.playing = false;
        else
            start(state.timer);
            state.playing = true;
        end
        guidata(src, state);
        return;
    case {'add', 'equal'}
        state.period = max(0.005, state.period / 1.5);
        state.timer.Period = state.period;
        guidata(src, state);
        fprintf('Periodo frame: %.3f s (%.1f frame/s)\n', state.period, 1/state.period);
        return;
    case {'subtract', 'hyphen'}
        state.period = min(2, state.period * 1.5);
        state.timer.Period = state.period;
        guidata(src, state);
        fprintf('Periodo frame: %.3f s (%.1f frame/s)\n', state.period, 1/state.period);
        return;
    case {'q', 'escape'}
        rls_close(src, []);
        return;
    otherwise
        return;
end

if state.playing
    stop(state.timer);
    state.playing = false;
end

newI = state.i + step;
while newI >= 1 && newI <= state.n && ~state.frameFound(newI)
    newI = newI + step;
end
if newI < 1 || newI > state.n
    guidata(src, state);
    return;
end
state.i = newI;
guidata(src, state);
rls_draw_frame(src);
end

function rls_draw_frame(fig)
state = guidata(fig);
i = state.i;
ax = state.ax;

x = state.T(i, :);
y = state.V(i, :);
colors = rls_gradient_colors(state.nSteps);   % giallo (step piu' recente) -> rosso (piu' vecchio)

trailH = rls_plot_gradient(ax, x, y, colors, 0.30, 0.8, 10);
state.trailFrames{end+1} = trailH;
if numel(state.trailFrames) > state.maxTrail
    delete(state.trailFrames{1});
    state.trailFrames(1) = [];
end

if ~isempty(state.currHandles)
    delete(state.currHandles);
end
state.currHandles = rls_plot_gradient(ax, x, y, colors, 1.0, 2.4, 45);

if state.playing
    statusStr = 'PLAY';
else
    statusStr = 'pausa';
end
title(ax, sprintf('frame %d/%d | slot#%d obs\\_id=%d | campo: %s | step %s | %s | giallo=piu'' recente -> rosso=piu'' vecchio', ...
    i, state.n, state.slot, state.idsSlot(i), state.fieldName, mat2str(state.steps), statusStr));

guidata(fig, state);
drawnow limitrate;
end

function colors = rls_gradient_colors(nSteps)
% Gradiente giallo (piu' recente) -> rosso (piu' vecchio), applicato
% nell'ordine in cui gli step sono stati passati (gia' ordinati
% crescenti = dal piu' recente al piu' vecchio).
tt = linspace(0, 1, nSteps)';
colors = [ones(nSteps,1), 1 - tt, zeros(nSteps,1)];
end

function h = rls_plot_gradient(ax, x, y, colors, alpha, lineWidth, markerSize)
% Disegna una polilinea x,y colorando ogni segmento/marker secondo
% 'colors' (una riga per punto), con trasparenza 'alpha'. Ritorna tutti
% gli handle creati (per poterli cancellare in blocco quando serve).
nPts = numel(x);
h = gobjects(1, nPts);   % nPts-1 segmenti + 1 scatter
for k = 1:nPts-1
    c = colors(k,:);
    h(k) = plot(ax, x(k:k+1), y(k:k+1), '-', 'Color', [c alpha], ...
        'LineWidth', lineWidth, 'HandleVisibility', 'off');
end
h(nPts) = scatter(ax, x, y, markerSize, colors, 'filled', ...
    'MarkerFaceAlpha', alpha, 'MarkerEdgeColor', 'none', 'HandleVisibility', 'off');
end

function counts = list_obs_ids(oh, doPrint)
% LIST_OBS_IDS Elenca gli obs_id presenti nel log, ordinati per numero
% di frame in cui compaiono (persistenza).
%
% USO:
%   list_obs_ids(log.perception__opponents_history)
%   c = list_obs_ids(oh, false);
if nargin < 2, doPrint = true; end
if isfield(oh, 'perception__opponents_history')
    oh = oh.perception__opponents_history;
end
ids = oh.opponents__obs_id;
allIds = ids(:);
allIds(allIds < 0 | isnan(allIds)) = [];
[u, ~, ic] = unique(allIds);
cnt = accumarray(ic, 1);
[cnt, ord] = sort(cnt, 'descend');
u = u(ord);
counts = struct('id', u, 'n', cnt);
if doPrint
    n = size(ids,1);
    fprintf('%d obs_id distinti trovati nel log (%d frame totali):\n', numel(u), n);
    for k = 1:numel(u)
        fprintf('  obs_id=%-6d  %5d/%d frame (%.1f%%)\n', u(k), cnt(k), n, 100*cnt(k)/n);
    end
end
end