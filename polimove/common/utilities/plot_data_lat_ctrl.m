function plot_data_lat_ctrl(data)
%% Time 
MPS2MPH=3.6/1.6;
kt=1;

%% Lateral signals in time
% speed - yaw rate - steer 
figure, set(gcf, 'Color', 'White')
spt(kt)=subplot(3,1,1);
kt=kt+1;
hold on
ylabel('vx [mph]')
plot(data.time, MPS2MPH*data.long_vel_ref, 'LineWidth',1.5,'color','r', 'DisplayName','v ref')
plot(data.time, MPS2MPH*data.vx_hat, 'LineWidth',1.5,'color','b', 'DisplayName','v hat')
legend show
    
spt(kt)=subplot(3,1,2);
kt=kt+1;
hold on
ylabel('yaw rate [deg/s]')
plot(data.time, rad2deg(data.omega_z_hat), 'LineWidth',1.5,'color','b', 'DisplayName','yaw rate hat')
plot(data.time, rad2deg(data.yaw_rate_ref), 'LineWidth',1.5,'color','r', 'DisplayName','yaw rate ref')
legend show

spt(kt)=subplot(3,1,3);
kt=kt+1;
hold on
ylabel('steer at the wheel [deg]')
xlabel('time [s]')
%plot(data.time, rad2deg(data.steer_angle_command_LEC), 'LineWidth',1.5,'color','c', 'DisplayName','steer LEC')
%plot(data.time, rad2deg(data.steer_angle_command_YRC),'LineWidth',1.5,'color','g', 'DisplayName','steer YRC')
plot(data.time, rad2deg(data.delta_sw./19.5),'LineWidth',1.5,'color','b', 'DisplayName','vehicle fbk steer')
plot(data.time, rad2deg(data.steer_angle_command_tot), 'LineWidth',1.5,'color','r', 'DisplayName','steer ctrl cmd')
legend show

linkaxes(spt,'x');


% speed - e lat - steer
figure, set(gcf, 'Color', 'White')
spt(kt)=subplot(3,1,1);
kt=kt+1;
hold on
ylabel('vx [mph]')
plot(data.time, MPS2MPH*data.long_vel_ref, 'LineWidth',1.5,'color','r', 'DisplayName','v ref')
plot(data.time, MPS2MPH*data.vx_hat, 'LineWidth',1.5,'color','b', 'DisplayName','v hat')
legend show
    
spt(kt)=subplot(3,1,2);
kt=kt+1;
hold on
ylabel('lateral error [m]')
xlabel('time [s]')
plot(data.time, data.e_lat, 'LineWidth',1.5,'color','r', 'DisplayName','e lat')
legend show
    
spt(kt)=subplot(3,1,3);
kt=kt+1;
hold on
ylabel('steer [deg]')
xlabel('time [s]')
%plot(data.time, rad2deg(data.steer_angle_command_LEC), 'LineWidth',1.5,'color','c', 'DisplayName','steer LEC')
%plot(data.time, rad2deg(data.steer_angle_command_YRC),'LineWidth',1.5,'color','g', 'DisplayName','steer YRC')
plot(data.time, rad2deg(data.delta_sw./19.5), 'LineWidth',1.5,'color','b', 'DisplayName','vehicle fbk steer')
plot(data.time, rad2deg(data.steer_angle_command_tot), 'LineWidth',1.5,'color','r', 'DisplayName','steer ctrl cmd')
legend show

linkaxes(spt,'x');

%% Space 
ks=1;

% speed -steer
figure, set(gcf, 'Color', 'White')
sps(ks)=subplot(2,1,1);
ks=ks+1;
hold on
ylabel('vx [mph]')
scatter3(data.track_idx*0.5,MPS2MPH*data.vx_hat,data.time,[],data.lap_count,'.')

sps(ks)=subplot(2,1,2);
ks=ks+1;
hold on
ylabel('steer [deg]'), xlabel('s [m]'),
scatter3(data.track_idx*0.5,rad2deg(data.steer_angle_command_tot),data.time,[],data.lap_count,'.')

linkaxes(sps,'x');


figure, set(gcf, 'Color', 'White')   
sps(ks)=subplot(4,1,1);
ks=ks+1;
hold on
ylabel('vx [mph]')
scatter3(data.track_idx*0.5,MPS2MPH*data.vx_hat,data.time,[],data.lap_count,'.')

sps(ks)=subplot(4,1,2);
ks=ks+1;
hold on
ylabel('e lat [m]')
scatter3(data.track_idx*0.5,rad2deg(data.steer_angle_command_tot),data.time,[],data.lap_count,'.')

sps(ks)=subplot(4,1,3);
ks=ks+1;
hold on
ylabel('yaw rate ref [deg/s]')
xlabel('idx')
scatter3(data.track_idx*0.5,data.e_lat,data.time,[],data.lap_count,'.')

sps(ks)=subplot(4,1,4);
ks=ks+1;
hold on
ylabel('yaw rate hat [deg/s]')
xlabel('s [m]')
scatter3(data.track_idx*0.5,rad2deg(data.omega_z_hat),data.time,[],data.lap_count,'.')

linkaxes(sps,'x');


end