figure("Name","Error - Summary")
subplot(2,2,[1 3]); hold on;
plot(lid_clust.y_ellipse,lid_clust.x_ellipse, 'Color',col.lidar,"DisplayName","Lidar Clustering","HandleVisibility","on",'LineWidth',2)
plot(rad_clust.y_ellipse,rad_clust.x_ellipse, 'Color',col.radar,"DisplayName","Radar Clustering","HandleVisibility","on",'LineWidth',2)
plot(lid_pp.y_ellipse,lid_pp.x_ellipse, 'Color',col.pointpillars,"DisplayName","Lidar Pointpillars","HandleVisibility","on",'LineWidth',2)
plot(cam_yolo.y_ellipse,cam_yolo.x_ellipse, 'Color',col.camera,"DisplayName","Camera Yolo","HandleVisibility","on",'LineWidth',2)
scatter(lid_clust.y_rel_mean, lid_clust.x_rel_mean,'o','MarkerFaceColor',col.lidar,'HandleVisibility','off')
scatter(rad_clust.y_rel_mean, rad_clust.x_rel_mean,'o','MarkerFaceColor',col.radar,'HandleVisibility','off')
scatter(lid_pp.y_rel_mean, lid_pp.x_rel_mean,'o','MarkerFaceColor',col.pointpillars,'HandleVisibility','off')
scatter(cam_yolo.y_rel_mean, cam_yolo.x_rel_mean,'o','MarkerFaceColor',col.camera,'MarkerEdgeColor',col.camera,'HandleVisibility','off')
xline(0,'--','LineWidth',0.3,"HandleVisibility","off")
yline(0,'--','LineWidth',0.3,"HandleVisibility","off")
title('Positional Errors'); axis equal; grid on; legend
xlabel('Y Rel [m]'); ylabel('X Rel [m]'); 

% Rho Dot Error
subplot(2,2,2); hold on;
boxplot(rad_clust.rho_dot_err,'Symbol','','Orientation','horizontal');
xline(0,'--','LineWidth',0.3,"HandleVisibility","off")
title('Range rate Error'); xlabel('[m/s]'); ylim([0.8 1.2]); xlim([-rad_clust.rho_dot_std rad_clust.rho_dot_std]);

% Heading Error
YawMaxStd = rad2deg(max([lid_clust.yaw_map_std,rad_clust.yaw_map_std,lid_pp.yaw_map_std,cam_yolo.yaw_map_std]));
error = rad2deg([lid_clust.yaw_map_err; rad_clust.yaw_map_err; lid_pp.yaw_map_err; cam_yolo.yaw_map_err]);
g1 = repmat({'Lid Clust'},length(lid_clust.yaw_map_err),1);
g2 = repmat({'Rad Clust'},length(rad_clust.yaw_map_err),1);
g3 = repmat({'Lid Pp'},length(lid_pp.yaw_map_err),1);
g4 = repmat({'Cam yolo'},length(cam_yolo.yaw_map_err),1);
g = [g1; g2; g3;g4];

subplot(2,2,4); hold on
boxplot(error,g,'Symbol','')
yline(0,'--','LineWidth',0.3,"HandleVisibility","off")
title('Heading Error'); ylabel('[deg]'); ylim([-2*YawMaxStd, 2*YawMaxStd])