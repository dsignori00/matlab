clc
close all
% clear all
clearvars -except log log_gt

addpath("00_func/")
dock_figures on;

set_default_figures_settings('latex')

%% Load Data
% load log
if (~exist('log','var'))
    [file,path] = uigetfile('*.mat','Load log');
    load(fullfile(path,file));
end

lla0 = [24.4680843 54.6047064 182.9];


%%
% Loc
loc.time = log.estimation__stamp__tot;
loc.x= log.estimation__x_cog;
loc.y = log.estimation__y_cog;
loc.vx = log.estimation__vx;
loc.vy = log.estimation__vy;
loc.heading = log.estimation__heading;
loc.ax = log.estimation__ax;
loc.ay = log.estimation__ay;
loc.yaw_rate = log.estimation__yaw_rate;
loc.s(1) = 0;
loc.sx(1)=0;
loc.sy(1)=0;
for i=2:height(loc.time)
    dt = loc.time(i) - loc.time(i-1);
    d_s=distanza_pp([loc.x(i),loc.y(i)],[loc.x(i-1),loc.y(i-1)]);
    loc.s(i,1) = loc.s(i-1) + d_s;
    a=loc.heading(i)-loc.heading(i-1);
    loc.sx(i,1) = loc.sx(i-1) + abs(d_s*cos(a));
    loc.sy(i,1) = loc.sy(i-1) + abs(d_s*sin(a));
end
loc.status = log.estimation__status__type;

% Recompute odometry with radii and omega wheel ekf
start_index = 1;
odom_ekf.time  = loc.time(start_index:end);
odom_ekf.x(1,1)   = loc.x(start_index);
odom_ekf.y(1,1)   = loc.y(start_index);
odom_ekf.heading(1,1) = loc.heading(start_index);
odom_ekf.vx = loc.vx(start_index:end);
odom_ekf.omega = loc.yaw_rate(start_index:end);
odom_ekf.vy = loc.vy(start_index:end);
odom_ekf.s(1) = 0;
for i=2:height(odom_ekf.time)
    dt = odom_ekf.time(i) - odom_ekf.time(i-1);
    odom_ekf.heading(i,1) = odom_ekf.heading(i-1) + odom_ekf.omega(i-1)*dt;
    odom_ekf.x(i,1) = odom_ekf.x(i-1) + odom_ekf.vx(i)*cos(odom_ekf.heading(i-1))*dt - odom_ekf.vy(i)*sin(odom_ekf.heading(i-1))*dt;
    odom_ekf.y(i,1) = odom_ekf.y(i-1) + odom_ekf.vx(i)*sin(odom_ekf.heading(i-1))*dt + odom_ekf.vy(i)*cos(odom_ekf.heading(i-1))*dt;
    d_s=distanza_pp([odom_ekf.x(i),odom_ekf.y(i)],[odom_ekf.x(i-1),odom_ekf.y(i-1)]);
    odom_ekf.s(i,1) = odom_ekf.s(i-1) + d_s;
end

v_from_acc.time = loc.time(start_index:end);
v_from_acc.ax = loc.ax(start_index:end);
v_from_acc.ay = loc.ay(start_index:end);
v_from_acc.yaw_rate = loc.yaw_rate(start_index:end);
v_from_acc.vx(1,1) = loc.vx(start_index);
v_from_acc.vy(1,1) = loc.vy(start_index);
for i=2:height(v_from_acc.time)
    dt = v_from_acc.time(i) - v_from_acc.time(i-1);
    v_from_acc.vx(i)=v_from_acc.vx(i-1)+v_from_acc.ax(i)*dt-loc.vy(start_index+i-1)*v_from_acc.yaw_rate(i)*dt;
    v_from_acc.vy(i)=v_from_acc.vy(i-1)+v_from_acc.ay(i)*dt+loc.vx(start_index+i-1)*v_from_acc.yaw_rate(i)*dt;
end

% GPS
gps.time = loc.time;
gps.x = log.estimation__gps_pos_report__x(:,1);
gps.y = log.estimation__gps_pos_report__y(:,1);
gps.s(1) = 0;
for i=2:height(gps.time)
    dt = gps.time(i) - gps.time(i-1);
    d_s=distanza_pp([gps.x(i),gps.y(i)],[gps.x(i-1),gps.y(i-1)]);
    gps.s(i,1) = gps.s(i-1) + d_s;
end
gps.status = log.estimation__gps_pos_report__unit_status__type(:,1);

