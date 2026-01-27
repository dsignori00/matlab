%% STATE FIGURE REL
figure('name', 'Series - CoG');
tiledlayout(3,1,'Padding','compact');

% pos x
ax(f) = nexttile([1,1]); f=f+1; hold on;
for i = 1:numel(sensors)
    s = sensors{i}.s;
    plot_detections(s.sens_stamp, s.x_rel, s.max_det, sensors{i}.col, sensors{i}.name);
end
if(use_ref || use_sim_ref); plot(gt.stamp, gt.x_rel, 'Color',col.ref,'DisplayName','gt'); end
grid on; ylabel('x rel [m]'); legend show;

% pos y
ax(f) = nexttile([1,1]); f=f+1; hold on;
for i = 1:numel(sensors)
    s = sensors{i}.s;
    plot_detections(s.sens_stamp, s.y_rel, s.max_det, sensors{i}.col, sensors{i}.name);
end
if(use_ref || use_sim_ref); plot(gt.stamp, gt.y_rel, 'Color',col.ref,'DisplayName','gt'); end
grid on; ylabel('y rel [m]'); legend show; ylim([-100 100]);

% count
ax(f) = nexttile([1,1]); f=f+1; hold on;
plot_area(tt.stamp, log.perception__opponents.opponents__rad_clust_meas, tt.max_opp, col.radar,        'Rad Clust');
plot_area(tt.stamp, log.perception__opponents.opponents__lid_pp_meas,    tt.max_opp, col.pp, 'Lid PP');
plot_area(tt.stamp, log.perception__opponents.opponents__lid_clust_meas, tt.max_opp, col.lidar,        'Lid Clust');
plot_area(tt.stamp, log.perception__opponents.opponents__cam_yolo_meas,  tt.max_opp, col.camera,       'Camera');
grid on; ylabel('count'); legend show; xlabel('timestamp [s]');
