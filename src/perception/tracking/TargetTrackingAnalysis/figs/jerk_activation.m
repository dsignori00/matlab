%% JERK_FF - jerk dei filtri con le bande di attivazione ff_flag
ff_alpha = 0.35;   % opacita' delle bande (era 0.15)

figure('name','Filter - jerk e ff','NumberTitle','off');
axes(f) = gca; f=f+1; hold on; grid on;
logs = {tt};  raws = {log};  cols = {col.tt};  names = {name1};
if exist('tt2','var'); logs{end+1}=tt2; cols{end+1}=col.tt2; names{end+1}=name2;
    if exist('log_2','var'); raws{end+1}=log_2; else; raws{end+1}=[]; end; end
if exist('tt3','var'); logs{end+1}=tt3; cols{end+1}=col.tt3; names{end+1}=name3;
    if exist('log_3','var'); raws{end+1}=log_3; else; raws{end+1}=[]; end; end

% --- bande ff_flag PRIMA delle curve: niente uistack, restano dietro ---
yl = [-60 60];   % scala fissa: le patch vanno create prima di conoscere i dati
ylim(yl);
for i = 1:numel(logs)
    ff = [];
    if isfield(logs{i},'ff_flag'); ff = logs{i}.ff_flag;
    elseif ~isempty(raws{i}) && isfield(raws{i}.perception__opponents,'opponents__ff_flag')
        ff = raws{i}.perception__opponents.opponents__ff_flag;
    end
    if isempty(ff); warning('jerk_ff: ff_flag non trovato per %s', names{i}); continue; end
    on = double(ff(:, min(opp_idx, size(ff,2)))) > 0.5;
    ts = logs{i}.stamp(:);
    d  = diff([false; on(:); false]);
    i0 = find(d==1); i1 = find(d==-1)-1;
    % UNA sola patch con N facce: X e Y sono matrici 4 x N, una colonna per
    % intervallo. Costo costante invece di N chiamate a patch + uistack.
    if ~isempty(i0)
        X = [ts(i0), ts(i1), ts(i1), ts(i0)].';
        Y = repmat([yl(1); yl(1); yl(2); yl(2)], 1, numel(i0));
        patch(X, Y, cols{i}, 'FaceAlpha', ff_alpha, 'EdgeColor', 'none', ...
            'DisplayName', sprintf('ff %s', names{i}));
    end
    fprintf('%s: %d attivazioni, duty %.1f%%\n', names{i}, numel(i0), 100*nnz(on)/numel(on));
end

% --- curve di jerk (disegnate dopo -> stanno sopra le bande) ---
for i = 1:numel(logs)
    T = logs{i};
    j = []; src = '';
    if isfield(T,'jerk');       j = T.jerk;   src = 'tt.jerk';
    elseif isfield(T,'ax_dot'); j = T.ax_dot; src = 'tt.ax_dot';
    elseif ~isempty(raws{i}) && isfield(raws{i}.perception__opponents,'opponents__ax_dot')
        j = raws{i}.perception__opponents.opponents__ax_dot; src = 'log.ax_dot';
    end
    if isempty(j); warning('jerk_ff: ax_dot non trovato per %s', names{i}); continue; end
    j = j(:, min(opp_idx, size(j,2)));
    j(j==0) = nan;
    fprintf('%s: jerk da %s, %d campioni validi\n', names{i}, src, nnz(~isnan(j)));
    plot(T.stamp, j, '-', 'Color', cols{i}, 'LineWidth', 1.3, 'DisplayName', names{i});
end
ylim(yl);
ylabel('jerk [m/s^3]'); xlabel('timestamp [s]'); legend show;

clearvars logs raws cols names i T j src ff yl on ts d i0 i1 X Y ff_alpha