gps_hd.time = loc.time;
gps_hd.heading = log.estimation__gps_hd2_report__heading(:,1);
gps_hd.status = log.estimation__gps_hd2_report__unit_status__type(:,1);
gps.error_lat =  log.estimation__gps_pos_report__dy(:,1);
gps.error_lon =  log.estimation__gps_pos_report__dy(:,1);
gps.is_new = log.estimation__gps_pos_report__new_meas;

lidar_loc.time = loc.time;
lidar_loc.x= log.estimation__lidar_loc_report__x;
lidar_loc.y = log.estimation__lidar_loc_report__y;
lidar_loc.z = log.estimation__lidar_loc_report__x*0;
lidar_loc.heading = unwrap(interp1(log.estimation__lidar_localization__stamp__tot,log.estimation__lidar_localization__yaw,lidar_loc.time));
lidar_loc.s(1) = 0;
lidar_loc.sx(1)=0;
lidar_loc.sy(1)=0;
for i=2:height(lidar_loc.time)
    dt = lidar_loc.time(i) - lidar_loc.time(i-1);
    d_s=distanza_pp([lidar_loc.x(i),lidar_loc.y(i)],[lidar_loc.x(i-1),lidar_loc.y(i-1)]);
    lidar_loc.s(i,1) = lidar_loc.s(i-1) + d_s;
    a=lidar_loc.heading(i)-lidar_loc.heading(i-1);
    lidar_loc.sx(i,1) = lidar_loc.sx(i-1) + abs(d_s*cos(a));
    lidar_loc.sy(i,1) = lidar_loc.sy(i-1) + abs(d_s*sin(a));
end
lidar_loc.status = log.estimation__lidar_loc_report__unit_status__type;
lidar_loc.error_lat =  log.estimation__lidar_loc_report__dx(:,1);
lidar_loc.error_lon =  log.estimation__lidar_loc_report__dy(:,1);
lidar_loc.is_new = log.estimation__lidar_loc_report__new_meas;

% Kisler 
kis.time = loc.time;
kis.vx = log.estimation__vx_vehicle_speed_report__v(:,2);
kis.vy = log.estimation__vy_vehicle_speed_report__v(:,2);
kis.s(1) = 0;
kis.sx(1) = 0;
kis.sy(1) = 0;
for i=2:height(kis.time)
    dt = kis.time(i) - kis.time(i-1);
    d_s = (kis.vx(i)+kis.vy(i))*dt;
    kis.s(i,1) = kis.s(i-1) + d_s;
    kis.sx(i,1) = kis.sx(i-1) + kis.vx(i)*dt;
    kis.sy(i,1) = kis.sy(i-1) + kis.vy(i)*dt;
end

%Wheel
wheel.time = loc.time;
wheel.vx = log.estimation__vx_vehicle_speed_report__v(:,1);
wheel.vy = log.estimation__vy_vehicle_speed_report__v(:,1);
wheel.s(1) = 0;
for i=2:height(wheel.time)
    dt = wheel.time(i) - wheel.time(i-1);
    d_s = (wheel.vx(i)+wheel.vy(i))*dt;
    wheel.s(i,1) = wheel.s(i-1) + d_s;
end

%imu
imu.time = loc.time;
imu.yaw_rate = loc.yaw_rate;
imu.yaw(1) = 0;
for i=2:height(imu.time)
    dt = imu.time(i) - imu.time(i-1);
    d_yaw= imu.yaw_rate(i)*dt;
    imu.yaw(i,1) = imu.yaw(i-1) + d_yaw;
end


%% STATUTS
figure(Name='Status'),hold on, grid on
plot(loc.time,loc.status)
% plot(ins.time,ins.status)
plot(gps.time,gps.status)
plot(gps_hd.time,gps_hd.status)
%%
% TEMPI
figure(Name='Dt'),hold on, grid on
plot(loc.time(2:end),diff(loc.time),'DisplayName','LOC')
plot(wheel.time(2:end),diff(wheel.time),'DisplayName','WHEEL')
plot(kis.time(2:end),diff(kis.time),'DisplayName','KISLER')

%% ACC

figure('Name', 'ACC')
f1=subplot(2,1,1);hold on,grid on
% plot(kis.time,kis.ax,'-','DisplayName',"Kis Odom","LineWidth",1.5)
plot(loc.time,loc.ax,'-','DisplayName',"EKF","LineWidth",1.5)
% plot(imu.time,imu.ax,'-','DisplayName',"wheel Odom","LineWidth",1.5)
xlabel('Time [s]')
ylabel('Ax [m/s^2]')
legend
title("Ax")
f2=subplot(2,1,2);hold on,grid on
% plot(kis.time,kis.ay,'-','DisplayName',"Kis Odom","LineWidth",1.5)
plot(loc.time,loc.ay,'-','DisplayName',"EKF","LineWidth",1.5)
% plot(imu.time,imu.ay,'-','DisplayName',"wheel Odom","LineWidth",1.5)
xlabel('Time [s]')
ylabel('Ay [m/s^2]')
title("Ay")
legend
linkaxes([f1 f2],'x')

