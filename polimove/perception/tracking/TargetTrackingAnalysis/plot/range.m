%% RANGE
figure('name', 'Filter - Range');
tiledlayout(3,1,'Padding','compact');

% rho 
axes(f) = nexttile([1,1]); f=f+1; hold on;
plot(lid_clust.sens_stamp,lid_clust.range(:,1:lid_clust.max_det),'o','MarkerFaceColor',col.lidar,'MarkerEdgeColor',col.lidar,'MarkerSize',sz,'DisplayName','Lid Clust');
plot(rad_clust.sens_stamp,rad_clust.range(:,1:rad_clust.max_det),'o','MarkerFaceColor',col.radar,'MarkerEdgeColor',col.radar,'MarkerSize',sz,'DisplayName','Rad Clust');
plot(cam_yolo.sens_stamp,cam_yolo.range(:,1:cam_yolo.max_det),'o','MarkerFaceColor',col.camera,'MarkerEdgeColor',col.camera,'MarkerSize',sz,'DisplayName','Camera');
plot(lid_pp.sens_stamp,lid_pp.range(:,1:lid_pp.max_det),'o','MarkerFaceColor',col.pointpillars,'MarkerEdgeColor',col.pointpillars,'MarkerSize',sz,'DisplayName','Lid PP');
plot(tt.stamp, tt.range(:,1:tt.max_opp), 'Color',col.tt,'DisplayName','tt');
if(compare); plot(tt2.stamp, tt2.range(:,1:tt2.max_opp), 'Color',col.tt2,'DisplayName',name2); end
if(use_ref || use_sim_ref)
    if(use_sim_ref); gt.rho = sqrt(gt.x_rel.^2 + gt.y_rel.^2); end
    plot(gt.stamp, gt.rho, 'Color',col.ref,'DisplayName','Ground Truth'); 
end
grid on; ylabel('range [m]'); ylim([0 200]);

% rho dot
axes(f) = nexttile([1,1]); f=f+1; hold on;
plot(rad_clust.sens_stamp,rad_clust.rho_dot(:,1:rad_clust.max_det),'o','MarkerFaceColor',col.radar,'MarkerEdgeColor',col.radar,'MarkerSize',sz,'DisplayName','Rad Clust');
plot(tt.stamp, tt.rho_dot(:,1:tt.max_opp), 'Color',col.tt,'DisplayName','tt');
if(compare); plot(tt2.stamp, tt2.rho_dot(:,1:tt2.max_opp), 'Color',col.tt2,'DisplayName',name2); end
if(use_ref || use_sim_ref); plot(gt.stamp, gt.rho_dot, 'Color',col.ref,'DisplayName','Ground Truth'); end
grid on; ylabel('rho dot [m/s]'); 

% count
axes(f) = nexttile([1,1]); f=f+1; hold on;
area(tt.stamp,log.perception__opponents.opponents__rad_clust_meas(:,1:tt.max_opp),'FaceColor',col.radar,'EdgeColor',col.radar,'DisplayName','Rad Clust');
area(tt.stamp,log.perception__opponents.opponents__lid_pp_meas(:,1:tt.max_opp),'FaceColor',col.pointpillars,'EdgeColor',col.pointpillars,'DisplayName','Lid PP');
area(tt.stamp,log.perception__opponents.opponents__lid_clust_meas(:,1:tt.max_opp),'FaceColor',col.lidar,'EdgeColor',col.lidar,'DisplayName','Lid Clust');
area(tt.stamp,log.perception__opponents.opponents__cam_yolo_meas(:,1:tt.max_opp),'FaceColor',col.camera,'EdgeColor',col.camera,'DisplayName','Camera');
grid on; ylabel('Count'); 