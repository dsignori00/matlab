%% ROW - LINE VISUALIZATION

%%% Select time portion on any plots, click refresh, use arrows to show
%%% each iteration in the selected range

fig2 = figure('Name','Chunk Visualization', 'NumberTitle','off');
set(fig2,'KeyPressFcn',@keyPressed);   % <-- enable arrows

% Axes for map (left side)
axMap = axes('Parent',fig2,'Units','normalized','Position',[0.06 0.15 0.50 0.75]);
title(axMap,'map');

% --- Two tables on the right, stacked (each half height) ---
colNames_chunks = {'Chunk#','state','counter','len'};
colNames_rows = {'Row#','p1','p2','rho','assoc.','x0','y0','dx','dy'};

tblLines = uitable(fig2, ...
    'Units','normalized', ...
    'Position',[0.58 0.53 0.39 0.42], ...   % top half
    'ColumnName', colNames_chunks, ...
    'Data', cell(0,8));

tblRows = uitable(fig2, ...
    'Units','normalized', ...
    'Position',[0.58 0.08 0.39 0.42], ...   % bottom half
    'ColumnName', colNames_rows, ...
    'Data', cell(0,9));

% Button
c = uicontrol('Style','pushbutton', ...
    'String','Refresh', ...
    'Units','normalized', ...
    'Position',[0.01 0.01 0.1 0.05], ...
    'Callback',@refreshTimeButtonPushed);

% Initialize empty state
S = struct();
S.ax       = axMap;
S.tblLines = tblLines;
S.tblRows  = tblRows;
guidata(fig2,S);

function refreshTimeButtonPushed(~,~)
    % Pull needed vars
    fig2        = evalin('base', 'fig2');
    ax         = evalin('base', 'ax');
    bag1       = evalin('base', 'bag1');
    FOOTPRINT  = evalin('base', 'FOOTPRINT');
    CHUNKSTATE = evalin('base', 'CHUNKSTATE');

    % Determine range from x-limits
    t_lim = xlim(ax(1));
    t1_chunk   = find(bag1.debug.stamp > t_lim(1), 1, 'first');
    tend_chunk = find(bag1.debug.stamp < t_lim(2), 1, 'last');

    if isempty(t1_chunk) || isempty(tend_chunk) || t1_chunk > tend_chunk
        warning('No line samples in the selected x-limits interval.');
        return;
    end

    % Build/update state
    S = guidata(fig2);

    S.bag1       = bag1;
    S.FOOTPRINT  = FOOTPRINT;
    S.CHUNKSTATE = CHUNKSTATE;
    S.iStart     = t1_chunk;
    S.iEnd       = tend_chunk;
    S.iCur       = t1_chunk;

    guidata(fig2,S);

    drawCurrentSample();
end

function keyPressed(~, event)
    fig2 = evalin('base','fig2');
    S = guidata(fig2);

    if ~isfield(S,'iCur') || isempty(S.iCur)
        return;
    end

    switch event.Key
        case 'rightarrow'
            S.iCur = min(S.iCur + 1, S.iEnd);
            guidata(fig2,S);
            drawCurrentSample();

        case 'leftarrow'
            S.iCur = max(S.iCur - 1, S.iStart);
            guidata(fig2,S);
            drawCurrentSample();
    end
end

function drawCurrentSample()
    fig2 = evalin('base','fig2');
    S = guidata(fig2);
    i = S.iCur;

    % --------- MAP DRAW ----------
    axes(S.ax);
    cla(S.ax,'reset');
    hold(S.ax,'on'); grid(S.ax,'on');
    xlabel(S.ax,'y[m]'); ylabel(S.ax,'x[m]');
    axis(S.ax,'equal'); xlim(S.ax,[-10,10]); ylim(S.ax,[-10,10]);

    rectangle('Position',[-S.FOOTPRINT.width/2 -S.FOOTPRINT.length/2 ...
                          S.FOOTPRINT.width S.FOOTPRINT.length], ...
              'EdgeColor','k','LineWidth',2);

    x = [S.bag1.debug.chunks.start_pt(i,:,1) ; S.bag1.debug.chunks.end_pt(i,:,1)];
    y = [S.bag1.debug.chunks.start_pt(i,:,2) ; S.bag1.debug.chunks.end_pt(i,:,2)];
    plot(-y, x, 'DisplayName','Chunks','LineWidth',2.0);

    rows_x = [S.bag1.debug.closest_lines.start_pt(i,:,1) ; S.bag1.debug.closest_lines.end_pt(i,:,1)];
    rows_y = [S.bag1.debug.closest_lines.start_pt(i,:,2) ; S.bag1.debug.closest_lines.end_pt(i,:,2)];
    plot(-rows_y, rows_x, 'LineStyle','--','LineWidth',0.3, 'DisplayName','Rows');

    txt = sprintf('sample %d / %d', i-S.iStart+1, S.iEnd-S.iStart+1);
    title(S.ax, ['map - ' txt]);
    hold(S.ax,'off');

    % --------- TABLE 1: CHUNK ----------
    state  = S.bag1.debug.chunks.state(i,:);
    counter  = S.bag1.debug.chunks.forget_chunk_len_counter(i,:);
    len = S.bag1.debug.chunks.end_row_detection_len(i,:);

    nL = 4;
    dataLines = cell(nL, 8);
    for k = 1:nL

        state_str = '';
        if(state(k) == S.CHUNKSTATE.NO_CHUNK);   state_str = 'NO_CHUNK';   end
        if(state(k) == S.CHUNKSTATE.NOT_FITTED); state_str = 'NOT_FITTED'; end
        if(state(k) == S.CHUNKSTATE.FITTED);     state_str = 'FITTED';     end
        if(state(k) == S.CHUNKSTATE.DISCARDED);  state_str = 'DISCARDED';  end

        dataLines{k,1} = k;
        dataLines{k,2} = state_str;
        dataLines{k,3} = counter(k);
        dataLines{k,4} = len(k);
    end
    if isfield(S,'tblLines') && isvalid(S.tblLines)
        S.tblLines.Data = dataLines;
    end

    % --------- TABLE 2: ROWS ----------
    p1r  = S.bag1.debug.closest_lines.p1(i,:);
    p2r  = S.bag1.debug.closest_lines.p2(i,:);
    rhor = S.bag1.debug.closest_lines.rho(i,:);
    associatedr = S.bag1.debug.closest_lines.associated_line(i,:);
    x0r  = S.bag1.debug.closest_lines.coeff(i,:,1);
    y0r  = S.bag1.debug.closest_lines.coeff(i,:,2);
    dxr  = S.bag1.debug.closest_lines.coeff(i,:,4);
    dyr  = S.bag1.debug.closest_lines.coeff(i,:,5);

    nR = numel(rhor);
    dataRows = cell(nR, 8);
    for k = 1:nR
        dataRows{k,1} = k;
        dataRows{k,2} = p1r(k);
        dataRows{k,3} = p2r(k);
        dataRows{k,4} = rhor(k);
        dataRows{k,5} = associatedr(k);
        dataRows{k,6} = x0r(k);
        dataRows{k,7} = y0r(k);
        dataRows{k,8} = dxr(k);
        dataRows{k,9} = dyr(k);
    end

    if isfield(S,'tblRows') && isvalid(S.tblRows)
        S.tblRows.Data = dataRows;
    end
end