%% Position

figure(Name='Position'), hold on, grid on, axis equal
plot(loc.x,loc.y,DisplayName='EKF')
plot(odom_ekf.x,odom_ekf.y,DisplayName='EKF odom')

%% SPEED

figure("Name","Speed Vx"),grid on, hold on
plot(kis.time,kis.vx,'-','DisplayName',"Kis Odom","LineWidth",1.5)
plot(wheel.time,wheel.vx,'-','DisplayName',"wheel Odom","LineWidth",1.5)
plot(loc.time,loc.vx,'-','DisplayName',"EKF","LineWidth",1.5)
plot(log.kistler_msg__correvit_stamp__tot,log.kistler_msg__vel_x/3.6,'-','DisplayName',"kis origin","LineWidth",1.5)
plot(log.kistler_msg__correvit_stamp__tot,log.kistler_msg__vel_x_corr/3.6,'-','DisplayName',"kist corr","LineWidth",1.5)
% plot(v_from_acc.time,v_from_acc.vx,'-','DisplayName',"From ACC","LineWidth",1.5)
xlabel("Time [s]")
ylabel("Vx [m/s]")
title("Vx")
legend

figure("Name","Speed Vy"),grid on, hold on
plot(loc.time,loc.vy,'-','DisplayName',"EKF","LineWidth",1.5)
plot(kis.time,kis.vy,'-','DisplayName',"Kis Odom","LineWidth",1.5)
plot(log.kistler_msg__correvit_stamp__tot,log.kistler_msg__vel_y,'-','DisplayName',"kis origin","LineWidth",1.5)
plot(log.kistler_msg__correvit_stamp__tot,log.kistler_msg__vel_y_corr,'-','DisplayName',"kist corr","LineWidth",1.5)
% plot(v_from_acc.time,v_from_acc.vy,'-','DisplayName',"From ACC","LineWidth",1.5)
plot(wheel.time,wheel.vy,'-','DisplayName',"wheel Odom","LineWidth",1.5)
xlabel("Time [s]")
ylabel("Vy [m/s]")
title("Vy")
legend

figure("Name","Yaw_rate"),grid on, hold on
plot(loc.time,loc.yaw_rate*180/pi,'-','DisplayName',"EKF","LineWidth",1.5)
% plot(kis.time,kis.yaw_rate,'-','DisplayName',"Kis ","LineWidth",1.5)
% plot(imu.time,imu.yaw_rate*180/pi,'-','DisplayName',"IMU","LineWidth",1.5)
xlabel("Time [s]")
ylabel("omega [deg/s]")
title("Yaw Rate")
legend

%% HEADING

figure("Name","EKF Psi Check Model"),grid on, hold on
plot(loc.time,wrapToPi(loc.heading-loc.heading(1))*180/pi,'-','DisplayName',"EKF","LineWidth",1.5)
plot(imu.time,wrapToPi(imu.yaw)*180/pi,'-','DisplayName',"IMU","LineWidth",1.5)
plot(odom_ekf.time,wrapToPi(odom_ekf.heading-odom_ekf.heading(1))*180/pi,'-','DisplayName',"odom_ekf","LineWidth",1.5)
plot(lidar_loc.time,wrapToPi(lidar_loc.heading-lidar_loc.heading(1))*180/pi,'-','DisplayName',"LidarLoc","LineWidth",1.5)
xlabel("Time [s]")
ylabel("Psi [deg]")
title("PSI: Ekf vs Ekf omega Integration vs IMU Integration")
legend


%% Check Model



figure("Name","EKF Psi Check Model"),grid on, hold on
plot(loc.time,(loc.heading-loc.heading(1))*180/pi,'-','DisplayName',"EKF","LineWidth",1.5)
plot(imu.time,(imu.yaw)*180/pi,'-','DisplayName',"IMU","LineWidth",1.5)
plot(odom_ekf.time,(odom_ekf.heading-odom_ekf.heading(1))*180/pi,'-','DisplayName',"odom_ekf","LineWidth",1.5)
plot(lidar_loc.time,(lidar_loc.heading-lidar_loc.heading(1))*180/pi,'-','DisplayName',"LidarLoc","LineWidth",1.5)
xlabel("Time [s]")
ylabel("Psi [deg]")
title("PSI: Ekf vs Ekf omega Integration vs IMU Integration")
legend


