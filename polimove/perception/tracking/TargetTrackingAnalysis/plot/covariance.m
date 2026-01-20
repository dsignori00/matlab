%% Covariance Analysis

% IDEAS:
% - only consider the first track
% - only plot associated measurements
% - usa bag simulate con bag reader: pubblico stato filtro dopo ciascuna misurazione 
%   (attenzione a effetto reprocessing -> vedi latenza, aggiungi campo a oppoenents)
% - plot covariance with shaded area (2 sigma) (vedi plot del cingo -> utile per analisi associazione misure)


% measurement matrices
R.lidar         = diag([0.7 0.7]);   % [m^2]
R.radar         = diag([1.5 2.0]);   % [m^2]
R.camera        = diag([10.0 10.0]); % [m^2]
R.pointpillars  = diag([0.7 0.7]);   % [m^2]

sensor_list = { ...
    'lidar',  SensorType.LIDAR_CLUSTERING,   col.lidar,        R.lidar;
    'radar',  SensorType.RADAR_CLUSTERING,   col.radar,        R.radar;
    'pp',     SensorType.LIDAR_POINTPILLARS, col.pointpillars, R.pointpillars;
    'camera', SensorType.CAMERA_YOLO,        col.camera,       R.camera
};


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
    sensor_points.(name) = interp1(tt.stamp, tt.covariance(:,1,1), stamp_vec(idx));

    plot(stamp_vec(idx), sensor_points.(name), 'o', ...
        'MarkerFaceColor', color, ...
        'MarkerEdgeColor', color, ...
        'MarkerSize', sz, ...
        'DisplayName', "R: " + num2str(noise(1,1)) + " - " + strrep(name,'_',' '));  
    hold on
end
plot(tt.stamp,tt.covariance(:,1, 1),'Color',col.tt,'DisplayName','Track');

if(compare)
    plot(tt2.stamp,tt2.covariance(:,1, 1),'Color',col.tt2,'DisplayName',name2);
end
grid on; ylabel('x map [m]'); ylim([0 5]); legend show;


axes(f) = nexttile([1,1]); f=f+1; hold on;
% --- Loop over each sensor type ---
for k = 1:size(sensor_list,1)
    name = sensor_list{k,1};
    type = sensor_list{k,2};
    color = sensor_list{k,3};
    noise = sensor_list{k,4};
    
    idx = (source_vec == type.Value);   % logical vector
    sensor_points.(name) = interp1(tt.stamp, tt.covariance(:,1,7), stamp_vec(idx));

    plot(stamp_vec(idx), sensor_points.(name), 'o', ...
        'MarkerFaceColor', color, ...
        'MarkerEdgeColor', color, ...
        'MarkerSize', sz, ...
        'DisplayName', "R: " + num2str(noise(2,2)) + " - " + strrep(name,'_',' '));  % nicer display
    hold on
end
plot(tt.stamp,tt.covariance(:,1, 7),'Color',col.tt,'DisplayName','Track');

if(compare)
    plot(tt2.stamp,tt2.covariance(:,1, 7),'Color',col.tt2,'DisplayName',name2);
end
grid on; ylabel('y map [m]'); ylim([0 5]); legend show;


% yaw
axes(f) = nexttile([1,1]); f=f+1; hold on;
% --- Loop over each sensor type ---
for k = 1:size(sensor_list,1)
    name = sensor_list{k,1};
    type = sensor_list{k,2};
    color = sensor_list{k,3};
    
    idx = (source_vec == type.Value);   % logical vector
    sensor_points.(name) = interp1(tt.stamp, tt.covariance(:,1,25), stamp_vec(idx));

    plot(stamp_vec(idx), sensor_points.(name), 'o', ...
        'MarkerFaceColor', color, ...
        'MarkerEdgeColor', color, ...
        'MarkerSize', sz, ...
        'DisplayName', strrep(name,'_',' '));  % nicer display
    hold on
end
plot(tt.stamp,tt.covariance(:,1, 25),'Color',col.tt,'DisplayName','Track');

if(compare)
    plot(tt2.stamp,tt2.covariance(:,1, 25),'Color',col.tt2,'DisplayName',name2);
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
    sensor_points.(name) = interp1(tt.stamp, tt.covariance(:,1,13), stamp_vec(idx));

    plot(stamp_vec(idx), sensor_points.(name), 'o', ...
        'MarkerFaceColor', color, ...
        'MarkerEdgeColor', color, ...
        'MarkerSize', sz, ...
        'DisplayName', strrep(name,'_',' '));  % nicer display
    hold on
end
plot(tt.stamp,tt.covariance(:,1, 13),'Color',col.tt,'DisplayName','Track');

if(compare)
    plot(tt2.stamp,tt2.covariance(:,1, 13),'Color',col.tt2,'DisplayName',name2);
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
    sensor_points.(name) = interp1(tt.stamp, tt.covariance(:,1,19), stamp_vec(idx));

    plot(stamp_vec(idx), sensor_points.(name), 'o', ...
        'MarkerFaceColor', color, ...
        'MarkerEdgeColor', color, ...
        'MarkerSize', sz, ...
        'DisplayName', strrep(name,'_',' '));  % nicer display
    hold on
end
plot(tt.stamp,tt.covariance(:,1, 19),'Color',col.tt,'DisplayName','Track');

if(compare)
    plot(tt2.stamp,tt2.covariance(:,1, 19),'Color',col.tt2,'DisplayName',name2);
end
grid on; ylabel('acc [m/s$^2$]'); legend show;