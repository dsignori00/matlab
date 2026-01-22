%% Covariance Analysis

% IDEAS:
% - only consider the first track
% - only plot associated measurements
% - usa bag simulate con bag reader: pubblico stato filtro dopo ciascuna misurazione 
%   (attenzione a effetto reprocessing -> vedi latenza, aggiungi campo a oppoenents)
% - plot covariance with shaded area (2 sigma) (vedi plot del cingo -> utile per analisi associazione misure)

% gating distance
dist = 10;  % [m]
% measurement matrices
R.lidar         = diag([0.7 0.7]);   % [m^2]
R.radar         = diag([1.5 2.0]);   % [m^2]
R.camera        = diag([10.0 10.0]); % [m^2]
R.pointpillars  = diag([0.7 0.7]);   % [m^2]

sensor_list = { ...
    'lidar',  SensorType.LIDAR_CLUSTERING,   col.lidar,        R.lidar,         lid_clust;
    'radar',  SensorType.RADAR_CLUSTERING,   col.radar,        R.radar,         rad_clust;
    'pp',     SensorType.LIDAR_POINTPILLARS, col.pointpillars, R.pointpillars,  lid_pp;
    'camera', SensorType.CAMERA_YOLO,        col.camera,       R.camera,        cam_yolo;
};

%% Time series figure


figure('name', 'Covariance - Positions');
tiledlayout(3,1,'Padding','compact');
sensor_points = struct();

source_vec = reshape(tt.measures.source(:,1,:), [], 1);   % [N*M x 1]
stamp_vec  = reshape(tt.measures.stamp(:,1,:),  [], 1);   % same size as source_vec

axes(f) = nexttile([1,1]); f=f+1; hold on;
% --- Loop over each sensor type ---
for k = 1:size(sensor_list,1)
    name = sensor_list{k,1};
    type = sensor_list{k,2};
    color = sensor_list{k,3};
    noise = sensor_list{k,4};
    
    idx = (source_vec == type.Value);   % logical vector
    sensor_points.(name) = interp1(tt.stamp, sqrt(tt.covariance(:,1,1)), stamp_vec(idx));

    plot(stamp_vec(idx), sensor_points.(name), 'o', ...
        'MarkerFaceColor', color, ...
        'MarkerEdgeColor', color, ...
        'MarkerSize', sz + size(sensor_list,1) - k, ...
        'DisplayName', "R: " + num2str(noise(1,1)) + " - " + strrep(name,'_',' '));  
    hold on
end
plot(tt.stamp,sqrt(tt.covariance(:,1, 1)),'Color',col.tt,'DisplayName','Track');

if(compare)
    plot(tt2.stamp,sqrt(tt2.covariance(:,1, 1)),'Color',col.tt2,'DisplayName',name2);
end
grid on; ylabel('x map [m]');  legend show;


axes(f) = nexttile([1,1]); f=f+1; hold on;
% --- Loop over each sensor type ---
for k = 1:size(sensor_list,1)
    name = sensor_list{k,1};
    type = sensor_list{k,2};
    color = sensor_list{k,3};
    noise = sensor_list{k,4};
    
    idx = (source_vec == type.Value);   % logical vector
    sensor_points.(name) = interp1(tt.stamp, sqrt(tt.covariance(:,1,7)), stamp_vec(idx));

    plot(stamp_vec(idx), sensor_points.(name), 'o', ...
        'MarkerFaceColor', color, ...
        'MarkerEdgeColor', color, ...
        'MarkerSize', sz + size(sensor_list,1) - k, ...
        'DisplayName', "R: " + num2str(noise(2,2)) + " - " + strrep(name,'_',' '));  % nicer display
    hold on
end
plot(tt.stamp,sqrt(tt.covariance(:,1, 7)),'Color',col.tt,'DisplayName','Track');

if(compare)
    plot(tt2.stamp,sqrt(tt2.covariance(:,1, 7)),'Color',col.tt2,'DisplayName',name2);
end
grid on; ylabel('y map [m]');  legend show;


% yaw
axes(f) = nexttile([1,1]); f=f+1; hold on;
% --- Loop over each sensor type ---
for k = 1:size(sensor_list,1)
    name = sensor_list{k,1};
    type = sensor_list{k,2};
    color = sensor_list{k,3};
    
    idx = (source_vec == type.Value);   % logical vector
    sensor_points.(name) = interp1(tt.stamp, sqrt(tt.covariance(:,1,25)), stamp_vec(idx));

    plot(stamp_vec(idx), sensor_points.(name), 'o', ...
        'MarkerFaceColor', color, ...
        'MarkerEdgeColor', color, ...
        'MarkerSize', sz + size(sensor_list,1) - k, ...
        'DisplayName', strrep(name,'_',' '));  % nicer display
    hold on