gps_hd_interp = interp1(gps_hd.time,gps_hd.heading,loc.time);
figure("Name","Error Psi Rispetto a EKF"),grid on, hold on
plot(loc.time,angdiff(loc.heading-loc.heading(1),loc.heading-loc.heading(1))*180/pi,'-','DisplayName',"EKF","LineWidth",1.5)
plot(imu.time,angdiff(loc.heading-loc.heading(1),imu.yaw)*180/pi,'-','DisplayName',"IMU","LineWidth",1.5)
plot(loc.time,angdiff(loc.heading-loc.heading(1),gps_hd_interp-gps_hd_interp(1))*180/pi,'-','DisplayName',"GPS","LineWidth",1.5)
plot(loc.time,angdiff(loc.heading-loc.heading(1),odom_ekf.heading-odom_ekf.heading(1))*180/pi,'-','DisplayName',"Odom ekf","LineWidth",1.5)
plot(loc.time,angdiff(loc.heading-loc.heading(1),lidar_loc.heading-lidar_loc.heading(1))*180/pi,'-','DisplayName',"lidarLoc","LineWidth",1.5)
xlabel("Time [s]")
ylabel("Psi [deg]")
title("PSI: Ekf vs Ekf omega Integration vs IMU Integration")
legend

figure("Name","EKF Curvilinea Check Model"),grid on, hold on
plot(loc.time,loc.s,'-','DisplayName',"EKF","LineWidth",1.5)
plot(kis.time,kis.s,'-','DisplayName',"Kis Odom","LineWidth",1.5)
plot(wheel.time,wheel.s,'-','DisplayName',"wheel Odom","LineWidth",1.5)
plot(odom_ekf.time,odom_ekf.s,'-','DisplayName',"wheel Odom","LineWidth",1.5)
plot(lidar_loc.time,lidar_loc.s,'-','DisplayName',"LidarLoc","LineWidth",1.5)
plot(gps.time,gps.s,'-','DisplayName',"Gnss","LineWidth",1.5)
xlabel("Time [s]")
ylabel("s [m]")
title("Ascissa curvilinea: Ekf vs Ekf V Integration")
legend

gps_s_interp = interp1(gps.time,gps.s,loc.time);
figure("Name","Errore Curvilinea rispetto EKF"),grid on, hold on
plot(loc.time,loc.s-loc.s,'-','DisplayName',"EKF","LineWidth",1.5)
plot(kis.time,loc.s-kis.s,'-','DisplayName',"Kis Odom","LineWidth",1.5)
plot(wheel.time,loc.s-wheel.s,'-','DisplayName',"wheel Odom","LineWidth",1.5)
plot(odom_ekf.time,loc.s-odom_ekf.s,'-','DisplayName',"EKF Odom","LineWidth",1.5)
plot(lidar_loc.time,loc.s-lidar_loc.s,'-','DisplayName',"LidarLoc","LineWidth",1.5)
plot(loc.time,loc.s-gps_s_interp,'-','DisplayName',"GPS","LineWidth",1.5)
xlabel("Time [s]")
ylabel("s [m]")
title("Ascissa curvilinea: Ekf vs Ekf V Integration")
legend


figure("Name","EKF Curvilinea Check Model x"),grid on, hold on
plot(loc.time,loc.sx,'-','DisplayName',"EKF","LineWidth",1.5)
plot(kis.time,kis.sx,'-','DisplayName',"Kis Odom","LineWidth",1.5)

figure("Name","EKF Curvilinea Check Model"),grid on, hold on
plot(loc.time,loc.sy,'-','DisplayName',"EKF","LineWidth",1.5)
plot(kis.time,kis.sy,'-','DisplayName',"Kis Odom","LineWidth",1.5)



%% Error

figure('Name', 'Eror')
f1=subplot(2,1,1);hold on,grid on
plot(lidar_loc.time,lidar_loc.error_lon,'-','DisplayName',"LidarLoc","LineWidth",1.5)
% plot(gps.time,gps.error_lon,'-','DisplayName',"Gnss","LineWidth",1.5)
scatter(lidar_loc.time,lidar_loc.error_lon,5,lidar_loc.status,'filled')
% scatter(gps.time,gps.error_lon,5,gps.status,'filled')
xlabel('Time [s]')
ylabel('Err [m]')
legend
title("Longitudianl Error")
f2=subplot(2,1,2);hold on,grid on
plot(lidar_loc.time,lidar_loc.error_lat,'-','DisplayName',"LidarLoc","LineWidth",1.5)
% plot(gps.time,gps.error_lat,'-','DisplayName',"Gnss","LineWidth",1.5)
scatter(lidar_loc.time,lidar_loc.error_lat,5,lidar_loc.status,'filled')
% scatter(gps.time,gps.error_lat,5,gps.status,'filled')
xlabel('Time [s]')
ylabel('Err [m]')
title("Lateral Error")
legend
linkaxes([f1 f2],'x')

