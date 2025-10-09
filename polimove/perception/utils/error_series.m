if(~show_error_series)
    return;
end

gat_thr = 10;
x_max = max([lid_clust.sens_stamp; rad_clust.sens_stamp; lid_pp.sens_stamp; cam_yolo.sens_stamp]);

% X MAP
figure('name','Error: x_map')
tiledlayout(4,1,'Padding','compact');

axes(f) = nexttile; f=f+1; hold on;
plot(linspace(0,x_max,100),zeros(100,1),'--','Color','k','LineWidth',0.3);
plot(lid_clust.sens_stamp,lid_clust.x_map_err,'*','Color',col.lidar);
grid on; title('lidar_clust_x_map [m]'); xlim([0 inf]); ylim([-gat_thr gat_thr]);

axes(f) = nexttile; f=f+1;nhold on;
plot(linspace(0,x_max,100),zeros(100,1),'--','Color','k','LineWidth',0.3);
plot(rad_clust.sens_stamp,rad_clust.x_map_err,'*','Color',col.radar);
grid on; title('radar_clust_x_map [m]'); xlim([0 inf]); ylim([-gat_thr gat_thr]);

axes(f) = nexttile; f=f+1; hold on;
plot(linspace(0,x_max,100),zeros(100,1),'--','Color','k','LineWidth',0.3);
plot(lid_pp.sens_stamp,lid_pp.x_map_err,'*','Color',col.pointpillars);
grid on; title('lidar_pp_x_map [m]'); xlim([0 inf]); ylim([-gat_thr gat_thr]);

axes(f) = nexttile; f=f+1; hold on;
plot(linspace(0,x_max,100),zeros(100,1),'--','Color','k','LineWidth',0.3);
plot(cam_yolo.sens_stamp,cam_yolo.x_map_err,'*','Color',col.camera);
grid on; title('camera_yolo_x_map [m]'); xlim([0 inf]); ylim([-gat_thr gat_thr]);

% Y 
figure('name','Error: y_map')
tiledlayout(4,1,'Padding','compact');

axes(f) = nexttile; f=f+1; hold on;
plot(linspace(0,x_max,100),zeros(100,1),'--','Color','k','LineWidth',0.3);
plot(lid_clust.sens_stamp,lid_clust.y_map_err,'*','Color',col.lidar);
grid on; title('lidar_clust_y_map [m]'); xlim([0 inf]); ylim([-gat_thr gat_thr])

axes(f) = nexttile; f=f+1; hold on;
plot(linspace(0,x_max,100),zeros(100,1),'--','Color','k','LineWidth',0.3);
plot(rad_clust.sens_stamp,rad_clust.y_map_err,'*','Color',col.radar);
grid on; title('radar_clust_y_map [m]'); xlim([0 inf]); ylim([-gat_thr gat_thr])

axes(f) = nexttile; f=f+1; hold on;
plot(linspace(0,x_max,100),zeros(100,1),'--','Color','k','LineWidth',0.3);
plot(lid_pp.sens_stamp,lid_pp.y_map_err,'*','Color',col.pointpillars);
grid on; title('lidar_pp_y_map [m]'); xlim([0 inf]); ylim([-gat_thr gat_thr])

axes(f) = nexttile; f=f+1; hold on;
plot(linspace(0,x_max,100),zeros(100,1),'--','Color','k','LineWidth',0.3);
plot(cam_yolo.sens_stamp,cam_yolo.y_map_err,'*','Color',col.camera);
grid on; title('camera_yolo_y_map [m]'); xlim([0 inf]); ylim([-gat_thr gat_thr])

% YAW MAP
figure('name','Error: yaw_map')
tiledlayout(4,1,'Padding','compact');

axes(f) = nexttile; f=f+1; hold on;
plot(linspace(0,x_max,100),zeros(100,1),'--','Color','k','LineWidth',0.3);
plot(lid_clust.sens_stamp,rad2deg(lid_clust.yaw_map_err),'*','Color',col.lidar);
grid on; title('lidar_clust_yaw_map [m]'); xlim([0 inf]); ylim([-10 10])

axes(f) = nexttile; f=f+1; hold on;
plot(linspace(0,x_max,100),zeros(100,1),'--','Color','k','LineWidth',0.3);
plot(rad_clust.sens_stamp,rad2deg(rad_clust.yaw_map_err),'*','Color',col.radar);
grid on; title('radar_clust_yaw_map [m]'); xlim([0 inf]); ylim([-10 10])

axes(f) = nexttile; f=f+1; hold on;
plot(linspace(0,x_max,100),zeros(100,1),'--','Color','k','LineWidth',0.3);
plot(lid_pp.sens_stamp,rad2deg(lid_pp.yaw_map_err),'*','Color',col.pointpillars);
grid on; title('lidar_pp_yaw_map [m]'); xlim([0 inf]); ylim([-10 10])

axes(f) = nexttile; f=f+1; hold on;
plot(linspace(0,x_max,100),zeros(100,1),'--','Color','k','LineWidth',0.3);
plot(cam_yolo.sens_stamp,rad2deg(cam_yolo.yaw_map_err),'*','Color',col.camera);
grid on; title('camera_yolo_yaw_map [m]'); xlim([0 inf]); ylim([-10 10])