end
plot(tt.stamp,sqrt(tt.covariance(:,1, 25)),'Color',col.tt,'DisplayName','Track');

if(compare)
    plot(tt2.stamp,sqrt(tt2.covariance(:,1, 25)),'Color',col.tt2,'DisplayName',name2);
end
grid on; ylabel('yaw map [m]'); legend show;


figure('name', 'Covariance - Speed Acc');
tiledlayout(2,1,'Padding','compact');

% speed
axes(f) = nexttile([1,1]); f=f+1; hold on;
% --- Loop over each sensor type ---
for k = 1:size(sensor_list,1)
    name = sensor_list{k,1};
    type = sensor_list{k,2};
    color = sensor_list{k,3};
    
    idx = (source_vec == type.Value);   % logical vector
    sensor_points.(name) = interp1(tt.stamp, sqrt(tt.covariance(:,1,13)), stamp_vec(idx));

    plot(stamp_vec(idx), sensor_points.(name), 'o', ...
        'MarkerFaceColor', color, ...
        'MarkerEdgeColor', color, ...
        'MarkerSize', sz + size(sensor_list,1) - k, ...
        'DisplayName', strrep(name,'_',' '));  % nicer display
    hold on
end
plot(tt.stamp,sqrt(tt.covariance(:,1, 13)),'Color',col.tt,'DisplayName','Track');

if(compare)
    plot(tt2.stamp,sqrt(tt2.covariance(:,1, 13)),'Color',col.tt2,'DisplayName',name2);
end
grid on; ylabel('speed [m/s]'); legend show;


% acceleration
axes(f) = nexttile([1,1]); f=f+1; hold on;
% --- Loop over each sensor type ---
for k = 1:size(sensor_list,1)
    name = sensor_list{k,1};
    type = sensor_list{k,2};
    color = sensor_list{k,3};
    
    idx = (source_vec == type.Value);   % logical vector
    sensor_points.(name) = interp1(tt.stamp, sqrt(tt.covariance(:,1,19)), stamp_vec(idx));

    plot(stamp_vec(idx), sensor_points.(name), 'o', ...
        'MarkerFaceColor', color, ...
        'MarkerEdgeColor', color, ...
        'MarkerSize', sz + size(sensor_list,1) - k, ...
        'DisplayName', strrep(name,'_',' '));  % nicer display
    hold on
end
plot(tt.stamp,sqrt(tt.covariance(:,1, 19)),'Color',col.tt,'DisplayName','Track');

if(compare)
    plot(tt2.stamp,sqrt(tt2.covariance(:,1, 19)),'Color',col.tt2,'DisplayName',name2);
end
grid on; ylabel('acc [m/s$^2$]'); legend show;


%% Association Figure


%%% Select time portion on any plots, click refresh, use arrows to show
%%% each iteration in the selected range
assFig = figure('name', 'Covariance - Association');
set(assFig,'KeyPressFcn',@keyPressed);   

% Axes for map (left side)
axMap = builtin('axes','Parent',assFig);
title(axMap,'map');

% Button
c = uicontrol('Style','pushbutton', ...
    'String','Refresh', ...
    'Units','normalized', ...
    'Position',[0.01 0.01 0.1 0.05], ...
    'Callback',@refreshTimeButtonPushed);

% Initialize empty state
S = struct();
S.ax       = axMap;
guidata(assFig,S);

function refreshTimeButtonPushed(~,~)
    % Pull needed vars
    assFig        = evalin('base', 'assFig');
    axes       = evalin('base', 'axes');
    tt         = evalin('base', 'tt');

    % Determine range from x-limits
    t_lim = xlim(axes(1));
    t1_tt   = find(tt.stamp > t_lim(1), 1, 'first');
    tend_tt = find(tt.stamp < t_lim(2), 1, 'last');

    if isempty(t1_tt) || isempty(tend_tt) || t1_tt > tend_tt
        warning('No opponents samples in the selected x-limits interval.');
        return;
    end

    % Build/update state
    S = guidata(assFig);

    S.tt        = tt;
    S.iStart    = t1_tt;
    S.iEnd      = tend_tt;
    S.iCur      = t1_tt;

    guidata(assFig,S);

    drawCurrentSample();
end