figure('Name', 'Eror gicp')
f1=subplot(2,1,1);hold on,grid on
plot(log.loc_node__debug__stamp__tot,log.loc_node__debug__gicp_mean_error,'-','DisplayName',"LidarLoc","LineWidth",1.5)
xlabel('Time [s]')
ylabel('Err [m]')
legend
title("Longitudianl Error")
ylim([0 1])
f2=subplot(2,1,2);hold on,grid on
plot(log.loc_node__debug__stamp__tot,log.loc_node__debug__gicp_perc_corr,'-','DisplayName',"LidarLoc","LineWidth",1.5)
xlabel('Time [s]')
ylabel('Err [m]')
title("Lateral Error")
legend
linkaxes([f1 f2],'x')

figure('Name', 'TIME')
plot(log.loc_node__debug__stamp__tot,log.loc_node__debug__lidar_call_exec_time,'-','DisplayName',"LidarLoc","LineWidth",1.5)
xlabel('Time [s]')
ylabel('Err [m]')
legend
title("TIME")
ylim([0 1])



return
%% TODO
% Migliorare grafici
% finire di fare i vari plot
% distanza punto punto tra le posizioni


%%

return

ins_x_interp = interp1(ins.time,ins.x,loc.time);
ins_y_interp = interp1(ins.time,ins.y,loc.time);


for i=1:length(gps0.time)
    distance_gps0_ins(i,1) = distanza_pp([ins_x_interp(i),ins_y_interp(i)],[gps0.x(i),gps0.y(i)]);
    distance_gps0_gps1(i,1) =  distanza_pp([gps1.x(i),gps1.y(i)],[gps0.x(i),gps0.y(i)]);
end



delay = gps_time_common-gps0.time_gps;
v =  interp1(log.estimation__stamp__tot,log.estimation__vx,gps0.time);
yaw = interp1(log.estimation__stamp__tot,log.estimation__heading,gps0.time);
for i=1:length(gps0.time)
    gps0_compensated.x(i,1) = gps0.x(i,1)+v(i)*delay(i)*cos(yaw(i));
    gps0_compensated.y(i,1) = gps0.y(i,1)+v(i)*delay(i)*sin(yaw(i));
    distance_gps0_ins_comp(i,1) = distanza_pp([ins_x_interp(i),ins_y_interp(i)],[gps0_compensated.x(i),gps0_compensated.y(i)]);

end

figure,hold on, grid on
plot(gps0.time,v,'DisplayName','gps0_ins')


figure,hold on, grid on
plot(gps0.time,distance_gps0_ins,'DisplayName','gps0_ins')
plot(gps0.time,distance_gps0_ins_comp,'DisplayName','gps0_ins')

figure,hold on, grid on, axis equal
scatter(gps0.x,gps0.y,10,gps0.time)
scatter(gps0_compensated.x,gps0_compensated.y,10,gps0.time)
% scatter(ins_x_interp,ins_y_interp,10,gps0.time)

figure, plot(gps0.time,gps0.time_gps-gps1.time_gps)

%%
figure, hold on, grid on
plot(gps0.time,gps0.acc(:,1))
plot(gps0.time,gps0.acc(:,2))
plot(gps0.time,gps0.acc(:,3))

acc_tot = sqrt(gps0.acc(:,1).^2 + gps0.acc(:,2).^2);
acc_tot(acc_tot>0.5)=0.5;
figure,hold on, grid on, axis equal
scatter(gps0.x,gps0.y,10,acc_tot)


figure,
scatter(gps0.time,sqrt(gps0.acc(:,1).^2 + gps0.acc(:,2).^2),10,gps0.status)

ins_yaw=90-unwrap(log.vectornav__raw__common__yawpitchroll__x);
figure, hold on
plot(gps_common.time,ins_yaw,'DisplayName','INS')
plot(log.estimation__stamp__tot,(log.estimation__heading)*180/pi,'DisplayName','LOC')


figure, hold on
% plot(gps_common.time,ins_yaw-360,'DisplayName','INS')
plot(log.estimation__stamp__tot,(log.estimation__x_cog),'DisplayName','LOC')
