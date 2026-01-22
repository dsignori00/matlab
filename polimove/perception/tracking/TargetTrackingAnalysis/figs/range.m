%% RANGE
figure('name', 'Filter - Range');
tiledlayout(3,1,'Padding','compact');

% rho 
axes(f) = nexttile([1,1]); f=f+1; hold on;
for i = 1:numel(sensors)
    s = sensors{i}.s;
    s.range = sqrt(s.x_rel.^2 + s.y_rel.^2);
    plotDetections(s.sens_stamp, s.range, s.max_det, sensors{i}.col, sensors{i}.name);
end

tt.range = sqrt(tt.x_rel.^2 + tt.y_rel.^2);
plotTT(tt.stamp, tt.range, tt.max_opp, col.tt, 'tt');

if(compare) 
    tt2.range = sqrt(tt2.x_rel.^2 + tt2.y_rel.^2);
    plotTT(tt2.stamp, tt2.range, tt2.max_opp, col.tt2, name2);
end

if(use_ref || use_sim_ref)
    if(use_sim_ref); gt.rho = sqrt(gt.x_rel.^2 + gt.y_rel.^2); end
    plot(gt.stamp, gt.rho, 'Color',col.ref,'DisplayName','Ground Truth'); 
end
grid on; ylabel('range [m]'); ylim([0 200]); legend show;

% rho dot
axes(f) = nexttile([1,1]); f=f+1; hold on;
plotDetections(rad_clust.sens_stamp, rad_clust.rho_dot, rad_clust.max_det, col.radar, 'Rad Clust');
plotTT(tt.stamp, tt.rho_dot, tt.max_opp, col.tt, 'tt');
if(compare); plotTT(tt2.stamp, tt2.rho_dot, tt2.max_opp, col.tt2, name2); end
if(use_ref || use_sim_ref); plot(gt.stamp, gt.rho_dot, 'Color',col.ref,'DisplayName','Ground Truth'); end
grid on; ylabel('rho dot [m/s]'); legend show;

% count
axes(f) = nexttile([1,1]); f=f+1; hold on;
plotArea(tt.stamp, log.perception__opponents.opponents__rad_clust_meas, tt.max_opp, col.radar,        'Rad Clust');
plotArea(tt.stamp, log.perception__opponents.opponents__lid_pp_meas,    tt.max_opp, col.pointpillars, 'Lid PP');
plotArea(tt.stamp, log.perception__opponents.opponents__lid_clust_meas, tt.max_opp, col.lidar,        'Lid Clust');
plotArea(tt.stamp, log.perception__opponents.opponents__cam_yolo_meas,  tt.max_opp, col.camera,       'Camera');
grid on; ylabel('Count'); legend show; xlabel('timestamp [s]');