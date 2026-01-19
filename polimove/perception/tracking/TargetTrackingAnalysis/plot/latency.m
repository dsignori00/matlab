%% LATENCY FIGURE
figure('name','Latency')
tiledlayout(4,1,'Padding','compact');

axes(f) = nexttile; f=f+1; hold on;
plot(lid_clust.stamp,lid_clust.stamp - lid_clust.sens_stamp);
grid on; ylabel('lidar clust [s]')

axes(f) = nexttile; f=f+1; hold on;
plot(rad_clust.stamp, rad_clust.stamp - rad_clust.sens_stamp);
grid on; ylabel('radar clust [s]')

axes(f) = nexttile; f=f+1; hold on;
plot(cam_yolo.stamp,cam_yolo.stamp - cam_yolo.sens_stamp);
grid on; ylabel('camera yolo [s]')

axes(f) = nexttile; f=f+1; hold on;
plot(lid_pp.stamp,lid_pp.stamp - lid_pp.sens_stamp);
grid on; ylabel('lidar pp [s]')