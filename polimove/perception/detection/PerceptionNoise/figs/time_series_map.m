%% STATE FIGURE MAP
figure('name', 'Series - Map');
tiledlayout(3,1,'Padding','compact');

% pos x
ax(f) = nexttile([1,1]); f=f+1; hold on;
for i = 1:numel(sensors)
    s = sensors{i}.s;
    plot_detections(s.sens_stamp, s.x_map, s.max_det, sensors{i}.col, sensors{i}.name);
end
if(use_ref || use_sim_ref); plot(gt.stamp,gt.x_map,'Color',col.ref,'DisplayName','gt'); end
grid on; ylabel('x map [m]'); legend show;

% pos y
ax(f) = nexttile([1,1]); f=f+1; hold on;
for i = 1:numel(sensors)
    s = sensors{i}.s;
    plot_detections(s.sens_stamp, s.y_map, s.max_det, sensors{i}.col, sensors{i}.name);
end

if(use_ref || use_sim_ref); plot(gt.stamp,gt.y_map,'Color',col.ref,'DisplayName','gt'); end
grid on; ylabel('y map [m]'); legend show;

% yaw
ax(f) = nexttile([1,1]); f=f+1; hold on;
for i = 1:numel(sensors)
    s = sensors{i}.s;
    plot_detections(s.sens_stamp, s.yaw_map, s.max_det, sensors{i}.col, sensors{i}.name);
end
if(use_ref || use_sim_ref); plot(gt.stamp,gt.yaw_map,'Color',col.ref,'DisplayName','gt'); end
grid on; ylabel('yaw [rad]'); legend show; xlabel('timestamp [s]');
