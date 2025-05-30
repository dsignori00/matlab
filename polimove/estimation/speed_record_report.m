%% mc20 speed record run

mps2mph = 2.23694;

% DIRECTION north-south
t_end=518.957;
idx_traj_server_end=102468;
s_end=log.traj_server.closest_idx_ref(idx_traj_server_end);
idx_traj_server_start=102244;
t_start=517.8356;
idx_traj_server_km_start=100228;
t_km_start=log.traj_server.bag_stamp(idx_traj_server_km_start);

idx_est_start=102262;   % 100m
% idx_est_start=100246;   % 1km
idx_est_end=102487;

% new
idx_est_start=101876;   % 100m
idx_est_end=102099;

x_start=log.estimation.x_cog(idx_est_start);
y_start=log.estimation.y_cog(idx_est_start);
x_end=log.estimation.x_cog(idx_est_end);
y_end=log.estimation.y_cog(idx_est_end);

dist=sqrt((x_end-x_start)^2+(y_end-y_start)^2)

% idx_nov_left_start=10355;   % 100m
idx_nov_left_start=10152;   % 1km
idx_nov_left_end=10377;
% new
idx_nov_left_start=10316; % 100m
idx_nov_left_end=10338;


mean_left=sum(log.novatel_left__bestvel.hor_speed(idx_nov_left_start:idx_nov_left_end))/(idx_nov_left_end-idx_nov_left_start+1)
mean_right=sum(log.novatel_right__bestvel.hor_speed(idx_nov_left_start:idx_nov_left_end))/(idx_nov_left_end-idx_nov_left_start+1)
mean_tot=(mean_left+mean_right)/2

top_speed = (max(log.novatel_left__bestvel.hor_speed)+max(log.novatel_right__bestvel.hor_speed))/2


% DIRECTION south-north
t_end=932.156;
idx_traj_server_end=184311;
s_end=log.traj_server.closest_idx_ref(idx_traj_server_end);
idx_traj_server_start=184086;
t_start=log.traj_server.bag_stamp(idx_traj_server_start);
idx_traj_server_km_start=182039;
t_km_start=log.traj_server.bag_stamp(idx_traj_server_km_start);

idx_est_start=184110;   % 100m
idx_est_start=182063;   % 1km
idx_est_end=184335;

x_start=log.estimation.x_cog(idx_est_start);
y_start=log.estimation.y_cog(idx_est_start);
x_end=log.estimation.x_cog(idx_est_end);
y_end=log.estimation.y_cog(idx_est_end);

dist=sqrt((x_end-x_start)^2+(y_end-y_start)^2)

% idx_nov_left_start=18618;   % 100m
idx_nov_left_start=18412;   % 1km
idx_nov_left_end=18641;

mean_left=sum(log.novatel_left__bestvel.hor_speed(idx_nov_left_start:idx_nov_left_end))/(idx_nov_left_end-idx_nov_left_start+1)
mean_right=sum(log.novatel_right__bestvel.hor_speed(idx_nov_left_start:idx_nov_left_end))/(idx_nov_left_end-idx_nov_left_start+1)
mean_tot=(mean_left+mean_right)/2

top_speed = (87.62+87.6085)/2


%% Figures
figure;
tiledlayout(2,2);
nexttile;
hold on;
plot(log.novatel_left__bestvel.bag_stamp,log.novatel_left__bestvel.hor_speed*3.6, 'DisplayName','Sensor 1');
plot(log.novatel_right__bestvel.bag_stamp,log.novatel_right__bestvel.hor_speed*3.6, 'DisplayName','Sensor 2');
grid on;
% xregion(507.7, 518.957,'HandleVisibility','off','FaceColor','#c2e628')
xregion(515.885, 517.006,'HandleVisibility','off','FaceColor','#c2e628')
legend('Location','northwest');
xlabel('Time [s]');
ylabel('Speed [km/h]');
xlim([460, 530]);
title('Speed North-South')

nexttile(3);
hold on;
plot(log.novatel_left__bestvel.bag_stamp,log.novatel_left__bestvel.hor_speed*3.6, 'DisplayName','Sensor 1');
plot(log.novatel_right__bestvel.bag_stamp,log.novatel_right__bestvel.hor_speed*3.6, 'DisplayName','Sensor 2');
grid on;
% xregion(920.69, 932.156,'HandleVisibility','off','FaceColor','#c2e628')
xregion(931.02, 932.156,'HandleVisibility','off','FaceColor','#c2e628')
legend('Location','northwest');
xlabel('Time [s]');
ylabel('Speed [km/h]');
xlim([870, 940]);
title('Speed South-North')

nexttile(2,[2,1])
grid on
geoscatter(log.novatel_left__bestgnsspos.lat,log.novatel_left__bestgnsspos.lon,5,'filled','MarkerFaceColor','#0ecef8')
geobasemap satellite
title('Trajectory')

set(gcf,'Position',[100, 100, 1000, 600])

%%
figure;
hold on;
plot(log.novatel_left__bestvel.bag_stamp,log.novatel_left__bestvel.hor_speed*3.6, 'HandleVisibility','off');
plot(log.novatel_right__bestvel.bag_stamp,log.novatel_right__bestvel.hor_speed*3.6, 'HandleVisibility','off');
scatter(516.3,321.16,200,'pentagram','filled','h','DisplayName','Top Speed','MarkerFaceColor','#11cff5')
grid on;
xregion(515.885, 517.006,'HandleVisibility','off','FaceColor','#c2e628')
legend('Location','northwest');
xlabel('Time [s]');
ylabel('Speed [km/h]');
xlim([515, 518.5]);
ylim([319 323])
title('Top Speed North-South')

set(gcf,'Position',[100, 100, 600, 300])

%%
figure;
tiledlayout(1,2);
nexttile;
hold on;
plot(log.novatel_left__bestvel.bag_stamp,log.novatel_left__bestvel.hor_speed*3.6, 'HandleVisibility','off');
plot(log.novatel_right__bestvel.bag_stamp,log.novatel_right__bestvel.hor_speed*3.6, 'HandleVisibility','off');
grid on;
% xregion(507.7, 518.957,'HandleVisibility','off','FaceColor','#c2e628')
% xregion(517.84, 518.957,'HandleVisibility','off','FaceColor','#11cff5')
xregion(515.885, 517.006,'HandleVisibility','off','FaceColor','#c2e628')
% legend('Location','northwest');
xlabel('Time [s]');
ylabel('Speed [km/h]');
xlim([514, 518]);
ylim([312 323])
title('Speed North-South')

nexttile;
hold on;
plot(log.novatel_left__bestvel.bag_stamp,log.novatel_left__bestvel.hor_speed*3.6, 'HandleVisibility','off');
plot(log.novatel_right__bestvel.bag_stamp,log.novatel_right__bestvel.hor_speed*3.6, 'HandleVisibility','off');
grid on;
% xregion(920.69, 932.156,'HandleVisibility','off','FaceColor','#c2e628')
xregion(931.02, 932.156,'HandleVisibility','off','FaceColor','#c2e628')
% legend('Location','northwest');
xlabel('Time [s]');
ylabel('Speed [km/h]');
xlim([929, 933]);
ylim([312 323])
title('Speed South-North')

set(gcf,'Position',[100, 100, 900, 300])
