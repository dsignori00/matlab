%% STATE FIGURE MAP
figure('name', 'Filter - Map');
tiledlayout(2,1,'Padding','compact');

% pos x
axes(f) = nexttile([1,1]); f=f+1; hold on;
plot(lid_clust.sens_stamp,lid_clust.x_map(:,1:lid_clust.max_det),'o','MarkerFaceColor',col.lidar,'MarkerEdgeColor',col.lidar,'MarkerSize',sz,'DisplayName','Lid Clust');
plot(rad_clust.sens_stamp,rad_clust.x_map(:,1:rad_clust.max_det),'o','MarkerFaceColor',col.radar,'MarkerEdgeColor',col.radar,'MarkerSize',sz,'DisplayName','Rad Clust');
plot(cam_yolo.sens_stamp,cam_yolo.x_map(:,1:cam_yolo.max_det),'o','MarkerFaceColor',col.camera,'MarkerEdgeColor',col.camera,'MarkerSize',sz,'DisplayName','Camera');
plot(lid_pp.sens_stamp,lid_pp.x_map(:,1:lid_pp.max_det),'o','MarkerFaceColor',col.pointpillars,'MarkerEdgeColor',col.pointpillars,'MarkerSize',sz,'DisplayName','Lid PP');
plot(tt.stamp,tt.x_map(:,1:tt.max_opp),'Color',col.tt,'DisplayName','tt');
if(compare); plot(tt2.stamp,tt2.x_map(:,1:tt2.max_opp),'Color',col.tt2,'DisplayName',name2); end
if(use_ref || use_sim_ref); plot(gt.stamp,gt.x_map,'Color',col.ref,'DisplayName','Ground Truth'); end
grid on; ylabel('x map [m]'); 

% pos y
axes(f) = nexttile([1,1]); f=f+1; hold on;
plot(lid_clust.sens_stamp,lid_clust.y_map(:,1:lid_clust.max_det),'o','MarkerFaceColor',col.lidar,'MarkerEdgeColor',col.lidar,'MarkerSize',sz,'DisplayName','Lid Clust');
plot(rad_clust.sens_stamp,rad_clust.y_map(:,1:rad_clust.max_det),'o','MarkerFaceColor',col.radar,'MarkerEdgeColor',col.radar,'MarkerSize',sz,'DisplayName','Rad Clust');
plot(cam_yolo.sens_stamp,cam_yolo.y_map(:,1:cam_yolo.max_det),'o','MarkerFaceColor',col.camera,'MarkerEdgeColor',col.camera,'MarkerSize',sz,'DisplayName','Camera');
plot(lid_pp.sens_stamp,lid_pp.y_map(:,1:lid_pp.max_det),'o','MarkerFaceColor',col.pointpillars,'MarkerEdgeColor',col.pointpillars,'MarkerSize',sz,'DisplayName','Lid PP');
plot(tt.stamp,tt.y_map(:,1:tt.max_opp),'Color',col.tt,'DisplayName','tt');
if(compare); plot(tt2.stamp,tt2.y_map(:,1:tt2.max_opp),'Color',col.tt2,'DisplayName',name2); end
if(use_ref || use_sim_ref); plot(gt.stamp,gt.y_map,'Color',col.ref,'DisplayName','Ground Truth'); end
grid on; ylabel('y map [m]'); 

%% YAW
figure('name', 'Filter - Yaw');

% yaw
lid_clust.yaw_map = mod(lid_clust.yaw_map,2*pi);
cam_yolo.yaw_map = mod(cam_yolo.yaw_map,2*pi);
rad_clust.yaw_map = mod(rad_clust.yaw_map,2*pi);
lid_pp.yaw_map = mod(lid_pp.yaw_map,2*pi);
tt.yaw_map = mod(tt.yaw_map,2*pi);
if(compare); tt2.yaw_map = mod(tt2.yaw_map,2*pi); end

axes(f) = nexttile([1,1]); f=f+1; hold on;
plot(lid_clust.sens_stamp,lid_clust.yaw_map(:,1:lid_clust.max_det),'o','MarkerFaceColor',col.lidar,'MarkerEdgeColor',col.lidar,'MarkerSize',sz,'DisplayName','Lid Clust');
plot(rad_clust.sens_stamp,rad_clust.yaw_map(:,1:rad_clust.max_det),'o','MarkerFaceColor',col.radar,'MarkerEdgeColor',col.radar,'MarkerSize',sz,'DisplayName','Rad Clust');
plot(cam_yolo.sens_stamp,cam_yolo.yaw_map(:,1:cam_yolo.max_det),'o','MarkerFaceColor',col.camera,'MarkerEdgeColor',col.camera,'MarkerSize',sz,'DisplayName','Camera');
plot(lid_pp.sens_stamp,lid_pp.yaw_map(:,1:lid_pp.max_det),'o','MarkerFaceColor',col.pointpillars,'MarkerEdgeColor',col.pointpillars,'MarkerSize',sz,'DisplayName','Lidar PP');
plot(tt.stamp,tt.yaw_map(:,1:tt.max_opp),'Color',col.tt,'DisplayName','tt');
if(compare); plot(tt2.stamp,tt2.yaw_map(:,1:tt2.max_opp),'Color',col.tt2,'DisplayName','tt'); end
if(use_ref || use_sim_ref)
    gt.yaw_map = mod(gt.yaw_map,2*pi);
    plot(gt.stamp,gt.yaw_map,'Color',col.ref,'DisplayName','Ground Truth');
end
grid on; ylabel('yaw [rad]'); 