%% STATE FIGURE MAP
figure('name', 'Filter - Map');
tiledlayout(3,1,'Padding','compact');

% pos x
axes(f) = nexttile([1,1]); f=f+1; hold on;
for i = 1:numel(sensors)
    s = sensors{i}.s;
    plot_detections(s.sens_stamp, s.x_map, s.max_det, sensors{i}.col, sensors{i}.name);
end
plot_tt(tt.stamp, tt.x_map, tt.max_opp, col.tt, 'tt');
if(compare); plot_tt(tt2.stamp, tt2.x_map, tt2.max_opp, col.tt2, name2); end
if(use_ref || use_sim_ref); plot(gt.stamp,gt.x_map,'Color',col.ref,'DisplayName','gt'); end
grid on; ylabel('x map [m]'); legend show;

% pos y
axes(f) = nexttile([1,1]); f=f+1; hold on;
for i = 1:numel(sensors)
    s = sensors{i}.s;
    plot_detections(s.sens_stamp, s.y_map, s.max_det, sensors{i}.col, sensors{i}.name);
end

plot_tt(tt.stamp, tt.y_map, tt.max_opp, col.tt, 'tt');
if(compare); plot_tt(tt2.stamp, tt2.y_map, tt2.max_opp, col.tt2, name2); end
if(use_ref || use_sim_ref); plot(gt.stamp,gt.y_map,'Color',col.ref,'DisplayName','gt'); end
grid on; ylabel('y map [m]'); legend show;

% yaw
axes(f) = nexttile([1,1]); f=f+1; hold on;
for i = 1:numel(sensors)
    s = sensors{i}.s;
    s.yaw_map = mod(s.yaw_map,2*pi);
    plot_detections(s.sens_stamp, s.yaw_map, s.max_det, sensors{i}.col, sensors{i}.name);
end
    
tt.yaw_map = mod(tt.yaw_map,2*pi);
plot_tt(tt.stamp, tt.yaw_map, tt.max_opp, col.tt, 'tt');

if(compare)
    tt2.yaw_map = mod(tt2.yaw_map,2*pi);
    plot_tt(tt2.stamp, tt2.yaw_map, tt2.max_opp, col.tt2, name2);
end

if(use_ref || use_sim_ref)
    gt.yaw_map = mod(gt.yaw_map,2*pi);
    plot(gt.stamp,gt.yaw_map,'Color',col.ref,'DisplayName','gt');
end
grid on; ylabel('yaw [rad]'); xlabel('timestamp [s]'); legend show;