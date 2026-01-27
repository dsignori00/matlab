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

if(use_ref || use_sim_ref)
    if(use_sim_ref); gt.rho = sqrt(gt.x_rel.^2 + gt.y_rel.^2); end
    plot(gt.stamp, gt.rho, 'Color',col.ref,'DisplayName','gt'); 
end
grid on; ylabel('range [m]'); ylim([0 200]); legend show;

% rho dot
ax(f) = nexttile([1,1]); f=f+1; hold on;
plot_detections(rad_clust.sens_stamp, rad_clust.rho_dot, rad_clust.max_det, col.radar, 'Rad Clust');
if(use_ref || use_sim_ref); plot(gt.stamp, gt.rho_dot, 'Color',col.ref,'DisplayName','gt'); end
grid on; ylabel('rho dot [m/s]'); legend show; ylim([-50 50]); xlabel('timestamp [s]');