%% DETECTIONS - FOV


[cam_x_fov,cam_y_fov]  = compute_fov(35,0);
[lid_x_fov,lid_y_fov]  = compute_fov(10,179);
[rad_x_fov,rad_y_fov]  = compute_fov(80,0);

[x_25m, y_25m] = calculate_ellipse(25,25,0,0); 
[x_50m, y_50m] = calculate_ellipse(50,50,0,0); 
[x_75m, y_75m] = calculate_ellipse(75,75,0,0); 
[x_100m, y_100m] = calculate_ellipse(100,100,0,0); 

figure('Name','Detections - FoV')
subplot(1,2,1)
ax1 = gca;
hold on;

%Lidar
plot(lid_pp.y_rel,lid_pp.x_rel,'*','Color',col.pointpillars,'DisplayName','Lidar PP')
plot(lid_clust.y_rel,lid_clust.x_rel,'*','Color',col.lidar,'DisplayName','Lidar Clust')
plot(lid_y_fov,lid_x_fov,'-','LineWidth',0.5,'Color',col.lidar,'HandleVisibility','off')

%Radar
plot(rad_clust.y_rel,rad_clust.x_rel,'*','Color',col.radar,'DisplayName','Radar Clust')
plot(rad_y_fov,rad_x_fov,'-','LineWidth',0.5,'Color',col.radar,'HandleVisibility','off')

%Camera
plot(cam_yolo.y_rel,cam_yolo.x_rel,'*','Color',col.camera,'DisplayName','Camera Yolo')
plot(cam_y_fov,cam_x_fov,'-','LineWidth',0.3,'Color',col.camera,'HandleVisibility','off')
plot(cam_y_fov,-cam_x_fov,'-','LineWidth',0.3,'Color',col.camera,'HandleVisibility','off')

plot(x_25m,y_25m,'--','LineWidth',0.3,'Color',[0.5 0.5 0.5],'HandleVisibility','off')
plot(x_50m,y_50m,'--','LineWidth',0.3,'Color',[0.5 0.5 0.5],'HandleVisibility','off')
plot(x_75m,y_75m,'--','LineWidth',0.3,'Color',[0.5 0.5 0.5],'HandleVisibility','off')
plot(x_100m,y_100m,'--','LineWidth',0.3,'Color',[0.5 0.5 0.5],'HandleVisibility','off')
plot(0,0,'d','Color','default','LineWidth',1,'DisplayName','Ego','MarkerSize',10)
ylabel('X [m]')
xlabel('Y [m]')
legend('Location','northwest')
grid on;
axis equal
ylim([-20 100])
xlim([-50 50])
title('Field of View')

subplot(1,2,2)
ax2 = gca;
hold on

% Camera
camera_err = sqrt(cam_yolo.x_map_err.^2+cam_yolo.y_map_err.^2);
scatter(cam_yolo.y_rel,cam_yolo.x_rel,[],camera_err,'filled','o','DisplayName','Camera Yolo')

% Lidar
lid_err = sqrt(lid_clust.x_map_err.^2+lid_clust.y_map_err.^2);
scatter(lid_clust.y_rel,lid_clust.x_rel,[],lid_err,'filled','square','DisplayName','Lid Clust')
pp_err = sqrt(lid_pp.x_map_err.^2+lid_pp.y_map_err.^2);
scatter(lid_pp.y_rel,lid_pp.x_rel,[],pp_err,'filled','^','DisplayName','Lid PP')

% Radar
rad_err = sqrt(rad_clust.x_map_err.^2+rad_clust.y_map_err.^2);
scatter(rad_clust.y_rel,rad_clust.x_rel,[],rad_err,'filled','diamond','DisplayName','Rad Clust')

plot(x_25m,y_25m,'--','LineWidth',0.3,'Color',[0.5 0.5 0.5],'HandleVisibility','off')
plot(x_50m,y_50m,'--','LineWidth',0.3,'Color',[0.5 0.5 0.5],'HandleVisibility','off')
plot(x_75m,y_75m,'--','LineWidth',0.3,'Color',[0.5 0.5 0.5],'HandleVisibility','off')
plot(x_100m,y_100m,'--','LineWidth',0.3,'Color',[0.5 0.5 0.5],'HandleVisibility','off')
plot(0,0,'d','Color','default','LineWidth',1,'DisplayName','Ego','MarkerSize',10)
ylabel('X [m]')
xlabel('Y [m]')
colorbar('Location','east')
legend('Location','northwest')
grid on;
axis equal
ylim([-20 100])
xlim([-50 50])
clim([0 3])
title('Detection Error')

linkaxes([ax1,ax2],'xy')