function keyPressed(~, event)
    assFig = evalin('base','assFig');
    S = guidata(assFig);

    if ~isfield(S,'iCur') || isempty(S.iCur)
        return;
    end

    switch event.Key
        case 'rightarrow'
            S.iCur = min(S.iCur + 1, S.iEnd);
            guidata(assFig,S);
            drawCurrentSample();

        case 'leftarrow'
            S.iCur = max(S.iCur - 1, S.iStart);
            guidata(assFig,S);
            drawCurrentSample();
    end
end

function drawCurrentSample()
    assFig = evalin('base','assFig');
    traj_db = evalin('base', 'trajDatabase');
    col = evalin('base', 'col');
    sensor_list = evalin('base', 'sensor_list');
    dist = evalin('base', 'dist');
    S = guidata(assFig);
    i = S.iCur;

    % --------- MAP DRAW ----------
    builtin('axes', S.ax);
    cla(S.ax,'reset');
    hold(S.ax,'on'); grid(S.ax,'on');
    xlabel(S.ax,'y[m]'); ylabel(S.ax,'x[m]'); axis(S.ax,'equal'); 

    % stampa tutte la misura tra le due iterazioni i e i-1 (solo 1, usa tt simulator)
    query_time = [];
    for k = 1:size(sensor_list,1)
        name  = sensor_list{k,1};
        color = sensor_list{k,3};
        noise = sensor_list{k,4};
        data  = sensor_list{k,5};

        if i == 1
            continue;
        end

        idx = find(data.stamp >= S.tt.stamp(i-1) & data.stamp < S.tt.stamp(i));
        if ~any(idx)
            continue;
        end

        query_time = data.sens_stamp(idx);

        for j = 1:sum(~isnan(data.x_map(idx,:)))
            % plot covariance ellipse
            mu = [data.x_map(idx,j); 
                  data.y_map(idx,j)];

            % rotazione yaw - per essere 'precisi' dovrei interpolare la yaw del veicolo al tempo della misura
            yaw = S.tt.yaw_map(i,j);
            if isnan(yaw)
                continue
            else
                R_vehicle_world = [cos(yaw), -sin(yaw);
                                   sin(yaw),  cos(yaw)];
            end

            noise_map = R_vehicle_world * noise * R_vehicle_world'
            [xe, ye] = covariance_ellipse(noise_map, mu, 1);  % ellisse 1-sigma
    
            patch(xe, ye, color, ...
                'FaceAlpha', 0.3, ...
                'EdgeColor', color, ...
                'LineWidth', 1, ...
                'HandleVisibility','off');
        end

        scatter(data.x_map(idx,:), data.y_map(idx,:), 'filled', ...
            'MarkerFaceColor', color, ...
            'MarkerEdgeColor', color, ...
            'DisplayName', name);
    end

    x = interp1(S.tt.stamp(:), S.tt.x_map, query_time);
    y = interp1(S.tt.stamp(:), S.tt.y_map, query_time);
    for j = 1:length(~isnan(x))
        if isnan(x(j)) || isnan(y(j))
            continue;
        end
        [xt, yt] = covariance_ellipse(diag([dist.^2, dist.^2]), [x(j); y(j)], 1);  % ellisse 1-sigma
        patch(xt, yt, col.tt, ...
            'FaceAlpha', 0.0, ...
            'EdgeColor', col.tt, ...
            'LineWidth', 1, ...
            'LineStyle', '--', ...
            'HandleVisibility','off');
        scatter(x(j), y(j), 'filled', 'MarkerFaceColor',col.tt, 'DisplayName','Track');
    end

    margin = 20;
    if ~isnan(S.tt.x_map(i,1)) && ~isnan(S.tt.y_map(i,1))
        xlim(S.ax, [min(S.tt.x_map(i,:))-margin max(S.tt.x_map(i,:))+margin]);
        ylim(S.ax, [min(S.tt.y_map(i,:))-margin max(S.tt.y_map(i,:))+margin]);
        axis(S.ax, 'manual');
    end

    % plot track lines
    id_left = length(traj_db) - 2;
    id_right = length(traj_db) - 1;
    plot(traj_db(id_left).X, traj_db(id_left).Y, 'color', 'k', 'LineWidth', 1, 'HandleVisibility','off');
    plot(traj_db(id_right).X, traj_db(id_right).Y, 'color', 'k', 'LineWidth', 1, 'HandleVisibility','off');

    txt = sprintf('sample %d / %d', i-S.iStart+1, S.iEnd-S.iStart+1);
    title(S.ax, ['map - ' txt]);
    hold(S.ax,'off');
end