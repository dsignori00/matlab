%% ROW - LINE VISUALIZATION

%%% Select time portion on any plots, click refresh, use arrows to show
%%% each iteration in the selected range

fig = figure('Name','COG Visualization', 'NumberTitle','off');
set(fig,'KeyPressFcn',@keyPressed);   % <-- enable arrows

% Axes for map (left side)
axMap = axes('Parent',fig,'Units','normalized','Position',[0.06 0.15 0.50 0.75]);
title(axMap,'map');

% --- Two tables on the right, stacked (each half height) ---
colNames_lines = {'Line#','p1','p2','rho','x0','y0','dx','dy'};
colNames_rows = {'Row#','p1','p2','rho','assoc.','x0','y0','dx','dy'};

tblLines = uitable(fig, ...
    'Units','normalized', ...
    'Position',[0.58 0.53 0.39 0.42], ...   % top half
    'ColumnName', colNames_lines, ...
    'Data', cell(0,8));

tblRows = uitable(fig, ...
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
guidata(fig,S);

function refreshTimeButtonPushed(~,~)
    % Pull needed vars
    fig        = evalin('base', 'fig');
    ax         = evalin('base', 'ax');
    bag1       = evalin('base', 'bag1');
    FOOTPRINT  = evalin('base', 'FOOTPRINT');

    % Determine range from x-limits
    t_lim = xlim(ax(1));
    t1_line_eq   = find(bag1.lines.stamp > t_lim(1), 1, 'first');
    tend_line_eq = find(bag1.lines.stamp < t_lim(2), 1, 'last');

    if isempty(t1_line_eq) || isempty(tend_line_eq) || t1_line_eq > tend_line_eq
        warning('No line samples in the selected x-limits interval.');
        return;
    end

    % Build/update state
    S = guidata(fig);

    S.bag1      = bag1;
    S.FOOTPRINT = FOOTPRINT;
    S.iStart    = t1_line_eq;
    S.iEnd      = tend_line_eq;
    S.iCur      = t1_line_eq;

    guidata(fig,S);

    drawCurrentSample();
end

function keyPressed(~, event)
    fig = evalin('base','fig');
    S = guidata(fig);

    if ~isfield(S,'iCur') || isempty(S.iCur)
        return;
    end

    switch event.Key
        case 'rightarrow'
            S.iCur = min(S.iCur + 1, S.iEnd);
            guidata(fig,S);
            drawCurrentSample();

        case 'leftarrow'
            S.iCur = max(S.iCur - 1, S.iStart);
            guidata(fig,S);
            drawCurrentSample();
    end
end

function drawCurrentSample()
    fig = evalin('base','fig');
    S = guidata(fig);
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

    x = [S.bag1.lines.start_pt(i,:,1) ; S.bag1.lines.end_pt(i,:,1)];
    y = [S.bag1.lines.start_pt(i,:,2) ; S.bag1.lines.end_pt(i,:,2)];
    plot(-y, x, 'DisplayName','Lines','LineWidth',2.0);

    rows_x = [S.bag1.measures.start_pt(i,:,1) ; S.bag1.measures.end_pt(i,:,1)];
    rows_y = [S.bag1.measures.start_pt(i,:,2) ; S.bag1.measures.end_pt(i,:,2)];
    plot(-rows_y, rows_x, 'LineStyle','--','LineWidth',0.3, 'DisplayName','Rows');

    % Rows direction 
    L = 3; x0 = 0; y0 = 0;
    angle = deg2rad(S.bag1.debug.rows_angle.cog(i));
    dx = L * cos(angle);
    dy = L * sin(angle);
    quiver(S.ax, y0, x0, -dy, dx, 0, ...
        'r', 'LineWidth', 2, 'MaxHeadSize', 2, ...
        'DisplayName','Direction');

    txt = sprintf('sample %d / %d', i-S.iStart+1, S.iEnd-S.iStart+1);
    title(S.ax, ['map - ' txt]);
    hold(S.ax,'off');

    % --------- TABLE 1: LINES ----------
    p1  = S.bag1.lines.p1(i,:);
    p2  = S.bag1.lines.p2(i,:);
    rho = S.bag1.lines.rho(i,:);
    x0  = S.bag1.lines.coeff(i,:,1);
    y0  = S.bag1.lines.coeff(i,:,2);
    dx  = S.bag1.lines.coeff(i,:,4);
    dy  = S.bag1.lines.coeff(i,:,5);

    nL = numel(rho);
    dataLines = cell(nL, 8);
    for k = 1:nL
        dataLines{k,1} = k;
        dataLines{k,2} = p1(k);
        dataLines{k,3} = p2(k);
        dataLines{k,4} = rho(k);
        dataLines{k,5} = x0(k);
        dataLines{k,6} = y0(k);
        dataLines{k,7} = dx(k);
        dataLines{k,8} = dy(k);
    end
    if isfield(S,'tblLines') && isvalid(S.tblLines)
        S.tblLines.Data = dataLines;
    end

    % --------- TABLE 2: ROWS ----------
    p1r  = S.bag1.measures.p1(i,:);
    p2r  = S.bag1.measures.p2(i,:);
    rhor = S.bag1.measures.rho(i,:);
    associatedr = S.bag1.measures.associated_line(i,:);
    x0r  = S.bag1.measures.coeff(i,:,1);
    y0r  = S.bag1.measures.coeff(i,:,2);
    dxr  = S.bag1.measures.coeff(i,:,4);
    dyr  = S.bag1.measures.coeff(i,:,5);

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