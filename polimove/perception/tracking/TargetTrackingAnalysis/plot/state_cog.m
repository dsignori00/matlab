%% STATE FIGURE REL
figure('name', 'Filter - CoG');
tiledlayout(3,1,'Padding','compact');

% pos x
axes(f) = nexttile([1,1]); f=f+1; hold on;
plot(lid_clust.sens_stamp,lid_clust.x_rel(:,1:lid_clust.max_det),'o','MarkerFaceColor',col.lidar,'MarkerEdgeColor',col.lidar,'MarkerSize',sz,'DisplayName','Lid Clust');
plot(rad_clust.sens_stamp,rad_clust.x_rel(:,1:rad_clust.max_det),'o','MarkerFaceColor',col.radar,'MarkerEdgeColor',col.radar,'MarkerSize',sz,'DisplayName','Rad Clust');
plot(cam_yolo.sens_stamp,cam_yolo.x_rel(:,1:cam_yolo.max_det),'o','MarkerFaceColor',col.camera,'MarkerEdgeColor',col.camera,'MarkerSize',sz,'DisplayName','Camera');
plot(lid_pp.sens_stamp,lid_pp.x_rel(:,1:lid_pp.max_det),'o','MarkerFaceColor',col.pointpillars,'MarkerEdgeColor',col.pointpillars,'MarkerSize',sz,'DisplayName','Lid PP');
plot(tt.stamp, tt.x_rel(:,1:tt.max_opp), 'Color',col.tt,'DisplayName','tt');
if(compare); plot(tt2.stamp, tt2.x_rel(:,1:tt2.max_opp), 'Color',col.tt2,'DisplayName',name2); end
if(use_ref || use_sim_ref); plot(gt.stamp, gt.x_rel, 'Color',col.ref,'DisplayName','Ground Truth'); end
grid on; ylabel('x rel [m]'); 

% pos y
axes(f) = nexttile([1,1]); f=f+1; hold on;
plot(lid_clust.sens_stamp,lid_clust.y_rel(:,1:lid_clust.max_det),'o','MarkerFaceColor',col.lidar,'MarkerEdgeColor',col.lidar,'MarkerSize',sz,'DisplayName','Lid Clust');
plot(rad_clust.sens_stamp,rad_clust.y_rel(:,1:rad_clust.max_det),'o','MarkerFaceColor',col.radar,'MarkerEdgeColor',col.radar,'MarkerSize',sz,'DisplayName','Rad Clust');
plot(cam_yolo.sens_stamp,cam_yolo.y_rel(:,1:cam_yolo.max_det),'o','MarkerFaceColor',col.camera,'MarkerEdgeColor',col.camera,'MarkerSize',sz,'DisplayName','Camera');
plot(lid_pp.sens_stamp,lid_pp.y_rel(:,1:lid_pp.max_det),'o','MarkerFaceColor',col.pointpillars,'MarkerEdgeColor',col.pointpillars,'MarkerSize',sz,'DisplayName','Lid PP');
plot(tt.stamp, tt.y_rel(:,1:tt.max_opp), 'Color',col.tt,'DisplayName','tt');
if(compare); plot(tt2.stamp, tt2.y_rel(:,1:tt2.max_opp), 'Color',col.tt2,'DisplayName',name2); end
if(use_ref || use_sim_ref); plot(gt.stamp, gt.y_rel, 'Color',col.ref,'DisplayName','Ground Truth'); end
grid on; ylabel('y rel [m]'); 

% rho dot
axes(f) = nexttile([1,1]); f=f+1; hold on;
plot(rad_clust.sens_stamp,rad_clust.rho_dot(:,1:tt.max_opp),'o','MarkerFaceColor',col.radar,'MarkerEdgeColor',col.radar,'MarkerSize',sz,'DisplayName','Rad Clust');
plot(tt.stamp, tt.rho_dot(:,1:tt.max_opp), 'Color',col.tt,'DisplayName','tt');
if(compare); plot(tt2.stamp, tt2.rho_dot(:,1:tt2.max_opp), 'Color',col.tt2,'DisplayName',name2); end
if(use_ref || use_sim_ref); plot(gt.stamp, gt.rho_dot, 'Color',col.ref,'DisplayName','Ground Truth'); end
grid on; ylabel('rho dot [m/s]'); 