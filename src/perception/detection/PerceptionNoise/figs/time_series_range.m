%% RANGE
figure('name', 'Series - Range');
tiledlayout(2,1,'Padding','compact');

% rho 
ax(f) = nexttile([1,1]); f=f+1; hold on;
for i = 1:numel(sensors)
    s = sensors{i}.s;
    s.range = sqrt(s.x_rel.^2 + s.y_rel.^2);
    plot_detections(s.sens_stamp, s.range, s.max_det, sensors{i}.col, sensors{i}.name);
end

if(use_sim_ref); gt.rho = sqrt(gt.x_rel.^2 + gt.y_rel.^2); end
plot(gt.stamp, gt.rho, 'Color',col.ref,'DisplayName','gt'); 
grid on; ylabel('range [m]'); ylim([0 200]); legend show;

% rho dot
ax(f) = nexttile([1,1]); f=f+1; hold on;
radarIdx = find(cellfun(@(sensor) sensor.has_rho_dot, sensors), 1);
if ~isempty(radarIdx)
    radar = sensors{radarIdx}.s;
    plot_detections(radar.sens_stamp, radar.rho_dot, radar.max_det, sensors{radarIdx}.col, sensors{radarIdx}.name);
end
plot(gt.stamp, gt.rho_dot, 'Color',col.ref,'DisplayName','gt')
grid on; ylabel('rho dot [m/s]'); legend show; ylim([-50 50]); xlabel('timestamp [s]');
